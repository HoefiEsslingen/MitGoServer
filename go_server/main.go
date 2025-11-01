package main

import (
	"bytes"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"sync"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// Config file location
const configFile = "config.json"

// Simple admin token (in production use env var or a proper auth mechanism)
var adminToken = getEnv("ADMIN_TOKEN", "my-secret-admin-token")

type Gebuehren struct {
	Name   string  `json:"name"`
	Amount float64 `json:"betrag"`
}

type EventKonfiguration struct {
	Year         int         `json:"jahr"`
	Date         string      `json:"datum"`     // ISO date: YYYY-MM-DD
	StartTime    string      `json:"startZeit"` // ISO datetime: YYYY-MM-DDTHH:MM:SS
	DieGebuehren []Gebuehren `json:"gebuehren"`
	UpdatedAt    string      `json:"updatedAt,omitempty"`
}

var (
	cfg   EventKonfiguration
	mutex sync.RWMutex
	// simple in-memory token store: token -> expiry
	tokenStore   = map[string]time.Time{}
	tokenStoreMu sync.Mutex
	// Parse / Back4App settings (optional)
	// Try PARSE_* env vars first, fallback to older BACK4APP_* names if present
	parseAppID     = getEnv("PARSE_APP_ID", getEnv("BACK4APP_APP_ID", ""))
	parseRestKey   = getEnv("PARSE_REST_KEY", getEnv("BACK4APP_REST_KEY", ""))
	parseServerURL = getEnv("PARSE_SERVER_URL", getEnv("BACK4APP_SERVER_URL", "https://parseapi.back4app.com"))
)

// Methoden zum Laden oder Initialisieren der Konfiguration
func getEnv(key, fallback string) string {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	return v
}

func loadOrInitConfig() error {
	if _, err := os.Stat(configFile); os.IsNotExist(err) {
		// create default
		cfg = EventKonfiguration{
			Year:      2025,
			Date:      "2025-11-01",
			StartTime: "2025-11-01T08:00:00Z",
			DieGebuehren: []Gebuehren{
				{Name: "Voranmeldung", Amount: 12.0},
				{Name: "Nachmeldung", Amount: 18.0},
			},
			UpdatedAt: time.Now().UTC().Format(time.RFC3339),
		}
		return saveConfigToFile(&cfg)
	}
	// load file
	b, err := os.ReadFile(configFile)
	if err != nil {
		return err
	}
	return json.Unmarshal(b, &cfg)
}

func saveConfigToFile(c *EventKonfiguration) error {
	b, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(configFile, b, 0644)
}

// configHandler handles GET (read) and PUT (update) on /api/config
func configHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		//		handleGetConfig(w, r)
		handleGetConfig(w)
	case http.MethodPut:
		handlePutConfig(w, r)
	default:
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
	}
}

// func handleGetConfig(w http.ResponseWriter, r *http.Request) {
func handleGetConfig(w http.ResponseWriter) {
	mutex.RLock()
	defer mutex.RUnlock()
	writeJSON(w, cfg)
}

func handlePutConfig(w http.ResponseWriter, r *http.Request) {
	// simple token check header: X-Admin-Token
	token := r.Header.Get("X-Admin-Token")
	if token != adminToken {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	var updated EventKonfiguration
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(&updated); err != nil {
		http.Error(w, "invalid json: "+err.Error(), http.StatusBadRequest)
		return
	}
	// validation
	if err := validateConfig(&updated); err != nil {
		http.Error(w, "validation failed: "+err.Error(), http.StatusBadRequest)
		return
	}

	updated.UpdatedAt = time.Now().UTC().Format(time.RFC3339)

	// persist
	mutex.Lock()
	cfg = updated
	if err := saveConfigToFile(&cfg); err != nil {
		mutex.Unlock()
		http.Error(w, "failed to persist config: "+err.Error(), http.StatusInternalServerError)
		return
	}
	mutex.Unlock()

	writeJSON(w, cfg)
}

func validateConfig(c *EventKonfiguration) error {
	if c.Year < 2000 || c.Year > 2100 {
		return errors.New("year out of range")
	}
	if c.Date == "" || c.StartTime == "" {
		return errors.New("date and startTime must be set")
	}
	// optional: parse times to ensure valid format
	if _, err := time.Parse("2006-01-02", c.Date); err != nil {
		return fmt.Errorf("date must be YYYY-MM-DD: %w", err)
	}
	if _, err := time.Parse(time.RFC3339, c.StartTime); err != nil {
		// allow also local "YYYY-MM-DDTHH:MM" formats? For simplicity require RFC3339
		return fmt.Errorf("startTime must be RFC3339 datetime: %w", err)
	}
	for _, f := range c.DieGebuehren {
		if f.Amount < 0 {
			return errors.New("fee amounts must not be negative")
		}
		if f.Name == "" {
			return errors.New("fee name required")
		}
	}
	return nil
}

func writeJSON(w http.ResponseWriter, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	_ = enc.Encode(v)
}

// cutoffTimeForEvent returns the cutoff (day before at 18:00) in server local time
func cutoffTimeForEvent(datum string) (time.Time, error) {
	// datum expected YYYY-MM-DD
	t, err := time.Parse("2006-01-02", datum)
	if err != nil {
		return time.Time{}, err
	}
	loc := time.Now().Location()
	// day before
	cutoff := time.Date(t.Year(), t.Month(), t.Day()-1, 18, 0, 0, 0, loc)
	return cutoff, nil
}

// generateRandomToken produces a URL-safe base64 token
func generateRandomToken(nbytes int) (string, error) {
	b := make([]byte, nbytes)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}

// validateAccessToken checks token validity and prunes expired tokens
func validateAccessToken(tkn string) bool {
	// If Parse is configured, validate against Parse class
	if parseEnabled() {
		return validateAccessTokenParse(tkn)
	}

	tokenStoreMu.Lock()
	defer tokenStoreMu.Unlock()
	exp, ok := tokenStore[tkn]
	if !ok {
		return false
	}
	if time.Now().UTC().After(exp) {
		delete(tokenStore, tkn)
		return false
	}
	return true
}

// parseEnabled returns true when Parse/Back4App credentials are present
func parseEnabled() bool {
	return parseAppID != "" && parseRestKey != "" && parseServerURL != ""
}

// sha256Hex returns hex-encoded SHA256 of input
func sha256Hex(s string) string {
	h := sha256.Sum256([]byte(s))
	return hex.EncodeToString(h[:])
}

// createParseAccessToken stores a hashed token in Back4App Parse class `AccessToken`.
func createParseAccessToken(token string, expires time.Time) error {
	tokenHash := sha256Hex(token)
	payload := map[string]interface{}{
		"tokenHash": tokenHash,
		"expiresAt": map[string]string{"__type": "Date", "iso": expires.UTC().Format(time.RFC3339)},
		"purpose":   "registration",
	}
	b, _ := json.Marshal(payload)
	endpoint := parseServerURL + "/classes/AccessToken"
	req, err := http.NewRequest("POST", endpoint, bytes.NewReader(b))
	if err != nil {
		return err
	}
	req.Header.Set("X-Parse-Application-Id", parseAppID)
	req.Header.Set("X-Parse-REST-API-Key", parseRestKey)
	req.Header.Set("Content-Type", "application/json")
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusCreated && resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("parse create token failed: %d %s", resp.StatusCode, string(body))
	}
	return nil
}

// validateAccessTokenParse checks token existence and expiry in Back4App
func validateAccessTokenParse(token string) bool {
	tokenHash := sha256Hex(token)
	// Query for matching tokenHash
	where := map[string]string{"tokenHash": tokenHash}
	whereB, _ := json.Marshal(where)
	endpoint := parseServerURL + "/classes/AccessToken?where=" + url.QueryEscape(string(whereB))
	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		log.Printf("validateAccessTokenParse request err: %v", err)
		return false
	}
	req.Header.Set("X-Parse-Application-Id", parseAppID)
	req.Header.Set("X-Parse-REST-API-Key", parseRestKey)
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("validateAccessTokenParse do err: %v", err)
		return false
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		log.Printf("parse validate token bad status: %d %s", resp.StatusCode, string(body))
		return false
	}
	var got struct {
		Results []struct {
			TokenHash string `json:"tokenHash"`
			ExpiresAt struct {
				Type string `json:"__type"`
				Iso  string `json:"iso"`
			} `json:"expiresAt"`
		} `json:"results"`
	}
	dec := json.NewDecoder(resp.Body)
	if err := dec.Decode(&got); err != nil {
		log.Printf("parse validate decode err: %v", err)
		return false
	}
	now := time.Now().UTC()
	for _, r := range got.Results {
		if r.ExpiresAt.Iso == "" {
			continue
		}
		if t, err := time.Parse(time.RFC3339, r.ExpiresAt.Iso); err == nil {
			if now.Before(t) || now.Equal(t) {
				return true
			}
		}
	}
	return false
}

// getRegistrationPasswordHashFromParse reads AppSetting with key registrationPasswordHash
func getRegistrationPasswordHashFromParse() (string, error) {
	where := map[string]string{"key": "registrationPasswordHash"}
	whereB, _ := json.Marshal(where)
	endpoint := parseServerURL + "/classes/AppSetting?where=" + url.QueryEscape(string(whereB))
	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("X-Parse-Application-Id", parseAppID)
	req.Header.Set("X-Parse-REST-API-Key", parseRestKey)
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("parse get setting failed: %d %s", resp.StatusCode, string(body))
	}
	var got struct {
		Results []struct {
			Key   string `json:"key"`
			Value string `json:"value"`
		} `json:"results"`
	}
	dec := json.NewDecoder(resp.Body)
	if err := dec.Decode(&got); err != nil {
		return "", err
	}
	if len(got.Results) == 0 {
		return "", errors.New("no registrationPasswordHash found in AppSetting")
	}
	return got.Results[0].Value, nil
}

// accessStatusHandler returns whether registration is open
func accessStatusHandler(w http.ResponseWriter, r *http.Request) {
	mutex.RLock()
	cfgCopy := cfg
	mutex.RUnlock()

	cutoff, err := cutoffTimeForEvent(cfgCopy.Date)
	now := time.Now().In(time.Now().Location())
	isOpen := false
	if err == nil {
		isOpen = now.Before(cutoff) || now.Equal(cutoff)
	}
	// If client provided an access token, validate it and report status
	token := r.Header.Get("X-Access-Token")
	hasValidToken := false
	if token != "" {
		hasValidToken = validateAccessToken(token)
	}

	resp := map[string]interface{}{
		"isRegistrationOpen": isOpen,
		"cutoffAt":           cutoff.Format(time.RFC3339),
		"now":                now.Format(time.RFC3339),
		"eventDate":          cfgCopy.Date,
		"hasValidToken":      hasValidToken,
	}
	writeJSON(w, resp)
}

// authHandler accepts password JSON and returns an access token
func authHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var req struct {
		Password string `json:"password"`
	}
	dec := json.NewDecoder(r.Body)
	if err := dec.Decode(&req); err != nil {
		http.Error(w, "invalid json: "+err.Error(), http.StatusBadRequest)
		return
	}
	// Authentication: if Parse is configured, read hashed password from Parse and compare via bcrypt.
	if parseEnabled() {
		hash, err := getRegistrationPasswordHashFromParse()
		if err != nil {
			log.Printf("failed to fetch registration password hash from Parse: %v", err)
			http.Error(w, "internal error", http.StatusInternalServerError)
			return
		}
		// hash is expected to be bcrypt hash
		if bcrypt.CompareHashAndPassword([]byte(hash), []byte(req.Password)) != nil {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}

		token, err := generateRandomToken(32)
		if err != nil {
			http.Error(w, "internal error", http.StatusInternalServerError)
			return
		}
		expires := time.Now().UTC().Add(12 * time.Hour)
		if err := createParseAccessToken(token, expires); err != nil {
			log.Printf("failed to store access token in Parse: %v", err)
			http.Error(w, "internal error", http.StatusInternalServerError)
			return
		}
		writeJSON(w, map[string]interface{}{
			"accessToken": token,
			"expiresAt":   expires.Format(time.RFC3339),
		})
		return
	}

	// Fallback: simple ENV password + in-memory token store (development)
	pw := getEnv("REGISTRATION_PASSWORD", "secret-password")
	if req.Password != pw {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	token, err := generateRandomToken(32)
	if err != nil {
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}
	expires := time.Now().UTC().Add(12 * time.Hour)
	tokenStoreMu.Lock()
	tokenStore[token] = expires
	tokenStoreMu.Unlock()

	writeJSON(w, map[string]interface{}{
		"accessToken": token,
		"expiresAt":   expires.Format(time.RFC3339),
	})
}

// Very simple CORS middleware (open for local dev). In production tighten origins.
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// allow your Flutter web host here (or use "*")
		w.Header().Set("Access-Control-Allow-Origin", getEnv("CORS_ORIGIN", "http://localhost:5173"))
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, X-Admin-Token, X-Access-Token")
		w.Header().Set("Access-Control-Allow-Methods", "GET, PUT, OPTIONS")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

/*
** Hauptprogramm
 */
func main() {
	// Load or create default config
	if err := loadOrInitConfig(); err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	mux := http.NewServeMux()
	// API endpoints
	mux.HandleFunc("/api/access-status", accessStatusHandler)
	mux.HandleFunc("/api/auth", authHandler)
	mux.HandleFunc("/api/config", configHandler)
	// static file server for admin UI or frontend
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Allow preflight through CORS middleware above
		log.Printf("Request: %s", r.URL.Path)

		// If requesting API prefix, return 404 (should be handled above)
		if r.URL.Path == "/api/config" || r.URL.Path == "/api/config/" {
			http.NotFound(w, r)
			return
		}

		// Serve static files from ./static, fallback to index.html for SPA routing
		// Normalize path: strip leading '/'
		requestPath := r.URL.Path
		if requestPath == "/" {
			http.ServeFile(w, r, filepath.Join("static", "index.html"))
			return
		}

		// Build filesystem path
		filePath := filepath.Join("static", requestPath)
		if _, err := os.Stat(filePath); os.IsNotExist(err) {
			// Fallback to index.html for client-side routing (Flutter)
			http.ServeFile(w, r, filepath.Join("static", "index.html"))
			return
		}

		http.ServeFile(w, r, filePath)
	})

	addr := ":8080"
	log.Printf("Starting server on %s", addr)
	if err := http.ListenAndServe(addr, corsMiddleware(mux)); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}

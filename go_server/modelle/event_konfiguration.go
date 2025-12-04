package modelle

type EventKonfiguration struct {
	Year         int         `json:"jahr"`
	Date         string      `json:"datum"`     // ISO date: YYYY-MM-DD
	StartTime    string      `json:"startZeit"` // ISO datetime: YYYY-MM-DDTHH:MM:SS
	DieGebuehren []Gebuehren `json:"gebuehren"`
	UpdatedAt    string      `json:"updatedAt,omitempty"`
}

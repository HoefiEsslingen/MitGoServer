package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"strings"

	"golang.org/x/crypto/bcrypt"
)

func main() {
	pwFlag := flag.String("p", "", "password to hash (if empty, read from stdin)")
	flag.Parse()

	var pw string
	if *pwFlag != "" {
		pw = *pwFlag
	} else {
		// read from stdin
		fmt.Fprint(os.Stderr, "Password: ")
		r := bufio.NewReader(os.Stdin)
		s, err := r.ReadString('\n')
		if err != nil {
			fmt.Fprintln(os.Stderr, "failed to read password:", err)
			os.Exit(2)
		}
		pw = strings.TrimSpace(s)
	}

	if pw == "" {
		fmt.Fprintln(os.Stderr, "empty password")
		os.Exit(2)
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(pw), bcrypt.DefaultCost)
	if err != nil {
		fmt.Fprintln(os.Stderr, "failed to hash password:", err)
		os.Exit(1)
	}

	// Print the bcrypt hash to stdout (copy this into Back4App AppSetting value)
	fmt.Println(string(hash))
}

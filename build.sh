#!/bin/zsh

# Fehlgeschlagene Befehle stoppen das Script
set -e

# Flutter PATH setzen
export PATH="$HOME/flutter/bin:$PATH"

echo "🚀 Start des Build-Prozesses..."

# In das Projektverzeichnis wechseln
cd "$(dirname "$0")"

# Flutter Web App bauen
echo "🔨 Baue Flutter Web App..."
cd sporttag
flutter build web --release
cd ..

# Build-Verzeichnis im Go-Server erstellen
echo "📁 Erstelle Build-Verzeichnis im Go-Server..."
mkdir -p go_server/static

# Flutter Build-Dateien in den Go-Server kopieren
echo "📦 Kopiere Flutter Build in den Go-Server..."
cp -r sporttag/build/web/* go_server/static/

# Go-Server bauen
echo "🔨 Baue Go-Server..."
cd go_server
go build -o server .
cd ..

echo "✅ Build abgeschlossen!"
echo "
Deployment-Anweisungen:
1. Kopiere den Inhalt des 'go_server' Verzeichnisses auf deinen Server
2. Führe './server' auf deinem Server aus
3. Die Anwendung ist nun verfügbar unter http://[server-ip]:8080
"
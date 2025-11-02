#!/bin/zsh

# run.sh — Build & Run helper for the MitGoServer project
# Usage:
#   ./run.sh build            # build flutter web and go server, copy web into go_server/static
#   ./run.sh start [PORT]     # start the go server (build if necessary). optional PORT (default 8080)
#   ./run.sh stop             # stop the running server (via pidfile)
#   ./run.sh restart [PORT]   # stop + start
#   ./run.sh logs             # tail the server log
#   ./run.sh help             # this message

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
export PATH="$HOME/flutter/bin:$PATH"

SERVER_DIR="$ROOT/go_server"
SERVER_BIN="$SERVER_DIR/server"
PIDFILE="$SERVER_DIR/server.pid"
LOGFILE="$SERVER_DIR/server.log"

usage() {
  cat <<EOF
Usage: $0 <command> [args]

Commands:
  build            Build Flutter web and Go server and copy web assets to go_server/static
  start [PORT]     Start the Go server (default PORT=8080). Uses existing binary or builds if missing
  stop             Stop the running server (uses pidfile)
  restart [PORT]   Stop and start
  logs             Tail the server log
  help             Show this help

Examples:
  $0 build
  $0 start 3000
  $0 logs
EOF
}

# Build flutter web and Go server, copy files
cmd_build() {
  echo "🔨 Building Flutter web..."
  cd "$ROOT/sporttag"

  # Ensure flutter is available
  if ! command -v flutter >/dev/null 2>&1; then
    echo "flutter not found on PATH. Make sure Flutter SDK is installed and available. Current PATH: $PATH"
    exit 2
  fi

  flutter clean || true
  flutter pub get
  flutter build web --release

  echo "📦 Copying web build to go_server/static..."
  mkdir -p "$SERVER_DIR/static"
  # remove old static files but keep directory
  rm -rf "$SERVER_DIR/static"/* || true
  cp -r "$ROOT/sporttag/build/web/"* "$SERVER_DIR/static/"

  echo "🔨 Building Go server..."
  cd "$SERVER_DIR"
  go build -o server .

  echo "✅ Build finished."
}

cmd_start() {
  local port="${1:-8080}"

  if [ -f "$PIDFILE" ]; then
    pid=$(cat "$PIDFILE" 2>/dev/null || true)
    if [ -n "$pid" ] && kill -0 "$pid" >/dev/null 2>&1; then
      echo "Server already running with pid $pid"
      exit 0
    else
      echo "Removing stale pidfile"
      rm -f "$PIDFILE"
    fi
  fi

  if [ ! -f "$SERVER_BIN" ]; then
    echo "Server binary not found, running build first..."
    cmd_build
  fi

  echo "📢 Starting server on port $PORT (logs -> $LOGFILE)"
  cd "$SERVER_DIR"
  PORT=$PORT nohup ./server > "$LOGFILE" 2>&1 &
  echo $! > "$PIDFILE"
  sleep 0.5
  echo "Started server pid $(cat "$PIDFILE")"
}

cmd_stop() {
  if [ -f "$PIDFILE" ]; then
    pid=$(cat "$PIDFILE")
    echo "Stopping server pid $pid"
    kill "$pid" || true
    rm -f "$PIDFILE"
    echo "Stopped."
  else
    echo "No pidfile found; trying to pkill server binary name"
    pkill -f "$SERVER_BIN" || true
    echo "Done (if server was running)."
  fi
}

cmd_logs() {
  mkdir -p "$(dirname "$LOGFILE")"
  tail -f "$LOGFILE"
}

case ${1:-help} in
  build)
    cmd_build
    ;;
  start)
    shift || true
    cmd_start "$1"
    ;;
  stop)
    cmd_stop
    ;;
  restart)
    shift || true
    cmd_stop
    cmd_start "$1"
    ;;
  logs)
    cmd_logs
    ;;
  help|*)
    usage
    ;;
esac

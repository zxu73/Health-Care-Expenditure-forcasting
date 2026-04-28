#!/usr/bin/env bash
set -e

# ── Helpers ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Locate repo root (script lives in the repo root) ─────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/medicaid_forecast"

[ -d "$APP_DIR" ] || error "Could not find medicaid_forecast/ next to this script. Are you in the right directory?"

# ── Check: Elixir / Mix ───────────────────────────────────────────────────────
if ! command -v elixir &>/dev/null; then
  error "Elixir is not installed.\n\n  Install it from https://elixir-lang.org/install.html\n  (or via asdf: asdf plugin add erlang && asdf plugin add elixir)"
fi

if ! command -v mix &>/dev/null; then
  error "Mix not found. It ships with Elixir — reinstalling Elixir should fix this."
fi

ELIXIR_VERSION=$(elixir --version | head -1)
info "Found $ELIXIR_VERSION"

# ── Check: forecast data ──────────────────────────────────────────────────────
DATA_FILE="$APP_DIR/priv/data/all_states_forecast.json"

if [ ! -f "$DATA_FILE" ]; then
  warn "Forecast data not found at priv/data/all_states_forecast.json"
  warn "Attempting to generate it now (requires Python 3 + pandas/statsmodels)…"

  if ! command -v python3 &>/dev/null && ! command -v python &>/dev/null; then
    error "Python 3 is required to generate the data file but was not found.\n  Install Python from https://www.python.org/downloads/ and re-run."
  fi

  PYTHON=$(command -v python3 || command -v python)
  info "Using $($PYTHON --version)"

  cd "$SCRIPT_DIR"
  "$PYTHON" -m pip install --quiet pandas openpyxl scikit-learn statsmodels numpy || \
    warn "pip install encountered warnings — continuing anyway."
  "$PYTHON" export_all_states.py || error "export_all_states.py failed. Fix the error above and re-run."
  info "Forecast data generated."
fi

# ── Install deps + build assets ───────────────────────────────────────────────
cd "$APP_DIR"

info "Installing Elixir dependencies and building assets (mix setup)…"
mix setup

# ── Start the server ──────────────────────────────────────────────────────────
info "Starting the Medicaid Forecast web app…"
info "Open http://localhost:4000 in your browser."
info "Press Ctrl+C twice to stop the server."
echo ""

mix phx.server

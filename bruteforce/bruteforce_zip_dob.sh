#!/usr/bin/env bash

set -euo pipefail

#
# Demo: brute-force ZIP password based on date of birth patterns
# - Extracts hash via zip2john
# - Tries numeric-only 8-digit mask (DDMMYYYY)
# - Optionally tries DD/MM/YYYY mask with '/'
#
# Usage:
#   ./bruteforce_zip_dob.sh <archive.zip> [--digits] [--with-slashes] [--both] [--max-time <sec>]
#
# Defaults:
#   Mode: --both (runs digits then slashes)
#
# Examples:
#   ./bruteforce_zip_dob.sh secret.zip           # digits then slashes
#   ./bruteforce_zip_dob.sh secret.zip --digits  # digits only
#   ./bruteforce_zip_dob.sh secret.zip --with-slashes  # DD/MM/YYYY only
#

MODE="both"           # digits | with-slashes | both
MAX_TIME=""           # optional john --max-run-time

print_usage() {
  echo "Usage: $0 <archive.zip> [--digits] [--with-slashes] [--both] [--max-time <sec>]" >&2
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[!] Command not found: $1" >&2
    echo "    Please install John the Ripper Jumbo (provides 'zip2john' and 'john')." >&2
    exit 1
  fi
}

already_cracked() {
  local hash_file="$1"
  # Let john auto-detect the format when showing
  john --show "$hash_file" | grep -qE ":[^:]*:"
}

show_result() {
  local hash_file="$1"
  echo
  echo "[✓] Résultat (john --show):"
  john --show "$hash_file" || true
}

run_john_mask() {
  local mask="$1"; shift
  local hash_file="$1"; shift
  local pot_file="$1"; shift
  local fmt="$1"; shift || true
  local args=(--pot="$pot_file" "$hash_file" --mask="$mask")
  if [[ -n "$fmt" ]]; then
    args=(--format="$fmt" "${args[@]}")
  fi
  if [[ -n "$MAX_TIME" ]]; then
    args=(--max-run-time="$MAX_TIME" "${args[@]}")
  fi
  echo "[*] john ${args[*]}"
  john "${args[@]}"
}

if [[ $# -lt 1 ]]; then
  print_usage
  exit 1
fi

ZIP_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --digits)
      MODE="digits"; shift ;;
    --with-slashes)
      MODE="with-slashes"; shift ;;
    --both)
      MODE="both"; shift ;;
    --max-time)
      MAX_TIME="${2:-}"; shift 2 ;;
    -h|--help)
      print_usage; exit 0 ;;
    *)
      if [[ -z "$ZIP_PATH" ]]; then
        ZIP_PATH="$1"; shift
      else
        echo "[!] Unexpected argument: $1" >&2
        print_usage; exit 1
      fi
    ;;
  esac
done

if [[ -z "$ZIP_PATH" ]]; then
  print_usage; exit 1
fi

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "[!] ZIP not found: $ZIP_PATH" >&2
  exit 1
fi

require_cmd john

# Try to locate a usable zip2john (package layouts vary by distro)
run_zip2john() {
  local zip_path="$1"

  # 1) On PATH
  if command -v zip2john >/dev/null 2>&1; then
    zip2john "$zip_path"
    return $?
  fi

  # 2) Common distro locations (installed but not symlinked into PATH)
  local candidates=(
    "./zip2john" "./zip2john.pl" "./zip2john.py"
    "$HOME/john/run/zip2john" "$HOME/john/run/zip2john.pl" "$HOME/john/run/zip2john.py"
    "/usr/share/john/zip2john"        "/usr/share/john/zip2john.pl"        "/usr/share/john/zip2john.py"
    "/usr/lib/john/zip2john"          "/usr/lib/john/zip2john.pl"          "/usr/lib/john/zip2john.py"
    "/usr/libexec/john/zip2john"      "/usr/libexec/john/zip2john.pl"      "/usr/libexec/john/zip2john.py"
    "/snap/bin/zip2john"
  )

  for cand in "${candidates[@]}"; do
    if [[ -x "$cand" ]]; then
      "$cand" "$zip_path"
      return $?
    elif [[ -f "$cand" ]]; then
      case "$cand" in
        *.pl)  perl    "$cand" "$zip_path"; return $? ;;
        *.py)  python3 "$cand" "$zip_path"; return $? ;;
      esac
    fi
  done

  # 3) Heuristic relative to john binary (some packages keep helpers under share/john)
  if command -v john >/dev/null 2>&1; then
    local john_bin
    john_bin=$(command -v john)
    local john_share
    john_share=$(dirname -- "$john_bin")/../share/john
    for cand in "$john_share/zip2john" "$john_share/zip2john.pl" "$john_share/zip2john.py"; do
      if [[ -x "$cand" ]]; then
        "$cand" "$zip_path"; return $?
      elif [[ -f "$cand" ]]; then
        case "$cand" in
          *.pl)  perl    "$cand" "$zip_path"; return $? ;;
          *.py)  python3 "$cand" "$zip_path"; return $? ;;
        esac
      fi
    done
  fi

  echo "[!] Command not found: zip2john" >&2
  echo "    Install John the Ripper Jumbo (includes zip2john) or ensure it's on PATH." >&2
  echo "    Hints:" >&2
  echo "    - Debian/Ubuntu/Kali: sudo apt install john" >&2
  echo "    - Arch: pacman -S john    |  Fedora: dnf install john" >&2
  echo "    - macOS: brew install john-jumbo" >&2
  echo "    - If already installed, add /usr/sbin to PATH or symlink zip2john into a bin directory." >&2
  return 127
}

# Work files next to the ZIP
BASE_NAME=$(basename -- "$ZIP_PATH")
NAME_NOEXT="${BASE_NAME%.*}"
DIR_NAME=$(cd "$(dirname -- "$ZIP_PATH")" && pwd)
HASH_FILE="$DIR_NAME/$NAME_NOEXT.john.hash"
POT_FILE="$DIR_NAME/$NAME_NOEXT.john.pot"

echo "[*] Extraction du hash avec zip2john…"
if ! run_zip2john "$ZIP_PATH" > "$HASH_FILE"; then
  echo "[!] Échec de l'extraction du hash (zip2john manquant?)." >&2
  exit 1
fi

echo "[*] Hash enregistré: $HASH_FILE"

# If already cracked in pot file, show immediately
if already_cracked "$HASH_FILE"; then
  show_result "$HASH_FILE"
  exit 0
fi

FORMAT=""
if grep -q '\$pkzip\$' "$HASH_FILE"; then
  FORMAT="PKZIP"
elif grep -q '\$zip2\$' "$HASH_FILE"; then
  FORMAT="ZIP"
fi
if [[ -n "$FORMAT" ]]; then
  echo "[*] Format détecté: $FORMAT"
else
  echo "[*] Format non détecté, on laisse john auto-détecter."
fi

CRACKED=0

if [[ "$MODE" == "digits" || "$MODE" == "both" ]]; then
  echo "[*] Tentative 1: masque 8 chiffres (DDMMYYYY)"
  run_john_mask '?d?d?d?d?d?d?d?d' "$HASH_FILE" "$POT_FILE" "$FORMAT" || true
  if already_cracked "$HASH_FILE"; then
    CRACKED=1
  fi
fi

if [[ $CRACKED -eq 0 && ( "$MODE" == "with-slashes" || "$MODE" == "both" ) ]]; then
  echo "[*] Tentative 2: masque DD/MM/YYYY (avec '/')"
  run_john_mask '?d?d/?d?d/?d?d?d?d' "$HASH_FILE" "$POT_FILE" "$FORMAT" || true
  if already_cracked "$HASH_FILE"; then
    CRACKED=1
  fi
fi

if [[ $CRACKED -eq 1 ]]; then
  show_result "$HASH_FILE"
  exit 0
else
  echo
  echo "[!] Mot de passe non trouvé avec ces masques."
  echo "    Astuces:"
  echo "    - Essayez --incremental=Digits pour couvrir d'autres longueurs." 
  echo "    - Ajoutez un masque supplémentaire (ex: YYYYMMDD: '?d?d?d?d?d?d?d?d')."
  echo "    - Vérifiez que l'archive est réellement protégée par mot de passe."
  exit 2
fi

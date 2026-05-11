#!/bin/bash

ACCESSION=$1

if [ -z "${ACCESSION}" ]; then
    echo "Usage: bash run_in_screen.sh <ACCESSION>"
    echo "  ACCESSION  PRJNA / PRJEB project or SRR run"
    exit 1
fi

# ---- check screen ----
if ! command -v screen &>/dev/null; then
    echo "[ERROR] 'screen' is not installed."
    echo "  Ubuntu: sudo apt install screen"
    echo "  macOS:  brew install screen"
    exit 1
fi

# ---- resolve script dir ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOWNLOADER="${SCRIPT_DIR}/download_ena.sh"

if [ ! -f "${DOWNLOADER}" ]; then
    echo "[ERROR] download_ena.sh not found at ${DOWNLOADER}"
    exit 1
fi

SESSION_NAME="${ACCESSION}"

# kill existing session with same name if present
screen -S "${SESSION_NAME}" -X quit 2>/dev/null

echo "[INFO] Launching screen session: ${SESSION_NAME}"
echo "[INFO] Script:  ${DOWNLOADER} ${ACCESSION}"
echo ""

# ---- launch screen ----
screen -dmS "${SESSION_NAME}" bash -c "
    echo '============================================================'
    echo ' Screen Session: ${SESSION_NAME}'
    echo ' Host:           \$(hostname)'
    echo ' Start:          \$(date '+%Y-%m-%d %H:%M:%S')'
    echo '============================================================'
    echo ''
    bash '${DOWNLOADER}' '${ACCESSION}'
    EXIT_CODE=\$?
    echo ''
    echo '============================================================'
    echo ' Exit code:      \${EXIT_CODE}'
    echo ' Finished:       \$(date '+%Y-%m-%d %H:%M:%S')'
    echo '============================================================'
    echo ''
    echo 'Press Enter to close this screen session.'
    echo 'Or detach with Ctrl+A D.'
"

sleep 1

# verify session started
if screen -list 2>/dev/null | grep -q "\.${SESSION_NAME}"; then
    echo "[OK] Screen session '${SESSION_NAME}' is running."
    echo ""
    echo "  Reattach:  screen -r ${SESSION_NAME}"
    echo "  List:      screen -list"
    echo "  Kill:      screen -S ${SESSION_NAME} -X quit"
else
    echo "[WARN] Screen session may have exited immediately."
    echo "  Check:  /mnt/hdd2/cxj-download/metagenome/${ACCESSION}/logs/download.log"
fi

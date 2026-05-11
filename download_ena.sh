#!/bin/bash

PROJECT_ID=$1

if [ -z "${PROJECT_ID}" ]; then
    echo "Usage: bash download_ena.sh PROJECT_ID"
    echo "  PROJECT_ID  PRJNA or PRJEB accession (e.g. PRJNA210709)"
    exit 1
fi

# ---- check dependencies ----
for cmd in curl wget; do
    if ! command -v ${cmd} &>/dev/null; then
        echo "[ERROR] '${cmd}' is required but not found in PATH"
        exit 1
    fi
done

# ---- paths ----
BASE_DIR="/mnt/hdd2/cxj-download/metagenome"
PROJECT_DIR="${BASE_DIR}/${PROJECT_ID}"
LOGDIR="${PROJECT_DIR}/logs"
DOWNLOAD_LIST="${PROJECT_DIR}/${PROJECT_ID}.download_list.tsv"

mkdir -p "${PROJECT_DIR}" "${LOGDIR}"

exec > >(tee -a "${LOGDIR}/download.log") 2>&1

echo "[INFO] Project:     ${PROJECT_ID}"
echo "[INFO] Output:      ${PROJECT_DIR}"
echo "[INFO] Timestamp:   $(date '+%Y-%m-%d %H:%M:%S')"

# ---- query ENA API ----
API_URL="https://www.ebi.ac.uk/ena/portal/api/filereport"
API_PARAMS="accession=${PROJECT_ID}&result=read_run&fields=run_accession,fastq_ftp,fastq_md5,library_layout&format=tsv&download=true"

echo "[INFO] Querying ENA API..."
TSV=$(curl -sS --retry 3 "${API_URL}?${API_PARAMS}")
CURL_EXIT=$?

if [ ${CURL_EXIT} -ne 0 ] || [ -z "${TSV}" ]; then
    echo "[ERROR] Failed to query ENA API (curl exit: ${CURL_EXIT})"
    exit 1
fi

# ---- save download list ----
echo "${TSV}" | tr -d '\r' > "${DOWNLOAD_LIST}"
echo "[INFO] Download list → ${DOWNLOAD_LIST}"

# ---- count runs ----
TOTAL_RUNS=$(tail -n +2 "${DOWNLOAD_LIST}" | grep -c .)
if [ "${TOTAL_RUNS}" -eq 0 ]; then
    echo "[ERROR] No runs found for project ${PROJECT_ID}"
    exit 1
fi

echo "[INFO] Total runs:   ${TOTAL_RUNS}"
echo ""

# ---- download each run ----
CURRENT=0
SUCCESS=0
FAILED=0

while IFS=$'\t' read -r run_acc fastq_ftp fastq_md5 layout; do
    CURRENT=$((CURRENT + 1))
    RUN_DIR="${PROJECT_DIR}/${run_acc}"
    mkdir -p "${RUN_DIR}"

    echo "============================================================"
    echo "[${CURRENT}/${TOTAL_RUNS}] ${run_acc}  (${layout})"
    echo "============================================================"

    IFS=';' read -ra URLS <<< "${fastq_ftp}"
    RUN_OK=0

    for url in "${URLS[@]}"; do
        FTP_URL="ftp://${url}"
        FILENAME=$(basename "${url}")
        DEST="${RUN_DIR}/${FILENAME}"

        echo "[DOWNLOAD] ${FILENAME}"
        echo "  URL:  ${FTP_URL}"
        echo "  →     ${DEST}"

        wget -c --progress=bar:force -O "${DEST}" "${FTP_URL}"
        WGET_EXIT=$?

        if [ ${WGET_EXIT} -eq 0 ]; then
            echo "  [OK]"
        else
            echo "  [FAIL] wget exited with code ${WGET_EXIT}"
            RUN_OK=1
        fi
        echo ""
    done

    if [ ${RUN_OK} -eq 0 ]; then
        SUCCESS=$((SUCCESS + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done < <(tail -n +2 "${DOWNLOAD_LIST}")

# ---- summary ----
echo "============================================================"
echo "[INFO] All done — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Success: ${SUCCESS}/${TOTAL_RUNS}"
if [ ${FAILED} -gt 0 ]; then
    echo "  Failed:  ${FAILED}/${TOTAL_RUNS}"
fi
echo "  Output:  ${PROJECT_DIR}"
echo "  Log:     ${LOGDIR}/download.log"
echo "  List:    ${DOWNLOAD_LIST}"
echo "============================================================"

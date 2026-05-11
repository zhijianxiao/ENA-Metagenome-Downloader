#!/bin/bash

SRR_ID=$1

if [ -z "${SRR_ID}" ]; then
    echo "Usage: bash download_sra.sh SRR_ID"
    exit 1
fi

OUTDIR="output/${SRR_ID}"
LOGDIR="logs"
mkdir -p "${OUTDIR}" "${LOGDIR}"

exec > >(tee -a "${LOGDIR}/${SRR_ID}.log") 2>&1

echo "[INFO] Downloading SRA..."
prefetch "${SRR_ID}" --output-directory "${OUTDIR}"
echo "[INFO] Download completed"

echo "[INFO] Converting to FASTQ..."
fasterq-dump "${SRR_ID}" --outdir "${OUTDIR}"
echo "[INFO] FASTQ conversion completed"

echo "[INFO] Compressing FASTQ files..."
gzip "${OUTDIR}"/*.fastq
echo "[INFO] Compression completed"

echo "[INFO] All steps completed successfully"
echo "FASTQ files: $(pwd)/${OUTDIR}"
echo "Log file:    $(pwd)/${LOGDIR}/${SRR_ID}.log"

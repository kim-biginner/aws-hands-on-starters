#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
AN="${AN:-udemy}"
aws accessanalyzer delete-analyzer --analyzer-name "$AN" --region $REGION
echo "[*] deleted analyzer: $AN"

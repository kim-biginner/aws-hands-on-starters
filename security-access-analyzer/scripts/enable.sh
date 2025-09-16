#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
AN="${AN:-udemy}"
echo "[+] create analyzer (ACCOUNT) if not exists"
EXIST=$(aws accessanalyzer list-analyzers --region $REGION --query "analyzers[?name=='$AN'].name" --output text)
if [[ -z "$EXIST" ]]; then
  aws accessanalyzer create-analyzer --analyzer-name "$AN" --type ACCOUNT --region $REGION
else
  echo "[*] analyzer already exists: $AN"
fi
aws accessanalyzer get-analyzer --analyzer-name "$AN" --region $REGION --query 'analyzer.status'

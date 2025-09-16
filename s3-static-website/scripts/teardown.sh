#!/usr/bin/env bash
set -euo pipefail

ACTION="${ACTION:-delete}"   # delete | privatize
BUCKET="${BUCKET:?set BUCKET}"
REGION="${REGION:-ap-northeast-1}"

if [[ "$ACTION" == "privatize" ]]; then
  echo "[+] remove public policy & block public access"
  aws s3api delete-bucket-policy --bucket "$BUCKET" || true
  aws s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration '{
    "BlockPublicAcls": true, "IgnorePublicAcls": true,
    "BlockPublicPolicy": true, "RestrictPublicBuckets": true
  }'
  echo "[*] $BUCKET is private now."
else
  echo "[+] delete all objects and bucket: $BUCKET"
  aws s3 rb s3://$BUCKET --force
fi

#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
FUNC="${FUNC:?set FUNC}"
echo "[+] switch to public (NONE) & add permission"
aws lambda update-function-url-config --function-name "$FUNC" --auth-type NONE --region $REGION >/dev/null
aws lambda add-permission --function-name "$FUNC" --region $REGION   --statement-id FunctionURLAllowPublicAccess --action lambda:InvokeFunctionUrl   --principal "*" --function-url-auth-type NONE >/dev/null
URL=$(aws lambda get-function-url-config --function-name "$FUNC" --region $REGION --query 'FunctionUrl' --output text)
echo "[*] Public URL: $URL"

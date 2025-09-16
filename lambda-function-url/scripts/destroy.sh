#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
FUNC="${FUNC:?set FUNC}"
ROLE="lambda-exec-$FUNC"
LOG="/aws/lambda/$FUNC"

echo "[+] delete function: $FUNC"
aws lambda delete-function --function-name "$FUNC" --region $REGION || true
echo "[+] delete log group: $LOG"
aws logs delete-log-group --log-group-name "$LOG" --region $REGION || true
echo "[+] detach & delete role: $ROLE"
aws iam detach-role-policy --role-name "$ROLE" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole || true
aws iam delete-role --role-name "$ROLE" || true
rm -f trust.json code.zip

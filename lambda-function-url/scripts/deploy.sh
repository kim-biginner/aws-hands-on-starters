#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-ap-northeast-1}"
FUNC="${FUNC:-lambda-hello-$(date +%s)}"
ROLE="lambda-exec-$FUNC"

echo "[+] create role: $ROLE"
cat > trust.json <<'JSON'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}
JSON
aws iam create-role --role-name "$ROLE" --assume-role-policy-document file://trust.json >/dev/null
aws iam attach-role-policy --role-name "$ROLE" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

ROLE_ARN=$(aws iam get-role --role-name "$ROLE" --query 'Role.Arn' --output text)

echo "[+] package & create function: $FUNC"
zip -q code.zip ../src/lambda_function.py
aws lambda create-function   --function-name "$FUNC" --runtime python3.12   --role "$ROLE_ARN" --handler lambda_function.handler   --zip-file fileb://code.zip --timeout 5 --memory-size 128 --region $REGION >/dev/null

echo "[+] create Function URL (IAM認証)"
aws lambda create-function-url-config --function-name "$FUNC" --auth-type AWS_IAM --region $REGION >/dev/null

URL=$(aws lambda get-function-url-config --function-name "$FUNC" --region $REGION --query 'FunctionUrl' --output text)
echo "[*] Function URL (IAM auth): $URL"
echo "[*] 公開にする場合は scripts/open.sh を実行してください。"

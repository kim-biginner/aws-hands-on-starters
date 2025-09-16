#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-ap-northeast-1}"
BUCKET="${BUCKET:-my-static-$(date +%s)}"

echo "[+] create bucket: $BUCKET in $REGION"
aws s3api create-bucket --bucket "$BUCKET" --create-bucket-configuration LocationConstraint=$REGION

cat > website.json <<'JSON'
{
  "IndexDocument": {"Suffix": "index.html"},
  "ErrorDocument": {"Key": "error.html"}
}
JSON
aws s3api put-bucket-website --bucket "$BUCKET" --website-configuration file://website.json

echo "[+] upload website files"
aws s3 cp ../website/index.html s3://$BUCKET/
aws s3 cp ../website/error.html s3://$BUCKET/

echo "[+] (temp) allow public read"
aws s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration '{
  "BlockPublicAcls": false, "IgnorePublicAcls": false,
  "BlockPublicPolicy": false, "RestrictPublicBuckets": false
}'
cat > policy.json <<POL
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicReadGetObject",
    "Effect":"Allow",
    "Principal":"*",
    "Action":["s3:GetObject"],
    "Resource":["arn:aws:s3:::$BUCKET/*"]
  }]
}
POL
aws s3api put-bucket-policy --bucket "$BUCKET" --policy file://policy.json

echo "[*] Website URL:"
echo "http://$BUCKET.s3-website-$REGION.amazonaws.com"

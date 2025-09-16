#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
AN="${AN:-udemy}"
ARN=$(aws accessanalyzer get-analyzer --analyzer-name "$AN" --region $REGION --query 'analyzer.arn' --output text)
aws accessanalyzer list-findings --analyzer-arn "$ARN" --region $REGION   --filter '{"status":{"eq":["ACTIVE"]}}'   --query 'findings[].{Id:id,Type:resourceType,Public:isPublic,Resource:resource,Created:createdAt}'   --output table

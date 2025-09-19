#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
TAG_PREFIX="ec2-ebs-lab"

# 인스턴스/볼륨 자동 탐색 (환경변수 없을 때)
INSTANCE="${INSTANCE:-$(aws ec2 describe-instances --region "$REGION" \
  --filters Name=tag:Name,Values=${TAG_PREFIX}-instance Name=instance-state-name,Values=pending,running,stopping,stopped \
  --query 'Reservations[0].Instances[0].InstanceId' --output text 2>/dev/null || true)}"

if [ -z "$INSTANCE" ] || [ "$INSTANCE" = "None" ]; then
  echo "No active instance found."
  exit 0
fi

echo "INSTANCE=$INSTANCE"

aws ec2 describe-instances --instance-ids "$INSTANCE" --region "$REGION" \
  --query 'Reservations[].Instances[].BlockDeviceMappings[].{Device:DeviceName,VolumeId:Ebs.VolumeId,DeleteOnTermination:Ebs.DeleteOnTermination}' \
  --output table

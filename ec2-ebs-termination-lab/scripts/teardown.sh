#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
TAG_PREFIX="ec2-ebs-lab"

# 탐색
INSTANCE="${INSTANCE:-$(aws ec2 describe-instances --region "$REGION" \
  --filters Name=tag:Name,Values=${TAG_PREFIX}-instance Name=instance-state-name,Values=pending,running,stopping,stopped \
  --query 'Reservations[0].Instances[0].InstanceId' --output text 2>/dev/null || true)}"

# 추가 EBS(태그 기준)
VOL="${VOL:-$(aws ec2 describe-volumes --region "$REGION" \
  --filters Name=tag:Name,Values=${TAG_PREFIX}-extra-ebs \
  --query 'Volumes[0].VolumeId' --output text 2>/dev/null || true)}"

if [ -n "$INSTANCE" ] && [ "$INSTANCE" != "None" ]; then
  echo "Terminating instance: $INSTANCE"
  aws ec2 terminate-instances --instance-ids "$INSTANCE" --region "$REGION" >/dev/null
  aws ec2 wait instance-terminated --instance-ids "$INSTANCE" --region "$REGION"
fi

# 추가 EBS 상태 확인
if [ -n "$VOL" ] && [ "$VOL" != "None" ]; then
  echo "Extra EBS state after termination:"
  aws ec2 describe-volumes --region "$REGION" --volume-ids "$VOL" \
    --query 'Volumes[].{Id:VolumeId,State:State,Size:Size}' --output table

  # 삭제
  echo "Deleting extra EBS: $VOL"
  aws ec2 delete-volume --volume-id "$VOL" --region "$REGION" || true
fi

echo "[OK] teardown complete."

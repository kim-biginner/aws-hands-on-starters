#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
TAG_PREFIX="ec2-ebs-lab"

# 최신 Amazon Linux 2023 x86_64
AMI=$(aws ec2 describe-images --region "$REGION" --owners amazon \
  --filters "Name=name,Values=al2023-ami-*" "Name=architecture,Values=x86_64" \
  --query 'Images | sort_by(@,&CreationDate)[-1].ImageId' --output text)

# 인스턴스 생성 (기본 루트 설정 사용)
INSTANCE=$(aws ec2 run-instances --region "$REGION" --image-id "$AMI" --instance-type t2.micro \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${TAG_PREFIX}-instance}]" \
  --query 'Instances[0].InstanceId' --output text)
echo "INSTANCE=$INSTANCE"
aws ec2 wait instance-running --instance-ids "$INSTANCE" --region "$REGION"

# AZ 조회
AZ=$(aws ec2 describe-instances --instance-ids "$INSTANCE" --region "$REGION" \
  --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' --output text)
echo "AZ=$AZ"

# 추가 EBS (2GB) 생성 및 연결
VOL=$(aws ec2 create-volume --region "$REGION" --availability-zone "$AZ" --size 2 --volume-type gp3 \
  --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=${TAG_PREFIX}-extra-ebs}]" \
  --query 'VolumeId' --output text)
echo "VOL=$VOL"
aws ec2 wait volume-available --volume-ids "$VOL" --region "$REGION"
aws ec2 attach-volume --region "$REGION" --volume-id "$VOL" --instance-id "$INSTANCE" --device /dev/sdf

# 루트 DeleteOnTermination 보장 (대부분 기본 true지만 확실히 설정)
ROOT_DEV=$(aws ec2 describe-instances --instance-ids "$INSTANCE" --region "$REGION" \
  --query 'Reservations[0].Instances[0].RootDeviceName' --output text)
aws ec2 modify-instance-attribute --region "$REGION" --instance-id "$INSTANCE" \
  --block-device-mappings "DeviceName=$ROOT_DEV,Ebs={DeleteOnTermination=true}"

cat <<EOF
---
SET THESE IF NEEDED:
export REGION=$REGION
export INSTANCE=$INSTANCE
export VOL=$VOL
export ROOT_DEV=$ROOT_DEV
---
EOF

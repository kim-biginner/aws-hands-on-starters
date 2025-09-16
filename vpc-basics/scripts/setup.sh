#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"

echo "[1/6] Create VPC"
VPC_ID=$(aws ec2 create-vpc --region "$REGION" --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --region "$REGION" --resources "$VPC_ID" --tags Key=Name,Value=vpc-lab
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support   '{"Value":true}' --region "$REGION"
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames '{"Value":true}' --region "$REGION"

echo "[2/6] Create two subnets (public/private)"
AZS=($(aws ec2 describe-availability-zones --region "$REGION" --query 'AvailabilityZones[?State==`available`].ZoneName' --output text))
AZ1="${AZS[0]}"
AZ2="${AZS[1]:-${AZS[0]}}"
PUB_SUB=$(aws ec2 create-subnet --region "$REGION" --vpc-id "$VPC_ID" --cidr-block 10.0.0.0/24 --availability-zone "$AZ1" --query 'Subnet.SubnetId' --output text)
PRV_SUB=$(aws ec2 create-subnet --region "$REGION" --vpc-id "$VPC_ID" --cidr-block 10.0.1.0/24 --availability-zone "$AZ2" --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --region "$REGION" --resources "$PUB_SUB" --tags Key=Name,Value=subnet-public
aws ec2 create-tags --region "$REGION" --resources "$PRV_SUB" --tags Key=Name,Value=subnet-private

echo "[3/6] Create and attach Internet Gateway"
IGW=$(aws ec2 create-internet-gateway --region "$REGION" --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 create-tags --region "$REGION" --resources "$IGW" --tags Key=Name,Value=igw-lab
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$VPC_ID" --region "$REGION"

echo "[4/6] Create Route Tables and associate"
PUB_RT=$(aws ec2 create-route-table --region "$REGION" --vpc-id "$VPC_ID" --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --region "$REGION" --resources "$PUB_RT" --tags Key=Name,Value=rtb-public
aws ec2 associate-route-table --region "$REGION" --route-table-id "$PUB_RT" --subnet-id "$PUB_SUB" >/dev/null
aws ec2 create-route --region "$REGION" --route-table-id "$PUB_RT" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW" >/dev/null

PRV_RT=$(aws ec2 create-route-table --region "$REGION" --vpc-id "$VPC_ID" --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --region "$REGION" --resources "$PRV_RT" --tags Key=Name,Value=rtb-private
aws ec2 associate-route-table --region "$REGION" --route-table-id "$PRV_RT" --subnet-id "$PRV_SUB" >/dev/null

echo "[5/6] Gateway VPC Endpoint for S3 (private access)"
S3EP=$(aws ec2 create-vpc-endpoint --region "$REGION" \
  --vpc-id "$VPC_ID" --service-name "com.amazonaws.$REGION.s3" \
  --vpc-endpoint-type Gateway --route-table-ids "$PRV_RT" \
  --query 'VpcEndpoint.VpcEndpointId' --output text)
aws ec2 create-tags --region "$REGION" --resources "$S3EP" --tags Key=Name,Value=vpce-s3-gw

echo "[6/6] Summary"
echo "VPC=$VPC_ID"
echo "PUB_SUB=$PUB_SUB   PRV_SUB=$PRV_SUB"
echo "IGW=$IGW"
echo "PUB_RT=$PUB_RT     PRV_RT=$PRV_RT"
echo "S3EP=$S3EP"

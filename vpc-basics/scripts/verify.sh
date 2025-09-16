#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"

VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters Name=tag:Name,Values=vpc-lab --query 'Vpcs[0].VpcId' --output text 2>/dev/null || true)
if [[ -z "${VPC_ID}" || "${VPC_ID}" == "None" ]]; then
  echo "vpc-lab not found by tag. Set VPC_ID=<vpc-id> env to override."
  exit 0
fi

PUB_RT=$(aws ec2 describe-route-tables --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" Name=tag:Name,Values=rtb-public --query 'RouteTables[0].RouteTableId' --output text)
PRV_RT=$(aws ec2 describe-route-tables --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" Name=tag:Name,Values=rtb-private --query 'RouteTables[0].RouteTableId' --output text)

echo "[ROUTES]"
aws ec2 describe-route-tables --region "$REGION" --route-table-ids $PUB_RT $PRV_RT \
  --query 'RouteTables[].{RT:RouteTableId,Routes:Routes[*].Target,Assoc:Associations[*].SubnetId}' --output table

echo "[VPC / SUBNETS / IGW / VPCE]"
echo "VPC=$(aws ec2 describe-vpcs --region "$REGION" --vpc-ids "$VPC_ID" --query 'Vpcs[0].VpcId' --output text)"
aws ec2 describe-subnets --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" --query 'Subnets[].{Id:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value}' --output table
aws ec2 describe-internet-gateways --region "$REGION" --filters Name=attachment.vpc-id,Values="$VPC_ID" --query 'InternetGateways[].{IGW:InternetGatewayId,Name:Tags[?Key==`Name`]|[0].Value}' --output table
aws ec2 describe-vpc-endpoints --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" --query 'VpcEndpoints[].{Id:VpcEndpointId,Service:ServiceName,Type:VpcEndpointType,Name:Tags[?Key==`Name`]|[0].Value}' --output table

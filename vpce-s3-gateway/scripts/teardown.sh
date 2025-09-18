#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"

# lookup
VPC_ID=$(aws ec2 describe-vpcs --region $REGION --filters Name=tag:Name,Values=vpc-vpce-lab --query 'Vpcs[0].VpcId' --output text 2>/dev/null || true)
PUB_RT=$(aws ec2 describe-route-tables --region $REGION --filters Name=vpc-id,Values=$VPC_ID Name=tag:Name,Values=rtb-public --query 'RouteTables[0].RouteTableId' --output text)
PRV_RT=$(aws ec2 describe-route-tables --region $REGION --filters Name=vpc-id,Values=$VPC_ID Name=tag:Name,Values=rtb-private --query 'RouteTables[0].RouteTableId' --output text)
IGW=$(aws ec2 describe-internet-gateways --region $REGION --filters Name=attachment.vpc-id,Values=$VPC_ID --query 'InternetGateways[0].InternetGatewayId' --output text)
PUB_SUB=$(aws ec2 describe-subnets --region $REGION --filters Name=vpc-id,Values=$VPC_ID Name=tag:Name,Values=subnet-public --query 'Subnets[0].SubnetId' --output text)
PRV_SUB=$(aws ec2 describe-subnets --region $REGION --filters Name=vpc-id,Values=$VPC_ID Name=tag:Name,Values=subnet-private --query 'Subnets[0].SubnetId' --output text)

# 1) endpoints
for EP in $(aws ec2 describe-vpc-endpoints --region $REGION --filters Name=vpc-id,Values=$VPC_ID --query 'VpcEndpoints[].VpcEndpointId' --output text); do
  aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $EP --region $REGION || true
done

# 2) disassociate non-main RT assocs
for A in $(aws ec2 describe-route-tables --region $REGION --filters Name=vpc-id,Values=$VPC_ID --query 'RouteTables[].Associations[?Main!=`true`].RouteTableAssociationId' --output text); do
  aws ec2 disassociate-route-table --association-id $A --region $REGION || true
done

# 3) delete routes & RTs
for RT in $PRV_RT $PUB_RT; do
  aws ec2 delete-route --route-table-id $RT --destination-cidr-block 0.0.0.0/0 --region $REGION || true
  aws ec2 delete-route-table --route-table-id $RT --region $REGION || true
done

# 4) IGW
aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_ID --region $REGION || true
aws ec2 delete-internet-gateway  --internet-gateway-id $IGW --region $REGION || true

# 5) subnets
for SUB in $PRV_SUB $PUB_SUB; do
  aws ec2 delete-subnet --subnet-id $SUB --region $REGION || true
done

# 6) VPC
aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION || true
echo "[OK] teardown vpc $VPC_ID"

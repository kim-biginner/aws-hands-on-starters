#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"
VPC_ID="${VPC_ID:-}"

if [[ -z "$VPC_ID" ]]; then
  VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters Name=tag:Name,Values=vpc-lab --query 'Vpcs[0].VpcId' --output text 2>/dev/null || true)
fi

if [[ -z "$VPC_ID" || "$VPC_ID" == "None" ]]; then
  echo "VPC_ID not found. Set VPC_ID=<vpc-id> or tag your VPC as Name=vpc-lab"
  exit 0
fi

echo "[*] Cleaning VPC: $VPC_ID"

# 1) Delete VPC Endpoints
for EP in $(aws ec2 describe-vpc-endpoints --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" --query 'VpcEndpoints[].VpcEndpointId' --output text); do
  echo "delete vpce $EP"
  aws ec2 delete-vpc-endpoints --vpc-endpoint-ids "$EP" --region "$REGION" || true
done

# 2) Disassociate non-main route table associations
for A in $(aws ec2 describe-route-tables --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" --query 'RouteTables[].Associations[?Main!=`true`].RouteTableAssociationId' --output text); do
  echo "disassociate rtb assoc $A"
  aws ec2 disassociate-route-table --association-id "$A" --region "$REGION" || true
done

# 3) Delete non-main route tables (remove default routes first)
MAIN_RT=$(aws ec2 describe-route-tables --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" Name=association.main,Values=true --query 'RouteTables[0].RouteTableId' --output text)
for RT in $(aws ec2 describe-route-tables --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" --query 'RouteTables[].RouteTableId' --output text); do
  if [[ "$RT" != "$MAIN_RT" ]]; then
    aws ec2 delete-route --region "$REGION" --route-table-id "$RT" --destination-cidr-block 0.0.0.0/0 || true
    aws ec2 delete-route-table --route-table-id "$RT" --region "$REGION" || true
  fi
done

# 4) Detach & delete IGWs
for IGW in $(aws ec2 describe-internet-gateways --region "$REGION" --filters Name=attachment.vpc-id,Values="$VPC_ID" --query 'InternetGateways[].InternetGatewayId' --output text); do
  echo "detach/delete igw $IGW"
  aws ec2 detach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$VPC_ID" --region "$REGION" || true
  aws ec2 delete-internet-gateway  --internet-gateway-id "$IGW" --region "$REGION" || true
done

# 5) Delete subnets
for SUB in $(aws ec2 describe-subnets --region "$REGION" --filters Name=vpc-id,Values="$VPC_ID" --query 'Subnets[].SubnetId' --output text); do
  echo "delete subnet $SUB"
  aws ec2 delete-subnet --subnet-id "$SUB" --region "$REGION" || true
done

# 6) Delete the VPC
aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION"
echo "[OK] Deleted VPC $VPC_ID"

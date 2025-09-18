#!/usr/bin/env bash
set -euo pipefail
REGION="${REGION:-ap-northeast-1}"

# find by tag
VPC_ID=$(aws ec2 describe-vpcs --region $REGION --filters Name=tag:Name,Values=vpc-vpce-lab --query 'Vpcs[0].VpcId' --output text 2>/dev/null || true)
PUB_RT=$(aws ec2 describe-route-tables --region $REGION --filters Name=vpc-id,Values=$VPC_ID Name=tag:Name,Values=rtb-public --query 'RouteTables[0].RouteTableId' --output text)
PRV_RT=$(aws ec2 describe-route-tables --region $REGION --filters Name=vpc-id,Values=$VPC_ID Name=tag:Name,Values=rtb-private --query 'RouteTables[0].RouteTableId' --output text)

aws ec2 describe-route-tables --region $REGION --route-table-ids $PRV_RT $PUB_RT \
  --query 'RouteTables[].{RT:RouteTableId,Routes:Routes[].{Dst:(DestinationPrefixListId||DestinationCidrBlock),Target:(TransitGatewayId||VpcEndpointId||NatGatewayId||GatewayId||VpcPeeringConnectionId)}}' \
  --output table

aws ec2 describe-vpc-endpoints --region $REGION --filters Name=vpc-id,Values=$VPC_ID \
  --query 'VpcEndpoints[].{Id:VpcEndpointId,Type:VpcEndpointType,Service:ServiceName,RouteTables:RouteTableIds,State:State}' \
  --output table

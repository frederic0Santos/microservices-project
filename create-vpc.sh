#!/bin/bash

# Variables
VPC_NAME="week5-vpc"
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_1A="10.0.1.0/24"
PRIVATE_SUBNET_1A="10.0.2.0/24"
PRIVATE_SUBNET_1B="10.0.3.0/24"
REGION="us-east-1"
AZ_1A="us-east-1a"
AZ_1B="us-east-1b"

echo "Creating VPC..."

# Create VPC
VPC_ID=$(aws ec2 create-vpc \
 --cidr-block $VPC_CIDR \
 --region $REGION \
 --query 'Vpc.VpcId' \
 --output text)

echo "Created VPC: $VPC_ID"

# Tag VPC
aws ec2 create-tags \
 --resources $VPC_ID \
 --tags Key=Name,Value=$VPC_NAME \
 --region $REGION

# Enable DNS hostnames
aws ec2 modify-vpc-attribute \
 --vpc-id $VPC_ID \
 --enable-dns-hostnames \
 --region $REGION

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
 --region $REGION \
 --query 'InternetGateway.InternetGatewayId' \
 --output text)

echo "Created Internet Gateway: $IGW_ID"

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
 --internet-gateway-id $IGW_ID \
 --vpc-id $VPC_ID \
 --region $REGION

# Create Public Subnet
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
 --vpc-id $VPC_ID \
 --cidr-block $PUBLIC_SUBNET_1A \
 --availability-zone $AZ_1A \
 --region $REGION \
 --query 'Subnet.SubnetId' \
 --output text)

echo "Created Public Subnet: $PUBLIC_SUBNET_ID"

# Tag Public Subnet
aws ec2 create-tags \
 --resources $PUBLIC_SUBNET_ID \
 --tags Key=Name,Value=public-subnet-1a \
 --region $REGION

# Enable auto-assign public IP
aws ec2 modify-subnet-attribute \
 --subnet-id $PUBLIC_SUBNET_ID \
 --map-public-ip-on-launch \
 --region $REGION

# Create Private Subnets
PRIVATE_SUBNET_1A_ID=$(aws ec2 create-subnet \
 --vpc-id $VPC_ID \
 --cidr-block $PRIVATE_SUBNET_1A \
 --availability-zone $AZ_1A \
 --region $REGION \
 --query 'Subnet.SubnetId' \
 --output text)

PRIVATE_SUBNET_1B_ID=$(aws ec2 create-subnet \
 --vpc-id $VPC_ID \
 --cidr-block $PRIVATE_SUBNET_1B \
 --availability-zone $AZ_1B \
 --region $REGION \
 --query 'Subnet.SubnetId' \
 --output text)

echo "Created Private Subnets: $PRIVATE_SUBNET_1A_ID, $PRIVATE_SUBNET_1B_ID"

# Tag Private Subnets
aws ec2 create-tags \
 --resources $PRIVATE_SUBNET_1A_ID \
 --tags Key=Name,Value=private-subnet-1a \
 --region $REGION

aws ec2 create-tags \
 --resources $PRIVATE_SUBNET_1B_ID \
 --tags Key=Name,Value=private-subnet-1b \
 --region $REGION

# Get default route table
DEFAULT_RT_ID=$(aws ec2 describe-route-tables \
 --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=true" \
 --region $REGION \
 --query 'RouteTables[0].RouteTableId' \
 --output text)

# Create Public Route Table
PUBLIC_RT_ID=$(aws ec2 create-route-table \
 --vpc-id $VPC_ID \
 --region $REGION \
 --query 'RouteTable.RouteTableId' \
 --output text)

echo "Created Public Route Table: $PUBLIC_RT_ID"

# Tag Route Table
aws ec2 create-tags \
 --resources $PUBLIC_RT_ID \
 --tags Key=Name,Value=public-rt \
 --region $REGION

# Add route to Internet Gateway
aws ec2 create-route \
 --route-table-id $PUBLIC_RT_ID \
 --destination-cidr-block 0.0.0.0/0 \
 --gateway-id $IGW_ID \
 --region $REGION

# Associate Public Subnet with Public Route Table
aws ec2 associate-route-table \
 --subnet-id $PUBLIC_SUBNET_ID \
 --route-table-id $PUBLIC_RT_ID \
 --region $REGION

echo ""
echo "VPC Setup Complete!"
echo "VPC ID: $VPC_ID"
echo "Internet Gateway: $IGW_ID"
echo "Public Subnet: $PUBLIC_SUBNET_ID"
echo "Private Subnets: $PRIVATE_SUBNET_1A_ID, $PRIVATE_SUBNET_1B_ID"
echo "Public Route Table: $PUBLIC_RT_ID"
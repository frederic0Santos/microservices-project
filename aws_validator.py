#!/usr/bin/env python3
"""
AWS Permissions Validator
Validates IAM permissions for a user or role
"""

import boto3
import json
from botocore.exceptions import ClientError


def validate_s3_access(s3_client, bucket_name):
    """Validate S3 bucket access"""
    try:
        response = s3_client.head_bucket(Bucket=bucket_name)
        print(f" Can access bucket: {bucket_name}")
        return True
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == '403':
            print(f" Access denied to bucket: {bucket_name}")
        elif error_code == '404':
            print(f" Bucket not found: {bucket_name}")
        else:
            print(f" Error accessing bucket: {e}")
        return False


def validate_ec2_permissions(ec2_client):
    """Validate EC2 describe permissions"""
    try:
        response = ec2_client.describe_instances()
        instance_count = sum(
            len(reservation['Instances'])
            for reservation in response['Reservations']
        )
        print(f" Can describe EC2 instances (found {instance_count} instances)")
        return True
    except ClientError as e:
        print(f" Cannot describe EC2 instances: {e}")
        return False


def get_caller_identity(sts_client):
    """Get current AWS identity"""
    try:
        response = sts_client.get_caller_identity()
        print(f"\nCurrent Identity:")
        print(f" Account: {response['Account']}")
        print(f" ARN: {response['Arn']}")
        print(f" User ID: {response.get('UserId', 'N/A')}")
        return response
    except ClientError as e:
        print(f" Cannot get caller identity: {e}")
        return None


def main():
    """Main validation function"""
    print("AWS Permissions Validator\n")
    print("=" * 50)

    # Create clients
    sts = boto3.client('sts')
    s3 = boto3.client('s3')
    ec2 = boto3.client('ec2')

    # Get identity
    identity = get_caller_identity(sts)
    if not identity:
        return

    print("\n" + "=" * 50)
    print("Validating Permissions:\n")

    # Validate S3 access
    bucket_name = 'student-bucket'  # Change to your bucket
    validate_s3_access(s3, bucket_name)

    # Validate EC2 permissions
    validate_ec2_permissions(ec2)

    print("\n" + "=" * 50)
    print("Validation Complete")


if __name__ == '__main__':
    main()

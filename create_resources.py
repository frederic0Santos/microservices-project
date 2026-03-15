#!/usr/bin/env python3
"""
Automated AWS Resource Creation
Creates S3 bucket and EC2 instance with proper IAM roles
"""

import boto3
import time
from botocore.exceptions import ClientError


def create_s3_bucket(s3_client, bucket_name, region='us-east-1'):
    """Create S3 bucket"""
    try:
        if region == 'us-east-1':
            s3_client.create_bucket(Bucket=bucket_name)
        else:
            s3_client.create_bucket(
                Bucket=bucket_name,
                CreateBucketConfiguration={'LocationConstraint': region}
            )

        print(f"Created S3 bucket: {bucket_name}")
        return True

    except ClientError as e:
        if e.response['Error']['Code'] == 'BucketAlreadyExists':
            print(f"Bucket {bucket_name} already exists")
            return True

        print(f"Error creating bucket: {e}")
        return False


def create_ec2_instance(ec2_client, image_id, instance_type, key_name):
    """Create EC2 instance"""
    try:
        response = ec2_client.run_instances(
            ImageId=image_id,
            MinCount=1,
            MaxCount=1,
            InstanceType=instance_type,
            KeyName=key_name,
            TagSpecifications=[
                {
                    'ResourceType': 'instance',
                    'Tags': [
                        {'Key': 'Name', 'Value': 'Week4-Instance'},
                        {'Key': 'Project', 'Value': 'CloudComputing'}
                    ]
                }
            ]
        )

        instance_id = response['Instances'][0]['InstanceId']
        print(f"Created EC2 instance: {instance_id}")
        return instance_id

    except ClientError as e:
        print(f"Error creating instance: {e}")
        return None


def main():
    """Main function"""
    print("AWS Resource Creation Script\n")

    # Create clients
    s3 = boto3.client('s3', region_name='us-east-1')
    ec2 = boto3.client('ec2', region_name='us-east-1')

    # Create S3 bucket
    bucket_name = 'week4-student-bucket-' + str(int(time.time()))
    create_s3_bucket(s3, bucket_name)

    # Create EC2 instance
    # Note: Update these values for your environment
    images = ec2.describe_images(
        Owners=['amazon'],
        Filters=[{'Name': 'name', 'Values': ['amzn2-ami-hvm-2.0.*-x86_64-gp2']}]
    )

    image_id = sorted(
        images['Images'],
        key=lambda x: x['CreationDate'],
        reverse=True
    )[0]['ImageId']

    instance_type = 't3.micro' # If you have the freetier error, change t2 to t3
    key_name = 'my-key-pair'  # EC2 key pair name (create in EC2 → Key pairs in the console)

    instance_id = create_ec2_instance(ec2, image_id, instance_type, key_name)

    if instance_id:
        print("\nResources created successfully!")
        print(f"S3 Bucket: {bucket_name}")
        print(f"EC2 Instance: {instance_id}")


if __name__ == '__main__':
    main()
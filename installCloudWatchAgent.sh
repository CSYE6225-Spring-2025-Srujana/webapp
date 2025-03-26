#!/bin/bash
 
 # Update and install prerequisites
 sudo apt-get update -y
 sudo apt-get install -y unzip curl
 
 # Download and install the Unified CloudWatch Agent
 curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
 sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
 
 # Move the CloudWatch configuration file to the appropriate directory
 sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
 sudo mv /tmp/cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json
 
sudo mkdir -p /opt/csye6225/webapp/logs
sudo chown -R csye6225:csye6225 /opt/csye6225/webapp/logs
sudo chmod -R 755 /opt/csye6225/webapp/logs 
 
 # Enable and start the CloudWatch Agent service using the configuration
 sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
     -a fetch-config \
     -m ec2 \
     -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json \
     -s
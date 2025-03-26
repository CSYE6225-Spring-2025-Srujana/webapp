# Health Check API

## Overview
- The health check API allows us to monitor the health of the application instance and alert us when something is not working as expected.
- The health check API prevents us from sending traffic to unhealthy application instances and automatically replace/repair them. It also helps us improve user experience by not routing their quests to unhealthy instances.
- File API allows us to upload and delete a file to s3 bucket in AWS and also store, get and delete file's metadata in RDS.
  
### **Web Application Updates**
- **Observability**:  
  - Logs: Application log data is stored in Amazon CloudWatch.  
  - Metrics: CloudWatch collects metrics for API usage, including the number of calls and response times.  

- **Custom Metrics**:  
  - **API Call Count**: Tracks the frequency of API calls.  
  - **API Response Time**: Measures the time taken (ms) to process each API call.  
  - **Database Query Time**: Records the execution time (ms) of database queries.  
  - **S3 Operation Time**: Tracks the duration (ms) of calls to AWS S3.  
  
- **API Features**:  
  - All request/response payloads are JSON.  
  - Proper HTTP status codes are returned for all operations.  

- **Image Management**:  
  - Can upload files in formats like PNG, JPG, and JPEG.  
  - Files are stored in an S3 bucket, with metadata saved in the database.  
  - Can delete files; they are removed from both S3 and the database.  

- **S3 Security**:  
  - S3 credentials are securely managed via IAM roles attached to EC2 instances.
  
## Prerequisites
Before you begin, ensure you have the following installed:
1. **Node.js** (v20 or higher)
2. **MySQL** (v9 or higher)
3. **npm** (Node package manager, usually included with Node.js)
4. **Git** (for version control)
5. **Packer** (for Custom AMI build)
6. **Terraform** (IaaC - infra setup)
7. **AWS-SDK** (for AWS SDK)
8. **Winston Logger** (Cloud Watch)

## Getting Started

### Git Instructions

**Fork the Repository**
   - Go to the [GitHub repository](https://github.com/CSYE6225-Spring-2025-Srujana/webapp) and click the "Fork" button at the top right.
  
**Clone Your Fork**
   - Once you have forked the repository, clone it to your local machine using the following command:
   ```bash
   git clone https://github.com/YOUR_USERNAME/webapp.git
``` 

### Setting Up Environment Variables
Navigate to the project directory:
```
cd webapp
```

**Create a .env file in the root directory of the project**

`DB_USER=your_database_user`\
`DB_PASSWORD=your_database_password`\
`DB_HOST=localhost`\
`DB_PORT=3306`\
`DB_NAME=your_database_name`\
`DB_DIALECT=mysql`\
`DB_FORCE_CHANGES=false`\
`S3_BUCKET_NAME=webapp-bucket`\
`AWS_REGION=us-east-1`

Fill in the placeholders in the `.env` file template with actual values.


### Install Dependencies
Run the following command to install the required dependencies:
```
npm install
```
### Build and Deploy
To start the application, use the following command:
```
node app.js
```
- The application will be running on http://localhost:8080.
- A `healthChecks` table with 2 columns(checkId, dateTime) will be created in the database mentioned in the .env file.


### API Behavior
1.  Endpoint: /healthz
    - Supported Method: Only GET requests are allowed.
    - Responses:
      
      - `200 OK`: Connected to the database and inserted a record into the "healthChecks" table.
      - `400 Bad Request`: If the request includes a body or any query parameters.
      - `405 Method Not Allowed`: If using any method other than GET.
      - `503 Service Unavailable`: If the database connection/insertion fails.

2. Endpoint: /v1/file
   - Supported Method: Only POST requests with a single file key as "webapp-file" is allowed.
   - Responses:
     
     - `201 Created`: Connected to the database and inserted a record into the "Files" table as well as s3 bucket.
     - `400 Bad Request`: If the request method is GET, DELETE or includes a body or any query parameters.
     - `405 Method Not Allowed`: If using any method other than POST, GET, DELETE.
     - `503 Service Unavailable`: If the database connection/insertion fails.

3. Endpoint: /v1/file/{id}
   - Supported Method: Only GET, DELETE requests are allowed.
   - Responses:
     
     - `200 OK`: Connected to the database and succesfully retrieved the data stored in database.
     - `404 Not Found`: If the file with {id} is not found.
     - `405 Method Not Allowed`: If using any method other than GET, DELETE.
     - `503 Service Unavailable`: If the database connection/insertion fails.
  
### Testing the Health Check API
- Use Postman or curl to test the API
- Run tests: npm test
- Check coverage: npx jest coverage

## Deploying Application on Cloud

### Launch Ubuntu 24.04 LTS VM on DigitalOcean
1. Sign in to DigitalOcean
2. Create a Droplet:
   - Choose Ubuntu 24.04 LTS
   - Select appropriate plan and region
   - Set up SSH keys or password
   
### Deploy Application
1. Transfer files to VM:
```
scp /path/to/your/code.zip .env webappSetup.sh root@your_droplet_ip:/tmp
```
2. SSH into your VM
3. Navigate to /tmp and set permissions:
```
chmod +x webappSetup.sh
```
4. Run the setup script:
```
./webappSetup.sh
```
5. Start the application:
```
cd /opt/csye6225/webapp
node app.js
```

### Successful Request:
```
curl -vvv http://localhost:8080/healthz
```
### Method Not Allowed Example:
```
curl -vvv -XPUT http://localhost:8080/healthz
```
### Stopping the Application
To stop the application, use Ctrl + C in the terminal where the application is running.

## Packer - For Building Custom Images

**Building a Custom Application Image Using Packer**
- This  will show how to use Packer to build a custom image for our application using Ubuntu 24.04 LTS as the base image. The custom image will include the necessary application dependencies, the database (MySQL), and configuration files.

**Prerequisites**

Before proceeding, ensure that you have the following setup:

- Packer installed on your local machine.
- AWS CLI configured with access to your DEV AWS account.
- A VPC set up in your DEV AWS account.
- Access to the repository where the Packer template will be stored alongside the web application code.

**Steps to Build a Custom Image**
- Install Packer:
- create a packer/ directory to store your Packer template.
- The template should include configurations for:
- The Ubuntu 24.04 LTS base image.
- Installing all necessary dependencies for the web application (e.g., Node, Java, Python, Tomcat, etc.).
- Starting services (e.g., systemctl enable <service_name>).
- Ensuring that the services are started on instance launch.
- **Make the Image Private**: Ensure that all custom images created are marked as private. This restricts access so that only you can launch instances from it.
- Store the Packer template (eg: machine-image.pkr.hcl) at the root level of your application repository.
**Build the Custom Image**

Run the following Packer commands to build and validate the custom image:

Format the Packer template:
```
packer fmt machine-image.pkr.hcl
```
Validate the Packer template:

```
packer validate -var-file=dev.pkrvars.hcl machine-image.pkr.hcl
```
Build the custom image:
```
packer build -var-file=dev.pkrvars.hcl machine-image.pkr.hcl
```
**Using dev.pkrvars.hcl for Packer Configuration**

- For this project, we will use Packer to build custom application images and manage environment-specific variables (such as AWS region, instance type, etc.) via a dev.pkrvars.hcl file.
-  This makes it easy to maintain separate configurations for different environments (e.g., dev, prod, etc.).
```
dev.tfvars
aws_region    = "us-east-1"
source_ami    = "ami-<ubuntu-24.04-id>"
instance_type = "t2.micro"
project_path  = "./webapp.zip"
ssh_username  = "ubuntu"
aws_profile   = "<aws-profile>"
```

**Configure Image Launch in AWS**:

- The custom image build should happen in your DEV AWS account and within the default VPC.
- Once the image is built, ensure the correct security groups are configured when launching instances from it.

**Running the Application on the Custom Image**
- When the custom image is launched, it should already have MySQL installed and running, and all application dependencies should be in place.
- Ensure that the application starts as a service using systemd when the instance is launched.
  
### Additional Notes
- Ensure your MySQL server is running before starting the application.
- The webappSetup.sh script automates the setup process on Ubuntu systems

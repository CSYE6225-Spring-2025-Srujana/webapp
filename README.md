# Health Check API

## Overview
- The health check API allows us to monitor the health of the application instance and alert us when something is not working as expected.
- The health check API prevents us from sending traffic to unhealthy application instances and automatically replace/repair them. It also helps us improve user experience by not routing their quests to unhealthy instances.
  
## Prerequisites
Before you begin, ensure you have the following installed:
1. **Node.js** (v20 or higher)
2. **MySQL** (v9 or higher)
3. **npm** (Node package manager, usually included with Node.js)
4. **Git** (for version control)

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

### Create a .env file in the root directory of the project
DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database_name
DB_DIALECT=mysql
DB_FORCE_CHANGES=false

- Fill in the placeholders in the `.env` file template with actual values.


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
The application will be running on http://localhost:8080.
"healthChecks" table with 2 columns(checkId, dateTime) will be created in the database mentioned in the .env file.


### API Behavior
- Endpoint: /healthz
- Supported Method: Only GET requests are allowed.
- Responses:
  
  - 200 OK: Connected to the database and inserted a record into the "healthChecks" table.
  - 400 Bad Request: If the request includes a body or any query parameters.
  - 405 Method Not Allowed: If using any method other than GET.
  - 503 Service Unavailable: If the database connection/insertion fails.


### Testing the Health Check API
You can test the Health Check API using Postman or curl.

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

### Additional Notes
- Ensure your MySQL server is running before starting the application.

# Orchestration Saga document
## Setup and Run
### 1. Environments
- Java 17
- Maven
- Docker
### 2. Build and Run

```
mvn clean install -DskipTests
mvn clean install
docker compose up

```
### 3. Test 
```
API /backoffice/api/v1/backoffice/order
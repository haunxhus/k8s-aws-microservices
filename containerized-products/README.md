# Kafka and Redis documents
## Getting started
Apache Kafka is an open-source distributed event streaming platform used by thousands of companies for 
high-performance data pipelines, streaming analytics, data integration, and mission-critical applications.

Redis is open source, in-memory data store used by millions of developers as a database, cache, streaming engine, 
and message broker.


## Setup and Run
### 1. Environments
- Java 17
- Maven
- Docker
### 2. Build and Run

```
mvn clean install -DskipTests
mvn clean package -DskipTests
docker compose build
docker compose up

```
### 3. Test
```
Kafka
http://localhost:2227/product/send-event

Redis
GET All
http://localhost:2227/product
Delete All
http://localhost:2227/product/delete-cache
Delete by id
http://localhost:2227/product/2
Get cache
http://localhost:2227/product/2
PUt update cache
http://localhost:2227/product/2
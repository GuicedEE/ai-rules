# Health Implementation

* Health checks must validate:
  * DB connectivity
  * Redis or caching layer availability
  * Outbound HTTP service response time
  * Kafka or Pub/Sub availability if configured
* Expose detailed health report on `/health` endpoint in JSON
* Terraform must provision health check probes in Cloud Run using HTTP GET on `/health` with 200 OK required
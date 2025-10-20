# Metrics Implementation

* Configure Prometheus export endpoint on `/metrics`.
* Enable detailed metrics via Vert.x `MicrometerMetricsOptions`.
* Terraform enables GCP Managed Prometheus to scrape metrics.
* Service labels must include `service_name`, `version`, `instance_id`.
* Latency, throughput, pool stats, event loop blocking, and error counts must be exposed per service.
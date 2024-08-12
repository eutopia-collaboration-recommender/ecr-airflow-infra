output "airflow_web_interface" {
  description = "The URL of the Airflow web interface for the Composer environment."
  value       = google_composer_environment.composer_environment.config.0.airflow_uri
}
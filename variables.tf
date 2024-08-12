variable "project" {
  description = "The GCP project to deploy resources"
  default     = "collaboration-recommender"
}

variable "project_number" {
  description = "The GCP project number"
  default     = "309142996153"
}

variable "region" {
  description = "The GCP region to deploy resources"
  default     = "us-central1"
}

variable "location" {
  description = "The GCP location to deploy resources"
  default     = "US"
}

variable "composer-environment-name" {
  description = "The name of the Composer environment"
  default     = "ecr-composer"
}

variable "composer-environment-version" {
  description = "The version of Composer to use"
  default     = "composer-2.8.7-airflow-2.9.1"
}

variable "composer-environment-size" {
  description = "The size of the Composer environment"
  default     = "ENVIRONMENT_SIZE_SMALL"
}
variable "service-account" {
  description = "The service account to use for the Composer environment"
  default     = "ecr-composer-service-account"
}

variable "dataproc-cluster-machine-type" {
  description = "The machine type to use for the Dataproc cluster"
  default     = "n2-standard-4"
}

variable "dataproc-cluster-worker-count" {
  description = "The number of workers to use for the Dataproc cluster"
  default     = 4
}
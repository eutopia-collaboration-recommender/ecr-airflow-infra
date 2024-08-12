terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.40.0"
    }
  }
}

provider "google" {
  project = var.project
}

###############################################################################################################
# Data
###############################################################################################################


###############################################################################################################
# IAM
###############################################################################################################

# Add the service account for the Composer environment
resource "google_service_account" "composer_service_account" {
  account_id   = var.service-account
  display_name = var.service-account

}
# Add roles: Dataproc Worker, Secret Manager Secret Accessor, Storage Admin
resource "google_project_iam_member" "dataproc_worker_iam_member" {
  project = var.project
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.composer_service_account.email}"
}

resource "google_project_iam_member" "dataflow_admin_iam_member" {
  project = var.project
  role    = "roles/dataflow.admin"
  member  = "serviceAccount:${google_service_account.composer_service_account.email}"
}

resource "google_project_iam_member" "dataflow_worker_iam_member" {
  project = var.project
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.composer_service_account.email}"
}

resource "google_project_iam_member" "composer_worker_iam_member" {
  project = var.project
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer_service_account.email}"
}


resource "google_project_iam_member" "secret_manager_secret_accessor_iam_member" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.composer_service_account.email}"
}

resource "google_project_iam_member" "storage_admin_iam_member" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.composer_service_account.email}"
}

resource "google_project_iam_member" "composer_api_service_agent" {
  project = var.project
  role    = "roles/composer.ServiceAgentV2Ext"
  member  = "serviceAccount:${google_service_account.composer_service_account.email}"
}

###############################################################################################################
# Cloud Storage
###############################################################################################################

# Add a new resource block for the main environment particularly for the Composer environment
resource "google_storage_bucket" "ecr_bucket_main" {
  name     = "${var.composer-environment-name}-bucket-main"
  location = var.region

  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 7
    }
  }
}

# Add a new resource block for the temp bucket particularly for the Dataproc cluster
resource "google_storage_bucket" "ecr_bucket_dataproc_temp" {
  name     = "${var.composer-environment-name}-bucket-dataproc-temp"
  location = var.location

  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 1
    }
  }
}

# Add a new resource block for the stage bucket particularly for the Dataproc cluster
resource "google_storage_bucket" "ecr_bucket_dataproc_stage" {
  name     = "${var.composer-environment-name}-bucket-dataproc-stage"
  location = var.location

  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 7
    }
  }
}


###############################################################################################################
# Cloud Composer
###############################################################################################################

# Add the Composer environment
resource "google_composer_environment" "composer_environment" {
  name   = var.composer-environment-name
  region = var.region
  config {
    environment_size = var.composer-environment-size
    node_config {
      service_account = google_service_account.composer_service_account.name
    }
    software_config {
      image_version = var.composer-environment-version
    }
  }
  storage_config {
    bucket = google_storage_bucket.ecr_bucket_main.name
  }
}
###############################################################################################################
# Dataproc
###############################################################################################################

# Add the Dataproc cluster
resource "google_dataproc_cluster" "dataproc_cluster" {
  name   = "${var.composer-environment-name}-cluster"
  region = var.region
  cluster_config {
    staging_bucket = google_storage_bucket.ecr_bucket_dataproc_stage.name
    temp_bucket    = google_storage_bucket.ecr_bucket_dataproc_temp.name
    master_config {
      num_instances = 1
      machine_type  = var.dataproc-cluster-machine-type
    }
    worker_config {
      num_instances = var.dataproc-cluster-worker-count
      machine_type  = var.dataproc-cluster-machine-type
    }
    gce_cluster_config {
      service_account = google_service_account.composer_service_account.email
      service_account_scopes = [
        "cloud-platform"
      ]
    }
  }
}


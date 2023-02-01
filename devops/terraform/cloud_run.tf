// -----------------------------------------------------------------
// ---- Cloud RUN
// -----------------------------------------------------------------

resource "google_cloud_run_service" "dbt_cloudrun_svc" {
  name     = "${var.zone}-${var.env}-dbt-app"
  project  = var.app_project_id
  location = var.zone
  template {
    spec {
      containers {
        image = var.dbt_image
        env {
          name  = "GCP_PROJECT_APP"
          value = var.app_project_id
        }
        env {
          name  = "ENV"
          value = var.env
        }
      }
      service_account_name = google_service_account.dbt_cloud_run_sa.email
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_project_iam_member" "cloudrun_bq_dataeditor" {
  project = var.app_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dbt_cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloudrun_bq_jobuser" {
  project = var.app_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.dbt_cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloudrun_logging_writer" {
  project = var.app_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.dbt_cloud_run_sa.email}"
}

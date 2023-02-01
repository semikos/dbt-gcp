// -----------------------------------------------------------------
// ---- Cloud Build trigger for dbt CI
// -----------------------------------------------------------------

resource "google_cloudbuild_trigger" "dbt_cloudbuild_ci_trigger" {
  project     = var.app_project_id
  name        = "dbt-cloudbuild-ci-trigger"
  description = "For runing CI process of dbt app"
  disabled    = false
  github {
    owner = "mohameddhaoui"
    name  = "*******"
    push {
      branch       = ".*"
      invert_regex = false
    }
  }
  substitutions = {
    _GCP_PROJECT_APP       = var.app_project_id
    _ENVIRONMENT           = var.env
    _ARTIFACT_REGISTRY_URL = "${var.region}-docker.pkg.dev/${var.app_project_id}/${google_artifact_registry_repository.artifact_repository.name}" # TO BE SET DYNAMICALLY.

  }
  filename = "devops/ci.cloudbuild.yaml"
}

resource "google_project_iam_member" "cloudbuild_bq_dataeditor" {
  project = var.sdx_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${var.app_project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_bq_jobuser" {
  project = var.sdx_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${var.app_project_number}@cloudbuild.gserviceaccount.com"
}

// -----------------------------------------------------------------
// ---- Cloud Build trigger for dbt CD
// -----------------------------------------------------------------

resource "google_cloudbuild_trigger" "dbt_cloudbuild_cd_trigger" {
  project     = var.app_project_id
  name        = "dbt-cloudbuild-cd-trigger"
  description = "For runing CD process of dbt app"
  disabled    = true
  github {
    owner = "mohameddhaoui"
    name  = "********"
    push {
      branch       = ".*"
      invert_regex = false
    }
  }
  substitutions = {
    _GCP_PROJECT_APP       = var.app_project_id
    _ENVIRONMENT           = var.env
    _ARTIFACT_REGISTRY_URL = "${var.region}-docker.pkg.dev/${var.app_project_id}/${google_artifact_registry_repository.artifact_repository.name}"
    _BUILD_DIR             = "devops/terraform"
    _TF_ENVIRONMENT        = var.env
    _CDB_ARTIFACTS_BUCKET  = var.app_terraform_state_bucket
    _TERRAFORM_VERSION     = "1.0.6"
  }
  filename = "devops/cd.cloudbuild.yaml"
}

locals {
  app_code = "dbt-gcp"
}

// -----------------------------------------------------------------
// ---- Activate APIs
// -----------------------------------------------------------------
resource "google_project_service" "project_apis" {
  for_each           = var.activate_apis
  project            = var.app_project_id
  service            = each.value
  disable_on_destroy = false
}

// -----------------------------------------------------------------
// ---- Service account
// -----------------------------------------------------------------
resource "google_service_account" "dbt_cloud_run_sa" {
  account_id = "${local.app_code}-${var.env}-cloudrun-sa"
  project    = var.app_project_id
}

// ---------------------------------------------------------------
// ---- Artifact registry
// ---------------------------------------------------------------

resource "google_artifact_registry_repository" "artifact_repository" {
  provider      = google-beta
  project       = var.app_project_id
  location      = var.region
  repository_id = "dbt-registry"
  description   = "Artifact registry for dbt app containers."
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "cloudbuild_artifact_repository_reader" {
  provider   = google-beta
  project    = var.app_project_id
  location   = google_artifact_registry_repository.artifact_repository.location
  repository = google_artifact_registry_repository.artifact_repository.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.app_project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_artifact_registry_repository_iam_member" "cloudbuild_artifact_repository_writer" {
  provider   = google-beta
  project    = var.app_project_id
  location   = google_artifact_registry_repository.artifact_repository.location
  repository = google_artifact_registry_repository.artifact_repository.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.app_project_number}@cloudbuild.gserviceaccount.com"
}

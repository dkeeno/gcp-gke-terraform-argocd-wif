# Dedicated SA for cluster nodes — least privilege (no editor / owner).
resource "google_service_account" "node" {
  account_id   = "${local.cluster_name}-node"
  display_name = "${local.cluster_name} GKE node SA"
}

resource "google_project_iam_member" "node_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.node.email}"
}

resource "google_project_iam_member" "node_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.node.email}"
}

resource "google_project_iam_member" "node_metadata" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.node.email}"
}

resource "google_project_iam_member" "node_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.node.email}"
}

# Dedicated SA for GitLab CI — keyless, used only via WIF.
resource "google_service_account" "gitlab_ci" {
  account_id   = "${local.cluster_name}-gitlab-ci"
  display_name = "${local.cluster_name} GitLab CI SA (WIF only — no JSON keys)"
}

# Permissions the GitLab CI SA needs to deploy to the cluster.
resource "google_project_iam_member" "gitlab_ci_gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.gitlab_ci.email}"
}

resource "google_project_iam_member" "gitlab_ci_artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.gitlab_ci.email}"
}

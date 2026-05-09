# Workload Identity Federation — keyless GitLab CI authentication.
#
# Flow:
#   1. GitLab issues a short-lived OIDC token (id_token) inside each CI job
#   2. CI calls GCP STS, presenting the OIDC token
#   3. STS verifies the token against THIS provider, applies the attribute
#      condition, and returns a short-lived GCP access token impersonating
#      the bound service account
#   4. CI uses that access token for `gcloud` / `kubectl` / `terraform`
#
# No service-account JSON keys exist anywhere in this flow.

resource "google_iam_workload_identity_pool" "gitlab" {
  workload_identity_pool_id = "${local.cluster_name}-gitlab-pool"
  display_name              = "GitLab WIF Pool (${local.cluster_name})"
  description               = "Federated identity pool for GitLab CI keyless auth"
}

resource "google_iam_workload_identity_pool_provider" "gitlab" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.gitlab.workload_identity_pool_id
  workload_identity_pool_provider_id = "gitlab-provider"
  display_name                       = "GitLab OIDC Provider"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.gitlab_namespace" = "assertion.namespace_path"
    "attribute.gitlab_project"   = "assertion.project_path"
    "attribute.gitlab_ref"       = "assertion.ref"
    "attribute.gitlab_ref_type"  = "assertion.ref_type"
  }

  # Only allow tokens issued by GitLab for projects in our namespace AND
  # (if specified) only the named project. This is the security-critical
  # check — without it, anyone with a GitLab account could impersonate.
  attribute_condition = var.gitlab_project_path != "" ? (
    "attribute.gitlab_namespace == \"${var.gitlab_namespace}\" && attribute.gitlab_project == \"${var.gitlab_project_path}\""
    ) : (
    "attribute.gitlab_namespace == \"${var.gitlab_namespace}\""
  )

  oidc {
    issuer_uri = var.gitlab_url
  }
}

# Allow the federated principal (GitLab CI) to impersonate the gitlab_ci SA.
resource "google_service_account_iam_member" "gitlab_ci_wif_binding" {
  service_account_id = google_service_account.gitlab_ci.name
  role               = "roles/iam.workloadIdentityUser"

  member = var.gitlab_project_path != "" ? (
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gitlab.name}/attribute.gitlab_project/${var.gitlab_project_path}"
    ) : (
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gitlab.name}/attribute.gitlab_namespace/${var.gitlab_namespace}"
  )
}

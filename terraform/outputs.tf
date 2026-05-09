output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "GKE control-plane endpoint."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}

output "node_service_account_email" {
  value = google_service_account.node.email
}

output "gitlab_ci_sa_email" {
  description = "Service account that GitLab CI impersonates via WIF. Set this as GCP_SERVICE_ACCOUNT in your CI variables."
  value       = google_service_account.gitlab_ci.email
}

output "wif_provider_name" {
  description = "Full WIF provider resource name. Set this as GCP_WORKLOAD_IDENTITY_PROVIDER in your CI variables."
  value       = "projects/${data.google_client_config.default.project}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.gitlab.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.gitlab.workload_identity_pool_provider_id}"
}

output "argocd_namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}

output "kubeconfig_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.this.name} --region ${var.region} --project ${var.project_id}"
}

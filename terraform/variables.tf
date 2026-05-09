variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region for the regional GKE cluster."
  type        = string
  default     = "europe-west1"
}

variable "project_name" {
  description = "Short project name — used in resource names."
  type        = string
  default     = "demo-gke"
}

variable "environment" {
  description = "Environment (dev / staging / prod)."
  type        = string
  default     = "dev"
}

variable "subnet_cidr" {
  description = "Primary CIDR for the cluster subnet."
  type        = string
  default     = "10.20.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary range CIDR for Pod IPs."
  type        = string
  default     = "10.30.0.0/14"
}

variable "services_cidr" {
  description = "Secondary range CIDR for Service IPs."
  type        = string
  default     = "10.40.0.0/20"
}

variable "master_cidr" {
  description = "CIDR for the GKE control plane VPC peering range."
  type        = string
  default     = "172.16.0.0/28"
}

variable "node_machine_type" {
  description = "Machine type for the node pool."
  type        = string
  default     = "e2-medium"
}

variable "node_count_per_zone" {
  description = "Number of nodes per zone (regional cluster spans 3 zones)."
  type        = number
  default     = 1
}

variable "kubernetes_version" {
  description = "GKE Kubernetes version."
  type        = string
  default     = "1.30"
}

# Workload Identity Federation — GitLab integration

variable "gitlab_url" {
  description = "Your GitLab instance URL (almost always https://gitlab.com)."
  type        = string
  default     = "https://gitlab.com"
}

variable "gitlab_namespace" {
  description = "GitLab top-level group (e.g. 'my-org') allowed to authenticate via WIF."
  type        = string
  default     = "my-org"
}

variable "gitlab_project_path" {
  description = "Optional: restrict WIF to a specific GitLab project path (e.g. 'my-org/my-repo'). If empty, the whole namespace is allowed."
  type        = string
  default     = ""
}

resource "google_container_cluster" "this" {
  name     = local.cluster_name
  location = var.region

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  # Regional cluster: control plane HA across 3 zones, nodes too.
  # Remove the default node pool — we'll create a dedicated managed pool.
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "STABLE"
  }

  # Private cluster: nodes have NO public IPs; control plane reachable only
  # from authorized networks or via VPC peering.
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # set true if you only ever access via IAP
    master_ipv4_cidr_block  = var.master_cidr
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Workload Identity for in-cluster pod → GCP SA mapping (separate from WIF
  # which is for external GitLab CI → GCP SA mapping).
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  master_authorized_networks_config {
    cidr_blocks {
      # Open to anywhere by default for the demo. Lock down to your office /
      # CI runner CIDR in real use.
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  }

  resource_labels = local.common_labels

  deletion_protection = false # demo; set true in prod
}

resource "google_container_node_pool" "default" {
  name     = "default"
  cluster  = google_container_cluster.this.id
  location = var.region

  node_count = var.node_count_per_zone

  node_config {
    machine_type    = var.node_machine_type
    disk_size_gb    = 50
    disk_type       = "pd-standard"
    service_account = google_service_account.node.email

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = local.common_labels
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

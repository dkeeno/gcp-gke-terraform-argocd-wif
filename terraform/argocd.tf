resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [google_container_node_pool.default]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.3.0"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Sensible defaults for a demo. In real use, override with a values.yaml:
  # - server.ingress.* for an actual ingress
  # - controller.metrics.enabled for Prometheus scrape
  # - configs.repositories for non-public repo auth
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "configs.params.\"server\\.insecure\""
    value = "true"
  }

  # Faster reconciliation in dev:
  set {
    name  = "controller.args.appResyncPeriod"
    value = "60"
  }
}

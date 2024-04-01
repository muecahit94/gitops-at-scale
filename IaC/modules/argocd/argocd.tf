resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.argocd_namespace

  timeout         = 300
  cleanup_on_fail = true
  max_history     = 10
  wait            = true
  force_update    = true
  recreate_pods   = true

  values = [
    templatefile("${path.module}/templates/values.yaml.tpl", {
      argocd_cm_create             = true
      argocd_server_admin_enabled  = true
      argocd_server_host           = var.host
      cluster_credentials          = var.cluster_credentials
      argocd_server_admin_password = var.argocd_server_admin_password
    })
  ]

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  depends_on = [kubernetes_namespace.argocd]
}
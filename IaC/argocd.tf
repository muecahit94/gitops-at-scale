module "argocd" {
  source                       = "./modules/argocd"
  argocd_namespace             = "argocd"
  host                         = local.argocd_host
  argocd_server_admin_password = var.argocd_admin_password

  providers = {
    helm = helm
  }

  cluster_credentials = {
    for cluster in kind_cluster.stages : cluster.name => {
      stage                  = cluster.name
      server                 = cluster.endpoint
      client_certificate     = base64encode(cluster.client_certificate)
      client_key             = base64encode(cluster.client_key)
      cluster_ca_certificate = base64encode(cluster.cluster_ca_certificate)
      insecure               = false
    }
  }

  depends_on = [kind_cluster.mgt, kind_cluster.stages]
}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.mgt.endpoint
    client_certificate     = kind_cluster.mgt.client_certificate
    client_key             = kind_cluster.mgt.client_key
    cluster_ca_certificate = kind_cluster.mgt.cluster_ca_certificate
  }
}

provider "kubernetes" {
  host                   = kind_cluster.mgt.endpoint
  client_certificate     = kind_cluster.mgt.client_certificate
  client_key             = kind_cluster.mgt.client_key
  cluster_ca_certificate = kind_cluster.mgt.cluster_ca_certificate
}

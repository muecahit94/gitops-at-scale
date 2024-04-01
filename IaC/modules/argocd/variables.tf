variable "host" {
  description = "AKS Host url with https:// and port"
  type        = string
}

variable "argocd_namespace" {
  description = "Name of the argocd namespace"
  type        = string
}

variable "argocd_server_admin_password" {
  description = "argocd server admin password"
  type        = string
}

variable "cluster_credentials" {
  description = "the projects e.g.: dev each stage has one cluster which needs to be accessible from argocd"
  type = map(
    object({
      stage                  = string
      server                 = string
      client_certificate     = string
      client_key             = string
      cluster_ca_certificate = string
      insecure               = bool
  }))
}

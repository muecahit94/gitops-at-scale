variable "host_ip_address" {
  description = "your host ip address"
  type        = string
}

variable "argocd_admin_password" {
  description = "argocd admin password (bcrypt hashed)" # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml#L528
  type        = string
}

variable "stage_count" {
  description = "number of stages"
  type        = number
}
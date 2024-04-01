# azure_kubernetes_cluster_argocd

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.9.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >=2.18.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >=2.18.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.argocd_apps](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.cert_wildcard_mike_railcargo_com](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_azure_auth_client_id"></a> [argocd\_azure\_auth\_client\_id](#input\_argocd\_azure\_auth\_client\_id) | Client ID for the argocd azure auth | `string` | n/a | yes |
| <a name="input_argocd_azure_auth_policies"></a> [argocd\_azure\_auth\_policies](#input\_argocd\_azure\_auth\_policies) | policy for argocd azure auth example: https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml#L273 | <pre>object({<br>    policy_default = string<br>    policy_csv     = list(string)<br>    scopes         = string<br>  })</pre> | <pre>{<br>  "policy_csv": [<br>    "p, role:org-admin, applications, *, */*, allow",<br>    "p, role:org-admin, clusters, get, *, allow",<br>    "p, role:org-admin, repositories, *, *, allow",<br>    "p, role:org-admin, logs, get, *, allow",<br>    "p, role:org-admin, exec, create, */*, allow",<br>    "g, azure-group-id, role:org-admin"<br>  ],<br>  "policy_default": "",<br>  "scopes": "[groups, email]"<br>}</pre> | no |
| <a name="input_argocd_azure_auth_tenant_id"></a> [argocd\_azure\_auth\_tenant\_id](#input\_argocd\_azure\_auth\_tenant\_id) | Tenant ID for the argocd azure auth | `string` | n/a | yes |
| <a name="input_argocd_kv_tls_certificate"></a> [argocd\_kv\_tls\_certificate](#input\_argocd\_kv\_tls\_certificate) | The keyvaultname and certificatename for the TLS cert | <pre>object({<br>    keyvault_name = string<br>    cert_name     = string<br>  })</pre> | n/a | yes |
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | Name of the argocd namespace | `string` | n/a | yes |
| <a name="input_argocd_projects"></a> [argocd\_projects](#input\_argocd\_projects) | initial argocd projects | <pre>map(object({<br>    name                  = string<br>    additionalLabels      = map(string)<br>    additionalAnnotations = map(string)<br>    description           = string<br>    files                 = list(string)<br>    finalizers            = list(string)<br>    destinations = list(object({<br>      server = string<br>      name   = string<br>    }))<br>    clusterResourceWhitelist = list(object({<br>      group = string<br>      kind  = string<br>    }))<br>    clusterResourceBlacklist = list(object({<br>      group = string<br>      kind  = string<br>    }))<br>    namespaceResourceBlacklist = list(object({<br>      group = string<br>      kind  = string<br>    }))<br>    namespaceResourceWhitelist = list(object({<br>      group = string<br>      kind  = string<br>    }))<br>    sourceRepos = list(string)<br>  }))</pre> | <pre>{<br>  "devops": {<br>    "additionalAnnotations": {},<br>    "additionalLabels": {},<br>    "azureLoginClientId": "3d484be1-52ec-45c9-bb03-ddb5494e0fdb",<br>    "azureLoginTenantId": "085c0b65-6a84-4006-851e-5faa7ec5367e",<br>    "clusterResourceBlacklist": [],<br>    "clusterResourceWhitelist": [<br>      {<br>        "group": "*",<br>        "kind": "*"<br>      }<br>    ],<br>    "description": "",<br>    "destinations": [<br>      {<br>        "name": "in-cluster",<br>        "server": "https://kubernetes.default.svc"<br>      }<br>    ],<br>    "files": [<br>      "mik/**/*.yaml",<br>      "mce/**/*.yaml",<br>      "mmg/**/*.yaml"<br>    ],<br>    "finalizers": [<br>      "resources-finalizer.argocd.argoproj.io"<br>    ],<br>    "name": "devops",<br>    "namespaceResourceBlacklist": [],<br>    "namespaceResourceWhitelist": [<br>      {<br>        "group": "*",<br>        "kind": "*"<br>      }<br>    ],<br>    "sourceRepos": [<br>      "https://dev.azure.com/BCC-IKT-Plattformen-4-RCG/Cargo1492/_git/mike-architecture-argocd-projects"<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_azure_devops_https_repository_pat"></a> [azure\_devops\_https\_repository\_pat](#input\_azure\_devops\_https\_repository\_pat) | pat for the default password connection from argocd to azure devops | `string` | n/a | yes |
| <a name="input_cluster_credentials"></a> [cluster\_credentials](#input\_cluster\_credentials) | the projects e.g.: mike-dev each stage has one cluster which needs to be accessible from argocd | <pre>map(<br>    object({<br>      stage                  = string<br>      server                 = string<br>      client_key             = string<br>      cluster_ca_certificate = string<br>      insecure               = bool<br>  }))</pre> | n/a | yes |
| <a name="input_host"></a> [host](#input\_host) | AKS Host url with https:// and port | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

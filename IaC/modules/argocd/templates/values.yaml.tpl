installCRDs: false

# -- Provide a name in place of `argocd`
nameOverride: argocd
# -- String to fully override `"argo-cd.fullname"`
fullnameOverride: ""
# -- Override the Kubernetes version, which is used to evaluate certain manifests
kubeVersionOverride: ""
# Override APIVersions
# If you want to template helm charts but cannot access k8s API server
# you can set api versions here
apiVersionOverrides:
  # -- String to override apiVersion of cert-manager resources rendered by this helm chart
  certmanager: "" # cert-manager.io/v1
  # -- String to override apiVersion of GKE resources rendered by this helm chart
  cloudgoogle: "" # cloud.google.com/v1
  # -- String to override apiVersion of autoscaling rendered by this helm chart
  autoscaling: "" # autoscaling/v2
  # -- String to override apiVersion of ingresses rendered by this helm chart
  ingress: "" # networking.k8s.io/v1beta1
  # -- String to override apiVersion of pod disruption budgets rendered by this helm chart
  pdb: "" # policy/v1

# -- Create clusterroles that extend existing clusterroles to interact with argo-cd crds
## Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles
createAggregateRoles: false

openshift:
  # -- enables using arbitrary uid for argo repo server
  enabled: false

## Custom resource configuration
crds:
  # -- Install and upgrade CRDs
  install: true
  # -- Keep CRDs on chart uninstall
  keep: true
  # -- Annotations to be added to all CRDs
  annotations: {}

## Globally shared configuration
global:
  # -- Common labels for the all resources
  additionalLabels: {}
    # app: argo-cd

  # -- Number of old deployment ReplicaSets to retain. The rest will be garbage collected.
  revisionHistoryLimit: 3

  # Default image used by all components
  image:
    # -- If defined, a repository applied to all Argo CD deployments
    repository: quay.io/argoproj/argocd
    # -- Overrides the global Argo CD image tag whose default is the chart appVersion
    tag: ""
    # -- If defined, a imagePullPolicy applied to all Argo CD deployments
    imagePullPolicy: IfNotPresent

  # -- Secrets with credentials to pull images from a private registry
  imagePullSecrets: []

  # Default logging options used by all components
  logging:
    # -- Set the global logging format. Either: `text` or `json`
    format: text
    # -- Set the global logging level. One of: `debug`, `info`, `warn` or `error`
    level: info

  # -- Annotations for the all deployed Statefulsets
  statefulsetAnnotations: {}

  # -- Annotations for the all deployed Deployments
  deploymentAnnotations: {}

  # -- Annotations for the all deployed pods
  podAnnotations: {}

  # -- Labels for the all deployed pods
  podLabels: {}

  # -- Toggle and define pod-level security context.
  # @default -- `{}` (See [values.yaml])
  securityContext: {}
  #  runAsUser: 999
  #  runAsGroup: 999
  #  fsGroup: 999

  # -- Mapping between IP and hostnames that will be injected as entries in the pod's hosts files
  hostAliases: []
  # - ip: 10.20.30.40
  #   hostnames:
  #   - git.myhostname

  networkPolicy:
    # -- Create NetworkPolicy objects for all components
    create: false
    # -- Default deny all ingress traffic
    defaultDenyIngress: false

## Argo Configs
configs:
  # General Argo CD configuration
  ## Ref: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/argocd-cm.yaml
  cm:
    # -- Create the argocd-cm configmap for [declarative setup]
    create: ${ argocd_cm_create }

    url: https://${ argocd_server_host }
    admin:
      enabled: ${ argocd_server_admin_enabled }


    # -- Annotations to be added to argocd-cm configmap
    annotations: {}

    # -- The name of tracking label used by Argo CD for resource pruning
    # @default -- Defaults to app.kubernetes.io/instance
    application.instanceLabelKey: argocd.argoproj.io/instance

    # -- Enable logs RBAC enforcement
    ## Ref: https://argo-cd.readthedocs.io/en/latest/operator-manual/upgrading/2.3-2.4/#enable-logs-rbac-enforcement
    server.rbac.log.enforce.enable: false

    # -- Enable exec feature in Argo UI
    ## Ref: https://argo-cd.readthedocs.io/en/latest/operator-manual/rbac/#exec-resource
    exec.enabled: false

    # -- Enable local admin user
    ## Ref: https://argo-cd.readthedocs.io/en/latest/faq/#how-to-disable-admin-user
    admin.enabled: ${ argocd_server_admin_enabled }

    # -- Timeout to discover if a new manifests version got published to the repository
    timeout.reconciliation: 180s

    # -- Timeout to refresh application data as well as target manifests cache
    timeout.hard.reconciliation: 0s

    # Dex configuration
    # dex.config: |
    #   connectors:
    #     # GitHub example
    #     - type: github
    #       id: github
    #       name: GitHub
    #       config:
    #         clientID: aabbccddeeff00112233
    #         clientSecret: $dex.github.clientSecret # Alternatively $<some_K8S_secret>:dex.github.clientSecret
    #         orgs:
    #         - name: your-github-org

    # OIDC configuration as an alternative to dex (optional).
    # the secret for clientSecret needs to be created https://github.com/argoproj/argo-cd/issues/4188#issuecomment-1071580832, format: $secretname:key-from-secret
    # oidc.config:
    #   rootCA: |
    #     -----BEGIN CERTIFICATE-----
    #     ... encoded certificate data here ...
    #     -----END CERTIFICATE-----


  # Argo CD configuration parameters
  ## Ref: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/argocd-cmd-params-cm.yaml
  params:
    # -- Annotations to be added to the argocd-cmd-params-cm ConfigMap
    annotations: {}

    ## Generic parameters
    # -- Open-Telemetry collector address: (e.g. "otel-collector:4317")
    otlp.address: ''

    ## Controller Properties
    # -- Number of application status processors
    controller.status.processors: 20
    # -- Number of application operation processors
    controller.operation.processors: 10
    # -- Specifies timeout between application self heal attempts
    controller.self.heal.timeout.seconds: 5
    # -- Repo server RPC call timeout seconds.
    controller.repo.server.timeout.seconds: 60

    ## Server properties
    # -- Run server without TLS
    server.insecure: true
    # -- Value for base href in index.html. Used if Argo CD is running behind reverse proxy under subpath different from /
    server.basehref: /
    # -- Used if Argo CD is running behind reverse proxy under subpath different from /
    server.rootpath: ''
    # -- Directory path that contains additional static assets
    server.staticassets: /shared/app
    # -- Disable Argo CD RBAC for user authentication
    server.disable.auth: false
    # -- Enable GZIP compression
    server.enable.gzip: false
    # -- Set X-Frame-Options header in HTTP responses to value. To disable, set to "".
    server.x.frame.options: sameorigin

    ## Repo-server properties
    # -- Limit on number of concurrent manifests generate requests. Any value less the 1 means no limit.
    reposerver.parallelism.limit: 0

  # Argo CD RBAC policy configuration
  ## Ref: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/rbac.md
  rbac:
    # -- Create the argocd-rbac-cm configmap with ([Argo CD RBAC policy]) definitions.
    # If false, it is expected the configmap will be created by something else.
    # Argo CD will not work if there is no configmap created with the name above.
    create: true

    # -- Annotations to be added to argocd-rbac-cm configmap
    annotations: {}

    # -- The name of the default role which Argo CD will falls back to, when authorizing API requests (optional).
    # If omitted or empty, users may be still be able to login, but will see no apps, projects, etc...

    # -- File containing user-defined policies and role definitions.
    # @default -- `''` (See [values.yaml])
    #policy.csv: ''
    # Policy rules are in the form:
    #  p, subject, resource, action, object, effect
    # Role definitions and bindings are in the form:
    #  g, subject, inherited-subject

    # -- OIDC scopes to examine during rbac enforcement (in addition to `sub` scope).
    # The scope value can be a string, or a list of strings.

  # GnuPG public keys for commit verification
  ## Ref: https://argo-cd.readthedocs.io/en/stable/user-guide/gpg-verification/
  gpg:
    # -- Annotations to be added to argocd-gpg-keys-cm configmap
    annotations: {}

    # -- [GnuPG] public keys to add to the keyring
    # @default -- `{}` (See [values.yaml])
    ## Note: Public keys should be exported with `gpg --export --armor <KEY>`
    keys: {}
      # 4AEE18F83AFDEB23: |
      #   -----BEGIN PGP PUBLIC KEY BLOCK-----
      #   ...
      #   -----END PGP PUBLIC KEY BLOCK-----


  # -- Provide one or multiple [external cluster credentials]
  # @default -- `[]` (See [values.yaml])
  ## Ref:
  ## - https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#clusters
  ## - https://argo-cd.readthedocs.io/en/stable/operator-manual/security/#external-cluster-credentials
  clusterCredentials:
%{ for key, value in cluster_credentials ~}
    - name: ${key}
      server: ${value.server}
      labels:
        domain: ${key}
        stage: ${value.stage}
      annotations: {}
      config:
        tlsClientConfig:
          insecure: ${value.insecure}
          caData: ${value.cluster_ca_certificate}
          certData: ${value.client_certificate}
          keyData: ${value.client_key}
%{ endfor ~}
    # - name: mycluster
    #   server: https://mycluster.com
    #   labels: {}
    #   annotations: {}
    #   config:
    #     bearerToken: ""
    #     tlsClientConfig:
    #       insecure: false
    #       caData: ""
    # - name: mycluster2
    #   server: https://mycluster2.com
    #   labels: {}
    #   annotations: {}
    #   namespaces: namespace1,namespace2
    #   clusterResources: true
    #   config:
    #     bearerToken: "<authentication token>"
    #     tlsClientConfig:
    #       insecure: false
    #       caData: "<base64 encoded certificate>"

  # -- Known Hosts configmap annotations
  knownHostsAnnotations: {}
  knownHosts:
    data:
      # -- Known Hosts
      # @default -- See [values.yaml]
      ssh_known_hosts: |
        ssh.dev.azure.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7Hr1oTWqNqOlzGJOfGJ4NakVyIzf1rXYd4d7wo6jBlkLvCA4odBlL0mDUyZ0/QUfTTqeu+tm22gOsv+VrVTMk6vwRU75gY/y9ut5Mb3bR5BV58dKXyq9A9UeB5Cakehn5Zgm6x1mKoVyf+FFn26iYqXJRgzIZZcZ5V6hrE0Qg39kZm4az48o0AUbf6Sp4SLdvnuMa2sVNwHBboS7EJkm57XQPVU3/QpyNLHbWDdzwtrlS+ez30S3AdYhLKEOxAG8weOnyrtLJAUen9mTkol8oII1edf7mWWbWVf0nBmly21+nZcmCTISQBtdcyPaEno7fFQMDD26/s0lfKob4Kw8H
        vs-ssh.visualstudio.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7Hr1oTWqNqOlzGJOfGJ4NakVyIzf1rXYd4d7wo6jBlkLvCA4odBlL0mDUyZ0/QUfTTqeu+tm22gOsv+VrVTMk6vwRU75gY/y9ut5Mb3bR5BV58dKXyq9A9UeB5Cakehn5Zgm6x1mKoVyf+FFn26iYqXJRgzIZZcZ5V6hrE0Qg39kZm4az48o0AUbf6Sp4SLdvnuMa2sVNwHBboS7EJkm57XQPVU3/QpyNLHbWDdzwtrlS+ez30S3AdYhLKEOxAG8weOnyrtLJAUen9mTkol8oII1edf7mWWbWVf0nBmly21+nZcmCTISQBtdcyPaEno7fFQMDD26/s0lfKob4Kw8H
  # -- TLS certificate configmap annotations
  tlsCertsAnnotations: {}
  # -- TLS certificate
  # @default -- See [values.yaml]
  tlsCerts:
    {}
    # data:
    #   argocd.example.com: |
    #     -----BEGIN CERTIFICATE-----
    #     MIIF1zCCA7+gAwIBAgIUQdTcSHY2Sxd3Tq/v1eIEZPCNbOowDQYJKoZIhvcNAQEL
    #     BQAwezELMAkGA1UEBhMCREUxFTATBgNVBAgMDExvd2VyIFNheG9ueTEQMA4GA1UE
    #     BwwHSGFub3ZlcjEVMBMGA1UECgwMVGVzdGluZyBDb3JwMRIwEAYDVQQLDAlUZXN0
    #     c3VpdGUxGDAWBgNVBAMMD2Jhci5leGFtcGxlLmNvbTAeFw0xOTA3MDgxMzU2MTda
    #     Fw0yMDA3MDcxMzU2MTdaMHsxCzAJBgNVBAYTAkRFMRUwEwYDVQQIDAxMb3dlciBT
    #     YXhvbnkxEDAOBgNVBAcMB0hhbm92ZXIxFTATBgNVBAoMDFRlc3RpbmcgQ29ycDES
    #     MBAGA1UECwwJVGVzdHN1aXRlMRgwFgYDVQQDDA9iYXIuZXhhbXBsZS5jb20wggIi
    #     MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCv4mHMdVUcafmaSHVpUM0zZWp5
    #     NFXfboxA4inuOkE8kZlbGSe7wiG9WqLirdr39Ts+WSAFA6oANvbzlu3JrEQ2CHPc
    #     CNQm6diPREFwcDPFCe/eMawbwkQAPVSHPts0UoRxnpZox5pn69ghncBR+jtvx+/u
    #     P6HdwW0qqTvfJnfAF1hBJ4oIk2AXiip5kkIznsAh9W6WRy6nTVCeetmIepDOGe0G
    #     ZJIRn/OfSz7NzKylfDCat2z3EAutyeT/5oXZoWOmGg/8T7pn/pR588GoYYKRQnp+
    #     YilqCPFX+az09EqqK/iHXnkdZ/Z2fCuU+9M/Zhrnlwlygl3RuVBI6xhm/ZsXtL2E
    #     Gxa61lNy6pyx5+hSxHEFEJshXLtioRd702VdLKxEOuYSXKeJDs1x9o6cJ75S6hko
    #     Ml1L4zCU+xEsMcvb1iQ2n7PZdacqhkFRUVVVmJ56th8aYyX7KNX6M9CD+kMpNm6J
    #     kKC1li/Iy+RI138bAvaFplajMF551kt44dSvIoJIbTr1LigudzWPqk31QaZXV/4u
    #     kD1n4p/XMc9HYU/was/CmQBFqmIZedTLTtK7clkuFN6wbwzdo1wmUNgnySQuMacO
    #     gxhHxxzRWxd24uLyk9Px+9U3BfVPaRLiOPaPoC58lyVOykjSgfpgbus7JS69fCq7
    #     bEH4Jatp/10zkco+UQIDAQABo1MwUTAdBgNVHQ4EFgQUjXH6PHi92y4C4hQpey86
    #     r6+x1ewwHwYDVR0jBBgwFoAUjXH6PHi92y4C4hQpey86r6+x1ewwDwYDVR0TAQH/
    #     BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAgEAFE4SdKsX9UsLy+Z0xuHSxhTd0jfn
    #     Iih5mtzb8CDNO5oTw4z0aMeAvpsUvjJ/XjgxnkiRACXh7K9hsG2r+ageRWGevyvx
    #     CaRXFbherV1kTnZw4Y9/pgZTYVWs9jlqFOppz5sStkfjsDQ5lmPJGDii/StENAz2
    #     XmtiPOgfG9Upb0GAJBCuKnrU9bIcT4L20gd2F4Y14ccyjlf8UiUi192IX6yM9OjT
    #     +TuXwZgqnTOq6piVgr+FTSa24qSvaXb5z/mJDLlk23npecTouLg83TNSn3R6fYQr
    #     d/Y9eXuUJ8U7/qTh2Ulz071AO9KzPOmleYPTx4Xty4xAtWi1QE5NHW9/Ajlv5OtO
    #     OnMNWIs7ssDJBsB7VFC8hcwf79jz7kC0xmQqDfw51Xhhk04kla+v+HZcFW2AO9so
    #     6ZdVHHQnIbJa7yQJKZ+hK49IOoBR6JgdB5kymoplLLiuqZSYTcwSBZ72FYTm3iAr
    #     jzvt1hxpxVDmXvRnkhRrIRhK4QgJL0jRmirBjDY+PYYd7bdRIjN7WNZLFsgplnS8
    #     9w6CwG32pRlm0c8kkiQ7FXA6BYCqOsDI8f1VGQv331OpR2Ck+FTv+L7DAmg6l37W
    #     +LB9LGh4OAp68ImTjqf6ioGKG0RBSznwME+r4nXtT1S/qLR6ASWUS4ViWRhbRlNK
    #     XWyb96wrUlv+E8I=
    #     -----END CERTIFICATE-----

  # -- Repository credentials to be used as Templates for other repos
  ## Creates a secret for each key/value specified below to create repository credentials
  # credentialTemplates:
  #   https-creds:
  #     url: ""
  #     password: ""
  #     username: ""

  credentialTemplatesAnnotations: {}

  # -- Repositories list to be used by applications
  ## Creates a secret for each key/value specified below to create repositories
  ## Note: the last example in the list would use a repository credential template, configured under "configs.repositoryCredentials".

    # istio-helm-repo:
    #   url: https://storage.googleapis.com/istio-prerelease/daily-build/master-latest-daily/charts
    #   name: istio.io
    #   type: helm
    # private-helm-repo:
    #   url: https://my-private-chart-repo.internal
    #   name: private-repo
    #   type: helm
    #   password: my-password
    #   username: my-username
    # private-repo:
    #   url: https://github.com/argoproj/private-repo

  # -- Annotations to be added to `configs.repositories` Secret
  repositoriesAnnotations: {}

  # Argo CD sensitive data
  # Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#sensitive-data-and-sso-client-secrets
  secret:
    # -- Create the argocd-secret
    createSecret: true
    # -- Annotations to be added to argocd-secret
    annotations: {}

    # -- Shared secret for authenticating GitHub webhook events
    githubSecret: ""
    # -- Shared secret for authenticating GitLab webhook events
    gitlabSecret: ""
    # -- Shared secret for authenticating BitbucketServer webhook events
    bitbucketServerSecret: ""
    # -- UUID for authenticating Bitbucket webhook events
    bitbucketUUID: ""
    # -- Shared secret for authenticating Gogs webhook events
    gogsSecret: ""

    # -- add additional secrets to be added to argocd-secret
    ## Custom secrets. Useful for injecting SSO secrets into environment variables.
    ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#sensitive-data-and-sso-client-secrets
    ## Note that all values must be non-empty.
    extra:
      {}
      # LDAP_PASSWORD: "mypassword"

    # -- Argo TLS Data
    # DEPRECATED - Use server.certificate or server.certificateSecret
    # argocdServerTlsConfig:
    #  key: ''
    #  crt: ''

    # -- Bcrypt hashed admin password
    ## Argo expects the password in the secret to be bcrypt hashed. You can create this hash with
    ## `htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/'`
    argocdServerAdminPassword: "${ argocd_server_admin_password }"
    # -- Admin password modification time. Eg. `"2006-01-02T15:04:05Z"`
    # @default -- `""` (defaults to current time)
    argocdServerAdminPasswordMtime: ""

  # -- Define custom [CSS styles] for your argo instance.
  # This setting will automatically mount the provided CSS and reference it in the argo configuration.
  # @default -- `""` (See [values.yaml])
  ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/custom-styles/
  styles: ""
  # styles: |
  #  .nav-bar {
  #    background: linear-gradient(to bottom, #999, #777, #333, #222, #111);
  #  }

# -- Array of extra K8s manifests to deploy
extraObjects: []
  # - apiVersion: secrets-store.csi.x-k8s.io/v1
  #   kind: SecretProviderClass
  #   metadata:
  #     name: argocd-secrets-store
  #   spec:
  #     provider: aws
  #     parameters:
  #       objects: |
  #         - objectName: "argocd"
  #           objectType: "secretsmanager"
  #           jmesPath:
  #               - path: "client_id"
  #                 objectAlias: "client_id"
  #               - path: "client_secret"
  #                 objectAlias: "client_secret"
  #     secretObjects:
  #     - data:
  #       - key: client_id
  #         objectName: client_id
  #       - key: client_secret
  #         objectName: client_secret
  #       secretName: argocd-secrets-store
  #       type: Opaque
  #       labels:
  #         app.kubernetes.io/part-of: argocd

## Application controller
controller:
  # -- Application controller name string
  name: application-controller

  # -- The number of application controller pods to run.
  # Additional replicas will cause sharding of managed clusters across number of replicas.
  replicas: 1

  ## Application controller Pod Disruption Budget
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  pdb:
    # -- Deploy a [PodDisruptionBudget] for the application controller
    enabled: false
    # -- Labels to be added to application controller pdb
    labels: {}
    # -- Annotations to be added to application controller pdb
    annotations: {}
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailble after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `controller.pdb.minAvailable`
    maxUnavailable: ""

  ## Application controller image
  image:
    # -- Repository to use for the application controller
    # @default -- `""` (defaults to global.image.repository)
    repository: ""
    # -- Tag to use for the application controller
    # @default -- `""` (defaults to global.image.tag)
    tag: ""
    # -- Image pull policy for the application controller
    # @default -- `""` (defaults to global.image.imagePullPolicy)
    imagePullPolicy: ""

  # -- Secrets with credentials to pull images from a private registry
  # @default -- `[]` (defaults to global.imagePullSecrets)
  imagePullSecrets: []

  # -- DEPRECATED - Application controller commandline flags
  args: {}
  # DEPRECATED - Use configs.params to override
  #  # -- define the application controller `--status-processors`
  #  statusProcessors: "20"
  #  # -- define the application controller `--operation-processors`
  #  operationProcessors: "10"
  #  # -- define the application controller `--app-hard-resync`
  #  appHardResyncPeriod: "0"
  #  # -- define the application controller `--app-resync`
  #  appResyncPeriod: "180"
  #  # -- define the application controller `--self-heal-timeout-seconds`
  #  selfHealTimeout: "5"
  #  # -- define the application controller `--repo-server-timeout-seconds`
  #  repoServerTimeoutSeconds: "60"

  # DEPRECATED - Use configs.params to override
  # -- Application controller log format. Either `text` or `json`
  # @default -- `""` (defaults to global.logging.format)
  # logFormat: ""
  # -- Application controller log level. One of: `debug`, `info`, `warn` or `error`
  # @default -- `""` (defaults to global.logging.level)
  # logLevel: ""

  # -- Additional command line arguments to pass to application controller
  extraArgs: []

  # -- Environment variables to pass to application controller
  env: []

  # -- envFrom to pass to application controller
  # @default -- `[]` (See [values.yaml])
  envFrom: []
  # - configMapRef:
  #     name: config-map-name
  # - secretRef:
  #     name: secret-name

  # -- Annotations for the application controller StatefulSet
  statefulsetAnnotations: {}

  # -- Annotations to be added to application controller pods
  podAnnotations: {}

  # -- Labels to be added to application controller pods
  podLabels: {}

  # -- Application controller container-level security context
  # @default -- See [values.yaml]
  containerSecurityContext:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL

  # -- Application controller listening port
  containerPort: 8082

  # Rediness probe for application controller
  ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
  readinessProbe:
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1

  # -- Additional volumeMounts to the application controller main container
  volumeMounts: []

  # -- Additional volumes to the application controller pod
  volumes: []

  # -- [Node selector]
  nodeSelector: {}

  # -- [Tolerations] for use with node taints
  tolerations: []

  # -- Assign custom [affinity] rules to the deployment
  affinity: {}

  # -- Assign custom [TopologySpreadConstraints] rules to the application controller
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
  ## If labelSelector is left out, it will default to the labelSelector configuration of the deployment
  topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: topology.kubernetes.io/zone
  #   whenUnsatisfiable: DoNotSchedule

  # -- Priority class for the application controller pods
  priorityClassName: ""

  # -- Resource limits and requests for the application controller pods
  resources: {}
  #  limits:
  #    cpu: 500m
  #    memory: 512Mi
  #  requests:
  #    cpu: 250m
  #    memory: 256Mi

  serviceAccount:
    # -- Create a service account for the application controller
    create: true
    # -- Service account name
    name: argocd-application-controller
    # -- Annotations applied to created service account
    annotations: {}
    # -- Labels applied to created service account
    labels: {}
    # -- Automount API credentials for the Service Account
    automountServiceAccountToken: true

  ## Application controller metrics configuration
  metrics:
    # -- Deploy metrics service
    enabled: false
    applicationLabels:
      # -- Enables additional labels in argocd_app_labels metric
      enabled: false
      # -- Additional labels
      labels: []
    service:
      # -- Metrics service annotations
      annotations: {}
      # -- Metrics service labels
      labels: {}
      # -- Metrics service port
      servicePort: 8082
      # -- Metrics service port name
      portName: http-metrics
    serviceMonitor:
      # -- Enable a prometheus ServiceMonitor
      enabled: false
      # -- Prometheus ServiceMonitor interval
      interval: 30s
      # -- Prometheus [RelabelConfigs] to apply to samples before scraping
      relabelings: []
      # -- Prometheus [MetricRelabelConfigs] to apply to samples before ingestion
      metricRelabelings: []
      # -- Prometheus ServiceMonitor selector
      selector: {}
        # prometheus: kube-prometheus

      # -- Prometheus ServiceMonitor scheme
      scheme: ""
      # -- Prometheus ServiceMonitor tlsConfig
      tlsConfig: {}
      # -- Prometheus ServiceMonitor namespace
      namespace: "" # "monitoring"
      # -- Prometheus ServiceMonitor labels
      additionalLabels: {}
      # -- Prometheus ServiceMonitor annotations
      annotations: {}
    rules:
      # -- Deploy a PrometheusRule for the application controller
      enabled: false
      # -- PrometheusRule.Spec for the application controller
      spec: []
      # - alert: ArgoAppMissing
      #   expr: |
      #     absent(argocd_app_info) == 1
      #   for: 15m
      #   labels:
      #     severity: critical
      #   annotations:
      #     summary: "[Argo CD] No reported applications"
      #     description: >
      #       Argo CD has not reported any applications data for the past 15 minutes which
      #       means that it must be down or not functioning properly.  This needs to be
      #       resolved for this cloud to continue to maintain state.
      # - alert: ArgoAppNotSynced
      #   expr: |
      #     argocd_app_info{sync_status!="Synced"} == 1
      #   for: 12h
      #   labels:
      #     severity: warning
      #   annotations:
      #     summary: "[{{`{{$labels.name}}`}}] Application not synchronized"
      #     description: >
      #       The application [{{`{{$labels.name}}`}} has not been synchronized for over
      #       12 hours which means that the state of this cloud has drifted away from the
      #       state inside Git.
    #   selector:
    #     prometheus: kube-prometheus
    #   namespace: monitoring
    #   additionalLabels: {}
    #   annotations: {}

  ## Enable if you would like to grant rights to Argo CD to deploy to the local Kubernetes cluster.
  clusterAdminAccess:
    # -- Enable RBAC for local cluster deployments
    enabled: true

  ## Enable this and set the rules: to whatever custom rules you want for the Cluster Role resource.
  ## Defaults to off
  clusterRoleRules:
    # -- Enable custom rules for the application controller's ClusterRole resource
    enabled: false
    # -- List of custom rules for the application controller's ClusterRole resource
    rules: []

  # -- Additional containers to be added to the application controller pod
  extraContainers: []

  # -- Init containers to add to the application controller pod
  ## If your target Kubernetes cluster(s) require a custom auth provider executable
  ## you could use this (and the same in the server pod) to bootstrap
  ## that executable into your Argo CD container
  initContainers: []
  #  - name: download-tools
  #    image: alpine:3.8
  #    command: [sh, -c]
  #    args:
  #      - wget -qO- https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz | tar -xvzf - &&
  #        mv linux-amd64/helm /custom-tools/
  #    volumeMounts:
  #      - mountPath: /custom-tools
  #        name: custom-tools
  #  volumeMounts:
  #  - mountPath: /usr/local/bin/helm
  #    name: custom-tools
  #    subPath: helm

## Dex
dex:
  # -- Enable dex
  enabled: true
  # -- Dex name
  name: dex-server

  # -- Additional command line arguments to pass to the Dex server
  extraArgs: []

  metrics:
    # -- Deploy metrics service
    enabled: false
    service:
      # -- Metrics service annotations
      annotations: {}
      # -- Metrics service labels
      labels: {}
      # -- Metrics service port name
      portName: http-metrics
    serviceMonitor:
      # -- Enable a prometheus ServiceMonitor
      enabled: false
      # -- Prometheus ServiceMonitor interval
      interval: 30s
      # -- Prometheus [RelabelConfigs] to apply to samples before scraping
      relabelings: []
      # -- Prometheus [MetricRelabelConfigs] to apply to samples before ingestion
      metricRelabelings: []
      # -- Prometheus ServiceMonitor selector
      selector: {}
        # prometheus: kube-prometheus

      # -- Prometheus ServiceMonitor scheme
      scheme: ""
      # -- Prometheus ServiceMonitor tlsConfig
      tlsConfig: {}
      # -- Prometheus ServiceMonitor namespace
      namespace: "" # "monitoring"
      # -- Prometheus ServiceMonitor labels
      additionalLabels: {}
      # -- Prometheus ServiceMonitor annotations
      annotations: {}

  ## Dex Pod Disruption Budget
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  pdb:
    # -- Deploy a [PodDisruptionBudget] for the Dex server
    enabled: false
    # -- Labels to be added to Dex server pdb
    labels: {}
    # -- Annotations to be added to Dex server pdb
    annotations: {}
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailble after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `dex.pdb.minAvailable`
    maxUnavailable: ""

  ## Dex image
  image:
    # -- Dex image repository
    repository: ghcr.io/dexidp/dex
    # -- Dex image tag
    tag: v2.35.3
    # -- Dex imagePullPolicy
    # @default -- `""` (defaults to global.image.imagePullPolicy)
    imagePullPolicy: ""

  # -- Secrets with credentials to pull images from a private registry
  # @default -- `[]` (defaults to global.imagePullSecrets)
  imagePullSecrets: []

  # Argo CD init image that creates Dex config
  initImage:
    # -- Argo CD init image repository
    # @default -- `""` (defaults to global.image.repository)
    repository: ""
    # -- Argo CD init image tag
    # @default -- `""` (defaults to global.image.tag)
    tag: ""
    # -- Argo CD init image imagePullPolicy
    # @default -- `""` (defaults to global.image.imagePullPolicy)
    imagePullPolicy: ""

  # -- Environment variables to pass to the Dex server
  env: []

  # -- envFrom to pass to the Dex server
  # @default -- `[]` (See [values.yaml])
  envFrom: []
  # - configMapRef:
  #     name: config-map-name
  # - secretRef:
  #     name: secret-name

  # TLS certificate configuration via Secret
  ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#configuring-tls-to-argocd-dex-server
  ## Note: Issuing certificates via cert-manager in not supported right now because it's not possible to restart Dex automatically without extra controllers.
  certificateSecret:
    # -- Create argocd-dex-server-tls secret
    enabled: false
    # -- Labels to be added to argocd-dex-server-tls secret
    labels: {}
    # -- Annotations to be added to argocd-dex-server-tls secret
    annotations: {}
    # -- Certificate authority. Required for self-signed certificates.
    ca: ''
    # -- Certificate private key
    key: ''
    # -- Certificate data. Must contain SANs of Dex service (ie: argocd-dex-server, argocd-dex-server.argo-cd.svc)
    crt: ''

  # -- Annotations to be added to the Dex server Deployment
  deploymentAnnotations: {}

  # -- Annotations to be added to the Dex server pods
  podAnnotations: {}

  # -- Labels to be added to the Dex server pods
  podLabels: {}

  # -- Dex container-level security context
  # @default -- See [values.yaml]
  containerSecurityContext:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL

  ## Probes for Dex server
  ## Supported from Dex >= 2.28.0
  livenessProbe:
    # -- Enable Kubernetes liveness probe for Dex >= 2.28.0
    enabled: false
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1
  readinessProbe:
    # -- Enable Kubernetes readiness probe for Dex >= 2.28.0
    enabled: false
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1

  serviceAccount:
    # -- Create dex service account
    create: true
    # -- Dex service account name
    name: argocd-dex-server
    # -- Annotations applied to created service account
    annotations: {}
    # -- Automount API credentials for the Service Account
    automountServiceAccountToken: true

  # -- Additional volumeMounts to the dex main container
  volumeMounts: []

  # -- Additional volumes to the dex pod
  volumes: []

  # -- Container port for HTTP access
  containerPortHttp: 5556
  # -- Service port for HTTP access
  servicePortHttp: 5556
  # -- Service port name for HTTP access
  servicePortHttpName: http
  # -- Container port for gRPC access
  containerPortGrpc: 5557
  # -- Service port for gRPC access
  servicePortGrpc: 5557
  # -- Service port name for gRPC access
  servicePortGrpcName: grpc
  # -- Container port for metrics access
  containerPortMetrics: 5558
  # -- Service port for metrics access
  servicePortMetrics: 5558

  # -- [Node selector]
  nodeSelector: {}
  # -- [Tolerations] for use with node taints
  tolerations: []
  # -- Assign custom [affinity] rules to the deployment
  affinity: {}

  # -- Assign custom [TopologySpreadConstraints] rules to dex
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
  ## If labelSelector is left out, it will default to the labelSelector configuration of the deployment
  topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: topology.kubernetes.io/zone
  #   whenUnsatisfiable: DoNotSchedule

  # -- Priority class for dex
  priorityClassName: ""

  # -- Resource limits and requests for dex
  resources: {}
  #  limits:
  #    cpu: 50m
  #    memory: 64Mi
  #  requests:
  #    cpu: 10m
  #    memory: 32Mi

  # -- Additional containers to be added to the dex pod
  extraContainers: []

  # -- Init containers to add to the dex pod
  initContainers: []
  #  - name: download-tools
  #    image: alpine:3.8
  #    command: [sh, -c]
  #    args:
  #      - wget -qO- https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz | tar -xvzf - &&
  #        mv linux-amd64/helm /custom-tools/
  #    volumeMounts:
  #      - mountPath: /custom-tools
  #        name: custom-tools
  #  volumeMounts:
  #  - mountPath: /usr/local/bin/helm
  #    name: custom-tools
  #    subPath: helm

## Redis
redis:
  # -- Enable redis
  enabled: true
  # -- Redis name
  name: redis

  ## Redis Pod Disruption Budget
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  pdb:
    # -- Deploy a [PodDisruptionBudget] for the Redis
    enabled: false
    # -- Labels to be added to Redis pdb
    labels: {}
    # -- Annotations to be added to Redis pdb
    annotations: {}
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailble after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `redis.pdb.minAvailable`
    maxUnavailable: ""

  ## Redis image
  image:
    # -- Redis repository
    repository: public.ecr.aws/docker/library/redis
    # -- Redis tag
    tag: 7.0.5-alpine
    # -- Redis imagePullPolicy
    imagePullPolicy: IfNotPresent

  # -- Secrets with credentials to pull images from a private registry
  # @default -- `[]` (defaults to global.imagePullSecrets)
  imagePullSecrets: []

  # -- Additional command line arguments to pass to redis-server
  extraArgs: []
  # - --bind
  # - "0.0.0.0"

  # -- Redis container port
  containerPort: 6379
  # -- Redis service port
  servicePort: 6379

  # -- Environment variables to pass to the Redis server
  env: []

  # -- envFrom to pass to the Redis server
  # @default -- `[]` (See [values.yaml])
  envFrom: []
  # - configMapRef:
  #     name: config-map-name
  # - secretRef:
  #     name: secret-name

  # -- Annotations to be added to the Redis server Deployment
  deploymentAnnotations: {}

  # -- Annotations to be added to the Redis server pods
  podAnnotations: {}

  # -- Labels to be added to the Redis server pods
  podLabels: {}

  # -- Redis pod-level security context
  # @default -- See [values.yaml]
  securityContext:
    runAsNonRoot: true
    runAsUser: 999
    seccompProfile:
      type: RuntimeDefault

  # -- Redis container-level security context
  # @default -- See [values.yaml]
  containerSecurityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL

  # -- [Node selector]
  nodeSelector: {}
  # -- [Tolerations] for use with node taints
  tolerations: []
  # -- Assign custom [affinity] rules to the deployment
  affinity: {}

  # -- Assign custom [TopologySpreadConstraints] rules to redis
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
  ## If labelSelector is left out, it will default to the labelSelector configuration of the deployment
  topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: topology.kubernetes.io/zone
  #   whenUnsatisfiable: DoNotSchedule

  # -- Priority class for redis
  priorityClassName: ""

  serviceAccount:
    # -- Create a service account for the redis pod
    create: false
    # -- Service account name for redis pod
    name: ""
    # -- Annotations applied to created service account
    annotations: {}
    # -- Automount API credentials for the Service Account
    automountServiceAccountToken: false

  # -- Resource limits and requests for redis
  resources: {}
  #  limits:
  #    cpu: 200m
  #    memory: 128Mi
  #  requests:
  #    cpu: 100m
  #    memory: 64Mi

  # -- Additional volumeMounts to the redis container
  volumeMounts: []
  # -- Additional volumes to the redis pod
  volumes: []

  # -- Additional containers to be added to the redis pod
  extraContainers: []

  # -- Init containers to add to the redis pod
  initContainers: []
  #  - name: download-tools
  #    image: alpine:3.8
  #    command: [sh, -c]
  #    args:
  #      - wget -qO- https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz | tar -xvzf - &&
  #        mv linux-amd64/helm /custom-tools/
  #    volumeMounts:
  #      - mountPath: /custom-tools
  #        name: custom-tools
  #  volumeMounts:
  #  - mountPath: /usr/local/bin/helm
  #    name: custom-tools
  #    subPath: helm

  service:
    # -- Redis service annotations
    annotations: {}
    # -- Additional redis service labels
    labels: {}

  metrics:
    # -- Deploy metrics service and redis-exporter sidecar
    enabled: false
    image:
      # -- redis-exporter image repository
      repository: public.ecr.aws/bitnami/redis-exporter
      # -- redis-exporter image tag
      tag: 1.26.0-debian-10-r2
      # -- redis-exporter image PullPolicy
      imagePullPolicy: IfNotPresent
    # -- Port to use for redis-exporter sidecar
    containerPort: 9121

    # -- Redis exporter security context
    # @default -- See [values.yaml]
    containerSecurityContext:
      runAsNonRoot: true
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      seccompProfile:
        type: RuntimeDefault
      capabilities:
        drop:
        - ALL

    # -- Resource limits and requests for redis-exporter sidecar
    resources: {}
      # limits:
      #   cpu: 50m
      #   memory: 64Mi
      # requests:
      #   cpu: 10m
      #   memory: 32Mi
    service:
      # -- Metrics service type
      type: ClusterIP
      # -- Metrics service clusterIP. `None` makes a "headless service" (no virtual IP)
      clusterIP: None
      # -- Metrics service annotations
      annotations: {}
      # -- Metrics service labels
      labels: {}
      # -- Metrics service port
      servicePort: 9121
      # -- Metrics service port name
      portName: http-metrics
    serviceMonitor:
      # -- Enable a prometheus ServiceMonitor
      enabled: false
      # -- Interval at which metrics should be scraped
      interval: 30s
      # -- Prometheus [RelabelConfigs] to apply to samples before scraping
      relabelings: []
      # -- Prometheus [MetricRelabelConfigs] to apply to samples before ingestion
      metricRelabelings: []
      # -- Prometheus ServiceMonitor selector
      selector: {}
        # prometheus: kube-prometheus

      # -- Prometheus ServiceMonitor scheme
      scheme: ""
      # -- Prometheus ServiceMonitor tlsConfig
      tlsConfig: {}
      # -- Prometheus ServiceMonitor namespace
      namespace: "" # "monitoring"
      # -- Prometheus ServiceMonitor labels
      additionalLabels: {}
      # -- Prometheus ServiceMonitor annotations
      annotations: {}


# This key configures Redis-HA subchart and when enabled (redis-ha.enabled=true)
# the custom redis deployment is omitted
# Check the redis-ha chart for more properties
redis-ha:
  # -- Enables the Redis HA subchart and disables the custom Redis single node deployment
  enabled: false
  exporter:
    # -- If `true`, the prometheus exporter sidecar is enabled
    enabled: true
  persistentVolume:
    # -- Configures persistency on Redis nodes
    enabled: false
  redis:
    # -- Redis convention for naming the cluster group: must match `^[\\w-\\.]+$` and can be templated
    masterGroupName: argocd
    # -- Any valid redis config options in this section will be applied to each server (see `redis-ha` chart)
    # @default -- See [values.yaml]
    config:
      # -- Will save the DB if both the given number of seconds and the given number of write operations against the DB occurred. `""`  is disabled
      # @default -- `'""'`
      save: '""'
  haproxy:
    # -- Enabled HAProxy LoadBalancing/Proxy
    enabled: true
    metrics:
      # -- HAProxy enable prometheus metric scraping
      enabled: true
  image:
    # -- Redis tag
    tag: 7.0.5-alpine

  ## https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
  topologySpreadConstraints:
    # -- Enable Redis HA topology spread constraints
    enabled: false
    # -- Max skew of pods tolerated
    # @default -- `""` (defaults to `1`)
    maxSkew: ""
    # -- Topology key for spread
    # @default -- `""` (defaults to `topology.kubernetes.io/zone`)
    topologyKey: ""
    # -- Enforcement policy, hard or soft
    # @default -- `""` (defaults to `ScheduleAnyway`)
    whenUnsatisfiable: ""

# External Redis parameters
externalRedis:
  # -- External Redis server host
  host: ""
  # -- External Redis username
  username: ""
  # -- External Redis password
  password: ""
  # -- External Redis server port
  port: 6379
  # -- The name of an existing secret with Redis credentials (must contain key `redis-password`).
  # When it's set, the `externalRedis.password` parameter is ignored
  existingSecret: ""
  # -- External Redis Secret annotations
  secretAnnotations: {}

## Server
server:
  # -- Argo CD server name
  name: server

  # -- The number of server pods to run
  replicas: 1

  ## Argo CD server Horizontal Pod Autoscaler
  autoscaling:
    # -- Enable Horizontal Pod Autoscaler ([HPA]) for the Argo CD server
    enabled: false
    # -- Minimum number of replicas for the Argo CD server [HPA]
    minReplicas: 1
    # -- Maximum number of replicas for the Argo CD server [HPA]
    maxReplicas: 5
    # -- Average CPU utilization percentage for the Argo CD server [HPA]
    targetCPUUtilizationPercentage: 50
    # -- Average memory utilization percentage for the Argo CD server [HPA]
    targetMemoryUtilizationPercentage: 50
    # -- Configures the scaling behavior of the target in both Up and Down directions.
    # This is only available on HPA apiVersion `autoscaling/v2beta2` and newer
    behavior: {}
      # scaleDown:
      #  stabilizationWindowSeconds: 300
      #  policies:
      #   - type: Pods
      #     value: 1
      #     periodSeconds: 180
      # scaleUp:
      #   stabilizationWindowSeconds: 300
      #   policies:
      #   - type: Pods
      #     value: 2
      #     periodSeconds: 60

  ## Argo CD server Pod Disruption Budget
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  pdb:
    # -- Deploy a [PodDisruptionBudget] for the Argo CD server
    enabled: false
    # -- Labels to be added to Argo CD server pdb
    labels: {}
    # -- Annotations to be added to Argo CD server pdb
    annotations: {}
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailble after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `server.pdb.minAvailable`
    maxUnavailable: ""

  ## Argo CD server image
  image:
    # -- Repository to use for the Argo CD server
    # @default -- `""` (defaults to global.image.repository)
    repository: "" # defaults to global.image.repository
    # -- Tag to use for the Argo CD server
    # @default -- `""` (defaults to global.image.tag)
    tag: "" # defaults to global.image.tag
    # -- Image pull policy for the Argo CD server
    # @default -- `""` (defaults to global.image.imagePullPolicy)
    imagePullPolicy: "" # IfNotPresent

  # -- Secrets with credentials to pull images from a private registry
  # @default -- `[]` (defaults to global.imagePullSecrets)
  imagePullSecrets: []

  # -- Additional command line arguments to pass to Argo CD server
  extraArgs: []

  # -- Environment variables to pass to Argo CD server
  env: []

  # -- envFrom to pass to Argo CD server
  # @default -- `[]` (See [values.yaml])
  envFrom: []
  # - configMapRef:
  #     name: config-map-name
  # - secretRef:
  #     name: secret-name

  # -- Specify postStart and preStop lifecycle hooks for your argo-cd-server container
  lifecycle: {}

  # DEPRECATED - Use configs.params to override
  # -- Argo CD server log format: Either `text` or `json`
  # @default -- `""` (defaults to global.logging.format)
  # logFormat: ""
  # -- Argo CD server log level. One of: `debug`, `info`, `warn` or `error`
  # @default -- `""` (defaults to global.logging.level)
  # logLevel: ""

  # -- Annotations to be added to server Deployment
  deploymentAnnotations: {}

  # -- Annotations to be added to server pods
  podAnnotations: {}

  # -- Labels to be added to server pods
  podLabels: {}

  # -- Configures the server port
  containerPort: 8080

  ## Readiness and liveness probes for default backend
  ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
  readinessProbe:
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1
  livenessProbe:
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1

  # -- Additional volumeMounts to the server main container
  volumeMounts: []

  # -- Additional volumes to the server pod
  volumes: []

  # -- [Node selector]
  nodeSelector: {}
  # -- [Tolerations] for use with node taints
  tolerations: []
  # -- Assign custom [affinity] rules to the deployment
  affinity: {}

  # -- Assign custom [TopologySpreadConstraints] rules to the Argo CD server
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
  ## If labelSelector is left out, it will default to the labelSelector configuration of the deployment
  topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: topology.kubernetes.io/zone
  #   whenUnsatisfiable: DoNotSchedule

  # -- Priority class for the Argo CD server
  priorityClassName: ""

  # -- Server container-level security context
  # @default -- See [values.yaml]
  containerSecurityContext:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL

  # -- Resource limits and requests for the Argo CD server
  resources: {}
  #  limits:
  #    cpu: 100m
  #    memory: 128Mi
  #  requests:
  #    cpu: 50m
  #    memory: 64Mi

  # TLS certificate configuration via cert-manager
  ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#tls-certificates-used-by-argocd-server
  certificate:
    # -- Deploy a Certificate resource (requires cert-manager)
    enabled: false
    # -- The name of the Secret that will be automatically created and managed by this Certificate resource
    secretName: argocd-server-tls
    # -- Certificate primary domain (commonName)
    domain: argocd.example.com
    # -- Certificate Subject Alternate Names (SANs)
    additionalHosts: []
    # -- The requested 'duration' (i.e. lifetime) of the certificate.
    # @default -- `""` (defaults to 2160h = 90d if not specified)
    ## Ref: https://cert-manager.io/docs/usage/certificate/#renewal
    duration: ""
    # -- How long before the expiry a certificate should be renewed.
    # @default -- `""` (defaults to 360h = 15d if not specified)
    ## Ref: https://cert-manager.io/docs/usage/certificate/#renewal
    renewBefore: ""
    # Certificate issuer
    ## Ref: https://cert-manager.io/docs/concepts/issuer
    issuer:
      # -- Certificate issuer group. Set if using an external issuer. Eg. `cert-manager.io`
      group: ""
      # -- Certificate issuer kind. Either `Issuer` or `ClusterIssuer`
      kind: ""
      # -- Certificate isser name. Eg. `letsencrypt`
      name: ""
    # Private key of the certificate
    privateKey:
      # -- Rotation policy of private key when certificate is re-issued. Either: `Never` or `Always`
      rotationPolicy: Never
      # -- The private key cryptography standards (PKCS) encoding for private key. Either: `PCKS1` or `PKCS8`
      encoding: PKCS1
      # -- Algorithm used to generate certificate private key. One of: `RSA`, `Ed25519` or `ECDSA`
      algorithm: RSA
      # -- Key bit size of the private key. If algorithm is set to `Ed25519`, size is ignored.
      size: 2048

  # TLS certificate configuration via Secret
  ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#tls-certificates-used-by-argocd-server
  certificateSecret:
    # -- Create argocd-server-tls secret
    enabled: false
    # -- Annotations to be added to argocd-server-tls secret
    annotations: {}
    # -- Labels to be added to argocd-server-tls secret
    labels: {}
    # -- Private Key of the certificate
    key: ''
    # -- Certificate data
    crt: ''

  ## Server service configuration
  service:
    # -- Server service annotations
    annotations: {}
    # -- Server service labels
    labels: {}
    # -- Server service type
    type: NodePort
    # -- Server service http port for NodePort service type (only if `server.service.type` is set to "NodePort")
    nodePortHttp: 30080
    # -- Server service https port for NodePort service type (only if `server.service.type` is set to "NodePort")
    nodePortHttps: 30443
    # -- Server service http port
    servicePortHttp: 80
    # -- Server service https port
    servicePortHttps: 443
    # -- Server service http port name, can be used to route traffic via istio
    servicePortHttpName: http
    # -- Server service https port name, can be used to route traffic via istio
    servicePortHttpsName: https
    # -- Use named target port for argocd
    ## Named target ports are not supported by GCE health checks, so when deploying argocd on GKE
    ## and exposing it via GCE ingress, the health checks fail and the load balancer returns a 502.
    namedTargetPort: true
    # -- LoadBalancer will get created with the IP specified in this field
    loadBalancerIP: ""
    # -- Source IP ranges to allow access to service from
    loadBalancerSourceRanges: []
    # -- Server service external IPs
    externalIPs: []
    # -- Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    externalTrafficPolicy: ""
    # -- Used to maintain session affinity. Supports `ClientIP` and `None`
    sessionAffinity: ""

  ## Server metrics service configuration
  metrics:
    # -- Deploy metrics service
    enabled: false
    service:
      # -- Metrics service annotations
      annotations: {}
      # -- Metrics service labels
      labels: {}
      # -- Metrics service port
      servicePort: 8083
      # -- Metrics service port name
      portName: http-metrics
    serviceMonitor:
      # -- Enable a prometheus ServiceMonitor
      enabled: false
      # -- Prometheus ServiceMonitor interval
      interval: 30s
      # -- Prometheus [RelabelConfigs] to apply to samples before scraping
      relabelings: []
      # -- Prometheus [MetricRelabelConfigs] to apply to samples before ingestion
      metricRelabelings: []
      # -- Prometheus ServiceMonitor selector
      selector: {}
        # prometheus: kube-prometheus

      # -- Prometheus ServiceMonitor scheme
      scheme: ""
      # -- Prometheus ServiceMonitor tlsConfig
      tlsConfig: {}
      # -- Prometheus ServiceMonitor namespace
      namespace: ""  # monitoring
      # -- Prometheus ServiceMonitor labels
      additionalLabels: {}
      # -- Prometheus ServiceMonitor annotations
      annotations: {}

  serviceAccount:
    # -- Create server service account
    create: true
    # -- Server service account name
    name: argocd-server
    # -- Annotations applied to created service account
    annotations: {}
    # -- Labels applied to created service account
    labels: {}
    # -- Automount API credentials for the Service Account
    automountServiceAccountToken: true

  ingress:
    enabled: false
    # annotations:
    #   nginx.ingress.kubernetes.io/ssl-redirect: ""
    # ingressClassName: ""
    # hosts:
    # - ""
    # tls:
    # - secretName: ""
    #   hosts:
    #   - ""

  # dedicated ingress for gRPC as documented at
  # Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/
  ingressGrpc:
    # -- Enable an ingress resource for the Argo CD server for dedicated [gRPC-ingress]
    enabled: false
    # -- Setup up gRPC ingress to work with an AWS ALB
    isAWSALB: false
    # -- Additional ingress annotations for dedicated [gRPC-ingress]
    annotations: {}
    # -- Additional ingress labels for dedicated [gRPC-ingress]
    labels: {}
    # -- Defines which ingress controller will implement the resource [gRPC-ingress]
    ingressClassName: ""

    awsALB:
      # -- Service type for the AWS ALB gRPC service
      ## Service Type if isAWSALB is set to true
      ## Can be of type NodePort or ClusterIP depending on which mode you are
      ## are running. Instance mode needs type NodePort, IP mode needs type
      ## ClusterIP
      ## Ref: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/how-it-works/#ingress-traffic
      serviceType: NodePort
      # -- Backend protocol version for the AWS ALB gRPC service
      ## This tells AWS to send traffic from the ALB using HTTP2. Can use gRPC as well if you want to leverage gRPC specific features
      backendProtocolVersion: HTTP2

    # -- List of ingress hosts for dedicated [gRPC-ingress]
    ## Argo Ingress.
    ## Hostnames must be provided if Ingress is enabled.
    ## Secrets must be manually created in the namespace
    ##
    hosts:
      []
      # - argocd.example.com

    # -- List of ingress paths for dedicated [gRPC-ingress]
    paths:
      - /
    # -- Ingress path type for dedicated [gRPC-ingress]. One of `Exact`, `Prefix` or `ImplementationSpecific`
    pathType: Prefix
    # -- Additional ingress paths for dedicated [gRPC-ingress]
    extraPaths:
      []
      # - path: /*
      #   backend:
      #     serviceName: ssl-redirect
      #     servicePort: use-annotation
      ## for Kubernetes >=1.19 (when "networking.k8s.io/v1" is used)
      # - path: /*
      #   pathType: Prefix
      #   backend:
      #     service:
      #       name: ssl-redirect
      #       port:
      #         name: use-annotation

    # -- Ingress TLS configuration for dedicated [gRPC-ingress]
    tls:
      []
      # - secretName: your-certificate-name
      #   hosts:
      #     - argocd.example.com

    # -- Uses `server.service.servicePortHttps` instead `server.service.servicePortHttp`
    https: false

  # Create a OpenShift Route with SSL passthrough for UI and CLI
  # Consider setting 'hostname' e.g. https://argocd.apps-crc.testing/ using your Default Ingress Controller Domain
  # Find your domain with: kubectl describe --namespace=openshift-ingress-operator ingresscontroller/default | grep Domain:
  # If 'hostname' is an empty string "" OpenShift will create a hostname for you.
  route:
    # -- Enable an OpenShift Route for the Argo CD server
    enabled: false
    # -- Openshift Route annotations
    annotations: {}
    # -- Hostname of OpenShift Route
    hostname: ""
    # -- Termination type of Openshift Route
    termination_type: passthrough
    # -- Termination policy of Openshift Route
    termination_policy: None

  ## Enable Admin ClusterRole resources.
  ## Enable if you would like to grant rights to Argo CD to deploy to the local Kubernetes cluster.
  clusterAdminAccess:
    # -- Enable RBAC for local cluster deployments
    enabled: true

  GKEbackendConfig:
    # -- Enable BackendConfig custom resource for Google Kubernetes Engine
    enabled: false
    # -- [BackendConfigSpec]
    spec: {}
  #  spec:
  #    iap:
  #      enabled: true
  #      oauthclientCredentials:
  #        secretName: argocd-secret

  ## Create a Google Managed Certificate for use with the GKE Ingress Controller
  ## https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs
  GKEmanagedCertificate:
    # -- Enable ManagedCertificate custom resource for Google Kubernetes Engine.
    enabled: false
    # -- Domains for the Google Managed Certificate
    domains:
    - argocd.example.com

  ## Create a Google FrontendConfig Custom Resource, for use with the GKE Ingress Controller
  ## https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features#configuring_ingress_features_through_frontendconfig_parameters
  GKEfrontendConfig:
    # -- Enable FrontConfig custom resource for Google Kubernetes Engine
    enabled: false
    # -- [FrontendConfigSpec]
    spec: {}
  # spec:
  #   redirectToHttps:
  #     enabled: true
  #     responseCodeName: RESPONSE_CODE

  # -- Additional containers to be added to the server pod
  ## See https://github.com/lemonldap-ng-controller/lemonldap-ng-controller as example.
  extraContainers: []
  # - name: my-sidecar
  #   image: nginx:latest
  # - name: lemonldap-ng-controller
  #   image: lemonldapng/lemonldap-ng-controller:0.2.0
  #   args:
  #     - /lemonldap-ng-controller
  #     - --alsologtostderr
  #     - --configmap=$(POD_NAMESPACE)/lemonldap-ng-configuration
  #   env:
  #     - name: POD_NAME
  #       valueFrom:
  #         fieldRef:
  #           fieldPath: metadata.name
  #     - name: POD_NAMESPACE
  #       valueFrom:
  #         fieldRef:
  #           fieldPath: metadata.namespace
  #   volumeMounts:
  #   - name: copy-portal-skins
  #     mountPath: /srv/var/lib/lemonldap-ng/portal/skins

  # -- Init containers to add to the server pod
  ## If your target Kubernetes cluster(s) require a custom auth provider executable
  ## you could use this (and the same in the application controller pod) to bootstrap
  ## that executable into your Argo CD container
  initContainers: []
  #  - name: download-tools
  #    image: alpine:3.8
  #    command: [sh, -c]
  #    args:
  #      - wget -qO- https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz | tar -xvzf - &&
  #        mv linux-amd64/helm /custom-tools/
  #    volumeMounts:
  #      - mountPath: /custom-tools
  #        name: custom-tools
  #  volumeMounts:
  #  - mountPath: /usr/local/bin/helm
  #    name: custom-tools
  #    subPath: helm

  ## Argo UI extensions
  ## This function in tech preview stage, do expect unstability or breaking changes in newer versions.
  ## Ref: https://github.com/argoproj-labs/argocd-extensions
  extensions:
    # -- Enable support for Argo UI extensions
    enabled: false

    ## Argo UI extensions image
    image:
      # -- Repository to use for extensions image
      repository: "ghcr.io/argoproj-labs/argocd-extensions"
      # -- Tag to use for extensions image
      tag: "v0.1.0"
      # -- Image pull policy for extensions
      imagePullPolicy: IfNotPresent

    # -- Server UI extensions container-level security context
    # @default -- See [values.yaml]
    containerSecurityContext:
      runAsNonRoot: true
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      seccompProfile:
        type: RuntimeDefault
      capabilities:
        drop:
        - ALL

    # -- Resource limits and requests for the argocd-extensions container
    resources: {}
    #  limits:
    #    cpu: 50m
    #    memory: 128Mi
    #  requests:
    #    cpu: 10m
    #    memory: 64Mi

## Repo Server
repoServer:
  # -- Repo server name
  name: repo-server

  # -- The number of repo server pods to run
  replicas: 1

  ## Repo server Horizontal Pod Autoscaler
  autoscaling:
    # -- Enable Horizontal Pod Autoscaler ([HPA]) for the repo server
    enabled: false
    # -- Minimum number of replicas for the repo server [HPA]
    minReplicas: 1
    # -- Maximum number of replicas for the repo server [HPA]
    maxReplicas: 5
    # -- Average CPU utilization percentage for the repo server [HPA]
    targetCPUUtilizationPercentage: 50
    # -- Average memory utilization percentage for the repo server [HPA]
    targetMemoryUtilizationPercentage: 50
    # -- Configures the scaling behavior of the target in both Up and Down directions.
    # This is only available on HPA apiVersion `autoscaling/v2beta2` and newer
    behavior: {}
      # scaleDown:
      #  stabilizationWindowSeconds: 300
      #  policies:
      #   - type: Pods
      #     value: 1
      #     periodSeconds: 180
      # scaleUp:
      #   stabilizationWindowSeconds: 300
      #   policies:
      #   - type: Pods
      #     value: 2
      #     periodSeconds: 60

  ## Repo server Pod Disruption Budget
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  pdb:
    # -- Deploy a [PodDisruptionBudget] for the repo server
    enabled: false
    # -- Labels to be added to repo server pdb
    labels: {}
    # -- Annotations to be added to repo server pdb
    annotations: {}
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailble after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `repoServer.pdb.minAvailable`
    maxUnavailable: ""

  ## Repo server image
  image:
    # -- Repository to use for the repo server
    # @default -- `""` (defaults to global.image.repository)
    repository: "" # defaults to global.image.repository
    # -- Tag to use for the repo server
    # @default -- `""` (defaults to global.image.tag)
    tag: "" # defaults to global.image.tag
    # -- Image pull policy for the repo server
    # @default -- `""` (defaults to global.image.imagePullPolicy)
    imagePullPolicy: "" # IfNotPresent

  # -- Secrets with credentials to pull images from a private registry
  # @default -- `[]` (defaults to global.imagePullSecrets)
  imagePullSecrets: []

  # -- Additional command line arguments to pass to repo server
  extraArgs: []

  # -- Environment variables to pass to repo server
  env: []

  # -- envFrom to pass to repo server
  # @default -- `[]` (See [values.yaml])
  envFrom: []
  # - configMapRef:
  #     name: config-map-name
  # - secretRef:
  #     name: secret-name

  # DEPRECATED - Use configs.params to override
  # -- Repo server log format: Either `text` or `json`
  # @default -- `""` (defaults to global.logging.level)
  # logFormat: ""
  # -- Repo server log level. One of: `debug`, `info`, `warn` or `error`
  # @default -- `""` (defaults to global.logging.format)
  # logLevel: ""

  # -- Annotations to be added to repo server Deployment
  deploymentAnnotations: {}

  # -- Annotations to be added to repo server pods
  podAnnotations: {}

  # -- Labels to be added to repo server pods
  podLabels: {}

  # -- Configures the repo server port
  containerPort: 8081

  ## Readiness and liveness probes for default backend
  ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
  readinessProbe:
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1
  livenessProbe:
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1

  # -- Additional volumeMounts to the repo server main container
  volumeMounts: []

  # -- Additional volumes to the repo server pod
  volumes: []
  ## Use init containers to configure custom tooling
  ## https://argo-cd.readthedocs.io/en/stable/operator-manual/custom_tools/
  ## When using the volumes & volumeMounts section bellow, please comment out those above.
  #  - name: custom-tools
  #    emptyDir: {}

  # -- [Node selector]
  nodeSelector: {}
  # -- [Tolerations] for use with node taints
  tolerations: []
  # -- Assign custom [affinity] rules to the deployment
  affinity: {}

  # -- Assign custom [TopologySpreadConstraints] rules to the repo server
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
  ## If labelSelector is left out, it will default to the labelSelector configuration of the deployment
  topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: topology.kubernetes.io/zone
  #   whenUnsatisfiable: DoNotSchedule

  # -- Priority class for the repo server
  priorityClassName: ""

  # -- Repo server container-level security context
  # @default -- See [values.yaml]
  containerSecurityContext:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL

  # -- Resource limits and requests for the repo server pods
  resources: {}
  #  limits:
  #    cpu: 50m
  #    memory: 128Mi
  #  requests:
  #    cpu: 10m
  #    memory: 64Mi

  # TLS certificate configuration via Secret
  ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#configuring-tls-to-argocd-repo-server
  ## Note: Issuing certificates via cert-manager in not supported right now because it's not possible to restart repo server automatically without extra controllers.
  certificateSecret:
    # -- Create argocd-repo-server-tls secret
    enabled: false
    # -- Annotations to be added to argocd-repo-server-tls secret
    annotations: {}
    # -- Labels to be added to argocd-repo-server-tls secret
    labels: {}
    # -- Certificate authority. Required for self-signed certificates.
    ca: ''
    # -- Certificate private key
    key: ''
    # -- Certificate data. Must contain SANs of Repo service (ie: argocd-repo-server, argocd-repo-server.argo-cd.svc)
    crt: ''

  ## Repo server service configuration
  service:
    # -- Repo server service annotations
    annotations: {}
    # -- Repo server service labels
    labels: {}
    # -- Repo server service port
    port: 8081
    # -- Repo server service port name
    portName: https-repo-server

  ## Repo server metrics service configuration
  metrics:
    # -- Deploy metrics service
    enabled: false
    service:
      # -- Metrics service annotations
      annotations: {}
      # -- Metrics service labels
      labels: {}
      # -- Metrics service port
      servicePort: 8084
      # -- Metrics service port name
      portName: http-metrics
    serviceMonitor:
      # -- Enable a prometheus ServiceMonitor
      enabled: false
      # -- Prometheus ServiceMonitor interval
      interval: 30s
      # -- Prometheus [RelabelConfigs] to apply to samples before scraping
      relabelings: []
      # -- Prometheus [MetricRelabelConfigs] to apply to samples before ingestion
      metricRelabelings: []
      # -- Prometheus ServiceMonitor selector
      selector: {}
        # prometheus: kube-prometheus

      # -- Prometheus ServiceMonitor scheme
      scheme: ""
      # -- Prometheus ServiceMonitor tlsConfig
      tlsConfig: {}
      # -- Prometheus ServiceMonitor namespace
      namespace: "" # "monitoring"
      # -- Prometheus ServiceMonitor labels
      additionalLabels: {}
      # -- Prometheus ServiceMonitor annotations
      annotations: {}

  ## Enable Admin ClusterRole resources.
  ## Enable if you would like to grant cluster rights to Argo CD repo server.
  clusterAdminAccess:
    # -- Enable RBAC for local cluster deployments
    enabled: false
  ## Enable Custom Rules for the Repo server's Cluster Role resource
  ## Enable this and set the rules: to whatever custom rules you want for the Cluster Role resource.
  ## Defaults to off
  clusterRoleRules:
    # -- Enable custom rules for the Repo server's Cluster Role resource
    enabled: false
    # -- List of custom rules for the Repo server's Cluster Role resource
    rules: []

  ## Repo server service account
  ## If create is set to true, make sure to uncomment the name and update the rbac section below
  serviceAccount:
    # -- Create repo server service account
    create: true
    # -- Repo server service account name
    name: "" # "argocd-repo-server"
    # -- Annotations applied to created service account
    annotations: {}
    # -- Labels applied to created service account
    labels: {}
    # -- Automount API credentials for the Service Account
    automountServiceAccountToken: true

  # -- Additional containers to be added to the repo server pod
  extraContainers: []

  # -- Repo server rbac rules
  rbac: []
  #   - apiGroups:
  #     - argoproj.io
  #     resources:
  #     - applications
  #     verbs:
  #     - get
  #     - list
  #     - watch

  # -- Init containers to add to the repo server pods
  initContainers: []
  #  - name: download-tools
  #    image: alpine:3.8
  #    command: [sh, -c]
  #    args:
  #      - wget -qO- https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz | tar -xvzf - &&
  #        mv linux-amd64/helm /custom-tools/
  #    volumeMounts:
  #      - mountPath: /custom-tools
  #        name: custom-tools
  #  volumeMounts:
  #  - mountPath: /usr/local/bin/helm
  #    name: custom-tools
  #    subPath: helm

## ApplicationSet controller
applicationSet:
  # -- Enable ApplicationSet controller
  enabled: true

  # -- ApplicationSet controller name string
  name: applicationset-controller

  # -- The number of ApplicationSet controller pods to run
  replicaCount: 1

  ## ApplicationSet controller Pod Disruption Budget
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  pdb:
    # -- Deploy a [PodDisruptionBudget] for the ApplicationSet controller
    enabled: false
    # -- Labels to be added to ApplicationSet controller pdb
    labels: {}
    # -- Annotations to be added to ApplicationSet controller pdb
    annotations: {}
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailble after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `applicationSet.pdb.minAvailable`
    maxUnavailable: ""

  ## ApplicationSet controller image
  image:
    # -- Repository to use for the ApplicationSet controller
    # @default -- `""` (defaults to global.image.repository)
    repository: ""
    # -- Tag to use for the ApplicationSet controller
    # @default -- `""` (defaults to global.image.tag)
    tag: ""
    # -- Image pull policy for the ApplicationSet controller
    # @default -- `""` (defaults to global.image.imagePullPolicy)
    imagePullPolicy: ""

  # -- If defined, uses a Secret to pull an image from a private Docker registry or repository.
  # @default -- `[]` (defaults to global.imagePullSecrets)
  imagePullSecrets: []

  args:
    # -- The default metric address
    metricsAddr: :8080
    # -- The default health check port
    probeBindAddr: :8081
    # -- How application is synced between the generator and the cluster
    policy: sync
    # -- Enable dry run mode
    dryRun: false

  # -- ApplicationSet controller log format. Either `text` or `json`
  # @default -- `""` (defaults to global.logging.format)
  logFormat: ""
  # -- ApplicationSet controller log level. One of: `debug`, `info`, `warn`, `error`
  # @default -- `""` (defaults to global.logging.level)
  logLevel: ""

  # -- Additional containers to be added to the ApplicationSet controller pod
  extraContainers: []

  ## Metrics service configuration
  metrics:
    # -- Deploy metrics service
    enabled: false
    service:
      # -- Metrics service annotations
      annotations: {}
      # -- Metrics service labels
      labels: {}
      # -- Metrics service port
      servicePort: 8085
      # -- Metrics service port name
      portName: http-metrics
    serviceMonitor:
      # -- Enable a prometheus ServiceMonitor
      enabled: false
      # -- Prometheus ServiceMonitor interval
      interval: 30s
      # -- Prometheus [RelabelConfigs] to apply to samples before scraping
      relabelings: []
      # -- Prometheus [MetricRelabelConfigs] to apply to samples before ingestion
      metricRelabelings: []
      # -- Prometheus ServiceMonitor selector
      selector: {}
        # prometheus: kube-prometheus

      # -- Prometheus ServiceMonitor scheme
      scheme: ""
      # -- Prometheus ServiceMonitor tlsConfig
      tlsConfig: {}
      # -- Prometheus ServiceMonitor namespace
      namespace: ""  # monitoring
      # -- Prometheus ServiceMonitor labels
      additionalLabels: {}
      # -- Prometheus ServiceMonitor annotations
      annotations: {}

  ## ApplicationSet service configuration
  service:
    # -- ApplicationSet service annotations
    annotations: {}
    # -- ApplicationSet service labels
    labels: {}
    # -- ApplicationSet service port
    port: 7000
    # -- ApplicationSet service port name
    portName: webhook

  serviceAccount:
    # -- Specifies whether a service account should be created
    create: true
    # -- Annotations to add to the service account
    annotations: {}
    # -- Labels applied to created service account
    labels: {}
    # -- The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    name: ""

  # -- Annotations to be added to ApplicationSet controller Deployment
  deploymentAnnotations: {}

  # -- Annotations for the ApplicationSet controller pods
  podAnnotations: {}

  # -- Labels for the ApplicationSet controller pods
  podLabels: {}

  # -- ApplicationSet controller container-level security context
  # @default -- See [values.yaml]
  containerSecurityContext:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL

  ## Probes for ApplicationSet controller (optional)
  ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
  readinessProbe:
    # -- Enable Kubernetes liveness probe for ApplicationSet controller
    enabled: false
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3

  livenessProbe:
    # -- Enable Kubernetes liveness probe for ApplicationSet controller
    enabled: false
    # -- Number of seconds after the container has started before [probe] is initiated
    initialDelaySeconds: 10
    # -- How often (in seconds) to perform the [probe]
    periodSeconds: 10
    # -- Number of seconds after which the [probe] times out
    timeoutSeconds: 1
    # -- Minimum consecutive successes for the [probe] to be considered successful after having failed
    successThreshold: 1
    # -- Minimum consecutive failures for the [probe] to be considered failed after having succeeded
    failureThreshold: 3

  # -- Resource limits and requests for the ApplicationSet controller pods.
  resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 100m
    #   memory: 128Mi
    # requests:
    #   cpu: 100m
    #   memory: 128Mi

  # -- [Node selector]
  nodeSelector: {}

  # -- [Tolerations] for use with node taints
  tolerations: []

  # -- Assign custom [affinity] rules
  affinity: {}

  # -- If specified, indicates the pod's priority. If not specified, the pod priority will be default or zero if there is no default.
  priorityClassName: ""

  # -- List of extra mounts to add (normally used with extraVolumes)
  extraVolumeMounts: []
    # - mountPath: /tmp/foobar
    #   name: foobar

  # -- List of extra volumes to add
  extraVolumes: []
    # - name: foobar
    #   emptyDir: {}

  # -- List of extra cli args to add
  extraArgs: []

  # -- Environment variables to pass to the ApplicationSet controller
  extraEnv: []
    # - name: "MY_VAR"
    #   value: "value"

  # -- envFrom to pass to the ApplicationSet controller
  # @default -- `[]` (See [values.yaml])
  extraEnvFrom: []
    # - configMapRef:
    #     name: config-map-name
    # - secretRef:
    #     name: secret-name

  ## Webhook for the Git Generator
  ## Ref: https://argocd-applicationset.readthedocs.io/en/master/Generators-Git/#webhook-configuration)
  webhook:
    ingress:
      # -- Enable an ingress resource for Webhooks
      enabled: false
      # -- Additional ingress annotations
      annotations: {}
      # -- Additional ingress labels
      labels: {}
      # -- Defines which ingress ApplicationSet controller will implement the resource
      ingressClassName: ""

      # -- List of ingress hosts
      ## Hostnames must be provided if Ingress is enabled.
      ## Secrets must be manually created in the namespace
      hosts: []
        # - argocd-applicationset.example.com

      # -- List of ingress paths
      paths:
        - /api/webhook
      # -- Ingress path type. One of `Exact`, `Prefix` or `ImplementationSpecific`
      pathType: Prefix
      # -- Additional ingress paths
      extraPaths: []
        # - path: /*
        #   backend:
        #     serviceName: ssl-redirect
        #     servicePort: use-annotation
        ## for Kubernetes >=1.19 (when "networking.k8s.io/v1" is used)
        # - path: /*
        #   pathType: Prefix
        #   backend:
        #     service:
        #       name: ssl-redirect
        #       port:
        #         name: use-annotation

      # -- Ingress TLS configuration
      tls: []
        # - secretName: argocd-applicationset-tls
        #   hosts:
        #     - argocd-applicationset.example.com

## Notifications controller
notifications:
  # -- Enable notifications controller
  enabled: true

  # -- Notifications controller name string
  name: notifications-controller

  # -- Assign custom [affinity] rules
  affinity: {}

  # -- Argo CD dashboard url; used in place of {{.context.argocdUrl}} in templates
  argocdUrl:

  ## Notifications controller Pod Disruption Budget
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  pdb:
    # -- Deploy a [PodDisruptionBudget] for the notifications controller
    enabled: false
    # -- Labels to be added to notifications controller pdb
    labels: {}
    # -- Annotations to be added to notifications controller pdb
    annotations: {}
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailble after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `notifications.pdb.minAvailable`
    maxUnavailable: ""

  ## Notifications controller image
  image:
    # -- Repository to use for the notifications controller
    # @default -- `""` (defaults to global.image.repository)
    repository: ""
    # -- Tag to use for the notifications controller
    # @default -- `""` (defaults to global.image.tag)
    tag: ""
    # -- Image pull policy for the notifications controller
    # @default -- `""` (defaults to global.image.imagePullPolicy)
    imagePullPolicy: ""

  # -- Secrets with credentials to pull images from a private registry
  # @default -- `[]` (defaults to global.imagePullSecrets)
  imagePullSecrets: []

  # -- [Node selector]
  nodeSelector: {}

  # -- Define user-defined context
  ## For more information: https://argocd-notifications.readthedocs.io/en/stable/templates/#defining-user-defined-context
  context: {}
    # region: east
    # environmentName: staging

  secret:
    # -- Whether helm chart creates notifications controller secret
    create: true

    # -- key:value pairs of annotations to be added to the secret
    annotations: {}

    # -- Generic key:value pairs to be inserted into the secret
    ## Can be used for templates, notification services etc. Some examples given below.
    ## For more information: https://argocd-notifications.readthedocs.io/en/stable/services/overview/
    items: {}
      # slack-token:
      #   # For more information: https://argocd-notifications.readthedocs.io/en/stable/services/slack/

      # grafana-apiKey:
      #   # For more information: https://argocd-notifications.readthedocs.io/en/stable/services/grafana/

      # webhooks-github-token:

      # email-username:
      # email-password:
        # For more information: https://argocd-notifications.readthedocs.io/en/stable/services/email/

  # -- Notifications controller log format. Either `text` or `json`
  # @default -- `""` (defaults to global.logging.format)
  logFormat: ""
  # -- Notifications controller log level. One of: `debug`, `info`, `warn`, `error`
  # @default -- `""` (defaults to global.logging.level)
  logLevel: ""

  # -- Extra arguments to provide to the notifications controller
  extraArgs: []

  # -- Additional container environment variables
  extraEnv: []

  # -- envFrom to pass to the notifications controller
  # @default -- `[]` (See [values.yaml])
  extraEnvFrom: []
    # - configMapRef:
    #     name: config-map-name
    # - secretRef:
    #     name: secret-name

  # -- List of extra mounts to add (normally used with extraVolumes)
  extraVolumeMounts: []
    # - mountPath: /tmp/foobar
    #   name: foobar

  # -- List of extra volumes to add
  extraVolumes: []
    # - name: foobar
    #   emptyDir: {}

  metrics:
    # -- Enables prometheus metrics server
    enabled: false
    # -- Metrics port
    port: 9001
    service:
      # -- Metrics service annotations
      annotations: {}
      # -- Metrics service labels
      labels: {}
      # -- Metrics service port name
      portName: http-metrics
    serviceMonitor:
      # -- Enable a prometheus ServiceMonitor
      enabled: false
      # -- Prometheus ServiceMonitor selector
      selector: {}
        # prometheus: kube-prometheus
      # -- Prometheus ServiceMonitor labels
      additionalLabels: {}
      # -- Prometheus ServiceMonitor annotations
      annotations: {}
      # namespace: monitoring
      # interval: 30s
      # scrapeTimeout: 10s
      # -- Prometheus ServiceMonitor scheme
      scheme: ""
      # -- Prometheus ServiceMonitor tlsConfig
      tlsConfig: {}

  # -- Configures notification services such as slack, email or custom webhook
  # @default -- See [values.yaml]
  ## For more information: https://argocd-notifications.readthedocs.io/en/stable/services/overview/
  notifiers: {}
    # service.slack: |
    #   token: $slack-token

  # -- Annotations to be applied to the notifications controller Deployment
  deploymentAnnotations: {}

  # -- Annotations to be applied to the notifications controller Pods
  podAnnotations: {}

  # -- Labels to be applied to the notifications controller Pods
  podLabels: {}

  # -- Notification controller container-level security Context
  # @default -- See [values.yaml]
  containerSecurityContext:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL

  # -- Priority class for the notifications controller pods
  priorityClassName: ""

  # -- Resource limits and requests for the notifications controller
  resources: {}
    # limits:
    #   cpu: 100m
    #   memory: 128Mi
    # requests:
    #   cpu: 100m
    #   memory: 128Mi

  serviceAccount:
    # -- Specifies whether a service account should be created
    create: true

    # -- The name of the service account to use.
    ## If not set and create is true, a name is generated using the fullname template
    name: argocd-notifications-controller

    # -- Annotations applied to created service account
    annotations: {}

    # -- Labels applied to created service account
    labels: {}
  cm:
    # -- Whether helm chart creates notifications controller config map
    create: true

  # -- Contains centrally managed global application subscriptions
  ## For more information: https://argocd-notifications.readthedocs.io/en/stable/subscriptions/
  subscriptions: []
    # # subscription for on-sync-status-unknown trigger notifications
    # - recipients:
    #   - slack:test2
    #   - email:test@gmail.com
    #   triggers:
    #   - on-sync-status-unknown
    # # subscription restricted to applications with matching labels only
    # - recipients:
    #   - slack:test3
    #   selector: test=true
    #   triggers:
    #   - on-sync-status-unknown

  # -- The notification template is used to generate the notification content
  ## For more information: https://argocd-notifications.readthedocs.io/en/stable/templates/
  templates: {}
    # template.app-deployed: |
    #   email:
    #     subject: New version of an application {{.app.metadata.name}} is up and running.
    #   message: |
    #     {{if eq .serviceType "slack"}}:white_check_mark:{{end}} Application {{.app.metadata.name}} is now running new version of deployments manifests.
    #   slack:
    #     attachments: |
    #       [{
    #         "title": "{{ .app.metadata.name}}",
    #         "title_link":"{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
    #         "color": "#18be52",
    #         "fields": [
    #         {
    #           "title": "Sync Status",
    #           "value": "{{.app.status.sync.status}}",
    #           "short": true
    #         },
    #         {
    #           "title": "Repository",
    #           "value": "{{.app.spec.source.repoURL}}",
    #           "short": true
    #         },
    #         {
    #           "title": "Revision",
    #           "value": "{{.app.status.sync.revision}}",
    #           "short": true
    #         }
    #         {{range $index, $c := .app.status.conditions}}
    #         {{if not $index}},{{end}}
    #         {{if $index}},{{end}}
    #         {
    #           "title": "{{$c.type}}",
    #           "value": "{{$c.message}}",
    #           "short": true
    #         }
    #         {{end}}
    #         ]
    #       }]
    # template.app-health-degraded: |
    #   email:
    #     subject: Application {{.app.metadata.name}} has degraded.
    #   message: |
    #     {{if eq .serviceType "slack"}}:exclamation:{{end}} Application {{.app.metadata.name}} has degraded.
    #     Application details: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}.
    #   slack:
    #     attachments: |-
    #       [{
    #         "title": "{{ .app.metadata.name}}",
    #         "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
    #         "color": "#f4c030",
    #         "fields": [
    #         {
    #           "title": "Sync Status",
    #           "value": "{{.app.status.sync.status}}",
    #           "short": true
    #         },
    #         {
    #           "title": "Repository",
    #           "value": "{{.app.spec.source.repoURL}}",
    #           "short": true
    #         }
    #         {{range $index, $c := .app.status.conditions}}
    #         {{if not $index}},{{end}}
    #         {{if $index}},{{end}}
    #         {
    #           "title": "{{$c.type}}",
    #           "value": "{{$c.message}}",
    #           "short": true
    #         }
    #         {{end}}
    #         ]
    #       }]
    # template.app-sync-failed: |
    #   email:
    #     subject: Failed to sync application {{.app.metadata.name}}.
    #   message: |
    #     {{if eq .serviceType "slack"}}:exclamation:{{end}}  The sync operation of application {{.app.metadata.name}} has failed at {{.app.status.operationState.finishedAt}} with the following error: {{.app.status.operationState.message}}
    #     Sync operation details are available at: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}?operation=true .
    #   slack:
    #     attachments: |-
    #       [{
    #         "title": "{{ .app.metadata.name}}",
    #         "title_link":"{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
    #         "color": "#E96D76",
    #         "fields": [
    #         {
    #           "title": "Sync Status",
    #           "value": "{{.app.status.sync.status}}",
    #           "short": true
    #         },
    #         {
    #           "title": "Repository",
    #           "value": "{{.app.spec.source.repoURL}}",
    #           "short": true
    #         }
    #         {{range $index, $c := .app.status.conditions}}
    #         {{if not $index}},{{end}}
    #         {{if $index}},{{end}}
    #         {
    #           "title": "{{$c.type}}",
    #           "value": "{{$c.message}}",
    #           "short": true
    #         }
    #         {{end}}
    #         ]
    #       }]
    # template.app-sync-running: |
    #   email:
    #     subject: Start syncing application {{.app.metadata.name}}.
    #   message: |
    #     The sync operation of application {{.app.metadata.name}} has started at {{.app.status.operationState.startedAt}}.
    #     Sync operation details are available at: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}?operation=true .
    #   slack:
    #     attachments: |-
    #       [{
    #         "title": "{{ .app.metadata.name}}",
    #         "title_link":"{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
    #         "color": "#0DADEA",
    #         "fields": [
    #         {
    #           "title": "Sync Status",
    #           "value": "{{.app.status.sync.status}}",
    #           "short": true
    #         },
    #         {
    #           "title": "Repository",
    #           "value": "{{.app.spec.source.repoURL}}",
    #           "short": true
    #         }
    #         {{range $index, $c := .app.status.conditions}}
    #         {{if not $index}},{{end}}
    #         {{if $index}},{{end}}
    #         {
    #           "title": "{{$c.type}}",
    #           "value": "{{$c.message}}",
    #           "short": true
    #         }
    #         {{end}}
    #         ]
    #       }]
    # template.app-sync-status-unknown: |
    #   email:
    #     subject: Application {{.app.metadata.name}} sync status is 'Unknown'
    #   message: |
    #     {{if eq .serviceType "slack"}}:exclamation:{{end}} Application {{.app.metadata.name}} sync is 'Unknown'.
    #     Application details: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}.
    #     {{if ne .serviceType "slack"}}
    #     {{range $c := .app.status.conditions}}
    #         * {{$c.message}}
    #     {{end}}
    #     {{end}}
    #   slack:
    #     attachments: |-
    #       [{
    #         "title": "{{ .app.metadata.name}}",
    #         "title_link":"{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
    #         "color": "#E96D76",
    #         "fields": [
    #         {
    #           "title": "Sync Status",
    #           "value": "{{.app.status.sync.status}}",
    #           "short": true
    #         },
    #         {
    #           "title": "Repository",
    #           "value": "{{.app.spec.source.repoURL}}",
    #           "short": true
    #         }
    #         {{range $index, $c := .app.status.conditions}}
    #         {{if not $index}},{{end}}
    #         {{if $index}},{{end}}
    #         {
    #           "title": "{{$c.type}}",
    #           "value": "{{$c.message}}",
    #           "short": true
    #         }
    #         {{end}}
    #         ]
    #       }]
    # template.app-sync-succeeded: |
    #   email:
    #     subject: Application {{.app.metadata.name}} has been successfully synced.
    #   message: |
    #     {{if eq .serviceType "slack"}}:white_check_mark:{{end}} Application {{.app.metadata.name}} has been successfully synced at {{.app.status.operationState.finishedAt}}.
    #     Sync operation details are available at: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}?operation=true .
    #   slack:
    #     attachments: |-
    #       [{
    #         "title": "{{ .app.metadata.name}}",
    #         "title_link":"{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
    #         "color": "#18be52",
    #         "fields": [
    #         {
    #           "title": "Sync Status",
    #           "value": "{{.app.status.sync.status}}",
    #           "short": true
    #         },
    #         {
    #           "title": "Repository",
    #           "value": "{{.app.spec.source.repoURL}}",
    #           "short": true
    #         }
    #         {{range $index, $c := .app.status.conditions}}
    #         {{if not $index}},{{end}}
    #         {{if $index}},{{end}}
    #         {
    #           "title": "{{$c.type}}",
    #           "value": "{{$c.message}}",
    #           "short": true
    #         }
    #         {{end}}
    #         ]
    #       }]

  # -- [Tolerations] for use with node taints
  tolerations: []

  # -- The trigger defines the condition when the notification should be sent
  ## For more information: https://argocd-notifications.readthedocs.io/en/stable/triggers/
  triggers: {}
    # trigger.on-deployed: |
    #   - description: Application is synced and healthy. Triggered once per commit.
    #     oncePer: app.status.sync.revision
    #     send:
    #     - app-deployed
    #     when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
    # trigger.on-health-degraded: |
    #   - description: Application has degraded
    #     send:
    #     - app-health-degraded
    #     when: app.status.health.status == 'Degraded'
    # trigger.on-sync-failed: |
    #   - description: Application syncing has failed
    #     send:
    #     - app-sync-failed
    #     when: app.status.operationState.phase in ['Error', 'Failed']
    # trigger.on-sync-running: |
    #   - description: Application is being synced
    #     send:
    #     - app-sync-running
    #     when: app.status.operationState.phase in ['Running']
    # trigger.on-sync-status-unknown: |
    #   - description: Application status is 'Unknown'
    #     send:
    #     - app-sync-status-unknown
    #     when: app.status.sync.status == 'Unknown'
    # trigger.on-sync-succeeded: |
    #   - description: Application syncing has succeeded
    #     send:
    #     - app-sync-succeeded
    #     when: app.status.operationState.phase in ['Succeeded']
    #
    # For more information: https://argocd-notifications.readthedocs.io/en/stable/triggers/#default-triggers
    # defaultTriggers: |
    #   - on-sync-status-unknown

  ## The optional bot component simplifies managing subscriptions
  ## For more information: https://argocd-notifications.readthedocs.io/en/stable/bots/overview/
  bots:
    slack:
      # -- Enable slack bot
      ## You have to set secret.notifiers.slack.signingSecret
      enabled: false

      ## Slack bot Pod Disruption Budget
      ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
      pdb:
        # -- Deploy a [PodDisruptionBudget] for the Slack bot
        enabled: false
        # -- Labels to be added to Slack bot pdb
        labels: {}
        # -- Annotations to be added to Slack bot pdb
        annotations: {}
        # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
        # @default -- `""` (defaults to 0 if not specified)
        minAvailable: ""
        # -- Number of pods that are unavailble after eviction as number or percentage (eg.: 50%).
        ## Has higher precedence over `notifications.bots.slack.pdb.minAvailable`
        maxUnavailable: ""

      ## Slack bot image
      image:
        # -- Repository to use for the Slack bot
        # @default -- `""` (defaults to global.image.repository)
        repository: ""
        # -- Tag to use for the Slack bot
        # @default -- `""` (defaults to global.image.tag)
        tag: ""
        # -- Image pull policy for the Slack bot
        # @default -- `""` (defaults to global.image.imagePullPolicy)
        imagePullPolicy: ""

      # -- Secrets with credentials to pull images from a private registry
      # @default -- `[]` (defaults to global.imagePullSecrets)
      imagePullSecrets: []

      service:
        # -- Service annotations for Slack bot
        annotations: {}
        # -- Service port for Slack bot
        port: 80
        # -- Service type for Slack bot
        type: LoadBalancer

      serviceAccount:
        # -- Specifies whether a service account should be created
        create: true

        # -- The name of the service account to use.
        ## If not set and create is true, a name is generated using the fullname template
        name: argocd-notifications-bot

        # -- Annotations applied to created service account
        annotations: {}

      # -- Slack bot container-level security Context
      # @default -- See [values.yaml]
      containerSecurityContext:
        runAsNonRoot: true
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        seccompProfile:
          type: RuntimeDefault
        capabilities:
          drop:
          - ALL

      # -- Resource limits and requests for the Slack bot
      resources: {}
      # limits:
      #   cpu: 100m
      #   memory: 128Mi
      # requests:
      #   cpu: 100m
      #   memory: 128Mi

      # -- Assign custom [affinity] rules
      affinity: {}

      # -- [Tolerations] for use with node taints
      tolerations: []

      # -- [Node selector]
      nodeSelector: {}

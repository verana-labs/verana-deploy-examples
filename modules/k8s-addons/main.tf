# Cluster add-ons shared by every provider example:
#   - ingress-nginx behind a Service of type LoadBalancer, default ingress class "nginx"
#   - cert-manager with its CRDs
#   - a ClusterIssuer named letsencrypt-prod (HTTP-01 on class nginx)
#
# The Verana charts (vs-agent, indexer, graph, search, frontend) hardcode
# ingressClassName: nginx and the annotation cert-manager.io/cluster-issuer: letsencrypt-prod,
# so these names are not configurable here.

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_version
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = compact([
    yamlencode({
      controller = {
        ingressClassResource = { default = true }
        service = merge(
          {
            type        = "LoadBalancer"
            annotations = var.load_balancer_annotations
          },
          var.load_balancer_ip == "" ? {} : { loadBalancerIP = var.load_balancer_ip }
        )
      }
    }),
    var.ingress_nginx_extra_values,
  ])
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      crds = { enabled = true }
    })
  ]
}

resource "kubectl_manifest" "letsencrypt_prod" {
  depends_on = [helm_release.cert_manager, helm_release.ingress_nginx]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = { name = "letsencrypt-prod" }
    spec = {
      acme = {
        server              = "https://acme-v02.api.letsencrypt.org/directory"
        email               = var.acme_email
        privateKeySecretRef = { name = "letsencrypt-prod-account-key" }
        solvers = [
          { http01 = { ingress = { ingressClassName = "nginx" } } }
        ]
      }
    }
  })
}

# The address the provider gave to the ingress controller, for the DNS record.
data "kubernetes_service_v1" "ingress_nginx" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

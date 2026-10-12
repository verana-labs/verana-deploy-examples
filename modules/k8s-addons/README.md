# k8s-addons module

What every cluster needs before a Verana chart can be installed: ingress-nginx (default ingress class `nginx`, Service of type `LoadBalancer`), cert-manager with CRDs, and a `ClusterIssuer` named `letsencrypt-prod` with the HTTP-01 solver.

The names are fixed on purpose: the Verana charts set `ingressClassName: nginx` and `cert-manager.io/cluster-issuer: letsencrypt-prod` in their templates.

Inputs: `acme_email` (required), `load_balancer_ip` and `load_balancer_annotations` for providers that need a pre-reserved address, chart versions. Outputs: `load_balancer_ip`, `load_balancer_hostname`, whichever the provider fills.

The module expects configured `helm`, `kubernetes` and `kubectl` (alekc/kubectl) providers from the root module; see the `providers.tf` of each provider folder.

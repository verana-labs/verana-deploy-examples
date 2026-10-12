# Graph and search with Helm

Values for the "[Run the graph and search](https://docs.verana.io/docs/build/run-infrastructure/graph-and-search)" guide: the graph follows an indexer (yours from `../indexer/helm`, or the public one) and the search UI sits in front of the graph and the indexer's resolve endpoint.

```bash
kubectl -n verana create secret generic graph-db --from-literal=password="$(openssl rand -base64 24)"
helm upgrade --install graph oci://registry-1.docker.io/veranalabs/verana-graph-chart \
  --version <version> --namespace verana -f values-graph.yaml
curl -s https://graph.example.com/health
curl -s -X POST https://graph.example.com/v4/graph/search -H 'content-type: application/json' \
  -d '{"surface":"Ecosystem","q":"","limit":3}' | jq

helm upgrade --install search oci://registry-1.docker.io/veranalabs/verana-search-chart \
  --version <version> --namespace verana -f values-search.yaml
```

The graph chart has a generic ingress (host, class, TLS secret, annotations are all values); the search chart follows the Verana convention (`{{ host }}.{{ global.domain }}`, class `nginx`, issuer `letsencrypt-prod`).

Status: not yet verified against the v4 testnet.

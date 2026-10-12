# Indexer with Helm

Values for the chart of the [verana-indexer repository](https://github.com/verana-labs/verana-indexer/tree/main/charts), as used by the "[Run the indexer](https://docs.verana.io/docs/build/run-infrastructure/indexer)" guide. Point `RPC_ENDPOINT` and `LCD_ENDPOINT` at your own node when you run one; the public endpoints are traffic-shaped.

```bash
kubectl create namespace verana
kubectl -n verana create secret generic indexer-db --from-literal=password="$(openssl rand -base64 24)"
helm upgrade --install idx oci://registry-1.docker.io/veranalabs/verana-indexer-chart \
  --version <version> --namespace verana -f values.yaml
kubectl -n verana logs -f statefulset/idx -c idx-indexer-container
curl -s https://idx.example.com/v4/indexer/status | jq
```

Storage: the PostgreSQL volume holds the full chain history; start at 50 Gi and expand when needed (see "Storage sizing" in the chart README). Re-indexing after an upgrade that changes the schema: `--set reindex.enabled=true` once, then back to `false`.

Status: not yet verified against the v4 testnet.

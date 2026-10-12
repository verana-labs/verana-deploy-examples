# Frontend with Helm

Values for the chart of the [verana-frontend repository](https://github.com/verana-labs/verana-frontend/tree/main/charts), as used by the "[Run the frontend](https://docs.verana.io/docs/build/run-infrastructure/frontend)" guide. The chart repository also ships `values-devnet.yaml` and `values-testnet.yaml` with the network values; this file is the testnet set with the ingress and node selector made portable.

```bash
helm upgrade --install app oci://registry-1.docker.io/veranalabs/verana-frontend-chart \
  --version <version> --namespace verana -f values.yaml
```

Two things to change on your own cluster: `global.domain`, and `nodeSelector: {}` (the chart's default pins a specific node of the Verana cluster).

Status: not yet verified against the v4 testnet.

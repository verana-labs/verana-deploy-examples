# VS Agent with the official Helm chart

The values the "[Deploy on Kubernetes with Helm](https://docs.verana.io/docs/build/verifiable-services/kubernetes-helm)" guide uses, for the chart published next to the image: `oci://registry-1.docker.io/veranalabs/vs-agent-chart`.

Works on any cluster that has ingress-nginx and cert-manager with a `ClusterIssuer` named `letsencrypt-prod`; the provider folders of this repository create exactly that.

```bash
# 1. secrets (the chart creates none)
VERANA_ACCOUNT_MNEMONIC="$(cat mnemonic.txt)" ./create-secrets.sh agents vs-agent-secrets

# 2. edit values.yaml: global.domain, name, veranaCorporationId, storage.storageClassName, ECS claims

# 3. install
helm upgrade --install agent oci://registry-1.docker.io/veranalabs/vs-agent-chart \
  --version 2.0.0 --namespace agents -f values.yaml
kubectl -n agents rollout status statefulset/agent

# 4. verify
kubectl -n agents port-forward svc/agent 3000:3000 &
curl -s http://127.0.0.1:3000/v2/agent/health/ready
curl -s https://agent.example.com/.well-known/did.json | jq .id
```

| Setting | Why |
|---|---|
| `storage.storageClassName` | `gp3` on AWS, `standard-rwo` on GKE, `managed-csi` on AKS, `csi-cinder-high-speed` on OVHcloud |
| `adminApiAuthMode: internal` | the admin API answers only cluster-internal callers; your backend reaches `http://agent.agents.svc:3000` |
| `extraEnv` | the mnemonic is read from the Secret, never from values |
| `openid4vc.existingSecret` | set it when you issue or verify with OpenID4VC |

Upgrade: bump `image.tag` and `--version`, run the same `helm upgrade`. Rollback: `helm rollback agent`.

Status: not yet verified against the v4 testnet (the chart's 2.0.0 release ships with the 13 October 2026 upgrade).

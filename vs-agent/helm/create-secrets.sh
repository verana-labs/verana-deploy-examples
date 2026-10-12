#!/usr/bin/env bash
# Creates the namespace and the Secret the values.yaml of this folder refers to.
# Usage: VERANA_ACCOUNT_MNEMONIC="word1 ... word24" ./create-secrets.sh [namespace] [secret-name]
set -euo pipefail

NAMESPACE="${1:-agents}"
SECRET="${2:-vs-agent-secrets}"

if [ -z "${VERANA_ACCOUNT_MNEMONIC:-}" ]; then
  echo "Set VERANA_ACCOUNT_MNEMONIC to the agent's BIP-39 mnemonic first (keep it out of your shell history: read it from a file or a secret store)." >&2
  exit 1
fi

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

kubectl -n "$NAMESPACE" create secret generic "$SECRET" \
  --from-literal=VERANA_ACCOUNT_MNEMONIC="$VERANA_ACCOUNT_MNEMONIC" \
  --from-literal=POSTGRES_PASSWORD="$(openssl rand -base64 24)" \
  --from-literal=EVENTS_WEBHOOK_API_KEY="$(openssl rand -hex 32)" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret $SECRET created in namespace $NAMESPACE."

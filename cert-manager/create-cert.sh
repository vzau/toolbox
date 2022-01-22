#!/bin/bash

subdomain=$1
namespace=$2
secret=$(echo $subdomain | tr "." "-")

cat > ${secret}.yaml <<!EOF!
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: kzdv-dev
  namespace: $namespace
spec:
  secretName: ${secret}-tls
  issuerRef:
    name: letsencrypt-zdv
    kind: ClusterIssuer
  dnsNames:
  - $subdomain
!EOF!

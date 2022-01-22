#!/bin/bash

function check_fail() {
  if [[ $? != "0" ]]; then
    echo "Command failed. Exiting"
    exit 1
  fi
}

echo "Starting"
user=$1

if [[ -z "$user" ]]; then
  echo "User is required."
  exit 1
fi

#server=$(kubectl config get-contexts $(kubectl config current-context) --no-headers=true | awk '{ print $4 }')
server=$(kubectl config view -o json --flatten --minify | jq -r '.clusters[0].cluster.server' | tr -d '\n')
check_fail
context=$(kubectl config current-context)
check_fail

echo "- Creating ServiceAccount"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: user-$user
EOF
check_fail

echo "- Looking up secret name"
secret=$(kubectl get serviceaccounts user-$user -o json | jq -r '.secrets[0].name')
check_fail
echo "- found $secret"

echo "- Getting CA Cert"
sa_cacrt=$(kubectl get secret $secret -o json | jq -r '.data["ca.crt"]' | base64 -d)
sa_token=$(kubectl get secret $secret -o json | jq -r '.data["token"]' | base64 -d)
sa_namespace=$(kubectl get secret $secret -o json | jq -r '.data["namespace"]' | base64 -d)

echo "- Creating kubeconfig"
cat <<EOF >$user.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(kubectl get secrets -n kube-system root-ca-cert-publisher-token-ztmlr -o json | jq -r '.data["ca.crt"]' | tr -d '\n')
    server: $server
  name: $context
contexts:
- context:
    cluster: $context
    user: user-$user
  name: user-$user@$context
current-context: user-$user@$context
kind: Config
users:
- name: user-$user
  user:
    token: $sa_token
EOF

#!/bin/bash

user=$1
server=$2

if [[ -z "$user" ]]; then
  echo "No username specified"
  exit 1
fi

if [[ -z "$server" ]]; then
  echo "No server specified"
  exit 1
fi

echo "Creating user $user"

echo "- Generating key"
openssl genrsa -out $user.key 4096
echo "- Creating CSR"
openssl req -new -key $user.key -out $user.csr -subj "/C=US/ST=IL/L=Chicago/O=ZAU Kubernetes/OU=IT/CN=$user"

echo "- Passing to Kubernetes for signing"
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: user-$user
spec:
  groups:
  - system:authenticated
  request: $(cat $user.csr | base64 -w 0)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

echo "- Waiting 5 seconds for provisioning of object"
sleep 5
echo "- Approving certificate request"
kubectl certificate approve user-$user

function wait_for_issued() {
  kubectl get csr user-$user | grep "Approved,Issued"
  if [[ $? != "0" ]]; then
    echo "Waiting..."
    sleep 5
  fi
}

echo "- Waiting for approval and issuance"
wait_for_issued

echo "- Exporting certificate"
kubectl get csr user-$user -o jsonpath='{.status.certificate}' | base64 -d > $user.crt

echo "- Creating kubeconfig"
cacrt=$(kubectl get secrets -n kube-system root-ca-cert-publisher-token-ztmlr -o json | jq -r '.data["ca.crt"]' | tr -d '\n')
#kubectl config set-cluster $server --certificate-authority=$cacrt 
cat <<EOF >$user.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $cacrt
    server: https://$server:6443
  name: $server
contexts:
- context:
    cluster: $server
    user: $user
  name: $server-$user
current-context: $server-$user
kind: Config
preferences: {}
users:
- name: $user
  user:
    client-certificate-data: $(cat $user.crt | base64 -w 0)
    client-key-data: $(cat $user.key | base64 -w 0)
EOF

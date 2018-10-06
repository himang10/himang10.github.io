#!/bin/sh
if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
  echo "This utility needs to two parameter in integer"
  echo "@usage: $ ./create.sh 1 10"
  exit 0
fi

start=$1
end=$2

if [ "$start" -ge "$end" ]
then
  echo "$start is bigger than or equal $end"
else
  echo "============== Setup Starting ===================="

  for (( c=$start; c<=$end; c++ ))
  do
    kubectl config set-cluster --kubeconfig=./zcp-admin-0$c.conf zcp-gdi --server=https://169.56.69.242:32733 --certificate-authority=ca-seo01-zcp-gdi.pem --embed-certs=true
    kubectl config set-context --kubeconfig=./zcp-admin-0$c.conf zcp-gdi --cluster=zcp-gdi
    TOKEN_NAME=$(kubectl get sa -n zcp-system zcp-admin-0$c -o jsonpath="{.secrets[0].name}")
    DECODED=$(kubectl get secret -n zcp-system $TOKEN_NAME -o jsonpath="{.data.token}" | base64 -D)
    kubectl config set-credentials --kubeconfig=./zcp-admin-0$c.conf zcp-admin-0$c@sk.com --token=$DECODED
    kubectl config set-context --kubeconfig=./zcp-admin-0$c.conf zcp-gdi --user=zcp-admin-0$c@sk.com --namespace=ns-zcp-admin-0$c
    kubectl config use-context --kubeconfig=./zcp-admin-0$c.conf zcp-gdi

    echo "...."
  done

  echo "============== Setup Finished ===================="
fi

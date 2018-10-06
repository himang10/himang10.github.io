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
    kubectl create serviceaccount zcp-edu-0$c -n zcp-system
    kubectl label serviceaccount zcp-edu-0$c zcp-user=yes -n zcp-system
    SECRET_NAME=$(kubectl get serviceaccount -n zcp-system zcp-edu-0$c -o jsonpath="{.secrets[0].name}")
    kubectl label secret $SECRET_NAME zcp-user=yes -n zcp-system
    kubectl create namespace ns-zcp-edu-0$c
    kubectl create -f ./resourcequota.yaml -n ns-zcp-edu-0$c
    kubectl create -f ./mem-limit-range.yaml -n ns-zcp-edu-0$c
    kubectl create -f ./cpu-limit-range.yaml -n ns-zcp-edu-0$c
    kubectl create rolebinding rb-zcp-edu-0$c-admin --clusterrole=admin --serviceaccount=zcp-system:zcp-edu-0$c -n ns-zcp-edu-0$c
    echo "...."
  done

  echo "============== Setup Finished ===================="

fi

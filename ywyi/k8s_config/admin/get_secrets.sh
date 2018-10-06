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
    echo "zcp-system zcp-admin-0$c token = "
    TOKEN_NAME=$(kubectl get sa -n zcp-system zcp-admin-0$c -o jsonpath="{.secrets[0].name}")
    DECODED=$(kubectl get secret -n zcp-system $TOKEN_NAME -o jsonpath="{.data.token}" | base64 -D)
    echo $DECODED
    echo "\r\n"
  done

  echo "============== Setup Finished ===================="

fi

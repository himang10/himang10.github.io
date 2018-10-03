---
layout: post
title: Kubctl command
date: 2019-09-12
categories: Kubernetes
tags: [A Tag, kubectl, Lorem, Ipsum]
author: himang10
description: Kubernetes 관련 명령어 set 설명
---

#Kubectl CMD

##kubectl 기본 명령어

```
# cluster-info
kubectl cluster-info
kubectl config current-context
kubectl config use-context
kubectl config view 
kubectl get node --show-labels
```

namespace 변경
```
#change namespace
kubectl config view | grep current-context
kubectl config set-context <current-context> --namespace=study
```
POD 내에서 명령어 실행 방버
```
# docker exec
kubectl exec -it [pod name] -- bash
kubectl exec -it [pod name] -c [container name] -- bash -il
# example
kubectl exec -it node-js-pod sh
```

Context 추가 및 변경
```
# add context
kubectl config view
kubectl config set-context testk --namespace=testkafka --cluster=k8s.nogada.dev --user=admin
# change current-context
kubectl config use-context testk
kubectl config current-context
```

resource 검색 및 상세 검색
```
kubectl get ns
kubectl get [resource type] [resource-name] --namespace=kube-system or --all-namespaces

## checking detail status
kubectl describe [resource type] [resource-name] --namespace=kube-system or --all-namespaces
````
Pod Log 상세 검색
```
  # check Pod Logs
  kubectl logs pod [pod-name]
  # Return snapshot logs from pod nginx with only one container
  kubectl logs nginx

  # Return snapshot logs for the pods defined by label app=nginx
  kubectl logs -lapp=nginx

  # Return snapshot of previous terminated ruby container logs from pod web-1
  kubectl logs -p -c ruby web-1

  # Begin streaming the logs of the ruby container in pod web-1
  kubectl logs -f -c ruby web-1

  # Display only the most recent 20 lines of output in pod nginx
  kubectl logs --tail=20 nginx

  # Show all logs from pod nginx written in the last hour
  kubectl logs --since=1h nginx

  # Return snapshot logs from first container of a job named hello
  kubectl logs job/hello

  # Return snapshot logs from container nginx-1 of a deployment named nginx
  kubectl logs deployment/nginx -c nginx-1
```

Configmap 생성 및 상세 검색
```
kubectl create configmap $map_name --from-file /PATH/filename or /PATH/
kubectl create configmap literal-data --from-literal key1=value1 --from-literal key2=val2
kubectl describe configmaps $name
kubectl get configmaps  $nam [-o yaml]
```

yaml file을 이용하여 리소스를 생성 
```
kubectl create -f ./my-manifest.yaml           # create resource(s)
kubectl create -f ./my1.yaml -f ./my2.yaml     # create from multiple files
kubectl create -f ./dir                        # create resource(s) in all manifest files in dir
kubectl create -f https://git.io/vPieo         # create resource(s) from url
```

resource 설명
> kubectl explain pods,svc                       # get the documentation for pod and svc manifests

resource 실행
```
  # Start a single instance of nginx.
  kubectl run nginx --image=nginx

  # Start a single instance of hazelcast and let the container expose port 5701 .
  kubectl run hazelcast --image=hazelcast --port=5701

  # Start a single instance of hazelcast and set environment variables "DNS_DOMAIN=cluster" and "POD_NAMESPACE=default"
in the container.
  kubectl run hazelcast --image=hazelcast --env="DNS_DOMAIN=cluster" --env="POD_NAMESPACE=default"

  # Start a single instance of hazelcast and set labels "app=hazelcast" and "env=prod" in the container.
  kubectl run hazelcast --image=nginx --labels="app=hazelcast,env=prod"

  # Start a replicated instance of nginx.
  kubectl run nginx --image=nginx --replicas=5

  # Dry run. Print the corresponding API objects without creating them.
  kubectl run nginx --image=nginx --dry-run

  # Start a single instance of nginx, but overload the spec of the deployment with a partial set of values parsed from
JSON.
  kubectl run nginx --image=nginx --overrides='{ "apiVersion": "v1", "spec": { ... } }'

  # Start a pod of busybox and keep it in the foreground, don't restart it if it exits.
  kubectl run -i -t busybox --image=busybox --restart=Never

  # Start the nginx container using the default command, but use custom arguments (arg1 .. argN) for that command.
  kubectl run nginx --image=nginx -- <arg1> <arg2> ... <argN>

  # Start the nginx container using a different command and custom arguments.
  kubectl run nginx --image=nginx --command -- <cmd> <arg1> ... <argN>

  # Start the perl container to compute π to 2000 places and print it out.
  kubectl run pi --image=perl --restart=OnFailure -- perl -Mbignum=bpi -wle 'print bpi(2000)'

  # Start the cron job to compute π to 2000 places and print it out every 5 minutes.
  kubectl run pi --schedule="0/5 * * * ?" --image=perl --restart=OnFailure -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```
resource 삭제
```
## delete
kubectl delete -f ./pod.json                                              # Delete a pod using the type and name specified in pod.json
kubectl delete pod,service baz foo                                        # Delete pods and services with same names "baz" and "foo"
kubectl delete pods,services -l name=myLabel                              # Delete pods and services with label name=myLabel
kubectl delete pods,services -l name=myLabel --include-uninitialized      # Delete pods and services, including uninitialized ones, with label name=myLabel
kubectl -n my-ns delete po,svc --all                                      # Delete all pods and services, including uninitialized ones, in namespace my-ns,
```

persistent volume을 정의하고 Pod 등에서 필요로 하는  Storage Class를 정의한다. Claim은 statefulset에서 설정
persistent volume & persistence volume chaims & Storage Class
```
## PV & PVC & StorageClass 
kubectl -n testkafka describe pvc
kubectl get storageclass | sc
````
<code>
```
# persistent volume for local node disk volume
piVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem·
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: postgre-storage
  local:
    path: /vagrant/vm_pv
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - k8s1.nogada.dev
          - k8s2.nogada.dev
          - k8s3.nogada.dev
```
</code>

````
# Storage Class
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: postgre-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
````

#kube label view
kubectl get <nodes, pods> --show-labels

#kube info widw
kubectl get <nodes | pods> -o wide

kubectl create configmap game-config-env-file --from-env-file=docs/tasks/configure-pod-container/game-env-file.properties
------ game-env-file.properties
# Env-files contain a list of environment variables.
# These syntax rules apply:
#   Each line in an env file has to be in VAR=VAL format.
#   Lines beginning with # (i.e. comments) are ignored.
#   Blank lines are ignored.
#   There is no special handling of quotation marks (i.e. they will be part of the ConfigMap value)).


cat docs/tasks/configure-pod-container/game-env-file.properties
enemies=aliens
lives=3
allowed="true"

# This comment and the empty line above it are ignored
-----

## env
kubectl -n kube-system  exec tiller-deploy-759cb9df9-jhgvc -- printenv

# service info & DNS infos
kubectl -n kube-system describe svc kubernetes-dashboard
kubectl -n kube-system exec [pod name] -- yaml cmd execution
kubectl -n kube-system exec [pod-name with command flag] -- nslookup hue-reminders

-----
# nginx creation and test

kubectl run nginx --image=nginx --replicas=2
kubectl expose deployment nginx --port=80
kubectl get svc,pod

# busybox로 container 실행후 통신 실행
kubectl run busybox --rm -ti --image=busybox /bin/sh
wget --spider --timeout=1 nginx

# limit access to the nginx service
kubectl create -f nginx-policy.yaml

#Test access to the serivce when access label is not defined
#If we attempt to access the nginx Service from a pod without the correct labels, the request will now time out:
kubectl run busybox --rm -ti --image=busybox /bin/sh
wget --spider --timeout=1 nginx

kubectl run busybox --rm -ti --labels="access=true" --image=busybox /bin/sh
or 
kubectl exec -it busybox sh -n testkaka
## 접속후
nslookup
vi /etc/hosts
cat /etc/resolv.conf

wget --spider --timeout=1 nginx
dig naver.com



kubectl get pod --show-all | -a
## single command exectuion
## SErvice Name: svce_name or svc_name.{namespace}.svc.cluster.local
## POD Name: {pod_name}.{namespace}.pod.cluster.local
kubectl exec node-js-pod -- curl <node-js-intenal IP -- Cluster IP | Service Name | Pod IP>
## shell execution
kubectl exec -it node-js-pod sh

##  rolling update --> 단계적으로 한개씩 변경 실행
kubectl scale --current-replicas=2 --replicas=3 rc node-js-scale
kubectl rolling-update node-js-scale --image=jonbaier/pod-scaling:0.2 --update-priod="2m"
kubectl rolling-update node-js-scale node-js-scale-v2.0 --image=jonbaier/pod-scaling:0.2 --update-period="30s"
## rollout --> 버전을 그냥 교체하는 방법 (deployment rollout) - n개를 동시에 살리고 죽인다.
kubectl set image deployment node-js-deploy node-js-deploy=jonbaier/pod-scaling:0.2
kubectl rollout status deployment node-js-deploy

kubectl rollout history deployment node-js-deploy
## rollout undo
kubectl rollout undo deployment node-js-deploy

## pod autoscaling (HorizontalPodAutoscaler)
kubectl get hpa  


kubectl create -f node-js-deploy.yaml --record


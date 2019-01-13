---
layout: post
title: Kubctl 명령어 2
date: 2019-09-12
categories: Kubernetes
tags: [A Tag, kubectl, Lorem, Ipsum]
author: himang10
description: Kubernetes 관련 명령어 set 설명 두번째
---
# Table of Contents
1. [Kubectl 인증](#Kubectl-인증)
1. [환경변수로 적용](#환경변수로-적용)
1. [TLS 트래픽을 처리하기 위한 인그레스 설정](#TLS-트래픽을-처리하기-위한-인그레스-설정)
1. [Container 내 명령어 실행](#Container-내-명령어-실행)
1. [namespace 변경](#namespace-변경)
1. [docker 기반 테스트 구성](#docker-기반-테스트-구성)
1. [label](#label)
1. [api version 확인](#api-version-확인)
1. [api raw level query](#api-raw-level-query)
1. [Kube 정보 검색](#Kube-정보-검색)
1. [port-forward](#port-forward)



# Kubeclt cmd 두번째

## Kubectl 인증
> boot node의 "/opt/ibm-cloud-private-3.1.1/cluster/cfc-certs/kubernetes/kubecfg.crt, kubecfg.key"를 .ssh에 복사해서 사용
```
# cluster 접속
# ice 설치 시 설치되어 있는 crt 와 key값을 가져와서 설정 해야 함. 설치되어 있는 위치는 다음과 같다
# boot node의 /opt/ibm-cloud-private-3.1.1/cluster/cluster/cfc-certs/kuberentes/*.crt .key
kubectl config set-cluster mycluster --server=https://196.90.1.94:8001 --insecure-skip-tls-verify=true && kubectl config set-context mycluster --cluster=mycluster && kubectl config set-credentials admin --client-certificate=/Users/himang10/.ssh/kubecfg.crt --client-key=/Users/himang10/.ssh/kubecfg.key && kubectl config set-context mycluster --user=admin && kubectl config use-context mycluster
```

위의 내용을 실행하면 ~/.kube 아래에 아래의 config file이 생성됨
```yaml
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://196.90.1.94:8001
  name: mycluster
contexts:
- context:
    cluster: mycluster
    user: admin
  name: ""
- context:
    cluster: ""
    namespace: ywyi
    user: admin
  name: mycluster
- context:
    cluster: mycluster
    namespace: ywyi
    user: admin
  name: mycluster-context
current-context: mycluster-context
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate: /Users/himang10/ywyi/icp3.1/cfc-certs/kubernetes/kubecfg.crt
    client-key: /Users/himang10/ywyi/icp3.1/cfc-certs/kubernetes/kubecfg.key
```

## 환경변수로 적용
앞의 kube 인증 처리 구조와 namespace 변경
```
# .icp.env

kubectl config set-cluster mycluster --server=https://196.90.1.94:8001 --insecure-skip-tls-verify=true && kubectl config set-context mycluster-context --cluster=mycluster && kubectl config set-credentials admin --client-certificate=/Users/himang10/ywyi/icp3.1/cfc-certs/kubernetes/kubecfg.crt --client-key=/Users/himang10/ywyi/icp3.1/cfc-certs/kubernetes/kubecfg.key && kubectl config set-context mycluster-context --user=admin --namespace=ywyi && kubectl config use-context mycluster-context

export HELM_HOME=~/ywyi/icp3.1/.helm

alias kcns='kubectl config set-context $(kubectl config current-context) --namespace'
```

## TLS 트래픽을 처리하기 위한 인그레스 설정
1. 인그레스 컨트롤더 등 TLS 연결을 위한 키 생성 및 secret 생성
```
# ingress control로 아래의 도메인으로 접속하고자 할때 필요한 
# 개인 키 (tls.key) & 인증서 (tls.cert) - 개인키로 인증서를 만들어서 전달하면 public key로 풀리면 내가 맞다는 이야기
$ openssl genrsa -out tls.key 2048
$ openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj /CN=kubia.example.com
# 시크릿 생성 
$ kubectl create secret xls tis-secret —cert=tls.cert —key=tls.key
```

2. TLS 트래픽을 핸들리하는 인그레스 : kubia-ingress-tls.yaml
```yaml
apiVersion: extensions/v1beta1
Kind: Ingress
Metadata:
  Name:kubia
Spec:
  tls:  /* 전체 TLS 구성은 이 속성 이하에 위치 */
   - hosts: 
     - kubia.example.com
       secretName: tls-secret
    rules:
  - host: kubia.example.com
    http:
     paths:
     - path: /
       backend:
           serviceNAme: kubia-nodeport
           servicePort: 80
````

## Container 내 명령어 실행
```
$kubectl exec kubia-7nog1 — curl -s http://10.111.249.153
````

## namespace 변경
```
alias kcd ='kubectl config set-context $(kubectl config current-context) --namespace'
#그리고
kcd some-namespace
````

## docker 기반 테스트 구성
```
# deployment expose
$kubectl expose deployment kubia --port=80 --target-port=8080

#병렬로 다수의 리소스 감시
watch -n 1 kubectl get hpa,deployment --all-namespaces

$kubectl run -it --rm --restart=Never loadgenerator --image=busybox -- sh -c "while true;  do wget -O - -q http:/kubia.default; done"
````

## label 
```
kubectl get po --show-labels
kubeclt get po -L creation_method, env (value)
# label add
kubectl label po kubia-manual creation_method=manual
#label modification
kubectl label po kubia-manual-v2 env=debug --overwrite
````

## api version 확인
```
kubectl api-versions | grep autoscaling
````

## api raw level query
```
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq .
````

## Kube 정보 검색
```
Kubectl get nodes -o jsonpath=‘{.item[*].status.address[?(type==“ExternalIP”)].address}'
````

## port-forward
```
kubectl port-forward forune 8080:80
``
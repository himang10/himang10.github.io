---
layout: post
title: k8s에서 고급 스케쥴링 (Taint & Affinity)
date: 2019-01-06
categories: Kubernetes
tags: [A kubernetes, taint, affinity]
author: himang10
description: 고급 스케쥴링
---
고급 스케쥴링
============

## Table of Contents
1. [개요](#개요)
2. [Taint and Toleration](#Taint-and-Toleration)
3. [Node Taint](#Node-Taint)
3. [Taint Effect](#Taint-Effect)
3. [User-defined Taint](#User-defined-Taint)
3. [Affinity](#Affinity)
3. [Node Affinity기반 노드지정](#Node-Affinity기반-노드지정)
3. [노드우선순위지정](#노드우선순위지정)
3. [Pod Affinity & AntiAffinity](#Pod-Affinity-&-AntiAffinity)
3. [Pod Affinity](#Pod-Affinity)
3. [Pod AntiAffinity](#Pod-AntiAffinity)

## 개요
Affinity는 Pod에 노드 친화성 규칙을 적용하는 방식
Taint는 노드에 taint를 추가하여 특정 노드에 포드 배포를 거부하는 방식

## Taint and Toleration
> 목적: Taint 노드는 스케쥴링되지 않도록 하고 toerations 선언된 Pod만을 여기에 스케쥴링 할 수 있도록 지정
> 또는 기존에 돌고 있는 Pod를 제거 할 수 있도록 하는 방법 --> 제거 시 다른 곳으로 Deployment가 됨

### Node Taint
mster node의 기본 taint 정보
```
$ kubectl describe node 10.100.1.8
Name:               10.100.1.8
Roles:              etcd,management,master,proxy
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    etcd=true
                    kubernetes.io/hostname=10.100.1.8
                    management=true
                    master=true
                    node-role.kubernetes.io/etcd=true
                    node-role.kubernetes.io/management=true
                    node-role.kubernetes.io/master=true
                    node-role.kubernetes.io/proxy=true
                    proxy=true
                    role=master
Annotations:        node.alpha.kubernetes.io/ttl=0
                    volumes.kubernetes.io/controller-managed-attach-detach=true
Taints:             dedicated=infra:NoSchedule
```
> 기본 Taint의 표기법은 key, value, effect가 있고 <key>=<value>:<effect>

Taints가 dedicated=infra:NoSchedule로 되어 있어서 
```yaml
Tolerations:
    dedicated=infra:NoSchedule
```
만이 Taint 된 Node에 배포가능하다

### Taint Effect
* NoSchedule
> 노드가 Taint를 허용하지 않는 경우 Pod가 Node에 스케쥴링되지 않음

* PreferNoSchedule
> 기본은 NoSchedule. 그러나, 다른데 배포할 수 없는 상황에서는 Taint 허용이 되지 않더라도 스케쥴링 됨

* NoExecute
> NoSchedule을 스케쥴에만 영향을 주지만, 이것은 실행 중인 Pod에도 영향을 줌
> Taint허용되지 않는 Pod는 배포도 안되며, 이미 배포되어 있더라도 제거된다.

### User-defined Taint 
1. 노드에 사용자 정의 테인트 추가
```
kubectl taint node node1.k8s node-type=production:NoExecute
```

2. Toleration 추가
```yaml
$ cat production-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: prod
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: prod
    spec:
      containers:
      - args:
        - sleep
        - "99999"
        image: busybox
        name: main
      tolerations:
      - key: node-type
        operator: Equal
        value: production
        effect: NoSchedule
````
> toleration은 operator로 Equal , Exists 가 사용
> Equal을 이용하여 특정 값을 지정할 수 있으며, Exist 연산자를 사용하여 특정 Taint key의 값을 허용

## Affinity 
### Node Affinity기반 노드지정
* Node Selector 사용 노드
```yaml
$ cat kubia-gpu-nodeselector.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kubia-gpu
spec:
  nodeSelector:
    gpu: "true"
  containers:
  - image: luksa/kubia
    name: kubia
````

* Node Affinity 규칙 적용
```yaml
$ cat kubia-gpu-nodeaffinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kubia-gpu
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: gpu
            operator: In
            values:
            - "true"
  containers:
  - image: luksa/kubia
    name: kubia
````
* NodeAffinity Attribute 
 - requiresDuringScheduling...
    Pod를 특정 노드에 스케쥴링을 위해 노드가 가지고 있어야 하는 Label 
 - ...IngoredDuringExecution
    이미 실행 중인 포드에는 영향을 주지 않음
 - ...RequiredDuringExecution
   노드에서 Label을 제거하면 현재 실행 중인 Pod는 새로운 Affinity에 따라 제 스케쥴링 됨

### 노드우선순위지정
* preferredDuringSchedulingIngoredDuringExecution
선호하는 노드친화성 Deployment
```yaml
$ cat preferred-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pref
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: pref
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 80 # 분산 배포
            preference:
              matchExpressions:
              - key: availability-zone
                operator: In
                values:
                - zone1
          - weight: 20
            preference:
              matchExpressions:
              - key: share-type
                operator: In
                values:
                - dedicated
      containers:
      - args:
        - sleep
        - "99999"
        image: busybox
        name: main
````

## Pod Affinity & AntiAffinity
Pod간 친화성 지정
> Front-end와 Backend가 서로 가까이 배치될 수 있다면 대기 시간을 줄이고 애플리케이션 성능을 향상 시킬 수 있다

### Pod Affinity
* requiredDuringSchedulingIgnoredDuringExecution
```yaml
$ cat frontend-podaffinity-host.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: frontend
    spec:
      affinity:
        podAffinity: # Pod Affinity Rule 정의
          requiredDuringSchedulingIgnoredDuringExecution: # 선호도가 아니라 엄격한 요구사항 정의
          - topologyKey: kubernetes.io/hostname # Node의 Label key: 어떤 key라도 상관없음 
            labelSelector:
              matchLabels:
                app: backend
      containers:
      - name: main
        image: busybox
        args:
        - sleep
        - "99999"
```
> name=frontend deployment로 배포되는 container는 app=backend Pod와 동일한 node (kubernetes.io/hostname) 에 같이 배포

> 예외상황: backend를 삭제 후 다시 다른 노드에 backend가 배포되면 Pod Affinity는 걔진다. 

* preferredDuringSchedulingIgnoredDuringExecution
```yaml
$ cat frontend-podaffinity-preferred-host.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: frontend
    spec:
      affinity:
        podAffinity:
          preferredDuringSchedulingIgnoredDuringExecution: # 선호하는 것
          - weight: 80
            podAffinityTerm:
              topologyKey: kubernetes.io/hostname
              labelSelector:
                matchLabels:
                  app: backend
      containers:
      - name: main
        image: busybox
        args:
        - sleep
        - "99999"
```

### Pod AntiAffinity
app:frontend Pod는 app:frontend level이 있는 Pod와 동일한 시스템으로 스케쥴되지 않는다.
Replicaset으로 복제 Pod간에 동일 노드에 배포되는 것을 방지한다.

```yaml
$ cat frontend-podantiaffinity-host.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: frontend
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - topologyKey: kubernetes.io/hostname
            labelSelector:
              matchLabels:
                app: frontend
      containers:
      - name: main
        image: busybox
        args:
        - sleep
        - "99999"
````



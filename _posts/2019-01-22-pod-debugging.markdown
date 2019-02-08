---
layout: post
title: POD 내 명령어 호출 방식
date: 2019-01-24
categories: Kubernetes
tags: [A kubernetes, POD, call]
author: himang10
description: POD 직접 호출 방식
---
POD 직접 내부 명령어 호출 방식 정의
==================

# Table of Contents
1. [Pod 내 서비스 호출 방식](#Pod-내-서비스-호출-방식)
2. [docker를 실제 run해서 내부에서 실행하는 방식](#docker를-실제-run해서-내부에서-실행하는-방식)


## Pod 내 서비스 호출 방식
1. kubectrl proxy
````
kubectl proxy
````

2. port-forward
````
kubectl port-forward pods/redis-master-765d459796-258hz 6379:6379
kubectl port-forward deployment/redis-master 6379:6379 
kubectl port-forward svc/redis-master 6379:6379

````


3. api server 호출 방식
api server를 통해 직접 pod나 서비스를 호출하는 방법
```
curl localhost:8001/api/v1/namespaces/<namespace name>/pods/<podname>/proxy/<path>
curl localhost:8001/api/v1/namespaces/<namespace name>/services/<servicename>/proxy/<path>
```

4. api server를 통해 클러스터 내부의 서비스에 연결 방법
서비스에 대한 프록시 요청 URI 경로는 다음과 같이 구성된다.
> /api/v1/namespaces/<namespace>/services/<service name>/proxy/<path url in pod>
    
```
$kubectl proxy
Starting to server on 127.0.0.1:8001

$curl localhost:8001/api/v1/namespaces/default/services/kubia-public/proxy/
your're hit kubia-1
data stored on this pod: No data posted yet
````

## docker를 실제 run해서 내부에서 실행하는 방식
명령어를 포함하는 docker image를 직접 실행하여 명령 실행 하는 방식
```
$ docker search tutum
NAME                      DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
tutum/mongodb             MongoDB Docker image – listens in port 27017…   224                                     [OK]
tutum/influxdb            InfluxDB image - DEPRECATED. See https://doc…   221                                     [OK]
tutum/hello-world         Image to test docker deployments. Has Apache…   59                                      [OK]
tutum/grafana             Grafana dashboard for InfluxDB. Please set "…   57                                      [OK]
tutum/jboss               JBoss image - listens in port 8080, 9990. Fo…   56                                      [OK]
tutum/haproxy             HAProxy image that load balances between any…   47
tutum/centos              Simple CentOS docker image with SSH access      43
tutum/mysql               Base docker image to run a MySQL database se…   31
tutum/buildstep           Convert your application into a self-suffici…   23                                      [OK]
tutum/rabbitmq            Base docker image to run a RabbitMQ server      19
tutum/ubuntu              Simple Ubuntu docker images with SSH access     18
tutum/curl                Base ubuntu image with curl preinstalled        17                                      [OK]
tutum/logrotate           [Tutum System Image] Truncates container log…   16                                      [OK]
tutum/builder             Build, test and push a docker image inside a…   11                                      [OK]
tutum/cleanup             [Tutum System Image] Cleans up unused images…   7
tutum/cli                 CLI tool for Tutum                              6                                       [OK]
tutum/quickstart-python   Tutorial for getting started with Python app…   6                                       [OK]
tutum/dnsutils            Provides DNS utilities like dig and nslookup    5                                       [OK]
tutum/newrelic-agent      Dockerized version of New Relic's Server Mon…   5                                       [OK]
tutum/node                Run a Tutum node inside a container             4                                       [OK]
tutum/ntpd                [Tutum System Image] Keeps the host time in …   2                                       [OK]
tutum/events              [Tutum System Image] Sends docker events to …   1
tutum/docker-update       [Tutum System Image] Upgrades docker in Tutu…   0                                       [OK]
tutum/weave-daemon        [Tutum System Image] Provides a secure overl…   0
tutum/metrics             [Tutum System Image] Sends container and nod…   0
````
그 외 필요한 것이 있을 경우 
````
docker search {name}
````

tutum images를 이용하여 명령어 실행
- lookup 기능 실행 방식
```
# srvlookup이라는 일회용 포트 (--restart=Naver)를 실행한다. 이 포드는 콘솔(-it)에 연결돼 종료되자 마자 바로 삭제된다(--rm). 
# 포드는 tutum/dnsutils 이미지에서 단일 컨테이너를 실행하고 dig 명령어를 싷앻한다.
kubectl run -it srvlookup --image=tutum/dnsutils --rm --restart=Never -- dig SRV kubia.default.svc.cluster.local
kubectl run -it testifconfig --image=alpine --rm --restart=Never -- ifconfig
kubectl run -it curtest --image=tutum/curl --rm --restart=Naver -- curl .... 
````

## 프로세스 종료 원인 제공
kubectl describe pod 내 Message에 종료 시 정의한 메시지를 포함시키는 방법
```
apiVersion: v1
kind: Pod
metadata:
  name: successful-pod-with-termination-message
spec:
  restartPolicy: OnFailure
  containers:
  - image: busybox
    name: main
    command:
    - sh
    - -c
    - 'echo "I''ve completed my task" > /var/termination-reason ; exit 0'
    *terminationMessagePath*: /var/termination-reason
```
```
    State:       Waiting
      Reason:    CrashLoopBackOff
    Last State:  Terminated
      Reason:    Error
      Message:   I've completed my task
```

## Application Log handing
컨테이너가 크래쉬되고 새 컨테이너로 교체되면 새 컨테이너의 로그가 표신된다. 이전 컨테이너의 로그를 보려면 
```
kubectl logs pod -c conatiner --previous
````

````
kubectl exec <pod> cat <logfile>
# pod의 foo.log을 로컬로 복사
kubectl cp foo-pod:/var/log/foo.log foo.log

# local file을 pod에 복사
kubectl cp localfile foo-pod:/etc/remotefile | foo-pod:/etc/
````

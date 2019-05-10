---
layout: post
title: deployment
date: 2019-04-24
categories: kubernetes
author: himang10

tags: [kubernetes, deployment]
---

1. [xxx](#xxx)
2. [xxx](#xxx)
3. [xxx](#xxx)

### minReadySeconds
새로 생성된 Pod가 사용 가능한 상태로 전환하기 전 준비 상태로 머무는 시간의 지정한다. 이 시간동안 준비 상태로 존재한다. 
이 시간 내에 Readiness Probe로 준비 상태가 아님을 확인하게 되면 더이상 롤링 업데이트를 수행하지 않게 된다. 

### deployment 명령
```
$kubectl create -f kubia-deployment-v1.yaml --record

$ kubectl patch deployment kubia -p '{"spec": {"minReadySecond": 10}}'

# image 변경
# container name=nodejs, image=luksa/...
$ kubectl set image deployment kubia nodejs=kuksa/kubia:v2

#rollout status
$ kubectl rollout status deployment kubia

# rollout undu
$ kubectl rollout undo deployment kubia

# rollout history
$ kubectl rollout history deployment kubia

# 특정 리비전으로 rollback
$ kubectl rollout undo deployment kubia --to-revision=1
````

### roll-out 속도 통제

```yaml
spec:
    strategy:
        rollingUpdate:
            maxSurge: 1
            maxUnavailable: 0
        type: RollingUpdate
````
* maxSurge
rolling update 시 기존 replicaset 개수외에 추가적으로 뜨는 Pod 수 표시.
예를들어, replicaset=3이고 maxSurge=1이면 롤링업데이트 시 새로운 버전으로 업데이트 시 총 4개의 Pod가 기동된다. 

* maxUnavailable
maxUavailable은 롤링 업데이트 시 일시적으로 unavaible될 수 있는 개수를 의미.
예를들어, maxSurge=1이고 maxUnavaible=0이면, 롤링 업데이트 시 1개씩의 Pod만이 업데이트 될 수 있다. 
maxSurge=1, maxUnavaible=1이면, 롤링 업데이트 시 2개씩 Pod 업데이트될 수 있음
> 책은 406 Page 참고

### Rollout의 일시 중지를 통해 Canary release 적용
이미지를 변경 후 롤아웃을 수행하고 이후 즉시 (몇초 이내) 롤아웃을 일지 중지하는 방법으로 카나리를 적용
이를 통해 일부만 롤아웃이 된되.
```
$ kubectl set image deployment kubia nodejs=luksa/kubia:v4

$ kubectl rollout pause deployment kubia

# rollout 재개
$kubectl rollout resume deployment kubia
````
> 만약 undo를 실행하고자 한다면 kubectl rollout undo를 실행하면 된다. 단, puase 단계에서는 resume 실행 시점부터 undo가 동작한다.

### Readiness Probe와 minReadySeconds를 통해 잘못된 버전으로 롤아웃되는 것을 방지 하는 방법
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: kubia
spec:
  replicas: 3
  minReadySeconds: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      name: kubia
      labels:
        app: kubia
    spec:
      containers:
      - image: luksa/kubia:v3
        name: nodejs
        readinessProbe:
          periodSeconds: 1
          httpGet:
            path: /
            port: 8080
````
새 포드가 시작되자 마자 레디네스 프로브가 매초 시작된다. (현재 프로브 간격이 1초). 만약 애플리케이션 상에 10초 내에 프로브가 HTTP 상태코드를 500을 반환하는 경우 애프리케이션 준비가 실패가 된다.
이렇게 되면 포드는 서비스의 엔드포인트가 제거된다.
그러나 롤아웃 프로세스는 어떤가? rollout status 명령을 수행하면 하나의 새 복제본만 시작된 상태이며, 사용할 수 없는 상태로 남아 있다. 
여기서 maxUnavaible=0이므로 기존 Pod를 제거 하지 않았다. 

### Roll out deadline 설정
기본적으로 Roll out이 10분 안에 진행되지 않으면 실패한 것으로 간주하고 자동 롤아웃이 자동 중단된다. 
progressDeadlineSeconds

### Failed Deployment
Deployment는 다음과 같은 상황에 의해 배포가 막힐 수 있다.
* Insufficient quota
* Readiness probe failures
* Image pull errors
* Insufficient permissions
* Limit ranges
* Application runtime misconfiguration

One way you can detect this condition is to specify a deadline parameter in your Deployment spec
> 기본적으로 10분 안에 진행되지 않으면 실패한 것으로 간주하고 자동 롤 아웃이 자동 중단된다.

또는 배포에 다음과 같은 설정을 통해 변경할 수 있다.
```
kubectl patch deployment.v1.apps/nginx-deployment -p '{"spec":{"progressDeadlineSeconds":600}}'
```

Once the deadline has been exceeded, the Deployment controller adds a DeploymentCondition with the following attributes to the Deployment’s .status.conditions:

Type=Progressing
Status=False
Reason=ProgressDeadlineExceeded

### graceful shutdown for POD
포드 종료를 kubernetes에서 결정하면 일녕의 이벤트가 발생합니다.
1. 포드가 "Terminating" 상태로 설정되고 모든 service의 endpoint로부터 삭제된다.
새로운 트래픽을 받는 것을 먼준다. 그리고 Pod내에 실행되는 컨테이너는 영향을 받지 않는다. 
그리고 kubelet은 아래의 Hook을 호출하고, SIGnal을 호출한다.

2. PreStop Hook이 실행된다. (SIGTERM SIGNNAL을 받을 수 없을 때 이것을 사용하라)
Pod내 Container에 보내지는 special command 또는 http request이다. 
만약 app이 SIGTERM signal을 받았을 때 gracefull로 shutdown되지 않으면, graceful shutdown을 triggering하기 위해 이 hook을 사용할 수 있다. 
대부분의 프로그램은 SIGTERM Signal을 받았을 때 자연스럽게 graceful shutdown을 수행하지만, third party와 연결되거나 통제할 수 없는 시스템을 함께 연결되어 있다면, 이 훅을 이용할 수 있다. 

3. SIGTERM signal이 Pod로 보내진다. 
Kuberentes는 Pod 내 container에 SIGTERM signal을 전달하면, 코드에서는 이벤트를 listen하고 있다가 이지점에서 shutdown 작업을 실행한다.
에를들어, Long-lived connection을 stop시키거나 현재 상태를 저장하거나 등등


4. kubernetes는 grace period동안 기다린다. 
이점에서 kubernetes는 termination grace period동안 대기한다. 기본으로 30 second이다. 이것은 preStop과 SIGTERM signal이 동시에 발생한다는 것을 주목해야 한다.
kubernetes는 preSTop hook이 끝나기를 기다리진 않는다. 
만약 shutdown이 30 second 이상 걸린다면, grace period를 늘여야 한다.  

```yanl
apiVersion: vi
kind: Pod
metadata:
    name: my-pod
spec:
    containers:
    - name: my-container
      image: busybox
    terminationGracePeriodSeconds: 60
````

5. SIGKILL Siganl이 Pod로 보내지고, Pod는 삭제된다.
container가 아직 실행되고 있다면, SIGKILL signal을 보내지고 강제로 삭제된다. 
이 시점에 모든 Object는 잘 삭제된다. 

#### PreStop

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.15
        ports:
        - containerPort: 80
        lifecycle:
          preStop:
            exec:
              command: [
                # Gracefully shutdown nginx
                "/usr/sbin/nginx", "-s", "quit"
              ]
              
````

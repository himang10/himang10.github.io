---
layout: post
title: Internal Mechanism of kubernetes
date: 2019-03-25
categories: kubernetes
author: himang10
tags: [kubernetes, core, internal]
---


### API Server
kuberenetes component는 오직 API Server와만 통신한다. 서로 직접 통신하지 않는다.
API server는 etcd와 통신할 수 있는 유일한 컴포넌트이다. 
etcd와 직접 통신할 수 있는 컴포넌트는 없지만 대신 API Setver와 통신하도록 클러스터 상태를 변경할 수 있다. 

단, log를 가져오기 위해 실행중인 컨테이너 연결하기 위해 attach, exec port-foward 명령을 사용할때에는 API server가 직접 kubelet에 먼저 연결한다.

### etcd 
* 저장된 오브젝트의 일관성과 유효성 보장
api server의 낙관적 동시성 제어와 validation check를 통해 보장

```
# 낙관적 동시성 제어 #
낙관적 동시성 제어는 데이터를 잠그고 일지 못하도록 하는(비관적 동시성 제어) 대신 잠금이 필요한 위치에서 데이터가 업데이트되면 해당 데이터 조각에 버전 번호를 포함하는 것이다.
매번 데이터가 업데이트되면 버전 번호도 증가된다. 데이터가 업데이트됐을 때 클라이언트가 데이터를 읽은 시간과 업데이트가 요청된 시간 사이에 버전 번호가 증가됐는지를 체크를 한다.
증가되면 업데이트는 거절되고 클라이언트는 새로운 데이터를 다시 읽고 업데이트를 다시 시도한다.
그 결과 두 클라이언트가 같은 데이터에 업데이트를 시도했을 때 오직 하나의 클라이언트만 성공하게 된다.

모든 Kuberenets resource는 metadata.resourceVersion 필드가 있다. 클라이언트는 오브젝트를 업데이트할 때 API server로 다시 전달된다. 버전이 etcd에 저장된 것과 일치하는 것이 없다면 API Server는 갱신을 거절한다.
```

* 클러스터가 될 때 일관성 보장
RAFT 합의 알고리즘

### node scheduling
포드를 수용 가능한 노드인지 결정하기 위한 checklist

* Node가 Pod의 하드웨어 리소스 요청을 이행할 수 있는가? (Resource Quota)
* Node가 리소스가 충분한가?
* Node가 Pod spec의 node selector label로 되어 있는가?
* Pod가 특정 host port binding을 요청 시 해당 노드의 port가 유효한가?
* Pod가 특정 볼륨 유형을 요청 시, 이 볼륨을 마운트 할 수 있는가? 아니면 다른 Pod에서 동일 볼륨을 사용하고 있는가?
* Pod는 노드의 taint를 허용하는가?
* Pod가 Node or Pod의 affinity, anti-affinity rule을 설정 할 수 있는가? 

### 다중 스케불러 사용
Pod별로 다른 스케쥴러가 동작할 수 있도록 구성할 수 있다.
Pode Spec에 schedulerName을 변경할 수 있으며, 표시하지 않을 시 default-scheduler를 사용한다.


[kuberenetes.io my-scheduler 상세 설명](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/)

### Control Manager에서 실행되는 controller
단일 controller manager 프로세스는 다양한 조정 작업을 수행하는 다수의 controller를 통제한다. 결국 다수의 controller는 별도의 프로세스로 분할되므로 필요에 따라 각 controller를 사용자 지정 구현으로 대체할 수 있다. 
다수의 controller의 목록은 다음과 같다.

#### 리소스 컨트롤러 ####
> 리소스는 cluster에서 무엇을 실행해야 하는지 설명
> controller는 배치된 리소스의 결과로 실제 작업을 수행하는 활성화된 kubernetes component
> object는 리소스에 따라 만들어져서 상태를 관리하고 있는 객체를 표시. etcd에 객체로 존재한다.
> Manifest는 yaml file 자체

* Replication Manager (deprecated. replicationController 리소스의 컨트롤러)
* Replicaset controller or daemonset controller or job controller
* deployment controller
* statefulset controller
* node controller
* service controller
* endpoint controller
* namespace controller
* persistence volumn controller
* 그 외 controller (calico controller, ingress controller etc)

controller는 감시 메커니즘 (watch)로 변경 사항을 확인하며, 주기적으로 목록 작업을 수행하여 이벤트를 놓치지 않았는지 확인한다. 

```
controller source code
https://github.com/kubernetes/kubernetes/tree/master/pkg/controller

sample controller
https://github.com/kubernetes/sample-controller

각 controller는 일반적으로 Informer라는 contructer를 가진다. 이 constructer는 API object가 갱신되는 순간마다 불리는 리스너다. 
다시 말해 watch로 변경 이벤트가 발생할 때 마다 불리는 callback function이다. 
: informer는 controller가 바라보는 리소스에 대한 변화를 대기한다. 생성자를 보면 controller가 보고 있는 리소스가 표시되어 있다.

worker() methode는 실제 controller가 수행하는 작업이 정의되는 곳이다. 통상적으로 실제 함수는 syncHandler 또는 이름이 유사한 필드에 저장된다. 
이 필드는 생성자에서도 초기화되므로 여기서 호출되는 함수의 이름을 찾을 수 있다.
```

#### Replicaset, Daemonset, job controller
리소스에 정의된 포드 템플릿에서 Pod 리소스를 만든다. 이들 controller는 Pod 생성 요청을 API Server로 Post로 요청하고 
이를 통해 kubelet 은 변경 상황을 인지하여 리소스에 따라 Pod를 생성한다. 


#### deployment controller
relicaset을 생성해 롤아웃하고 오래된 Pod가 새로운 것으로 교체될때까지 배포에 지정된 전략을 기반으로 예전의 replicaet과 새로운 replicaset을 적절히 스케쥴링한다. 

#### statefulset 
Pod와 PersistentVolumeClaim을 인스턴스화하고 관리한다.

#### Node controller
worker node를 작성하고 노드 리소스를 관리한다. 
cluster에서 실행중인 실제 시스템 목록과 노드 오브젝트 목록을 동기화 상태로 유지한다. 또한 각 노드의 상태를 모니터링하고 연결할 수 없는 노드의 포드를 제거한다. 
단, 노드 오프젝트를 변화시키는 유일한 컴포넌트는 아니다. 이런 동작은 kubelet도 변화시킬 수 있고 REST API를 호출해 사용자가 직접 수정할 수 있다.

#### Service Controller
Server Controller는 LoadBalancer 유형의 서비스가 생성되거나 삭제될때 인프라스트럭저로 부터 Load balance를 요청하고 릴리즈하는 역할 수행


#### end-point controller
labe selector와 매칭되는 IP와 Portfmf 끊임없이 갱신해 end-point 목록을 유지하는 활성 컴포넌트이다. 
이것은 service와 pod resource를 모두 감시한다. 
서비스가 추가되거나 갱신되거나 포드가 추가되거나 갱신되거나 삭제될때 서비스의 포드 셀렉터와 매칭되는 포드를 선택하고 해당 IP와 포트를 엔드포인트 리소스에 추가한다.
엔드포인트 객체는 독립 실행형 객체이므로 컨트롤러가 해당 객체를 생성한다. 반면 서비스가 삭제될때 엔드포인트 객체도 삭제된다.

#### namespace controller
namespace 삭제 시 동일 namepsace에 속한 모든 리소스를 삭제한다.

#### PersistentVolume Controller
사용자가 PersistentVolumeClaim을 생성하면 Controller는 적절한 PersistentVolume을 찾아서 바인딩 작업을 수행한다.
필요 용량을 가진 최소 영구볼륨을 선택해 클레임과 가장 일치하는 가장 작은 영구볼륲을 바인딩한다. 


### Kubelet 
kubelet을 초기 작업은 
1) API server를 통해 Node Resource를 생성해 실행하고 있는 노드를 등록하는 것이다.

2) 그리고 노드에 스케쥴되는 Pod가 존재하는지를 감시 (watch)하다가 존재하면 포드의 컨테이너를 실행한다. 
이것은 설정된 컨테이너 런타임 (Docker, rtk등)에 특정 container image에서 container를 실행하도록 지지하여 이런 작업을 실행한다.

3) 그리고 kubelet은 지속적으로 실행 중인 container를 모니터링하고 상태와 이벤트, 리소스 소모를 API Server에 보고한다. 

4) Container Liveness & Readness Probe를 실행하는 컴포넌트이며, Prob가 오류가 발생할때 restart 시킨다. 

5) 마지막으로 Pod가 API Server에서 삭제됐을 때 container를 정지하고 Pod가 정지됐을 때 서버에게 통지한다. 


### Kube-proxy
service 가 Pod IP와 port에 연결되는 것을 보장한다. 
* userspace proxy mode 
* iptables proxy mode (현재는 이방식 상요)

두가지 차이점
1) 패킷처리를 userspace하느냐, 아니면 커널에서 하느냐
2) round-robin (userpsace) 이냐, 아니면 random 이냐

#### 동작 방식
API 서버에서 서비스를 만들면 즉시 Cluster IP를 할당한다. kube-proxy는 서비스 변경에 대한 API server를 감시하면서 endpoint object의 변경 사항을 감시한다. 
변경 사항은 iptables 라우팅 정보를 변경한다. 
iptables은 cluterIP:port - port IP:port 정보를 포함하고 있다. 
iptable의 동작은 iptables의 규칙을 설정해서 매핑하는 작업을 수행하므로써 실제 destion IP/PORT로 변경 작업을 수행할 수 있다.

<img src="/files/kubeproxy.jpeg" width="600"> 

### DNS 서버
cluster의 모든 Pod는 Cluster 내부 DNS 서버를 사용하도록 구성하는 것이 기본이다. 
headless service의 경우에는 Pod가 Pod의 이름 (pod-0.svc.namespace.svc.local)을 가지고 Pod를 쉽게 찾을 것을 허용한다. 

dns server에 대한 service Cluster IP는 모든 컨테이너 내부에 /etc/resolv.conf 파일의 nameserver에 지정된다. 
kub-dns Pod는 
 - service와 endpoint의 변화를 관찰하기 위해 API Server와 watch 연결로 감시 하며, 
 - 변화할때 마다 DNS record를 갱신한다. 

### Ingress Controller 의 동작 방식
controller는 nginx와 같은 역프록시 서버를 실행하고 Ingress, End-point Resource를 모니터링하고 이에 따라 프록시 서버 구성을 변경한다. 
그리고 외부 클라이언트가 ingress controller를 통해 연결할때 클라이언트 IP의 보존에 영향을 주지 않도록 하기 위해 
일반적으로 Ingress Controller는 Pod IP로 직접 전달하는 방식을 취한다. 


### Controller의 상호 협력 방식

<img src="/files/controllerflow.jpeg" width="600"> 

```
$kubectl get events --watch
```

### kubernetes 고가용성
#### application commonent 가용성
application은 기본적으로 replicaset을 2개 이상 설정하여 장애가 발생하더라도 서비스를 연속해서 지원할 수 있도록 한다. 그러나 replicaset이 1인 경우에는 
restart 정책에 따라 장애가 발생 시 즉시 재 동작하도록 할 수 있다. 단 application 자체 비즈 로직 장애는 probe등을 활용해서 restart을 수행하면 된다.

만약 scale-out이 어려운 경우에는 HA 구성이 필요한데, 이것은 
리더 선출 작업을 수행하면 해결된다. 이것을 application 자체에서 하는 것이 아니라 side car 형태로 구성되어 application 수정 없이 할 수 있다.
이에 대한 예는 다음과 같다.

[simple Leader Election with k8s and docker](https://github.com/kubernetes/contrib/tree/master/election)

#### kubenetes control plain component 가용성

<img src="/files/k8sha.jpeg" width="600"> 

```
* Control Plain Component에 사용된 리더 선출 메커니즘 이해

하나의 리소스에 여럿이 동시에 쓰려고 할때 먼저 작성한 사람이 우선권을 가진다. 동시에 리소스 업데이트를 진행하고 이것을 계속 읽어서 업데이트가 되지 않았으면 자기가 업데이트를 하고 그리고 그값을 다시 읽어서 자기것이 되었는지를 확인한다. 
```


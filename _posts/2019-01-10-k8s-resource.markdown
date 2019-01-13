---
layout: post
title: k8s Resource Policy 
date: 2019-01-06
categories: Kubernetes
tags: [A kubernetes, resource, quota]
author: himang10
description: Resource Quota
---
Resource Quota
============

# Table of Contents
1. [Pod가 Node에서 실행 시 Scheduling 결정 방법](#Pod가-Node에서-실행-시-Scheduling-결정-방법)
2. [Pod를 위한 최상의 노드를 선택할 때 스케쥴러가 포드의 요청을 사용하는 방법](#Pod를-위한-최상의-노드를-선택할-때-스케쥴러가-포드의-요청을-사용하는-방법)
3. [Conatiner에 사용 가능한 리소스 양 한계 설정](#Conatiner에-사용-가능한-리소스-양-한계-설정)
4. [포드의 QOS Clss](#포드의-QOS-Clss)
5. [Namespace resource Assign](#Namespace-resource-Assign)
6. [LimitRange Resource](#LimitRange-Resource)
7. [Resource Quota](#Resource-Quota)




## Pod가 Node에서 실행 시 Scheduling 결정 방법
request 총량을 기준으로 자원을 할당함. limit은 전체 총량보다 많이 할당 할 수 있음
* request 총량보다 많은 자원을 요청하게 되면 자원 할당이 불가하므로 실패
* Memory에 대해 실행되는 Pod가 실제 자원보다 많이 사용하게 되면 한계초과로 우선순위에 따라 OOM으로 낮은 우선 순위 Pod 부터 OOM Kill 하기 시작함
> scheduler가 스케쥴링할 때만다 개별 리소스가 정확히 얼마나 많이 사용되고 있는지 보지 않고 노드에 배포된 기존 포드가 요청한 리소스의 합께만을 확인해서 할당
> 그러므로 실제 자원이 남아 있더라도 전체 총량에서 request 총량을 뺀 후 나머지는 현재 request보다 작으면 할당 실패

## Pod를 위한 최상의 노드를 선택할 때 스케쥴러가 포드의 요청을 사용하는 방법
자원 기준 노드 선택 우선 순위 방식은 두가지 중 한 가지 방식으로 처리함
* `LeastRequestedPriority` - 요청된 resource가 더 적은 노드 (아직 할당되지 않은 리소스가 더 많은)를 우선 배정
* `MostRequestedPriority` 
   요청된 resource가 더 많은 노드 (할당되지 않은 리소스가 더 적은)를 우선 배정 
   이방식은 이미 자원이 할당되어 있는 워크 노드를 할당 하므로 결국 최소 수의 노드를 사용하도록 보장하는 방식
   포드를 강하게 Pack하여 유지하면 특정 노드가 비어 있게 되고 제거가 쉬워 질 수 있음. 개별 노드에 대한 비용을 지불하므로 비용 절감 효과가 있음

## Conatiner에 사용 가능한 리소스 양 한계 설정
1. 리소스 한계 포드 설정
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: limited-pod
spec:
  containers:
  - image: busybox
    command: ["dd", "if=/dev/zero", "of=/dev/null"]
    name: main
    resources:
      limits:
        cpu: 1
        memory: 20Mi
````
> 리소스 request를 지정하지 않았으므로 리소스 Limit와 동일한 값으로 설정된다

2. 한계 오버커밋 (over-committed)
리소스 한계는 노드의 할당 가능한 리소스 양에 의해 제한되지 않는다. 
그러므로 모든 포드의 모든 한계의 합이 **노드의 용량의 100%를 초과** 할 수 있다.
> 결국, 이것은 노드가 100% 소모되면 특정 컨테이너를 제거해야 한다.

3. 한계초과
* CPU
CPU는 컨테이너에 한계가 설정되어 있으면 구성된 한계보다 더 많은 CPU 시간을 할당하지 않음
* Memory
프로세스가 한계를 초과하면 강제 종료됨 (Out Of Memory Killed)
포드 시작 정책이 `Always`또는 `OnFailure`로 설정된 경우 즉시 다시 시작하는데 한계 초과로 다시 시작하게 되면 종료와 시작 사이 지연이 늘어나는 경우 `CrashLoopBackOff`상태로 표시됨
> CrashLookBackOff 상태는 Kubelet이 포기했음을 의미하지 않음. 충돌 후 즉시 컨테이너 다시 시작한 다음 10초, 20초, 40초, 80초 ~ 최대 300초 까지 지연시간 증가됨
> 충돌 해결되거나 삭제되기 전까지는 계속 실행하게 됨

4. 컨테이너는 노드의 메모리를 바라본다
* jvm으로 기동 시 -Xmx 옵션을 자바 가상 시스템의 최대 힙 크기를 지정하지 않는 경우
  컨테이너에서 사용 가능한 메모리 대신 노드의 총 메모리 기반으로 힙 크기 설정. 이러한 경우 메모리 한도를 초과해 OOMIilled 될 수 있음
* off-heap memory 사용 시
  -Xmx 옵셥을 설정하더라도 off-heap memory는 노드 메모리를 바라보므로 문제 될 수 있음
  단, 최근 자바에서는 컨테이너 한계를 고려함으로써 문제를 완화하고 있음 (버전 확인 필)
  
5. 컨테이너는 모든 노드의 CPU 코어를 볼 수 있음
> CPU Limit은 컨테이너가 사용할 수 있는 시간을 제한 하는 의미
> 예) 64 코어 CPU에 1 코어 CPU Limit을 설정하면 CPU 시간 사용은 1/64이다.

* 이러한 특성으로 인해 발생 가능한 성능적 이슈
특정 Application은 시스템의 CPU 수에 의해 실행되어야 하는 스레드수를 결정하게 되는데, 
만약 만은 코어를 제공하는 노드에서 스레드 단위 실행되는 앱을 만들게 되면 많은 수의 스레드가 돌아가도록 할당하됨
그러나 실제 기동은 `전체 CPU`가 아닌 `limited CPU`를 가지고 많은 스레드가 경쟁을 하게됨.
또한 각 스레드는 각각의 추가 메모리를 필요로 하게 되면서 메모리 소모량이 늘어날 수 있음

* 해결 방안
 - Downward API를 사용해 컨테이너에 CPU 한계를 전달하고 애플리케이션이 시스템어서 볼 수 있는 CPU 수에 의존하는 대신 이를 사용
 -  컨네이너내 cpu.cfs-quota_us, cpu.cfs_period_us값을 읽어서 CPU 한계를 가져오는 방법
```
$ kubectl exec -it requests-pod sh
/ # cd /sys/fs/cgroup/
/sys/fs/cgroup # ls
blkio             cpuacct           freezer           net_cls           perf_event
cpu               cpuset            hugetlb           net_cls,net_prio  pids
cpu,cpuacct       devices           memory            net_prio          systemd
/sys/fs/cgroup # cd cpu
/sys/fs/cgroup/cpu,cpuacct # ls
cgroup.clone_children  cpu.cfs_quota_us       cpuacct.stat           notify_on_release
cgroup.procs           cpu.shares             cpuacct.usage          tasks
cpu.cfs_period_us      cpu.stat               cpuacct.usage_percpu
/sys/fs/cgroup/cpu,cpuacct # cat cpu.cfs_quota_us
-1
/sys/fs/cgroup/cpu,cpuacct # cat cpu.cfs_period_us
100000
/sys/fs/cgroup/cpu,cpuacct #
```

## 포드의 QOS Clss
1. 포드의 3가지 QoS Class
스케쥴링을 위한 우선순위 지정하기 위한 3가지 품질 클래스 구분
> Request와 Limit이 모두 설정안되어 있으면 최하위, 파드 내 한개 이상이 최소 한개라도 Request가 설정되어 있으면 Burstable, Request = Limit이 모두 그렇게 설정되어 있으면 Guranteed로 설정됨

* BestEffort (최하위 우선 순위) - Request와 Limit을 모두 설정하지 않음
  최악의 경우 CPU 할당 안될 수 있으며 메모리를 뺏겨서 죽을 수있음. 단, 자원이 풍부할 경우 원하는 만큼 자원 사용 가능
* Burstable (버스트 가능) - Request < Limit
  ** Request는 설정되어 있지만 Limit이 설정되어 있지 않거나, Request < Limit로 설정 시
* Guranteed (최우선 우선순위) - Request = Limit
  클래스를 보장받기 위해서는 아래의 3가지 충족되어야 함
  ** CPU와 메모리에 Request와 Limit을 모두 설정해야 함 (Limit만 설정 시 Request=Limit으로 기본 설정)
  ** 각 Container 마다 설정되어야 함
  ** Request=Limit 동일

2. Container에 대한 CPU & Memory QoS 

  CPU Req & Limit   | mem Req & Limit   | Container Class
  -------------------------------------------------------
  Non               | Non               | **BestEffort**
  Non               | Req < Limit       | **Burstable**
  Non               | Req = Limit       | **Burstable**
  Req < Limit       | Non               | **Burstable**
  Req < Limit       | Req < Limit       | **Burstable**
  Req < Limit       | Req = Limit       | **Burstable**
  Req = Limit       | Req = Limit       | **Guranteed**
  
3. Pod에 대한 QoS

  Conatiner 1 QoS   | Conatiner 2 QoS   | PoD QoS Class
  -------------------------------------------------------
  BestEffort        | BestEffort        | **BestEffort**
  BestEffort        | Burstable         | **Burstable**
  BestEffort        | Guranteed         | **Burstable**
  Burstable         | Burstable         | **Burstable**
  Burstable         | Guranteed         | **Burstable**
  Guranteed         | Guranteed         | **Burstable**

4. 동일한 QoS 클래스의 컨테이너 처리 방식
동일 우선순위의 Pod는 OOM 점수를 비교하여 강제 종료 프로세스 선정
> 메모리가 더 필요할 때 가장 높은 점수를 받은 프로세스 종료
* OOM 점수 계산 법
  Memory Request 대비 실제 사용률이 높은 Pod가 우선 종료됨
  예를 들어, request는 1000Mi인데, 실제 사용은 500Mi Pod A와 request=500Mi, 실제 사용=400Mi인 Pod B가 있으면 Pod B가 먼저 종료됨

## Namespace resource Assign
### LimitRange Resource
Pod가 가질 수 있는 Request와 Limit에 대한 기본, 최소, 최대 값을 설정한다. 
CPU, Memory, Claim을 지정할 수 있다.
> LimitRange Admission Control Plugin 을 통해 LimitRange Resource 사용

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: example
spec:
  limits: # Pod 별 Min, Max
  - type: Pod
    min:
      cpu: 50m
      memory: 5Mi
    max:
      cpu: 1
      memory: 1Gi
  - type: Container
    defaultRequest: # default Request
      cpu: 100m
      memory: 10Mi
    default: # default Limit
      cpu: 200m
      memory: 100Mi
    min: 
      cpu: 50m
      memory: 5Mi
    max:
      cpu: 1
      memory: 1Gi
    maxLimitRequestRatio:
      cpu: 4
      memory: 10
  - type: PersistentVolumeClaim
    min:
      storage: 1Gi
    max:
      storage: 10Gi
````
** maxLimitRequestRatio : cpu Limit은 request보다 4대 이상 클수 없다,  

### Resource Quota
namespace 내 자원 크기 정의하기 위한 리소스
> 주의 사항: Resource Quota와 Limit Range는 함께 정의되어야 한다. 그렇지 않으면 아래와 같이 오류가 발생함
```
$ kubectl create -f kubia-manual.yaml
Error from server (Forbidden): error when creating "kubia-manual.yaml": pods "kubia-manual" is forbidden: failed quota: cpu-and-mem: must specify limits.cpu,limits.memory,requests.cpu,requests.memory
```

1. CPU & Memory 지정
```yaml
$ cat quota-cpu-memory.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: cpu-and-mem
spec:
  hard:
    requests.cpu: 400m
    requests.memory: 200Mi
    limits.cpu: 600m
    limits.memory: 500Mi
```

2. Persistent Storage 할당량 지정
```yaml
$ cat quota-storage.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage
spec:
  hard:
    requests.storage: 500Gi
    ssd.storageclass.storage.k8s.io/requests.storage: 300Gi
    standard.storageclass.storage.k8s.io/requests.storage: 1Ti
````

3. 생성 가능한 객체 수 제한
The 1.9 release added support to quota all standard namespaced resource types using the following syntax:

* count/<resource>.<group>
Here is an example set of resources users may want to put under object count quota:

* count/persistentvolumeclaims
* count/services
* count/secrets
* count/configmaps
* count/replicationcontrollers
* count/deployments.apps
* count/replicasets.apps
* count/statefulsets.apps
* count/jobs.batch
* count/cronjobs.batch
* count/deployments.extensions

```yaml
$ cat quota-object-count.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: objects
spec:
  hard:
    pods: 10
    replicationcontrollers: 5
    secrets: 10
    configmaps: 10
    persistentvolumeclaims: 5
    services: 5
    services.loadbalancers: 1
    services.nodeports: 2
    ssd.storageclass.storage.k8s.io/persistentvolumeclaims: 2
```
4. 특정 포드 상태나 QoS 클래스의 할당량 지정
현재 상태 및 QoS 클래스에 따른 할당량 범위 지정 방법 제시
* BestEffort, NotBestEffort
> 할당량이 BestEffort QoS 클래스에 적용되는지 , Burstable/Guaranteed에 적용되는지를 지정

* Terminating
* NotTerminating

```yaml
$ cat quota-scoped.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: besteffort-notterminating-pods
spec:
  scopes:
  - BestEffort
  - NotTerminating
  hard:
    pods: 4
````
> BestEffort는 Pod 수만 지정할 수 있지만, NotBestEffort는 request.cpu, request.memory, limit 등을 지정 가능


                            
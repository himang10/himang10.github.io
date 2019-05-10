---
layout: post
title: GPU 확장
date: 2019-01-06
categories: kubernetes-addon
author: himang10
tags: [kubernetes, gpu]
---


### Shared GPU Cluster Scheduling in Kubernetes

#### Background of problem
현재 kubernetes는 GPU card를 하나의 컨테이너에 할당한다. 이렇게하면 더 나은 격리를 달성하고 GPU를 사용하는 응용 프로그램이 다른 응용 프로그램의 영향을받지 않도록 할 수 있습니다.
이 구조는 in-depth learning model training의 시나리오에 매우 적합하지만 model development and model prediction 시나리오에서는 낭비 적입니다.
그 결과, 동일한 GPU 카드에서 더 많은 예측 서비스를 공유 할 수 있기 때문에 클러스터에서 Nvidia GPU의 사용률을 향상시킬 수 있습니다
이를 위해서는 GPU 리소스 파티셔닝이 필요합니다. GPU 리소스 파티셔닝의 차원은 GPU 메모리와 Cuda Kernel 스레드의 파티셔닝입니다. 
일반적으로 클러스터 수준에서 공유 GPU를 지원하는 것에 대해 이야기하는 두 가지 사항이 있습니다

1. scheduling
2. Isolation, we mainly discuss here is scheduling, the isolation scheme will be based on Nvidia MPS in the future.

현재 세분화 된 GPU 카드 스케줄링을 위해 Kubernetes 커뮤니티는 현재 좋은 해결책이 없습니다. 이는 Kubernetes가 GPU와 같은 확장 된 리소스를 정의하는 것은 정수 단위의 덧셈과 뺄셈을 지원하고 복잡한 리소스의 할당을 지원할 수 없기 때문입니다.
예를 들어, 사용자는 GPU Card의 반을 차지하는 Pod A를 사용하기를 원하지만 현재 Kubernetes 아키텍처 디자인에서는 리소스 할당 레고드를 획득하고 호출할 수 없습니다. 
여기에서 챌린지는 multi-card GPU sharing은 real vector resource 문제이며, 확장된 리소스는 scalar resources의 설명이라는 것이다. 

이 문제를 해결하기 위해 Kubernetes의 기존 작업 메커니즘에 의존하는 자유롭고 공유 된 GPU 스케줄링 스키마를 설계합니다.

* Extended Resource Definition
* Scheduler Extender mechanism
* Device Plugin mechanism

**User secenario**
* As a cluster administrator, I want to improve the GPU utilization of the cluster; during the development process, multiple users share the model development environment.
* As an application developer, I want to be able to run multiple reasoning tasks on Volta GPU at the same time.

**Target**
* Users can describe the application for a shared resource through API, and can realize the scheduling of such resource.


### 상세 내용은 아래 참고


[Shared GPU Cluster Scheduling in Kubernetes](https://developpaper.com/shared-gpu-cluster-scheduling-in-kubernetes/)
[확장팩 설치 방법 - git](https://github.com/AliyunContainerService/gpushare-scheduler-extender)
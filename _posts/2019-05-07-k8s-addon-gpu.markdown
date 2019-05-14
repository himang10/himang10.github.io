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

**Non target**
* Isolation of this shared resource is not supported
* Overselling is not supported

**Design principles**
* Define the problem and simplify the design. The first step is only responsible for scheduling and deployment, and then realize the display and memory control at runtime.
There are many clear demands of customers that they can first support multi-AI applications to be scheduled to the same GPU, and they can accept the control of memory size from the application level, using similar technologies.gpu_options.per_process_gpu_memory_fractionControl the display memory usage of the application. The problem we need to solve is to simplify the display memory as the scheduling ruler, and transfer the size of the display memory to the container in the form of parameters.
* No intrusive modifications
The design of Extended Resource, the implementation of Scheduler, the mechanism of Device Plugin and the design of Kubelet will not be modified in this design. Reuse Extended Resource to describe the application API for shared resources. The advantage of this is to provide a portable solution that users can use in native Kubernetes.
* It can coexist in the cluster in the way of display memory and card scheduling, but it is mutually exclusive in the same node, which does not support the coexistence of the two; either by the number of cards or by the display memory allocation.

**detailed design**
Premise:

* Kubernetes Extended Resource 정의가 여전히 사용되지만 측정 단위의 최소 단위가 GPU 카드에서 GPU 메모리의 MiB로 변경됩니다. 노드에서 사용하는 GPU가 단일 카드 16GiB 메모리 인 경우 해당 자원은 16276MiB입니다.
* GPU 공유에 대한 사용자의 요구가 모델 개발 및 모델 예측의 시나리오에 있기 때문에 이 시나리오에서 사용자가 적용한 GPU 리소스의 상한은 하나의 카드를 초과하지 않습니다. 즉, 적용되는 리소스의 최대 한도는 단일 카드입니다.

첫번째 작업은 두개의 새로운 Extended Resources를 정의하는 것이다. 
* 첫번째는 gpu-mem이다. (GPU Memory)
* 두번째는 gpu-count. (GPU Cards 수)

다음 그림은 기본 도식도 이다. 

<img src="/files/gpu_img1.jpg" width="700"> 

**Core function Modules:**
* **GPU Share Scheduler Extender**  kubernetes scheduler extension mechanism을 사용함으로써, 글로벌 스케줄러가 Filter and Bind 할 때 노드의 단일 GPU 카드가 충분한 GPU Mem을 제공 할 수 있는지, 할당 결과를 확인하기 위해 Bind 시간에 Annotation을 통해 Pod Spec에 GPU 할당 결과를 기록하는지 여부를 판단할 책임이 있다.
* **GPU Share Device Plugin** Device Plugin mechanism을 사용함으로써, 노드는 스케줄러 Extender 할당 결과에 따라 GPU 카드 할당을 담당하는 Kubelet에 의해 호출됩니다.

**Specific Process:**

### 상세 내용은 아래 참고


[Shared GPU Cluster Scheduling in Kubernetes](https://developpaper.com/shared-gpu-cluster-scheduling-in-kubernetes/)
[확장팩 설치 방법 - git](https://github.com/AliyunContainerService/gpushare-scheduler-extender)
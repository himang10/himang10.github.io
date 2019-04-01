---
layout: post
title: 출시후 테스트
date: 2019-03-29
categories: test
author: himang10
tags: [msa, architecture]
---

### Table of Contents
1. [Deployment를 Relase와 분리](#Deployment를_Relase와_분리)
3. [canary deployment](#canary_deployment)
3. [교차기능 테스트 (cross-functional requirements)](#교차기능_테스트_(cross-functional_requirements)


### 출시 후 테스트
배포 전에 시험을 하더라도 운영 중인 실환경 시스템에서 맞닥뜨릴 문제를 완전히 해소할 수 없다. 
즉 테스트를 늘려도 효과는 적은 현상 특정 시점부터 수확 체감(dimishing returns)이 발생한다. 
> 결국 배포 전의 테스팅을 통해서는 장애의 가능성을 완전히 없앨 수 없다.

### Deployment를 Relase와 분리
#### smoke test
소프트웨어를 배포해 실환경 부하를 주기 전에 배포한 곳에서 테스트 수행. 이를 통해 특정 환경에서 이슈를 사전에 발견

<img src="/files/bgdeployment.jpeg" width="600"> 

#### 전제조건
1. 실환경 트래픽을 다른 호스트로 향하게 할 수 있어야 한다.
이는 DNS를 변경하거나 부하분산 설정을 변경하여 지원

2. 한번에 두 버전의 마이크로 서비스를 프로비전할 수 있어야 한다

#### 이점
1. 실환경 트래픽을 보내기 전에 서비스를 그 자리에서 테스트 할 수 있는 이점 존재
2. 릴리스 작업을 수행하는 동안 과거 버전을 유지함으로써 소프트웨어 릴리스와 관련된 시스템의 정지 시간을 크게 낮출 수 있음

트래픽 경로 변경을 구현한 메커니즘 종류에 따라 무중단 배포 (Zero time deployment)를 제공

### canary deployment
카나리를 했을 때 시스템이 예상대로 수행하는지 보기 위해 실환경 트래픽을 유입시켜 새롭게 배포된 소프트웨어를 검증하고 있다고 하자. 예상대로 수행한다는 말은 기능 및 비기능적으로 여러 가지 의미를 포괄한다.
예르들어 새롭게 배포된 서비스가 500 밀리초 안에 응답하는지 확인하거나 신구 버전의 서비스에서 동일 비율의 에러가 발생하는지 확인할 수 있다.

카라리아는 버전들을 더 오래 공존시킬 수 있고 트래픽의 양을 자주 변경할 수 있다는 점에서 B/G 과 차이가 있다.

넷플릭스는 이 방법을 광법위하게 사용한다.

### 교차기능 테스트 (cross-functional requirements)
결제 서비스에 요구되는 서비스 내구성은 상당히 높게 책정하지만 뮤직 추천 서비스의 더 긴 다운타임에는 만족할 것이다.


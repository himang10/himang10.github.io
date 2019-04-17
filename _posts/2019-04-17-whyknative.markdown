---
layout: post
title: Why Knative
date: 2019-04-17
categories: serverless
author: himang10
tags: [knative, serverless, kubernetes]
---

1. [서버없는 세계에서 Knative에 의한 통합이 진행](#서버없는_세계에서_Knative에_의한_통합이_진행)
2. [Why Knative](#Why_Knative)
3. [Knative(and Istio)의 목적은?](#Knative(and_Istio)의_목적은?)

### 서버없는 세계에서 Knative에 의한 통합이 진행
Kubernetes에서 serverless를 제공하는 오픈 소스 소프트웨어 (OSS)은 이미 여럿 존재하고있다. 하지만 Cloud Native Computing Foundation (CNCF)의 COO (최고 운영 책임자) 인 Chris Aniszczyk는 **Knative가 serverless의 사실상 표준**이 될 것으로 보고있다.

> "Google이 Knative 발표 때, Pivotal는 자사가 개발하고 있던 (서버없는 소프트웨어) riff를 Knative에 재 구축한다고 발표하고 IBM도 비슷한 뜻을 밝혔다. 2019 년까지 serverless 소프트웨어의 Knative에 통합의 움직임은 더욱 진행될 것으로 예상하고 있다."

### Why Knative
그렇다 치더라도, Knative 왜 이렇게까지 주목되는 것인가?

Google의 Knative 담당 개발자는 약 1 년 전에 프로젝트를 시작했을 무렵, Red Hat 및 Pivotal에 대해 

> "이런 것을 만들려고하고 있지만, 당신들에게 도움이된다고 생각 하는가 '타진 한 후 피드백 를 받으면서 개발 왔다고 이번 행사에서 말했다. Knative이 발표 된 것은 2018 년 7 월이지만, 
> 그보다 훨씬 전에 '교섭'이 진행되고 있었다고 할 수있다.

Pivotal는 2018 년 7 월 Google Cloud NEXT '18에서 아래와 같은 그림을 보여주고, 서버 레스에서 자신의 부가가치 발휘 라인을 올리는 것을 설명했다. 
회사의 서버리스 OSS 프로젝트 riff에서 모든 것을 자신의 방식으로 개발하는 것이 아니라 기본적인 기능은 Knative에 맡기고 위의 레이어에서의 차별화에 주력 할 수 있다고하고있다. 
Red Hat과 IBM은 이번 행사에서 동일한 그림을 보여주고있다.

<img src="/files/riffknative.jpg" width="600"> 

Knative을 생산하는 업체가 얻을 수있는 장점은 **"지루한 부분"**을 자체 개발 않아도된다는 것만은 아니다. 기반을 공통화함으로써 **Serverless 플랫폼 간의 상호 운용성**을 확보 할 수있는 가능성이 생긴다.
또한 이상적으로는 Google Cloud, Pivotal Container Service (PKS), **IBM Cloud Kubernetes Service**, Red Hat OpenShift 등이 상호 연계하여 Cloud 플랫폼간에 Serverless Application을 구축 할 수있게된다

### Knative(and Istio)의 목적은?
클라우드 벤더 간에 구현되는 것의 우열을 경쟁할 수 있다. 그러나, 운영을 위한 API는 통일되고 표준화되어야 한다. 그러므로 운영 API는 오픈소스화되어야 한다. 이를 실현하는 노력 중 하나가 Knative와 istio이다. 

Knative의 현재 상황은 Kubernetes를 오픈 소스 화했을 무렵과 유사하다. 당시 적어도 12 개 이상의 컨테이너 오케스트레이션 시스템이 있었지만, 그 Kubernetes가 사실상의 표준이 되었다. 

Knative는 업계 여러파트너와 협력하여 serverless를 어떻게 보여줄지에 대한 공감대를 조성하는 것이다. 그리고 이것의 목표는 구현 마다 각자 고유한 것을 사용하지 않고 통일된 구조를 가져가도록 하는 것이다. 


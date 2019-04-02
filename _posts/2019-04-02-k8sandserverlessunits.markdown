---
layout: post
title: how knative can unite k8s and serverless
date: 2019-04-02
categories: serverless
author: himang10

tags: [serverless, knative, kubernetes]
---


Kubernetes와 serverless 는 오늘날 테크에서 가장 인기있는 유행어 중 두 가지입니다. 그렇지만 종종 같은 대화의 일부가 아닙니다. 
일반적으로 Kubernetes는 컨테이너 화 된 응용 프로그램을 조율하는 데 사용되고 서버가없는 컴퓨팅은 다른 유형의 배포 모델을 제공합니다. 
대부분의 사람들이 서버리스에 대해 생각할 때, AWS Lambda, Azure Functions 및 몇 년 전에 serverless를 주류로 생각하고 있습니다.

그러나 Kubernetes와 서버리스를 둘러싼 생태계는 Kubernetes에 의존하는 서버리스 프레임 워크의 출시로 인해 점점 더 교차되고 있습니다. 
서버없는 환경을 구축하고자하는 DevOps 팀은 이제 공용 클라우드 공급 업체의 호스트없는 Serverless 프레임 워크로 스스로를 제한 할 필요가 없게 되었습니다.

사실, DevOps 팀을 람다 (Lambda) 및 쿠버 넷 (Kubernetes) 기반 서버리스 환경으로 끌어들이는 데있어 가장 큰 역할을하는 것은 Knative입니다.

#### Kubeless
Kubeless 는 오픈 소스 Kubernetes 네이티브 프레임 워크로서 기본 인프라에 대해 걱정하지 않고 코드를 배포 할 수 있습니다. 
API 라우팅, 자동 확장, 모니터링, 문제 해결 등을 제공하기 위해 Kubernetes를 사용합니다. 
Kubeless는 Kubernetes 위에 서버가없는 작업 부하를 실행하는 것과 같은 것을 사람들에게 제공하기위한 초기 노력으로 만들어졌습니다. 
Kubeless는 Kubernetes를 기반으로하는 유일한 서버리스 프레임 워크가 아닙니다.

#### Fission 
관리 형 Kubernetes 서비스 인 Platform9 는 Lambda와 별도로 Serverless solution의 필요성을 인지했다. 그리고 오픈 소스 서버리스 프레임 워크 인 Fission을 출시했습니다 . 
그 목표는 사용자가 컨테이너와 관련된 Deployment 작업을하지 않고도 응용 프로그램을 시작하고 관리 할 수있는 쉬운 방법을 제공하는 것이 었습니다. 
Fission은 네이티브 Kubernetes를 기반으로합니다.

시스코 블로그에서 Pete Johnson 이 수행 한이 유용한 비교 는 Fission이 Lambda와 Kubernetes 중간 중간에 있음을 보여줍니다. 
그러나 그것의 주 목적은 람다보다 Kubernetes에 가까운 솔루션을 제공하는 것입니다. 
벤더 종속성이없고, 모든 클라우드 플랫폼이 오늘날 통합되는 플랫폼 인 Kubernetes를 기반으로하는 것입니다. 
Fission은 Platform9에 의해 상업적으로 제공되고 있지만, Kubernetes가 가지고있는 산업 전반에 걸쳐 채택되지 못했습니다. 
그러나, 지금 그 자리에 경쟁자가 있습니다 : Knative.

#### Knative
Knative 는 완전한 서버리스 솔루션이 아닙니다. 오히려 서버리스 솔루션을 구축하는 플랫폼입니다. 
이러한 의미에서, Knative는 Kubernetes 위에 serverless 솔루션을 구축하기 위해 공급 업체 나 운영 업체가 사용할 가능성이 더 큽니다. 
Google Cloud의 소프트웨어 엔지니어링 관리자 인 Dan Lorenc 은 Knative 프로젝트에 기여하면서 "Knative는 Kubernetes와 serverless 프레임 워크 사이의 계층 역할을합니다. 
따라서 Knative API를 대상으로 애플리케이션을 작성하면 Kubernetes가 실행되는 곳이면 어디서든 실행할 수 있습니다. "

#### Collaborative Approach of Vendors
Knative의 주요 motive는 서버리스 컴퓨팅에 대한 벤더에 독립적 인 표준을 정의하는 것입니다.
Knative는 Google, Pivotal 및 기타 주요 클라우드 조직의 컨소시엄의에 의해 만들어 졌다는 것입니다. 
Google Cloud의 제품 관리자 인 Jason Polites는 Knative를 만드는 공동 작업 방식에 대해 다음과 같이 말합니다. 
"고객은 공급자 간 일관성을 최대한으로 활용할 수 있다고 생각합니다. 오픈 소스와 커뮤니티 공동 작업이 이를 달성하는 가장 좋은 방법입니다. 우리는 이것이 Kubernetes에서 일어나는 것을 보았고, Knative도 비슷한 접근법을 취합니다. Jason의 최종 목표는 "container level뿐만 아니라 serverless platform level에서 이식성을 얻게됩니다."

예를 들어 serverless platform 전체와 서버에서 실행되는 모든 앱을 데이터 센터에서 클라우드 플랫폼으로 이동할 수 있습니다.

#### Serverless as an Adjective
Polites는 "serverless"를 명사가 아닌 형용사로 취급하는 것에 대해 흥미로운 점을 제시합니다. 
그말은 serverless가 된다는 것이 아니라 serverless compute, serverless memory 등을 필요로 한다는 것을 의미한다. 
그런 견해를 가진 것들을 보게되면 Polites는 "이제는 서버리스의 이점을 누리지 않고, 또는 서버리스의 이점을 최대한 활용하여 가장 적합한 추상화를 선택할 수 있습니다."라고 설명했습니다. 
Knative를 사용하면 서버리스 플랫폼을 유연하게 설계 할 수 있습니다 조직의 요구에 완벽하게 부합합니다. 서버없이 관리하려는 전체 스택의 부분을 선택하여 선택할 수 있으며 다른 스택은 그대로 유지할 수 있습니다.

#### Build, Serve, Event
Knative에는 세 가지 주요 구성 요소 인 빌드, 검색 및 이벤트가 포함됩니다.

* Build : 일단 코드가 작성되면 컨테이너에 패키징해야합니다. 이것은 Jenkins와 같은 CI 도구에서 일반적으로 처리하는 파이프 라인의 빌드 부분입니다. 컨테이너 이미지가 작성되면 컨테이너 레지스트리에 업로드됩니다. 거기에서 YAML 파일을 사용하여 배포하여 간단하거나 복잡한 배포를 만들 수 있습니다. Knative는 이러한 모든 단계를 단일 매니페스트 파일로 추상화합니다. Knative의 빌드 부분은 모든 컨테이너 오케스트레이션 작업을 처리합니다.

* Serve : 이것은 기본 인스턴스의 스케일을 0부터 큰 스케일까지 처리하고 서비스가 더 이상 사용되지 않을 때 0으로 되돌아가는 Knative의 일부입니다. 또한 Istio를 활용하여 여러 개정 또는 스냅 샷 간의 요청 라우팅을 처리합니다.

* Event : Knative의이 부분에서는 함수의 트리거를 설정하고 정의 할 수 있습니다. 단일 단계에서 또는 파이프 라인을 사용하는 복잡한 프로세스에서 자동화를 구축하는 데 도움이됩니다. 프로젝트의이 부분은 여전히 ​​진행중인 작업입니다.

#### Ease of Use
Knative는 실제로 사용하기 쉽기 때문에 운영 효율성 측면에서 많은 의미가 있습니다. Dan은 "Google Cloud 플랫폼 위에 Knative를 사용하려는 경우 매우 쉽게 사용 할 수 있습니다. 
Kubernetes 클러스터 내에서 서버없는 프레임 워크를 실행하려면 Knative가 최선의 선택입니다. 데이터 센터에서 동일한 사용 편의성을 누릴 수 있습니다. 
간단히 말해서 Kubernetes를 실행할 수있는 곳이면 어디서나 Knative 및 모든 서버리스 앱을 실행할 수 있습니다.

컨테이너를 serverless로 실행하면 전체 Kubernetes 생태계가 향하는 곳이됩니다. Lorenc은 "두 가지 노력 (컨테이너 및 서버리스)이 Knative의 맥락에서 어떻게 관련되어 있는지에 대해 곧 발표 할 것입니다."라고 말했습니다.
이 첫 번째 내용은 최초의 상용 제품 인 Knative GKE 애드온입니다. AWS Fargate 또는 완전히 새로운 것을 볼 수 있습니까? 기다리고 지켜봐야 할 것입니다.

Google의 노력 외에도 Knative를 기반으로하는 Pivotal Function Service 가 있습니다. 또 다른 흥미로운 시작은 TriggerMesh 입니다. 
TriggerMesh는 Kubeless 제작자인 Sebastien Goasguen에 의해 시작되었습니다

#### Kubernetes-Based Serverless or Lambda?
약 1 년 전, Lambda or Kubernetes 기반의 클라우드 기반 서버리스 프레임 워크 (cloudless serverless framework)를 사용할지 여부를 결정하려는 경우,이 질문에 대한 답은 전자였습니다.

그러나 오늘날 Knative는 풍경을 바꿔 우리에게 람다 (Lambda)에 대한 유능하고 탁월한 대안을 제공했습니다. 서버리스를 처음 시작하는 분이라면 GKE 애드온, Pivotal Function Service 또는 TriggerMesh와 같은 Knative 솔루션 중 하나를 선택하는 것이 좋습니다. 또한 람다 (Lambda)와 같은 서버가없는 플랫폼에서 이미 앱을 실행중인 경우 Knative 솔루션이 출시되고 초기 고객으로 심사를 받고 리뷰가 쏟아져 나올 때까지 몇 달 동안 기다리는 것이 좋습니다. Kubernetes와 serverless가 교차하는 지점 인 Knative가 만장일치로 검토 될 것입니다.
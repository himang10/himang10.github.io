---
layout: post
title: introduce knative
date: 2019-04-02
categories: serverless
author: himang10

tags: [serverless, knative, kubernetes]
---

## Table of Contents
1. [knative document](#knative_document)
2. [knative component](#knative_component)
3. [Example](#Example)

### knative document 
[welcom knative](https://www.knative.dev/docs/)

[Using knative to deploy serverless applications to Kubernetes](https://codelabs.developers.google.com/codelabs/knative-intro/#0)

<img src="https://www.knative.dev/docs/images/knative-audience.svg" width="800">

#### knative principles
* Knative is native to Kubernetes (APIs are hosted on Kubernetes, ### deployment unit ### is * container images *)
* You can install/use parts of Knative independently (e.g. only Knative Build, to do in-cluster builds)
* Knative components are pluggable (e.g. don't like the autoscaler? write your own)

### knative component (Resource Type)
Kubernetes offers a feature called Custom Resource Definitions (CRDs). 
With CRDs, third party Kubernetes controllers like Istio or Knative can install more APIs into Kubernetes
Resource Type
* Service
* Build / BuildTemplate
* Event

<img src="https://i1.wp.com/blog.openshift.com/wp-content/uploads/Build-Overview.png?w=703&ssl=1" width="800>

[openshift knative:building your serverless service](https://blog.openshift.com/knative-building-your-serverless-service/)                                                                                                    

Knative installs of three families of custom resource APIs:

1. [Build](https://github.com/knative/build/) - Source-to-container build orchestration
Set of APIs that allow you to execute builds (arbitrary transformations on source code) inside the cluster. For example, you can use Knative Build to compile an app into a container image, then push the image to a registry
* Retrieve source code from repositories.
* Run multiple sequential jobs against a shared filesystem, for example:
  - Install dependencies.
  - Run unit and integration tests.
* Build container images.
* Push container images to an image registry, or deploy them to a cluster.
knative build의 목표는 클러스터 상의 컨테이너 이미지 빌드를 정의하고 실행하기 위한 표준화, 이식성, 재사용성, 성능 최적화 방안을 제공하는 것이다. 
Kubernetes 상에 빌드를 실행하는 "boring but difficult" 작업을 대신해서 제공하므로써 공통의 쿠버기반 개발 프로세스를 개발하고 재생산해야 하는 것을 대신해준다. 
While today, a Knative build does not provide a complete standalone CI/CD solution, 
it does however, provide a lower-level building block that was purposefully designed to enable integration and utilization in larger systems.

2. [Eventing](https://github.com/knative/eventing) - Set of APIs that let you declare event sources and event delivery to your applications.
work-in-progress eventing system that is designed to address a common need for cloud native development
* Services are loosely coupled during development and deployed independently
* A producer can generate events before a consumer is listening, and a consumer can express an interest in an event or class of events that is not yet being produced.
* Services can be connected to create new applications
  - without modifying producer or consumer, and
  - with the ability to select a specific subset of events from a particular producer.

3. [Serving](https://github.com/knative/serving/) - Set of APIs that help you host applications that serve traffic. Provides features like custom routing and autoscaling.
Knative Serving builds on Kubernetes and Istio to support deploying and serving of serverless applications and functions. 
Serving is easy to get started with and scales to support advanced scenarios.

The Knative Serving project provides middleware primitives that enable:

* Rapid deployment of serverless containers
* Automatic scaling up and down to zero
* Routing and network programming for Istio components
* Point-in-time snapshots of deployed code and configurations

or documentation on using Knative Serving, see the serving folder of the Knative Docs repository.
For documentation on the Knative Serving specification, see the docs folder of this repository.
If you are interested in contributing, see CONTRIBUTING.md and DEVELOPMENT.md.

### Getting Started with App Deployment
#### Configuring your deployemnt
knative에서 app을 배포하기 위해 service를 정의하는 yaml configuration file이 필요하다. 
[for more information about the Service Object](https://github.com/knative/serving/blob/master/docs/spec/overview.md#service)'

* Service.yaml
```yaml
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-samples/helloworld-go # The URL to the image of the app
            env:
              - name: TARGET # The environment variable printed out by the sample app
                value: "Go Sample v1"
````

#### Deploying your app
```
kubectl apply -f service.yaml
```

Now that your service is created, Knative will perform the following steps:

* Create a new immutable revision for this version of the app.
* Perform network programming to create a route, ingress, service, and load balancer for your app.
* Automatically scale your pods up and down based on traffic, including to zero active pods.

#### Interacting with your app
app이 성공적으로 배포되었는지를 보기 위해 knative에서 생성된 host URL과 IP Address가 필요하다.

1. To find the IP address for your service

```
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
   INGRESSGATEWAY=knative-ingressgateway

   # The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
   # Use `istio-ingressgateway` instead, since `knative-ingressgateway`
   # will be removed in Knative v0.4.
   if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
   fi

   kubectl get svc $INGRESSGATEWAY --namespace istio-system

   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   istio-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

EXTERAL-IP address를 기억하고 다음 명령어에서 변수로써 ip address를 export해라
```
   export IP_ADDRESS=$(kubectl get svc $INGRESSGATEWAY --namespace istio-system --output 'jsonpath={.status.loadBalancer.ingress[0].ip}')
```

> NOTES: 만약 external load balancer를 가지고 있지 않다면, EXTERNAL-IP field는 `<pending>`으로 되어있습니다. 
> 그러므로 대신 NodeIP와 NodePort를 사용할 필요가 있습니다.
> apps의 NodeIP와 NodePort를 얻기 위해서는 다음과 같이 명령어를 수행해야 합니다.

```
   export IP_ADDRESS=$(kubectl get node  --output 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system   --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

### Example

[knative-build-tutorials](https://github.com/GoogleCloudPlatform/knative-build-tutorials/tree/master/getting-started)

[announcing riff v0.2.0](https://projectriff.io/blog/announcing-riff-0-2-0/)

[riff is for functions](https://github.com/projectriff/riff/)

[How to run knative using riff on GKE](https://projectriff.io/docs/getting-started/gke/)
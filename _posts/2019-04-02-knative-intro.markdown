---
layout: post
title: introduce knative
date: 2019-04-02
categories: serverless
author: himang10

tags: [serverless, knative, kubernetes]
---

## Table of Contents
1. [xxx](#xxx)
2. [xxx](#xxx)
3. [xxx](#xxx)

### knative document 
doc: https://www.knative.dev/docs/

<img src="https://www.knative.dev/docs/images/knative-audience.svg", width="600">

### knative component
1. [Build](https://github.com/knative/build/) - Source-to-container build orchestration
A Knative build extends Kubernetes and utilizes existing Kubernetes primitives to provide you with the ability to run on-cluster container builds from source. 
For example, you can write a build that uses Kubernetes-native resources to obtain your source code from a repository, build a container image, then run that image
While Knative builds are optimized for building, testing, and deploying source code, you are still responsible for developing the corresponding components that
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

2. [Eventing](https://github.com/knative/eventing) - Management and delivery of events
work-in-progress eventing system that is designed to address a common need for cloud native development
* Services are loosely coupled during development and deployed independently
* A producer can generate events before a consumer is listening, and a consumer can express an interest in an event or class of events that is not yet being produced.
* Services can be connected to create new applications
  - without modifying producer or consumer, and
  - with the ability to select a specific subset of events from a particular producer.

3. [Serving](https://github.com/knative/serving/) - Request-driven compute that can scale to zero
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



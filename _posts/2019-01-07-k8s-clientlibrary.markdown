---
layout: post
title: K8s Client 사용을 위한 Client Library
date: 2019-01-07
categories: Kubernetes
tags: [A kubernetes, client, library]
author: himang10
description: k8s client library개발을 위한 정보
---
kubernetes client library 정보
============

### 기존 클라이언트 라이브러리 사용
1. [***Golang Client***(https://github.com/kubernetes/client-go)](https://github.com/kubernetes/client-go)
2. [***fabric8 java client***(https://github.com/fabric8io/kubernetes-client)](https://github.com/fabric8io/kubernetes-client)
3. [***Amdatu java client***(https://bitbucket.org/amdatulabs/amdatu-kubernetes)](https://bitbucket.org/amdatulabs/amdatu-kubernetes)
4. [***Tenxcloud Node.js***(https://github.com/tenxcloud/node-kubernetes-client)](https://github.com/tenxcloud/node-kubernetes-client)
5. [***GoDaddy Node.js***(https://github.com/godaddy/kubernetes-client)](https://github.com/godaddy/kubernetes-client)

### Swagger와 OpenAPI를 사용해 자신만의 라이브러리 구축
> 프로그램밍 언어를 사용할 수 있는 클라이언트가 없다면 swagger api framework을 사용해 
> 클라이언트 라이브러리 및 문서를 생성 할 수 있다. kubernetes api 서버는 
> /swaggerapi에서 swagger api 정의를 /swagger.json에서 OpenAPI SPEC을 제공한다
> swagger framework에 대한 자세한 내용을 알고 싶다면 [***http://swagger.io***](http://swagger.io)
> 웹 사이트를 방문한다

### Swagger UI로 API 탐색
> kubernetes는 swagger api를 공개할 뿐만 아니라 스웨거 UI를 API 서버에 통합했다. 
> 이 기능은 기본적으로 활성화되어 있지 않다. 이를 활성화 하기 위해서는
> ***--enable-swagger-ui=true 옵션을 사용해 API 서버르 실행해야 한다.

UI를 활성화 한 후에는 브라우저에서 다음을 가리켜 UI를 열 수 있다.
http(S)://<api Server>:<port>/swagger-ui
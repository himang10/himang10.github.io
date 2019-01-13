---
layout: post
title: k8s에서 configmap resource 생성 및 사용 방법 가이드
date: 2019-01-06
categories: Kubernetes
tags: [A kubernetes, configmap]
author: himang10
description: Configmap 사용을 위한 설명
---
ConfigMap 사용
============

# Table of Contents
1. [command line에서 configmap 생성](#command-line에서-configmap-생성)
2. [configmap entry creation](#configmap-entry-creation)
3. [디렉토리 마운트 시 기존 디렉토리 파일을숨기지 않고 개별 configmap 엔트리로 마운트 방법](#configmap-entry-mount)

### configmap 전체 옵션 구조
-----
```
$ kubectl create configmap my-config
   --from-file=foo.json   # single file
   --from-file=bar=foobar.conf   # 사용자 정의 키 밑에 저장된 파일
   --from-file=config-opts/.        # directory
   --from-literal=some=thing.     # 리터럴 값
```

### command line에서 configmap 생성
<hr/>
```
$ kubectl create configmap myconfigmap --from-literal=foo=bar --from-literal=bar=baz
```

### configmap entry creation
<hr/>
```
$ cat my-nginx-config.conf
server {
    listen              80;
    server_name         www.kubia-example.com;

    gzip on;
    gzip_types text/plain application/xml;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

$ kubectl create configmap my-config --from-file=my-nginx-config.conf
configmap "my-config" created

$ kubectl get configmap my-config -o yaml
apiVersion: v1
data:
  my-nginx-config.conf: |
    server {
        listen              80;
        server_name         www.kubia-example.com;

        gzip on;
        gzip_types text/plain application/xml;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

    }
kind: ConfigMap
metadata:
  creationTimestamp: 2019-01-06T02:01:47Z
  name: my-config
  namespace: default
  resourceVersion: "864053"
  selfLink: /api/v1/namespaces/default/configmaps/my-config
  uid: 066a6104-1157-11e9-a6b2-fa163e26d271
## 수동으로 키를 지정

$ kubectl create configmap my-config --from-file=customkey=my-nginx-config.conf
configmap "my-config" created

$ kubectl get configmap my-config -o yaml
apiVersion: v1
data:
  customkey: |
    server {
        listen              80;
        server_name         www.kubia-example.com;

        gzip on;
        gzip_types text/plain application/xml;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

    }
kind: ConfigMap
metadata:
  creationTimestamp: 2019-01-06T02:07:22Z
  name: my-config
  namespace: default
  resourceVersion: "864610"
  selfLink: /api/v1/namespaces/default/configmaps/my-config
  uid: ce15eaab-1157-11e9-a6b2-fa163e26d271
```

### 디렉토리에 있는 파일로 부터 configmap 만들기
<hr/>
```
$ ls
Dockerfile     fortuneloop.sh

$ pwd
/Users/himang10/ywyi/icp3.1/k8sbook/kubernetes-in-action/Chapter07/fortune-env

$ kubectl create configmap my-config --from-file=/Users/himang10/ywyi/icp3.1/k8sbook/kubernetes-in-action/Chapter07/fortune-envconfigmap 
"my-config" created

$ kubectl get configmap my-config -o yaml
apiVersion: v1
data:
  Dockerfile: |
    FROM ubuntu:latest

    RUN apt-get update ; apt-get -y install fortune
    ADD fortuneloop.sh /bin/fortuneloop.sh

    ENTRYPOINT ["/bin/fortuneloop.sh"]
  fortuneloop.sh: |+
    #!/bin/bash
    trap "exit" SIGINT

    echo Configured to generate new fortune every $INTERVAL seconds

    mkdir -p /var/htdocs

    while :
    do
      echo $(date) Writing fortune to /var/htdocs/index.html
      /usr/games/fortune > /var/htdocs/index.html
      sleep $INTERVAL
    done

kind: ConfigMap
metadata:
  creationTimestamp: 2019-01-06T02:11:57Z
  name: my-config
  namespace: default
  resourceVersion: "865062"
  selfLink: /api/v1/namespaces/default/configmaps/my-config
  uid: 717f6751-1158-11e9-a6b2-fa163e26d271
```
### container의 환경변수로 configmap 엔트리 전달하기
<hr/>
{% highlight linux %}
fortune-pod-env-configmap.yaml
- valueFrom: 환경 변수 INTERVAL은 configmap.fortune-config.sleep-interval로 부터 왔다는 것을 정의
apiVersion: v1
kind: Pod
metadata:
  name: fortune-env-from-configmap
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      valueFrom:·
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html
    emptyDir: {}
config의 모든 항목을 한번에 환경변수로 전달

spec:
  containers:
  - image: some-image
    envFrom:                                   # env 대신에 envFrom 사용
    - prefix: CONFIG_                     # 모든 환경변수는 CONFIG_ 접두어 붙어짐. 만약 생략하면 환경변수와 동일한 이름으로 키가 생성
      configMapRef:                        # my-config-map으로 불리는 configmap 참고
        name: my-config-map
{% endhighlight %}


*** configmap 항목을 명령행 인자로 전달 ***
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fortune-args-from-configmap
spec:
  containers:
  - image: luksa/fortune:args
    env:
    - name: INTERVAL
      valueFrom:·
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
    args: ["$(INTERVAL)"]
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html
    emptyDir: {}
```
### configmap volume을 이용하여 configmap 엔트리를 파일로 노출
<hr/>
```yaml
$ kubectl create configmap fortune-config --from-file=configmap-files/
configmap "fortune-config" created

$ kubectl get configmap fortune-config -o yaml
apiVersion: v1
data:
  my-nginx-config.conf: |
    server {
        listen              80;
        server_name         www.kubia-example.com;

        gzip on;
        gzip_types text/plain application/xml;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

    }
  sleep-interval: |
    25
kind: ConfigMap
metadata:
  creationTimestamp: 2019-01-06T04:08:01Z
  name: fortune-config
  namespace: default
  resourceVersion: "876546"
  selfLink: /api/v1/namespaces/default/configmaps/fortune-config
  uid: a8ec280e-1168-11e9-a6b2-fa163e26d271
```
container web-server는 /etc/nginx/conf.d --> volume mount해서 볼 수 있도록 설정

*** volume에 configmap을 conf.d의 volumemount실행 ***
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fortune-configmap-volume
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
    - name: config
      mountPath: /tmp/whole-fortune-config-volume
      readOnly: true
    ports:
      - containerPort: 80
        name: http
        protocol: TCP
  volumes:
  - name: html
    emptyDir: {}
  - name: config
    configMap:
      name: fortune-config

$ kubectl exec fortune-configmap-volume -c web-server ls /etc/nginx/conf.d
my-nginx-config.conf
sleep-interval
```

### 볼륨의 특정 configmap 엔트리의 노출
<hr/>
일단 디렉토리 마운트 후 my-nginx-config.conf를 gzip.conf로만 노출하고 있음 다른 것은 보이지 않음

### 개별 항목(파일)을 지정할 때 항목의 키와 함께 개별 항목의 파일 이름을 설정해야 함.
<hr/>
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fortune-configmap-volume-with-items
spec:
  containers:
  - image: luksa/fortune:env
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    - name: config
      mountPath: /etc/nginx/conf.d/
      readOnly: true
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html
    emptyDir: {}
  - name: config
    configMap:
      name: fortune-config
      items:
      - key: my-nginx-config.conf
        path: gzip.conf
```
### configmap entry mount
#### (파일 마운트) 디렉토리 마운트 시 기존 디렉토리 파일을숨기지 않고 개별 configmap 엔트리로 마운트 방법
<hr/>
```yaml
configmap:app-config
* myconfig.conf
* another-file

apiVersion: v1
kind: Pod
metadata:
  name: fortune-configmap-volume
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    - name: config
      mountPath: /etc/nginx/conf.d/someconfig.conf # 디렉토리가 아니라 파일 
      subPath: myconfig.conf # configmap의 특정 마운트해야 할 파일
      readOnly: true
    - name: config
      mountPath: /tmp/whole-fortune-config-volume
      readOnly: true
    ports:
      - containerPort: 80
        name: http
        protocol: TCP
  volumes:
  - name: html
    emptyDir: {}
  - name: config
    configMap:
      name: fortune-config
```
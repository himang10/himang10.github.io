---
layout: post
title: Pod Security Policy 변경 방법
date: 2019-01-06
categories: Kubernetes
tags: [A kubernetes, psp, Pod, Security, Policy]
author: himang10
description: Pod Security Policy 변경 방법
---
Pod Security Policy 변경 방법
============

# Table of Contents
1. [ICP 3.1.1 기본 PSP](#ICP-3.1.1-기본-PSP)
2. [default PSP 변경 방법](#default-PSP-변경-방법)

# ICP Namespace Default PSP 설정 변경 방법

## ICP 3.1.1 기본 PSP
ICP 3.1.1은 기본적으로 ibm-privileged-psp를 기본으로 설정하고 있다. 이 특성은 Root 권한으로 접속 시 생성에 제약을 걸도록 하는 기능이다. 
이를 해결 하기 위해서는 Pod 생성 시 일반 사용자 ID로 사용할 수 있도록 securityContext를 설정하여야 하는데
예를들어
```yaml
securityContext:
  runAsUser: 2222
````

또는 default psp를 변경하여야 한다.

## default PSP 변경 방법
1. 변경 절차
* psp 신규 생성
```yaml
$ cat himang10-default-psp.yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: himang10-default-psp
spec:
  allowPrivilegeEscalation: true
  allowedCapabilities:
  - SETPCAP
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETUID
  - SETGID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - MKNOD
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - '*'
````
* 신규 psp (himang10-default-psp) 사용 권한을 가지는 clusterrole 생성
```yaml
$ cat himang10-psp-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: himang10-psp-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - himang10-default-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
````
* 기존 psp를 binding하고 있는 ***ibm-restricted-psp-users*** clusterrolebinding 삭제
```
$kubectl delete clusterrolebinding ibm-restricted-psp-users
````
* 새롭게 생성한 clusterrole을 authenticated, unauthenticated, serviceaccount 그룹에 소속되는 네이밍스페이스는 아래의 clusterrolebinding으로 설정
```yaml
$ cat himang10-psp-clusterrolebinding.yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: himang10-psp-clusterrolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: himang10-psp-clusterrole
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:authenticated
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:unauthenticated
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts
```
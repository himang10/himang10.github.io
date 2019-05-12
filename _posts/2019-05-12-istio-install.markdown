---
layout: post
title: Istio 1.1.5 설치
date: 2019-01-06
categories: istio
author: himang10
feature-img: "assets/img/pexels/desk-messy.jpeg"
thumbnail: "assets/img/thumbnails/desk-messy.jpeg"
tags: [istio, install]
---
[원본](https://istio.io/docs/concepts/what-is-istio/)


### Istio 1.1.5 버전 설치 및 ICP 방식 구성 (Mgmt, Proxy)

#### (1) Istio 1.1.5 다운로드 및 압축 해제
* 다운로드 링크
[https://github.com/istio/istio/releases/download/1.1.5/istio-1.1.5-linux.tar.gz](https://github.com/istio/istio/releases/download/1.1.5/istio-1.1.5-linux.tar.gz)

* 다운로드 및 압축 해제

```
root@cluster2-node-1:~# wget https://github.com/istio/istio/releases/download/1.1.5/istio-1.1.5-linux.tar.gz
--2019-05-08 13:35:04--  https://github.com/istio/istio/releases/download/1.1.5/istio-1.1.5-linux.tar.gz
Resolving github.com (github.com)... 192.30.255.112
Connecting to github.com (github.com)|192.30.255.112|:443... connected.
HTTP request sent, awaiting response... 302 Found
 
.. 중략 ..
 
istio-1.1.5-linux.tar.gz  100%[====================================>]  14.94M  1.55MB/s    in 11s
 
2019-05-08 13:35:18 (1.30 MB/s) - ‘istio-1.1.5-linux.tar.gz’ saved [15661322/15661322]
 
root@cluster2-node-1:~# tar xvfz istio-1.1.5-linux.tar.gz
istio-1.1.5/
istio-1.1.5/LICENSE
istio-1.1.5/samples/
istio-1.1.5/samples/helloworld/
istio-1.1.5/samples/helloworld/helloworld-gateway.yaml
istio-1.1.5/samples/helloworld/helloworld.yaml
istio-1.1.5/samples/helloworld/README.md
istio-1.1.5/samples/helloworld/src/
istio-1.1.5/samples/helloworld/src/requirements.txt
istio-1.1.5/samples/bookinfo/
istio-1.1.5/samples/bookinfo/swagger.yaml
istio-1.1.5/samples/bookinfo/telemetry/
 
 
 
 
.. 중략 ..
 
 
istio-1.1.5/install/kubernetes/helm/istio-init/files/crd-11.yaml
istio-1.1.5/install/kubernetes/helm/istio-init/files/crd-10.yaml
istio-1.1.5/install/kubernetes/helm/istio-init/Chart.yaml
istio-1.1.5/install/kubernetes/README.md
istio-1.1.5/install/kubernetes/istio-citadel-with-health-check.yaml
istio-1.1.5/install/kubernetes/mesh-expansion.yaml
istio-1.1.5/install/kubernetes/istio-demo-auth.yaml
istio-1.1.5/install/kubernetes/global-default-sidecar-scope.yaml
 
 
root@cluster2-node-1:~# ls istio-1.1.5
LICENSE  README.md  bin  install  istio.VERSION  samples  tools
root@cluster2-node-1:~#
```

#### (2) Istio 1.1.5 버전 재설치

1. Namespace 생성
1. Root CA를 Secret으로 등록
1. CRD 설치용 파일 생성
1. Istio 1.1.5 설치용 파일 생성
1. 설치

```
root@cluster2-node-1:~# ls istio-1.1.5
LICENSE  README.md  bin  install  istio.VERSION  samples  tools
 
root@cluster2-node-1:~# kubectl create namespace istio-system
namespace/istio-system created
 
root@cluster2-node-1:~# kubens
bar
cert-manager
default
foo
ibmcom
istio-system
kube-public
kube-system
legacy
mysql-test
platform
services
sock-shop
 
root@cluster2-node-1:~# kubens istio-system
Context "mycluster-context" modified.
Active namespace is "istio-system".
 
root@cluster2-node-1:~# kg all
No resources found.
 
root@cluster2-node-1:~# cd istio-1.1.5
 
root@cluster2-node-1:~/istio-1.1.5# kubectl create secret generic cacerts -n istio-system \
>     --from-file=samples/certs/ca-cert.pem \
>     --from-file=samples/certs/ca-key.pem \
>     --from-file=samples/certs/root-cert.pem \
>     --from-file=samples/certs/cert-chain.pem
secret/cacerts created
 
root@cluster2-node-1:~/istio-1.1.5# kubectl get secret
NAME                  TYPE                                  DATA   AGE
cacerts               Opaque                                4      9s
default-token-9qfhb   kubernetes.io/service-account-token   3      35s
 
root@cluster2-node-1:~/istio-1.1.5# cat install/kubernetes/helm/istio-init/files/crd-* > $HOME/istio.yaml
 
root@cluster2-node-1:~/istio-1.1.5# helm template install/kubernetes/helm/istio \
>     --set grafana.enabled=true \
>     --set kiali.enabled=true \
>     --set prometheus.enabled=true \
>     --set tracing.enabled=true \
>     --set tracing.ingress.enabled=true \
>     --set global.proxy.accessLogFile="/dev/stdout" \
>     --set global.meshExpansion.enabled=true \
>     --set global.meshExpansion.useILB=true \
>     --set gateways.istio-ingressgateway.enabled=true \
>     --set gateways.istio-ingressgateway.sds.enabled=true \
>     --set gateways.istio-egressgateway.enabled=true \
>     --name istio --namespace istio-system \
>     -f install/kubernetes/helm/istio/example-values/values-istio-multicluster-gateways.yaml >> $HOME/istio.yaml
 
root@cluster2-node-1:~/istio-1.1.5# cd
 
root@cluster2-node-1:~# ls istio.yaml
istio.yaml
 
root@cluster2-node-1:~# kubectl create -f istio.yaml
customresourcedefinition.apiextensions.k8s.io/virtualservices.networking.istio.io created
customresourcedefinition.apiextensions.k8s.io/destinationrules.networking.istio.io created
customresourcedefinition.apiextensions.k8s.io/serviceentries.networking.istio.io created
customresourcedefinition.apiextensions.k8s.io/gateways.networking.istio.io created
customresourcedefinition.apiextensions.k8s.io/envoyfilters.networking.istio.io created
customresourcedefinition.apiextensions.k8s.io/clusterrbacconfigs.rbac.istio.io created
customresourcedefinition.apiextensions.k8s.io/policies.authentication.istio.io created
customresourcedefinition.apiextensions.k8s.io/meshpolicies.authentication.istio.io created
customresourcedefinition.apiextensions.k8s.io/httpapispecbindings.config.istio.io created
customresourcedefinition.apiextensions.k8s.io/httpapispecs.config.istio.io created
customresourcedefinition.apiextensions.k8s.io/quotaspecbindings.config.istio.io created
customresourcedefinition.apiextensions.k8s.io/quotaspecs.config.istio.io created
 
 
.. 중략 ..
 
 
rule.config.istio.io/promhttp created
rule.config.istio.io/promtcp created
rule.config.istio.io/promtcpconnectionopen created
rule.config.istio.io/promtcpconnectionclosed created
handler.config.istio.io/kubernetesenv created
rule.config.istio.io/kubeattrgenrulerule created
rule.config.istio.io/tcpkubeattrgenrulerule created
kubernetes.config.istio.io/attributes created
destinationrule.networking.istio.io/istio-policy created
destinationrule.networking.istio.io/istio-telemetry created
 
 
root@cluster2-node-1:~# kubectl get pods
NAME                                      READY   STATUS      RESTARTS   AGE
grafana-7f4d444dd5-rzd4x                  1/1     Running     0          3m19s
istio-citadel-55dfd6d7df-l5mn5            1/1     Running     0          3m10s
istio-cleanup-secrets-1.1.5-72gdk         0/1     Completed   0          3m23s
istio-egressgateway-57b9c58c79-b4tgl      1/1     Running     0          3m21s
istio-galley-8ddb885b8-cztw4              1/1     Running     0          3m22s
istio-grafana-post-install-1.1.5-bwjzk    0/1     Completed   0          3m23s
istio-ingressgateway-5bbc847975-kl7g7     2/2     Running     0          3m20s
istio-pilot-5b588fdddc-t8vdx              2/2     Running     0          3m12s
istio-policy-5556c67f9-xcbcm              2/2     Running     4          3m15s
istio-security-post-install-1.1.5-g4nv9   0/1     Completed   0          3m23s
istio-sidecar-injector-95fb47999-clvd7    1/1     Running     0          3m9s
istio-telemetry-5cd7cc7b9c-jkksr          2/2     Running     4          3m13s
istio-tracing-79db5954f-ztjtj             1/1     Running     0          3m9s
istiocoredns-586757d55d-2m8b9             2/2     Running     0          3m17s
kiali-68677d47d7-5zg2g                    1/1     Running     0          3m17s
prometheus-5977597c75-vsdqj               1/1     Running     0          3m11s
root@cluster2-node-1:~#
```

#### (3) ICP 방식 구성 (Mgmt, Proxy)
* 구분
** Proxy Node
*** Ingress Gateway
*** Egress Gateway
** Management Node
*** 기타 Component
**** Pilot
**** Mixer
**** Citadel
**** Galley
...

* 대상
** 전체 Node 현황
```
root@cluster2-node-1:~# kubectl get nodes
NAME            STATUS   ROLES         AGE   VERSION
192.168.50.10   Ready    management    15d   v1.12.4+icp-ee
192.168.50.11   Ready    worker        15d   v1.12.4+icp-ee
192.168.50.13   Ready    worker        15d   v1.12.4+icp-ee
192.168.50.3    Ready    proxy         15d   v1.12.4+icp-ee
192.168.50.7    Ready    etcd,master   15d   v1.12.4+icp-ee
 
 
root@cluster2-node-1:~# kubectl get nodes --show-labels
NAME            STATUS   ROLES         AGE   VERSION          LABELS
192.168.50.10   Ready    management    15d   v1.12.4+icp-ee   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=192.168.50.10,management=true,node-role.kubernetes.io/management=true
192.168.50.11   Ready    worker        15d   v1.12.4+icp-ee   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=192.168.50.11,node-role.kubernetes.io/worker=true
192.168.50.13   Ready    worker        15d   v1.12.4+icp-ee   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=192.168.50.13,node-role.kubernetes.io/worker=true
192.168.50.3    Ready    proxy         15d   v1.12.4+icp-ee   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=192.168.50.3,node-role.kubernetes.io/proxy=true,proxy=true
192.168.50.7    Ready    etcd,master   15d   v1.12.4+icp-ee   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,etcd=true,kubernetes.io/hostname=192.168.50.7,master=true,node-role.kubernetes.io/etcd=true,node-role.kubernetes.io/master=true,role=master
```

** 대상 1 - Proxy Node
*** 192.168.50.3
*** Label: proxy=true
** 대상 2 - Management Node
*** 192.168.50.10
*** Label: management=true

* 구성 순서
1. 위에서 아래로 수동으로 반영 (추후 Helm Chart Customize 예정)
```
root@cluster2-node-1:~# kubectl get pods
NAME                                      READY   STATUS      RESTARTS   AGE
grafana-7f4d444dd5-rzd4x                  1/1     Running     0          3m19s
istio-citadel-55dfd6d7df-l5mn5            1/1     Running     0          3m10s
istio-cleanup-secrets-1.1.5-72gdk         0/1     Completed   0          3m23s
istio-egressgateway-57b9c58c79-b4tgl      1/1     Running     0          3m21s
istio-galley-8ddb885b8-cztw4              1/1     Running     0          3m22s
istio-grafana-post-install-1.1.5-bwjzk    0/1     Completed   0          3m23s
istio-ingressgateway-5bbc847975-kl7g7     2/2     Running     0          3m20s
istio-pilot-5b588fdddc-t8vdx              2/2     Running     0          3m12s
istio-policy-5556c67f9-xcbcm              2/2     Running     4          3m15s
istio-security-post-install-1.1.5-g4nv9   0/1     Completed   0          3m23s
istio-sidecar-injector-95fb47999-clvd7    1/1     Running     0          3m9s
istio-telemetry-5cd7cc7b9c-jkksr          2/2     Running     4          3m13s
istio-tracing-79db5954f-ztjtj             1/1     Running     0          3m9s
istiocoredns-586757d55d-2m8b9             2/2     Running     0          3m17s
kiali-68677d47d7-5zg2g                    1/1     Running     0          3m17s
prometheus-5977597c75-vsdqj               1/1     Running     0          3m11s
 
 
root@cluster2-node-1:~# kubectl get deployments
NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
grafana                  1         1         1            1           14m
istio-citadel            1         1         1            1           14m
istio-egressgateway      1         1         1            1           14m
istio-galley             1         1         1            1           14m
istio-ingressgateway     1         1         1            1           14m
istio-pilot              1         1         1            1           14m
istio-policy             1         1         1            1           14m
istio-sidecar-injector   1         1         1            1           14m
istio-telemetry          1         1         1            1           14m
istio-tracing            1         1         1            1           14m
istiocoredns             1         1         1            1           14m
kiali                    1         1         1            1           14m
prometheus               1         1         1            1           14m
root@cluster2-node-1:~#
```

2. grafana
```
root@cluster2-node-1:~# kubectl edit deploy grafana
 
 
.. 중략 ..
 
 
        - mountPath: /etc/grafana/provisioning/datasources/datasources.yaml
          name: config
          subPath: datasources.yaml
        - mountPath: /etc/grafana/provisioning/dashboards/dashboardproviders.yaml
          name: config
          subPath: dashboardproviders.yaml
      dnsPolicy: ClusterFirst
####################### 하기부분 추가 #######################
  
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext:
        fsGroup: 472
        runAsUser: 472
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
  
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - configMap:
          defaultMode: 420
          name: istio-grafana
        name: config
      - emptyDir: {}
        name: data
      - configMap:
          defaultMode: 420
 
 
.. 중략 ..
 
 
:wq
 
 
root@cluster2-node-1:~# kubectl get pods | grep grafana
grafana-56b5659c79-n2tp5                  1/1     Running     0          47s
istio-grafana-post-install-1.1.5-bwjzk    0/1     Completed   0          18m
```

3. citadel
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
 
 
 
.. 중략 ..
        volumeMounts:
        - mountPath: /etc/cacerts
          name: cacerts
          readOnly: true
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istio-citadel-service-account
      serviceAccountName: istio-citadel-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - name: cacerts
        secret:
          defaultMode: 420
          optional: true
          secretName: cacerts
 
 
.. 중략 ..
```

4. egressgateway
```
root@cluster2-node-1:~# kubectl edit deploy istio-egressgateway
 
 
.. 중략 ..
          readOnly: true
        - mountPath: /etc/istio/egressgateway-certs
          name: egressgateway-certs
          readOnly: true
        - mountPath: /etc/istio/egressgateway-ca-certs
          name: egressgateway-ca-certs
          readOnly: true
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        proxy: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istio-egressgateway-service-account
      serviceAccountName: istio-egressgateway-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - name: istio-certs
        secret:
          defaultMode: 420
          optional: true
          secretName: istio.istio-egressgateway-service-account
 
 
.. 중략 ..
```

5. galley
```
root@cluster2-node-1:~# kubectl edit deploy istio-galley
 
.. 중략 ..
 
        volumeMounts:
        - mountPath: /etc/certs
          name: certs
          readOnly: true
        - mountPath: /etc/config
          name: config
          readOnly: true
        - mountPath: /etc/mesh-config
          name: mesh-config
          readOnly: true
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istio-galley-service-account
      serviceAccountName: istio-galley-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - name: certs
        secret:
          defaultMode: 420
          secretName: istio.istio-galley-service-account
 
 
.. 중략 ..
```

6. ingressgateway
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
        volumeMounts:
        - mountPath: /var/run/ingress_gateway
          name: ingressgatewaysdsudspath
        - mountPath: /etc/certs
          name: istio-certs
          readOnly: true
        - mountPath: /etc/istio/ingressgateway-certs
          name: ingressgateway-certs
          readOnly: true
        - mountPath: /etc/istio/ingressgateway-ca-certs
          name: ingressgateway-ca-certs
          readOnly: true
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        proxy: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istio-ingressgateway-service-account
      serviceAccountName: istio-ingressgateway-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - emptyDir: {}
        name: ingressgatewaysdsudspath
      - name: istio-certs
        secret:
          defaultMode: 420
          optional: true
          secretName: istio.istio-ingressgateway-service-account
 
 
.. 중략 ..
```

7. pilot
```
  root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
      volumeMounts:
        - mountPath: /etc/certs
          name: istio-certs
          readOnly: true
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istio-pilot-service-account
      serviceAccountName: istio-pilot-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - configMap:
          defaultMode: 420
          name: istio
        name: config-volume
 
 
.. 중략 ..
```

8. policy
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
        volumeMounts:
        - mountPath: /etc/certs
          name: istio-certs
          readOnly: true
        - mountPath: /sock
          name: uds-socket
        - mountPath: /var/run/secrets/istio.io/policy/adapter
          name: policy-adapter-secret
          readOnly: true
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istio-mixer-service-account
      serviceAccountName: istio-mixer-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - name: istio-certs
        secret:
          defaultMode: 420
          optional: true
          secretName: istio.istio-mixer-service-account
 
 
.. 중략 ..
```

9. sidecar-injector
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
    volumeMounts:
        - mountPath: /etc/istio/config
          name: config-volume
          readOnly: true
        - mountPath: /etc/istio/certs
          name: certs
          readOnly: true
        - mountPath: /etc/istio/inject
          name: inject-config
          readOnly: true
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istio-sidecar-injector-service-account
      serviceAccountName: istio-sidecar-injector-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - configMap:
          defaultMode: 420
          name: istio
        name: config-volume
 
 
.. 중략 ..
```

10. telemetry
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
      volumeMounts:
        - mountPath: /etc/certs
          name: istio-certs
          readOnly: true
        - mountPath: /sock
          name: uds-socket
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istio-mixer-service-account
      serviceAccountName: istio-mixer-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - name: istio-certs
        secret:
          defaultMode: 420
          optional: true
          secretName: istio.istio-mixer-service-account
 
 
.. 중략 ..
```

11. tracing
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
        resources:
          requests:
            cpu: 10m
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: 2019-05-08T04:41:41Z
    lastUpdateTime: 2019-05-08T04:41:41Z
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
 
 
.. 중략 ..
```

12. coredns
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
       resources:
          requests:
            cpu: 10m
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: Default
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: istiocoredns-service-account
      serviceAccountName: istiocoredns-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - configMap:
          defaultMode: 420
          items:
          - key: Corefile
            path: Corefile
          name: coredns
        name: config-volume
 
 
.. 중략 ..
```

13. kiali
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
       volumeMounts:
        - mountPath: /kiali-configuration
          name: kiali-configuration
        - mountPath: /kiali-secret
          name: kiali-secret
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: kiali-service-account
      serviceAccountName: kiali-service-account
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - configMap:
          defaultMode: 420
          name: kiali
        name: kiali-configuration
 
 
.. 중략 ..
```

14. prometheus
```
root@cluster2-node-1:~# kubectl edit deploy istio-citadel
 
.. 중략 ..
 
 
      volumeMounts:
        - mountPath: /etc/prometheus
          name: config-volume
        - mountPath: /etc/istio-certs
          name: istio-certs
      dnsPolicy: ClusterFirst
 
 
####################### 하기부분 추가 #######################
 
      nodeSelector:
        management: "true"
 
 
####################### 상기부분 추가 #######################
 
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: prometheus
      serviceAccountName: prometheus
      terminationGracePeriodSeconds: 30
 
 
####################### 하기부분 추가 #######################
 
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
 
 
####################### 상기부분 추가 #######################
 
      volumes:
      - configMap:
          defaultMode: 420
          name: prometheus
        name: config-volume
 
 
.. 중략 ..
```

#### (4) ICP 방식으로 반영 결과

* Proxy Node
** 192.168.50.3
* Management Node
** 192.168.50.10
```
root@cluster2-node-1:~# kubectl get pods -o wide
NAME                                      READY   STATUS      RESTARTS   AGE    IP              NODE            NOMINATED NODE
grafana-56b5659c79-n2tp5                  1/1     Running     0          119m   10.51.194.188   192.168.50.10   <none>
istio-citadel-7f4d6f7bf5-88pm8            1/1     Running     0          49m    10.51.194.189   192.168.50.10   <none>
istio-cleanup-secrets-1.1.5-72gdk         0/1     Completed   0          136m   10.51.185.94    192.168.50.11   <none>
istio-egressgateway-7d9db495d4-grhxt      1/1     Running     0          46m    10.51.253.201   192.168.50.3    <none>
istio-galley-cd95985d-x7lzt               1/1     Running     0          43m    10.51.194.190   192.168.50.10   <none>
istio-grafana-post-install-1.1.5-bwjzk    0/1     Completed   0          136m   10.51.37.183    192.168.50.13   <none>
istio-ingressgateway-645649855b-xwgtx     2/2     Running     0          41m    10.51.253.202   192.168.50.3    <none>
istio-pilot-848d8bb66f-5zbmp              2/2     Running     0          40m    10.51.194.191   192.168.50.10   <none>
istio-pilot-848d8bb66f-nsggn              2/2     Running     0          105s   10.51.194.164   192.168.50.10   <none>
istio-policy-545bf6cd57-mhtnd             2/2     Running     0          38m    10.51.194.131   192.168.50.10   <none>
istio-security-post-install-1.1.5-g4nv9   0/1     Completed   0          136m   10.51.185.98    192.168.50.11   <none>
istio-sidecar-injector-54b6879bdf-8b2p7   1/1     Running     0          37m    10.51.194.133   192.168.50.10   <none>
istio-telemetry-7fb47c74c-pvbrp           2/2     Running     0          10m    10.51.194.161   192.168.50.10   <none>
istio-tracing-5f54d4d6ff-czt8k            1/1     Running     0          34m    10.51.194.151   192.168.50.10   <none>
istiocoredns-898d7c744-sq2xh              2/2     Running     0          33m    10.51.194.140   192.168.50.10   <none>
kiali-7c9b675989-9nxjq                    1/1     Running     0          32m    10.51.194.158   192.168.50.10   <none>
prometheus-6c894d488f-m2pn7               1/1     Running     0          31m    10.51.194.159   192.168.50.10   <none>
root@cluster2-node-1:~#

```


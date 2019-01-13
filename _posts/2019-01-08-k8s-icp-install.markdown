---
layout: post
title: ICP Install Guide
date: 2019-01-08
categories: Kubernetes
tags: [A kubernetes, icp, install]
author: himang10
description: ICP 3.1.1 install guide
---
ICP 3.1.1 Install Guide
============

# Table of Contents
[사전작업 all node](#사전작업-all-node)
[사전작업-Boot](#configmap-entry-creation)
[ICP Install](#ICP-Install)
[설치 이슈](#설치-이슈)



# 사전작업 all node
-----

1. DNS 설치
```
#/etc/resolv.conf에 nameserver 설정 
nameserver 10.38.201.250
```

2. icp, docker install file copy
```
* ibm-cloud-private-x86_64-3.1.1.tar.gz
* icp-docker-18.03.01_x86_64.bin
```

3. local storage 설정 
```
* / 100G | all
* /var/lib/docker 150G | master, mgmt, proxy, worker, va
* /var/lib/kubelet 50G | master
* /var/lib/icp 100G | master, mgmt, va
* /var/lib/etcd 50G | master
* /var/lib/mysql 50G | master
* /tmp 50G | master, mgmt,  proxy, worker, va
* /var/lib/icp/va/minio | 100G va
```

4. NAS NFS
```
* /var/lib/registry 100G | Master
* /var/lib/icp/audit 100G | M
* /var/log/audit 100G | M
* /var/lib/icp/helmrepo 100G | Master
```

5. 방화벽

```
* ZCP Portal 8080 / 8443
* ZCP Cli API 8001 / 8888
* ZCP Image Manager 8500 / 8600
* ZCP Ingress SErvice 80 / 443
* ZCP App SErvice 접속 30000 ~32737

```

6. swap memory off 및 확인

```
# /etc/fstab swap 항목 주석 처리하고 swapoff -a 진행
# /dev/mapper/rhel-swap swap swap defaults 0 0
swappoff -a

# 명령어를 통해서 swap memory 가 off 되었는지 확인
# swap memory가 여전히 사용중이라면 reboot 후 다시 확인
free -m
Mem: 32012 1505 
swap: 0           0

```

7. 패키지 설치

```
#socat, ntp 설치
sudo yum install -y socat ntp
--> socat-1.7.3.2-2.el7.x86_64 network util
```

8. ntp 설정 (redhat)

```
* (Redhat) sudo systemctl enable ntpd
* (Redhat) sudo systemctl start ntpd
* (Ubuntu) sudo systemctl restart ntp.service
```

9. ssh generation
```
$ ssh-keygen -b 4096 -f ~/.ssh/id_rsa -N ""
```

10. docker install
```
$ chmod u+x ./icp-docker-18.03.01_x86_64.bin
$ sudo ./icp-docker-18.03.1_x86_64.bin  --install
```

11. extract images and load them into docker
```
tar xvf ibm-cloud-private-x86_64-3.1.1.tar.gz -O | sudo docker load
```

12. python 설치 확인
```
$ python —version
$ sudo apt-get install python (2.7 version)
#rhel 7이상은 default로 python 2.7.5 버전이 설치되어 있음
```

13. /etc/hosts

```
127.0.0.1       localhost
#127.0.1.1     <host_name>
#The following lines are desirable for IPv6 capable hosts
#::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
<master_node_IP_address> <master_node_host_name>
<worker_node_1_IP_address> <worker_node_1_host_name>
<worker_node_2_IP_address> <worker_node_2_IP_host_name>
<proxy_node_IP_address> <proxy_node_host_name>
```

## NFS, NAS Mount 방법

1. NFS  Mount (Master Node)

```
mkdir -p /var/lib/registry
mkdir -p /var/lib/icp/audit
mkdir -p /var/log/audit
mkdir -p /var/lib/icp/helmrepo

#Host 내 NAS Voulm을 NFS로 마운트
$ mount -t nfs VNX5600_NAS:/Zcp_registry /var/lib/registry
$~~~
```

2. fstab 설정 (Master Node)

```
#/etc/fstab 파일에 아래 내용 추가
VNX5600_NAS:/Zcp_registry      /var/lib/registry nfs rw,hard  0 0
....
```

3. Local Disk LV 제거 및 생성
```
  1.1 기존 Local Disk (500G) LV unmount 및 제거 (Master Node)
       $ unmount /DATA01
       $ lvremove /dev/DATAAVG/LV01
  1.2 새로운 LV 생성 및 xfs filesystem으로 format (Master Node)
      $ lvcreate -L 150G -n lv_docker DATAVG
      $ lvcreate -L 50G -n lv_kubelet DATAVG
      $ lvcreate -L 50G -n lv_tmp DATAVG
      $ lvcreate -L 100G -n lv_icp DATAVG
      $ lvcreate -L 50G -n lv_etcd DATAVG
      $ lvcreate -L 50G -n lv_mysql DATAVG

      # xfs filesystem 으로 format
      $ mkfs.xfs /dev/DATAVG/lv_docker
  ….
 1.3. Mount Point  생성 (Master Node)
mkdir -p /var/lib/docker
mkdir -p /var/lib/kubelet
mkdir -p /var/lib/icp
mkdir -p /var/lib/etcd
mkdir -p /var/lib/mysql
mkdir -p /var/lib/tmp
1.4 /etc/fstab 등록 (Master Node)

#vi  /etc/fstab에 자동 마운트 설정
/dev/mapper/DATAVG-lv_docker /var/lib/docker xfs defaults 0 0
...
mount -a
1.5 LV  확인 (Master Node)
LV VG Attr LSize Pool
...
나머지도 각 노드에 맞게 위의 절차에 따라 마운트 필요

```

# 사전작업-Boot
<hr/>
## private key와 public key 할당 방법
### If 이미 pem file이 있는 경우

```
$ cp himang10 .ssh/id_rsa (private key    복사)
$ cp .ssh/authorized_keys .ssh/id_rsa.pub
```

### Else pem file이 없는 경우
1. Key gen
```
  #login to root 
  # sudo su -
ssh-keygen -b 4096 -f ~/.ssh/id_rsa -N ""
#it 만약 기존에 이미 ./ssh 로 연결되고 있는 경우
eval #(ssh-agent)
ssh-add /home/ubuntu/himang10.pem 으로 설정 (절체 패스로)
```

2. sharing ssh key
```
  https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/installing/ssh_keys.html
  #모든 노드에서 boot node의 ssh public key copy
  ssh-copy-id -i ~/.ssh/id_rsa.pub <user>@node_ip_address>
```

### 공통 작업

3. create installation dir
```
sudo mkdir /opt/ibm-cloud-private-3.1.1
```

4. extract the configuration files from the image
```
cd /opt/ibm-cloud-private-3.1.1
sudo docker run -v $(pwd):/data -e LICENSE=accept ibmcom/icp-inception-amd64:3.1.1-ee cp -r cluster /data
```

5. ssh copy
```
#1의 ssh key를 cluster ssh key에 복사
#해당 정보로 설치 시 cluster node ssh 접근 동작
cd /opt/ibm-cloud-private-3.1.1
sudo cp ~/.ssh/id_rsa ./cluster/ssh_key
```

6. edit config.yaml
```
   boot node: /opt/ibm-cloud-private-3.1.1/cluster/config.yaml
   #OpenStack 환경의 경우 /etc/hosts가 cloud-init 서비스에 의해 관리되는 경우에는 cloud-init 서비스가 /etc/hosts 파일을 수정하지 못하게 해야 합니다. /etc/cloud/cloud.cfg 파일에서 manage_etc_hosts 매개변수가 false로 설정되어 있는지 확인하십시오
```

7. edit hosts file
```
cluster node 정보 기입
#/opt/ibm-cloud-private-3.1.1/cluster/hosts

[master]
10.38.211.181

[worker]

[proxy]

[management]

[va]
#
#여기에 노드를 기술하지 않으면 node label이 등록되지 않음.
#management=true, master=true, proxy=true,
```

8. config.yaml 설정
```
network_type: calico
network_cidr: 10.1.0.0/16
service_cluster_ip_range: 10.0.0.0/16

cluster_name: icp311cluster
cluster_CA_domain: "{{ cluster_name }}.com"

etcd_extra_args: ["--grpc-keepalive-timeout=0", "--grpc-keepalive-interval=0", "--snapshot-count=10000"]
fips_enabled: false

default_admin_user: admin
default_admin_pawword: 

kubelet_extra_args: ["--fail-swap-on=false"]
auditlog_enabled: true

ansible_user:cldadmin
ansible_ssh_pass: cldadmin
ansible_become:true
ansible_become_pass: "{{ ansible_ssh_pass }}"
ansible_ssh_common_args: "-oPubkeyAuthentication=no"

management_services:
 istio: disabled
 vulnerability-advisor: enabled
 storage-glusterfs: disabled
 storage-minio: disabled

 kibana_install: true

#install을 위한 사용자를 ubuntu로 변경
#참고 자료 https://portal2portal.blogspot.com/2018/10/ibm-cloud-private-310-failed-to-connect.html
#https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/installing/config_yaml.html
ansible_user: ubuntu
ansible_become: true
```

# ICP Install
<hr/>

1. icp install을 위한 cluster 디렉토리로 이동
```
 $ cd /opt/ibm-cloud-private-3.1.1/cluster/
```

2. 설치 이미지를 다른 서버에세 사용할 수 있도록 아래 위치로 이동
```
$ sudo mkdir -p cluster/images;
$ sudo mv /<path_to_installation_file>/ibm-cloud-private-x86_64-3.1.1.tar.gz  cluster/images/
```

3. icp install
```
sudo docker run --net=host -t -e LICENSE=accept -v "$(pwd)":/installer/cluster ibmcom/icp-inception-amd64:3.1.1-ee install -vvv  (자세한 로그는 -vvvv)
#아래와 같은 화면이 나요면 install 성공
UI URL is https://<ip_address>:8443, default username/password is admin/admin
```

4. ICP Uninstall
```
$ cd /opt/ibm-cloud-private-3.1.1/cluster/
$ sudo docker run --net=host -t -e LICENSE=accept -v "$(pwd)":/installer/cluster ibmcom/icp-inception-amd64:3.1.1-ee uninstall
````

5. 필요시  모든 노드 docker service restart
```
 $ sudo systemctl restart docker 
 $ shutdown -r now
``` 
 
# 설치 이슈
<hr/>

1. tmp folder 권한 이슈
```
 $ sudo chmod 777 /tmp
```

2. kubectl 관련 이슈 발생 건
```
#master node의 /usr/local/bin/kubectl을 각 노드에 복사해서 다시 실행 
#opt/kubernetes/hyperkube를 /usr/local/bin/kubectl로 링크로 연결
 $ sudo su - 
 $ cd /usr/local/bin
 $ ln -s /opt/kubernetes/hyperkube kubectl

##다른 노드들도 그렇게 정의
#boot node에 hyperkube를 다운로드 해서 링크를 걸어줘야 함
```

3. docker image에서 yaml을 현재 위치의 디렉토리에 playbook아래 복사하는 방법
```
$ sudo docker run -v $(pwd):/data -e LICENSE=accept ibmcom/icp-inceptio-amd64:3.1.1-ee cp -r playbook /data
$ sudo docker run -v $(pwd):/data -e LICENSE=accept ibmcom/icp-inception-amd64:3.1.1-ee cp -r /installer /data

#DOCKER 이미지에서 전체 설정 정보 복사하기
```

4. /etc/hosts restart 방법
```
Offending key for IP in /home/ubuntu/.ssh/known_hosts:4

#Matching host key in /home/ubuntu/.ssh/known_hosts:12
sed -i '10d' ~/.ssh/known_hosts
ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R k8s-master-01
(MAC) ssh-keygen -R k8s-master-01 -f "~/.ssh/known_hosts"

$ sudo /etc/init.d/networking restart or sudo systemctl restart networking.service
```

5. Network port 확인
```
$ netstat -tnlp | awk '{print $4}'| egrep -w 8101|8500|3306|
```

6. 설치 장애 시 heath check
```
#만약 계속 장애가 나면 아래 명령어를 수행해서 문제를 확인한다.
sudo docker run --net=host -t -e LICENSE=accept -v "$(pwd)":/installer/cluster ibmcom/icp-inception-amd64:3.1.1-ee healthcheck
```

7. docker 이미지로 접속 방법
```
$cd /opt/ibm-cloud-private-3.1.1/cluster
$sudo docker run --net=host -it -e LICENSE=accept -v "$(pwd)":/installer/cluster ibmcom/icp-inception-amd64:3.1.1-ee sh
````

8. Docker로 직접 접속해서 내부에서 실행 하는 방법 
```
#Docker로 직접 접속해서  (sudo docker run --net=host -it -e LICENSE=accept -v "$(pwd)":/installer/cluster ibmcom/icp-inception-amd64:3.1.1-ee sh)
#installer.sh install 실행 후 계속 FAILED일 경우
  $ kubectl get pod -n kube-system으로 Pod 동작여부 확인
```

9. kubectl pod pending이면 describe로 내용 확인하여 빠젼 있는 부분 확인
```
#node selector가 빠져 있을 때 (management=true) —> kubectl label 10.100.1.12 management=true 설정
만약 PV 가 빠져 있을 때에는

----
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mgmt-repo-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: mgmt-repo-storage
  local:
    path: /var/lib/mgmt-repo
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 10.100.1.12 
```

10. cluster 접속
```
#docker 접속 후 sudo docker run --net=host -it -e LICENSE=accept -v "$(pwd)":/installer/cluster ibmcom/icp-inception-amd64:3.1.1-ee sh 실행
#다음 것 실행
kubectl config set-cluster mycluster --server=https://196.90.1.94:8001 --insecure-skip-tls-verify=true && kubectl config set-context mycluster --cluster=mycluster && kubectl config set-credentials admin --client-certificate=/home/ubuntu/cfc-certs/kubernetes/kubecfg.crt --client-key=/home/ubuntu/cfc-certs/kubernetes/kubecfg.key && kubectl config set-context mycluster --user=admin && kubectl config use-context mycluster
```

11. pod 생성 시 PodSecurity Policy 장애 (RunAsUser = MustRunAsNonRoot 문제)
```
Events:
  Type     Reason     Age               From                 Message
  ----     ------     ----              ----                 -------
  Normal   Scheduled  53s               default-scheduler    Successfully assigned ywyi/hue-reminders-bf94bdf54-2g49b to 10.100.1.6
  Normal   Pulling    52s               kubelet, 10.100.1.6  pulling image "g1g1/hue-reminders:v2.2"
  Normal   Pulled     44s               kubelet, 10.100.1.6  Successfully pulled image "g1g1/hue-reminders:v2.2"
  Warning  Failed     7s (x5 over 44s)  kubelet, 10.100.1.6  Error: container has runAsNonRoot and image will run as root
PSP의 RunAsUser의 MustRunAsNonRoot --> RunAsAny로 변경

$ kubectl get psp
NAME                        DATA      CAPS                                                                                                                    SELINUX    RUNASUSER   FSGROUP     SUPGROUP    READONLYROOTFS   VOLUMES
ibm-anyuid-hostaccess-psp   false     [SETPCAP AUDIT_WRITE CHOWN NET_RAW DAC_OVERRIDE FOWNER FSETID KILL SETUID SETGID NET_BIND_SERVICE SYS_CHROOT SETFCAP]   RunAsAny   RunAsAny    RunAsAny    RunAsAny    false            [*]
ibm-anyuid-hostpath-psp     false     [SETPCAP AUDIT_WRITE CHOWN NET_RAW DAC_OVERRIDE FOWNER FSETID KILL SETUID SETGID NET_BIND_SERVICE SYS_CHROOT SETFCAP]   RunAsAny   RunAsAny    RunAsAny    RunAsAny    false            [*]
ibm-anyuid-psp              false     [SETPCAP AUDIT_WRITE CHOWN NET_RAW DAC_OVERRIDE FOWNER FSETID KILL SETUID SETGID NET_BIND_SERVICE SYS_CHROOT SETFCAP]   RunAsAny   RunAsAny    RunAsAny    RunAsAny    false            [configMap emptyDir projected secret downwardAPI persistentVolumeClaim]
ibm-privileged-psp          true      [*]                                                                                                                     RunAsAny   RunAsAny    RunAsAny    RunAsAny    false            [*]
ibm-restricted-psp          false     []                                                                                                                      RunAsAny   MustRunAsNonRoot    MustRunAs   MustRunAs   false            [configMap emptyDir projected secret downwardAPI persistentVolumeClaim]
permit-root                 false     []                                                                                                                      RunAsAny   RunAsAny    RunAsAny    RunAsAny    false            [*]
값 변경

$ kubectl edit psp ibm-restricted-psp 
#MustRunAsNonRoot --> RunAsAny
```

12. audit log level 조정 
```
/etc/cfc/conf/audit-policy.yaml 에서 로그 조정
```

13. prometheus 본체 memory size 조정 - > 24 node는 8G

14. apiserver  restart
```
/etc/cfc/conf/audit-policy.yaml 수정 후 재 로딩을 위해 kubelet을 재시작해야 함
--> systemctl restart kubelet.service
apiserver를 재시작시키려면 systemctl restart kube-apiserver.service
```

15. API 기반 로그인 및 Token 요청 방법
```
$ curl -k -H "Content-Type:application/x-www-form-urlencoded:charset=UTF-8" -d "grant_type=password&username=admin&password=admin&scope=openid" https://10.38.201.191:8443/idprovider/auth/identitytoken --insecure
curl -k -H "Authorization:Bearer" $ID_TOKEN" https://10.38.201.191:8001/api/v1/namespaces/default/pods
````

15. k8s & ICPREST API 연계 가이드

```
https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/apis/access_api.html
```

16. apiserver, scheduler 등에 대한 재 기동
```
hybperkube apiserver 가 기동되고 있는지 확인하며 관련 yaml 설정 파일 위치를 확인한다.
그리고 그 값을 바꾸고 난 뒤에

k8s-master-*로 실행되고 있는 pod를 재 실행시키면 됨
```

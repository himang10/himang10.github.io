---
layout: post
title: kubernetes haproxy 설정
date: 2019-01-06
categories: kubernetes
author: himang10
tags: [kubernetes, haproxy]
---

고가용성 환경에서 마스터 또는 프록시 노드에 대해 외부 로드 밸런서를 구성하는 방법을 알아봅니다.
IBM® Cloud Private 고가용성 환경의 마스터 및 프록시 노드는 ucarp와 etcd를 모두 로드 밸런서로 사용합니다. 이 설정을 사용하면 가상 IP 주소(VIP)가 하나의 마스터 또는 하나의 프록시 노드에 바인드됩니다.
외부 로드 밸런서를 VIP의 대안 또는 대체로 사용할 수도 있습니다.
IBM Cloud Private 고가용성 환경에서 외부 로드 밸런서 모드를 사용으로 설정하려면 로드 밸런서 노드를 준비하고 HAProxy를 설치해야 합니다. 그런 다음 config.yaml 파일에서 cluster_lb_address 및 proxy_lb_address 매개변수를 설정하여 로드 밸런서를 구성하십시오.
클러스터 외부 로드 밸런서는 IBM Cloud Private 관리 서비스에 대해 로드 밸런싱을 수행하는 데 사용됩니다. 프록시 외부 로드 밸런서는 IBM Cloud Private 워크로드 서비스에 대해 로드 밸런싱을 수행하는 데 사용됩니다.
클러스터 외부 로드 밸런서를 설정하려면 8001, 8443, 8500 및 9443 포트가 로드 밸런서 노드에 추가되어 열려 있는지 확인하십시오.
프록시 외부 로드 밸런서를 설정하려면 80 및 443 포트가 로드 밸런서 노드에 추가되어 열려 있는지 확인하십시오.
로드 밸런서 노드를 설정하십시오. 이 로드 밸런서 노드는 마스터, 작업자 또는 프록시 노드 등의 다른 클러스터 노드와 공유되어서는 안 됩니다. 포트 충돌을 방지하기 위해 전용 노드가 필요합니다.
로드 밸런서 노드에 HAproxy를 설치하십시오.

Ubuntu의 경우:
```
      apt-get install haproxy
```

Red Hat Enterprise Linux(RHEL):
```
      yum install haproxy
```
HAproxy를 구성하십시오. 로드 밸런서 노드의 /etc/haproxy/haproxy.cfg 파일에서 HAproxy를 구성하십시오.
```
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
# Global settings     
global
      # To view messages in the /var/log/haproxy.log you need to:
      #
      # 1) Configure syslog to accept network log events.  This is done
      #    by adding the '-r' option to the SYSLOGD_OPTIONS in
      #    /etc/sysconfig/syslog.
      #
      # 2) Configure local2 events to go to the /var/log/haproxy.log
      #   file. A line similar to the following can be added to
      #   /etc/sysconfig/syslog.
      #
      #    local2.*                       /var/log/haproxy.log
      #
      log         127.0.0.1 local2

      chroot      /var/lib/haproxy
      pidfile     /var/run/haproxy.pid
      maxconn     4000
      user        haproxy
      group       haproxy
      daemon

      # 3) Turn on stats unix socket
      stats socket /var/lib/haproxy/stats            
# Common defaults that all the 'listen' and 'backend' sections
# use, if not designated in their block.     
defaults
      mode                    http
      log                     global
      option                  httplog
      option                  dontlognull
      option http-server-close
      option                  redispatch
      retries                 3
      timeout http-request    10s
      timeout queue           1m
      timeout connect         10s
      timeout client          1m
      timeout server          1m
      timeout http-keep-alive 10s
      timeout check           10s
      maxconn                 3000

  frontend k8s-api *:8001
      mode tcp
      option tcplog
      use_backend k8s-api

  backend k8s-api
      mode tcp
      balance roundrobin
      server server1 <master_node_1_IP_address>:8001
      server server2 <master_node_2_IP_address>:8001
      server server3 <master_node_3_IP_address>:8001

  frontend dashboard 
      bind *:8443
      mode tcp
      option tcplog
      use_backend dashboard

  backend dashboard
      mode tcp
      balance roundrobin
      server server1 <master_node_1_IP_address>:8443
      server server2 <master_node_2_IP_address>:8443
      server server3 <master_node_3_IP_address>:8443

  frontend auth 
      bind *:9443
      mode tcp
      option tcplog
      use_backend auth

  backend auth
      mode tcp
      balance roundrobin
      server server1 <master_node_1_IP_address>:9443
      server server2 <master_node_2_IP_address>:9443
      server server3 <master_node_3_IP_address>:9443

  frontend registry 
      bind *:8500
      mode tcp
      option tcplog
      use_backend registry

  backend registry
      mode tcp
      balance roundrobin
      server server1 <master_node_1_IP_address>:8500
      server server2 <master_node_2_IP_address>:8500
      server server3 <master_node_3_IP_address>:8500

  frontend proxy-http 
      bind *:80
      mode tcp
      option tcplog
      use_backend proxy-http

  backend proxy-http
      mode tcp
      balance roundrobin
      server server1 <proxy_node_1_IP_address>:80
      server server2 <proxy_node_2_IP_address>:80
      server server3 <proxy_node_3_IP_address>:80

  frontend proxy-https 
      bind *:443
      mode tcp
      option tcplog
      use_backend proxy-https

  backend proxy-https
      mode tcp
      balance roundrobin
      server server1 <proxy_node_1_IP_address>:443
      server server2 <proxy_node_2_IP_address>:443
      server server3 <proxy_node_3_IP_address>:443
```

클러스터 로드 밸런서를 설정하려면 <master_node_1_IP_address>, <master_node_2_IP_address> 및 <master_node_3_IP_address>를 사용자의 HA 마스터 노드에 대한 IP 주소로 대체하십시오.

프록시 로드 밸런서를 설정하려면 <proxy_node_1_IP_address>, <proxy_node_2_IP_address> 및 <proxy_node_3_IP_address>를 사용자의 HA 프록시 노드에 대한 IP 주소로 대체하십시오.
config.yaml 파일을 업데이트하십시오. cluster_lb_address 또는 proxy_lb_address 매개변수를 사용자의 외부 로드 밸런서 노드에 대한 IP 주소로 대체하십시오.

haproxy reoad & debugging
```
sudo systemctl reload haproxy.service
if fault
systemctl status haproxy.service or journalctl -xe
```

```
## External loadbalancer IP or domain
## Or floating IP in OpenStack environment
cluster_lb_address: none
```
```
## External loadbalancer IP or domain
## Or floating IP in OpenStack environment
proxy_lb_address: none
```

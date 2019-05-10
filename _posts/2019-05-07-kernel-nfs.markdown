---
layout: post
title: NFS Structure
date: 2019-05-10
categories: kernel
author: himang10
tags: [kernel, nfs]
---

### nfs git for kubernetes
[https://github.com/kubernetes/examples/tree/master/staging/volumes/nfs](https://github.com/kubernetes/examples/tree/master/staging/volumes/nfs)

[kubernetes persistence volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistent-volumes)

[NFS Server Provisioner](https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner)

### NFS
NFS를 사용하면 원격 디렉토리를 마운트하는 방식으로 한 시스템의 프로그램에서 다른 시스템의 파일에 쉽게 액세스할 수 있습니다.

일반적으로 서버가 부트되면 exportfs 명령을 통해 디렉토리가 사용 가능해지고 원격 액세스를 처리하는 디먼(nfsd 디먼)이 시작됩니다. 마찬가지로, 클라이언트 시스템 부트 중에는 원격 디렉토리가 마운트되고, 원격 액세스를 처리하기 위해 적당한 수의 NFS 블록 입출력 디먼(biod 디먼)이 초기화됩니다.

nfsd 및 biod 디먼은 모두 멀티스레드 디먼이므로, 프로세스 내에 복수의 커널 스레드가 있습니다. 또한 이 디먼은 NFS 활동량에 따라 필요 시 스레드를 작성하거나 삭제한다는 점에서 자체 조정 디먼입니다.

다음은 NFS 클라이언트와 서버 간의 대화 구조를 보여주는 그림입니다. 클라이언트 시스템 내의 스레드가 NFS 마운트 디렉토리의 파일을 읽거나 파일에 쓰려고 시도할 경우, 요청은 일반 입출력 메커니즘에서 클라이언트의 biod 스레드 중 하나로 방향 재지정됩니다. biod 스레드가 요청을 해당 서버로 전송하면 요청이 서버의 NFS 스레드(nfsd 스레드) 중 하나에 지정됩니다. 해당 요청이 처리되는 동안 관련된 biod 및 nfsd 스레드는 다른 작업을 전혀 수행하지 않습니다.

그림 1. NFS 클라이언트-서버 상호작용. 이 그림은 네트워크에 두 개의 클라이언트와 한 개의 서버가 일반적인 별 형태로 배치된 모습을 보여줍니다. 클라이언트 A는 애플리케이션 스레드 m을 실행하고 있으며, 이 스레드의 데이터는 biod 스레드 중 하나로 전달됩니다. 마찬가지로, 클라이언트 B는 애플리케이션 스레드 n을 실행하고 있으며, 데이터를 biod 스레드 중 하나로 전달합니다. 각 스레드는 네트워크를 통해 데이터를 서버 Z로 전송하면 해당 데이터는 서버의 NFS(nfsd) 스레드 중 하나에 지정됩니다.

<img src="/files/nfs.jpg" width="600"> 


NFS는 원격 프로시저 호출(RPC)을 사용하여 통신합니다. RPC는 데이터를 전송하고 다른 구조로 된 머신이 정보를 교환할 수 있도록 먼저 데이터를 일반 형식으로 변환하는 XDR(External Data Representation) 프로토콜을 기반으로 합니다. RPC 라이브러리는 로컬(클라이언트) 프로세스가 자체 주소 공간에서 프로시저 호출을 실행한 것처럼 원격(서버) 프로세스가 프로시저 호출을 실행하도록 지시하는 데 사용할 수 있는 프로시저 라이브러리입니다. 클라이언트와 서버는 별도의 두 프로세스이므로 동일한 물리적 시스템에 있을 필요는 없습니다.

그림 2. 마운트 및 NFS 프로세스. 이 그림은 세 개의 열로 구성된 테이블로, 열 표제는 각각 클라이언트 활동, 클라이언트, 서버입니다. 첫 번째 클라이언트 활동은 마운트입니다. RPC 호출은 클라이언트에서 서버의 portmapper mountd로 진행됩니다. 두 번째 클라이언트 활동은 열기/닫기, 읽기/쓰기입니다. 클라이언트의 biod 스레드와 서버의 nfsd 스레드 간에는 양방향 상호작용이 있습니다.


<img src="/files/nfs1.jpg" width="600">

portmap 디먼인 portmapper는 특정 프로그램과 연관된 포트 번호를 검색하는 표준 방법을 클라이언트에 제공하는 네트워크 서비스 디먼입니다. 서버의 서비스가 요청되면 해당 서비스는 portmap 디먼에 사용 가능한 서버로 등록됩니다. 그러면 portmap 디먼이 프로그램-포트 쌍으로 된 테이블을 유지합니다.

클라이언트가 서버에 대한 요청을 초기화할 경우 먼저 portmap 디먼에 접속하여 서비스가 상주하는 위치를 확인합니다. portmap 디먼이 잘 알려진 포트를 청취하므로 클라이언트가 포트를 검색할 필요가 없습니다. portmap 디먼은 클라이언트가 요청하는 서비스의 포트를 사용하여 클라이언트에 응답합니다. 포트 번호를 수신한 클라이언트는 애플리케이션에 대한 모든 추가 요청을 직접 생성할 수 있습니다.

mountd 디먼은 클라이언트 요청에 응답하여 서버의 반출된 파일 시스템이나 디렉토리를 마운트하는 서버 디먼입니다. mountd 디먼은 /etc/xtab 파일을 읽어 사용 가능한 파일 시스템을 판별합니다. 마운트 프로세스는 다음과 같이 진행됩니다.

클라이언트 마운트가 서버의 portmap 디먼을 호출하여 mountd 디먼에 지정된 포트 번호를 찾습니다.
portmap 디먼이 포트 번호를 클라이언트에 전달합니다.
클라이언트 mount 명령이 서버 mountd 디먼에 직접 접속하여 원하는 디렉토리의 이름을 전달합니다.
서버 mountd 디먼이 /etc/xtab(/etc/exports를 읽는 exportfs -a 명령으로 작성됨)을 검사하여 요청된 디렉토리의 가용성과 권한을 검증합니다.
모든 사항이 검증되면, 서버 mountd 디먼이 반출된 디렉토리에 대한 파일 핸들(파일 시스템 디렉토리에 대한 포인터)을 가져와서 이를 다시 클라이언트 커널에 전달합니다.
클라이언트는 시스템 재시작 후 첫 번째 마운트 요청의 portmap 디먼에만 접속합니다. 클라이언트가 mountd 디먼의 포트 번호가 알고 있으면 후속 마운트 요청에 대해 해당 포트 번호로 직접 이동합니다.

biod 디먼은 블록 입출력 디먼으로, 디렉토리 읽기뿐만 아니라 선행 읽기 및 후행 쓰기 요청을 수행하는 데 필요합니다. biod 디먼 스레드는 NFS 클라이언트 애플리케이션을 대신하여 버퍼를 채우거나 비우는 방식으로 NFS 성능을 향상시킵니다. 클라이언트 시스템의 사용자가 서버의 파일을 읽거나 이 파일에 쓰려고 할 경우, biod 스레드가 해당 요청을 서버로 전송합니다. 다음과 같은 NFS 조작은 운영 체제의 NFS 클라이언트 커널 확장에서 서버로 직접 전송되므로, biod 디먼을 사용할 필요가 없습니다.

getattr()
setattr()
lookup()
readlink()
create()
remove()
rename()
link()
symlink()
mkdir()
rmdir()
readdir()
readdirplus()
fsstat()
nfsd 디먼은 NFS 서버에서 NFS 서비스를 제공하는 활성 에이전트입니다. 클라이언트에서 NFS 프로토콜 요청을 수신하려면 요청이 충족되고 요청 처리 결과가 다시 클라이언트로 전송될 때까지 nfsd 디먼 스레드를 주의 깊게 살펴야 합니다.

### NFS 네트워크 전송
TCP는 NFS의 디폴트 전송 프로토콜이지만, UDP도 사용할 수 있습니다.

마운트 단위로 전송 프로토콜을 선택할 수 있습니다. UDP는 깨끗하거나 효율적인 네트워크 및 응답 서버에서 효과적으로 작동합니다. 광역 네트워크, 트래픽이 많은 네트워크 또는 속도가 느린 서버가 있는 네트워크에서는 TCP가 보다 향상된 성능을 제공할 수 있는데, TCP의 고유한 흐름 제어가 네트워크에서 재전송 대기 시간을 최소화할 수 있기 때문입니다.

### NFS의 다양한 버전

#### [NFS 버전 4](https://www.ibm.com/support/knowledgecenter/ko/ssw_aix_71/com.ibm.aix.performance/nfs_v4.htm)
NFS 버전 4는 NFS에 대한 최신 프로토콜 스펙이며 RFC 3530에 정의되어 있습니다.

#### [NFS 버전 3](https://www.ibm.com/support/knowledgecenter/ko/ssw_aix_71/com.ibm.aix.performance/nfs_v3.htm)
NFS 버전 3은 성능을 향상시킬 수 있는 고유한 프로토콜 기능 때문에 NFS 버전 2보다 적극 권장됩니다.

### [NFS 성능](https://www.ibm.com/support/knowledgecenter/ko/ssw_aix_71/com.ibm.aix.performance/nfs_perf.htm) 
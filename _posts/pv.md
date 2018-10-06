---
layout: post
title: Sample post
tags: [A Tag, Test, Lorem, Ipsum]
excerpt_separator:
---

컨테이너는 기본적으로 상태가 없는(stateless) 앱을 사용합니다. 상태가 없다는건 어떤 이유로건 컨테이너가 죽었을때 현재까지의 데이터가 사라진다는 것입니다. 상태가 없기 때문에 컨테이너에 문제가 있거나 노드에 장애가 발생해서 컨테이너를 새로 띄우거나 다른곳으로 옮기는게 자유롭습니다. 이것이 컨테이너의 장점입니다. 하지만 앱의 특성에 따라서 컨테이너가 죽더라도 데이터가 사라지면 안되고 보존되어야 하는 경우가 있습니다. 대표적으로 정보를 파일로 기록해두는 젠킨스가 있습니다. mysql같은 데이터베이스도 컨테이너가 내려가거나 재시작했다고해서 데이터가 사라지면 안됩니다. 그 때 사용할 수 있는게 볼륨입니다. 볼륨을 사용하게 되면 컨테이너가 재시작을 하더라도 데이터가 사라지지 않고 유지됩니다. 더 나아가서 퍼시스턴스 볼륨을 사용하게 된다면 컨테이너가 재시작할때 데이터를 쌓아뒀던 노드가 아니라 다른 노드에서 실행된다고 하더라도 자동으로 데이터가 있는 볼륨이 컨테이너가 새로 시작한 노드에 옮겨 붙어서 쌓아뒀던 데이터를 그대로 활용해서 사용할 수 있습니다. 이런 식의 구성하게 되면 단순히 하나의 서버에서만 데이터를 기록해두고 사용하는것 보다 더 안정적으로 서비스를 운영할 수 있게 됩니다.
현재 쿠버네티스에서 사용가능한 볼륨은 다음과 같습니다.
awsElasticBlockStore
azureDisk
azureFile
cephfs
configMap
csi
downwardAPI
emptyDir
fc (fibre channel)
flocker
gcePersistentDisk
gitRepo (deprecated)
glusterfs
hostPath
iscsi
local
nfs
persistentVolumeClaim
projected
portworxVolume
quobyte
rbd
scaleIO
secret
storageos
vsphereVolume


퍼시스턴트볼륨(PersistentVolume, PV)과 퍼시스턴트볼륨클레임(PersistentVolumeClaim)
쿠버네티스에서 볼륨을 사용하는 구조는 PV라고 불리는 퍼시스턴트볼륨(PersistentVolume)과 PVC라고하는 퍼시스턴트볼륨클레임(PersistentVolumeClaim) 2개로 분리되어 있습니다. PV는 볼륨 자체를 의미합니다. 클러스터내에서 리소스로 다뤄집니다. 포드하고는 별개로 관리되고 별도의 생명주기를 가지고 있습니다. PVC는 사용자가 PV에 하는 요청입니다. 사용하고 싶은 용량은 얼마인지 읽기/쓰기는 어떤 모드로 설정하고 싶은지등을 정해서 요청합니다. 쿠버네티스는 볼륨을 포드에 직접할당하는 방식이 아니라 이렇게 중간에 PVC를 둠으로써 포드와 포드가 사용할 스토리지를 분리했습니다. 이런 구조는 각자의 상황에 맞게 다양한 스토리지를 사용할 수 있게 해줍니다. 클라우드 서비스를 사용하는 경우에는 본인이 사용하는 클라우드 서비스에서 제공해주는 볼륨 서비스를 사용할 수도 있고, 사설로 직접 구축해서 사용중인 스토리지가 있다면 그걸 사용할 수도 있습니다. 이렇게 다양한 스토리지를 PV로 사용할 수 있지만 포드에 직접 연결하는게 아니라 PVC를 통해서 사용하기 때문에 포드는 자신이 어떤 스토리지를 사용하고 있는지 신경쓰지 않아도 됩니다.

PV, PVC 생명주기
PV와 PVC는 다음 그림에서 보이는 것 같은 생명주기를 가집니다.



생명주기 : 프로비저닝(Provisioning)
PV를 사용하기 위해서는 먼저 PV가 만들어져 있어야 합니다. 이 PV를 만드는 단계를 프로비저닝이라고 합니다. PV 프로비저닝 방법에는 2가지가 있습니다. PV를 미리 만들어두고 사용하는 정적(static) 방법과 요청이 있을때마다 PV를 만드는 동적(dynamic) 방법입니다.
정적으로 PV를 준비한다는건 클러스터 관리자가 미리 적정용량의 PV를 만들어 두고 사용자들의 요청이 있으면 미리 만들어둔 PV를 할당해 주는 방식입니다. 사용할 수 있는 스토리지 용량에 제한이 있을 때 유용하게 사용할 수 있는 방법입니다. 사용자들에게 미리 만들어둔 PV의 용량이 100기가라면 150기가를 사용하려는 요청들은 실패하게 됩니다. 1테라짜리 스토리지를 사용한다고 하더라도 미리 만들어둔 PV의 용량이 150기가이상 되는 것이 없다면 요청이 실패하게 됩니다.
동적으로 PV를 준비하는건 미리 PV를 준비해두는 것이 아니고 사용자가 PVC를 통해서 요청을 했을때 PV를 생성해서 제공해 주는 방식입니다. 쿠버네티스 클러스터를 위해 1테라짜리 스토리지를 준비해 뒀다고 하면 사용자가 필요할 때 원하는 용량만큼을 생성해서 사용할 수 있습니다. 정적 PV생성과 달리 한번에 200기가 짜리도 필요하면 만들어 쓸 수 있습니다. 동적 프로비저닝을 위해서 PVC는 스토리지클래스(StorageClasses)를 사용합니다. 스토리지클래스를 이용해서 원하는 스토리지에 PV를 생성합니다.

생명주기 : 바인딩(Binding)
바인딩은 프로비저닝을 통해 만들어진 PV를 PVC와 바인딩하는 단계입니다. PVC가 원하는 스토리지의 용량과 접근방법을 명시해서 요청하면 거기에 맞는 PV가 할당됩니다. 이 때 PVC에 맞는 PV가 없다면 요청은 실패합니다. 하지만 한 번 실패했다고 요청이 끝나는건 아니고 계속해서 대기하고 있게 됩니다. 그러다가 기존에 사용하던 PV가 반납되거나 새로운 PV가 생성되서 PVC에 맞는 PV가 생기면 PVC에 바인딩이 됩니다. PV와 PVC의 매핑은 1대1 관계입니다. 하나의 PVC가 여러개의 PV에 바인딩되는건 불가능 합니다.

생명주기 : 사용중(Using)
PVC는 포드에 설정되고 포드는 PVC를 볼륨으로 인식해서 사용하게 됩니다. 할당된 PVC는 포드가 유지되는 동안 계속해서 사용됩니다.   포드가 사용중인 PVC는 시스템에서 임의로 삭제할 수 없습니다. 이 기능을 사용중인 스토리지 객체 보호 (Storage Object in Use Protection) 라고 합니다. 사용중인 데이터 스토리지를 임의로 삭제하게 되면 치명적인 결과를 초래할 수 있기 때문에 이런 보호 기능이 있습니다. 포드가 사용중인 PVC를 삭제하려고 하면 상태가 Terminating으로 되지만 해당 PVC를 사용중인 포드가 남아 있는 도중에는 삭제되지 않고 남아 있게 됩니다. kubectl describe으로 pvc의 상태를 확인해 보면 다음처럼 pvc-protection이 적용되어 있는걸 확인할 수 있습니다.
Finalizers:    [kubernetes.io/pvc-protection]


생명주기 : 리클레이밍(Reclaiming)
사용이 끝난 PVC는 삭제가 되고 PVC가 사용중이던 PV를 초기화(reclaim)하는 과정을 거치게 됩니다. 이걸 리클레이밍이라고 합니다. 초기화 정책은 Retain, Delete, Recycle의 3가지가 있습니다.

Retain
Retain은 단어가 가지는 의미 그대로 PV를 그대로 보존해 둡니다. PVC가 삭제되면 사용중이던 PV는 해제상태만 되고 아직 다른 PVC에 의해 재사용 가능한 상태는 아니게 됩니다. 단순히 사용해제만 됐기 때문에 PV안의 데이터는 그대로 유지가 된채로 남아 있는 상태입니다. 이 PV를 재사용하려면 관리자가 다음 순서대로 직접 초기화를 해주어야 합니다.
PV 삭제. PV가 만약 외부 스토리지와 연계되어 있었다면 PV는 삭제되더라도 외부 스토리지의 볼륨은 그대로 남아 있는 상태가 됩니다.
스토리지에 남아 있는 데이터를 직접 정리.
남아 있는 스토리지의 볼륨을 삭제하거나 재사용하려면 그 볼륨을 이용하는 PV를 다시 만들어 줍니다.

Delete
PV를 삭제하고 연계되어 있는 외부 스토리지 쪽의 볼륨도 삭제합니다. 프로비저닝할 때 동적볼륨할당으로 생성된 PV들은 기본 리클레임 정책이 Delete입니다. 필요하면 처음에 Delete로 설정된 PV의 리클레임 정책을 수정해서 사용해야 합니다.

Recycle
recycle은 PV의 데이터들을 삭제하고 PV를 다시 새로운 PVC에서 사용가능하게 만들어 둡니다. 쿠버네티스에서 지원이 어렵다고해서 지금은 deprecated된 정책입니다. 데이터 초기화용으로 특별한 포드를 만들어두고 초기화할때 사용하는 기능도 있긴 하지만 PV의 데이터들을 초기화하는데 여러가지 상황들을 쿠버네티스에서 모두 지원하기는 어렵다고 판단해서 더 이상 지원하지 않게 되었습니다. 현재는 동적 볼륨 할당을 기본 사용하라고 추천하고 있습니다.

퍼시스턴트볼륨(PersistentVolume) 템플릿
퍼시스턴트 볼륨 템플릿은 다음과 같은 구조입니다.
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-hostpath
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  persistentVolumeReclaimPolicy: Delete
  hostPath:
    path: /tmp/k8s-pv

apiVersion, kind, metadata부분은 다른 것들과 비슷한 구조입니다. spec부분을 주로 살펴 보도록 하겠습니다. 먼저 spec의 capacity부분을 보면 storage용량으로 1기가를 설정한걸 알 수 있습니다. 현재는 용량 관련한 설정만 가능하지만 앞으로는 IOPS나 throughput등도 설정할 수 있도록 추가될 예정입니다. volumeMode는 쿠버네티스 1.9버전에 알파 기능으로 추가된 옵션입니다. 기본값은 filesystem으로 볼륨을 파일시스템형식으로 붙여서 사용하게 합니다. 추가로 설정가능한 옵션은 raw입니다. 볼륨을 로우블록디바이스형식으로 붙여서 사용할 수 있게 해줍니다. 로우블록디바이스를 지원하는 플러그인들은 AWSElasticBlockStore, AzureDisk, FC (Fibre Channel), GCEPersistentDisk, iSCSI, Local volume, RBD (Ceph Block Device) 등이 있습니다.
accessModes는 볼륨의 읽기/쓰기에 관한 옵션을 지정합니다. 볼륨은 한번에 하나의 accessModes만 설정할 수 있고, 다음 3가지중 하나를 지정할 수 있습니다.
ReadWriteOnce : 하나의 노드가 볼륨을 읽기/쓰기 가능하게 마운트할 수 있음.
ReadOnlyMany : 여러개의 노드가 읽기 전용으로 마운트할 수 있음.
ReadWriteMany : 여러개의 노드가 읽기/쓰기 가능할게 마운트할 수 있음.
볼륨 플러그인 별로 지원가능한 옵션은 다음과 같습니다.
Volume Plugin
ReadWriteOnce
ReadOnlyMany
ReadWriteMany
AWSElasticBlockStore
✓
-
-
AzureFile
✓
✓
✓
AzureDisk
✓
-
-
CephFS
✓
✓
✓
Cinder
✓
-
-
FC
✓
✓
-
FlexVolume
✓
✓
-
Flocker
✓
-
-
GCEPersistentDisk
✓
✓
-
Glusterfs
✓
✓
✓
HostPath
✓
-
-
iSCSI
✓
✓
-
Quobyte
✓
✓
✓
NFS
✓
✓
✓
RBD
✓
✓
-
VsphereVolume
✓
-
- (works when pods are collocated)
PortworxVolume
✓
-
✓
ScaleIO
✓
✓
-
StorageOS
✓
-
-

storageClassName은 스토리지클래스(StorageClass)를 지정하는 옵션입니다. 특정 스토리지클래스를 가진 PV는 그 스토리지클래스에 맞는 PVC하고만 연결됩니다. PV에 storageClassName이 없으면 storageClassName이 없는 PVC에만 연결됩니다.
persistentVolumeReclaimPolicy 에는 PV가 해제되었을때의 초기화옵션을 넣을 수 있습니다. 앞에서 살펴봤던데로 Retain, Recycle, Delete중 하나가 올 수 있습니다.
이 예제에는 없지만 mountOptions이라는 옵션도 있습니다. 볼륨을 마운트할때 추가적인 옵션을 설정할 수 있는 스토리지들에서 사용할 수 있습니다. 마운트 옵션을 사용할 수 있는 스토리지에는 GCEPersistentDisk, AWSElasticBlockStore, AzureFile, AzureDisk, NFS, iSCSI, RBD (Ceph Block Device), CephFS, Cinder (OpenStack block storage), Glusterfs, VsphereVolume, Quobyte Volumes등이 있습니다. 마운트 옵션이 잘못되어 있으면 마운트가 실패합니다.
마지막으로 hostPath는 이 PV가 hostPath타입이라는걸 명시합니다. 그 하위에 마운트 시킬 호스트의 경로를 path를 이용해서 지정해 줍니다.
위 설정 내용을 pv-hostpath.yaml 파일로 저장하고 적용합니다. pv의 상태를 확인해보면 다음처럼 Available 상태로 나오는걸 확인할 수 있습니다.
$ kubectl apply -f pv-hostpath.yaml
persistentvolume "pv-hostpath" created
$ kubectl get pv
NAME          CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
pv-hostpath   2Gi        RWO            Delete           Available             manual                   7s

pv의 상태는 Available을 포함해서 다음 4가지가 있습니다.
Available : PVC에서 사용할 수 있게 준비된 상태
Bound : 특정 PVC에 연결된 상태
Released : PVC는 삭제된 상태이고 PV는 아직 초기화되지 않은 상태
Failed : 자동 초기화가 실패한 상태

퍼시스턴트볼륨클레임(PersistentVolumeClaims) 템플릿
PVC의 간단한 예제는 다음 템플릿 내용으로 확인할 수 있습니다.
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-hostpath
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi
  storageClassName: manual

이 내용을 pvc-hostpath.yaml로 저장하고 적용합니다. 그럼 다음처럼 앞에서 만들었던 PV와 연결된걸 확인할 수 있습니다. PV정보를 조회해보면 이제 PVC에 연결되어서 상태가 Bound로 나오는걸 확인할 수 있습니다.
$ kubectl apply -f pvc-hostpath.yaml
persistentvolumeclaim "pvc-hostpath" created
$ kubectl get pvc
NAME           STATUS    VOLUME        CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-hostpath   Bound     pv-hostpath   2Gi        RWO            manual         3s
$ kubectl get pv
NAME          CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                  STORAGECLASS   REASON    AGE
pv-hostpath   2Gi        RWO            Delete           Bound     default/pvc-hostpath   manual                   11m

여기 사용된 PVC의 설정 내용을 살펴보겠습니다. spec 하위 내용을 보겠습니다. accessModes에는 PV와 마찬가지로 어떤 읽기/쓰기 모드로 연결할지를 지정합니다. ReadWriteOnce, ReadOnlyMany, ReadWriteMany 등이 올 수 있습니다. volumeMode도 PV와 동일한 옵션입니다. 파일시스템인지 블록 디바이스인지를 filesystem, raw등을 통해 설정할 수 있습니다. resources는 얼만큼의 자원을 사용할 것인지에 대한 요청(request)을 입력합니다. 여기서는 1기가를 요청했습니다. 앞에서 만들어둔 PV의 용량이 2기가 였기 때문에 현재 PVC에서 사용할 수 있습니다. 만약에 PVC가 requests의 storage에 2기가 이상의 용량을 입력했다면 거기에 맞는 PV가 없어서 PVC는 Pending상태로 남게 되고 생성이 안됩니다.
storageClassName에는 사용할 스토리지클래스를 명시해 줍니다.

레이블을 이용해서 pvc, pv 연결하기
pv는 쿠버네티스 내부에서 사용되는 자원이고 pvc는 그 자원에 대한 요청을 하는 것이기 때문에 포드와 서비스를 연결할 때 처럼 레이블을 사용할 수 있습니다. 앞에서 사용했던 pv와 pvc에 다음처럼 label관련 설정을 추가하면 됩니다.

pv-hostpath-label.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-hostpath-label
  labels:
    location: local
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  persistentVolumeReclaimPolicy: Delete
  hostPath:
    path: /tmp/k8s-pv

pvc-hostpath-label.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-hostpath-label
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi
  storageClassName: manual
  selector:
    matchLabels:
      location: local

pv에는 metadata부분에 레이블을 추가했고, pvc에는 spec하위에 selector를 둬서 거기서 matchLabels를 통해서 앞의 pv에서 사용했던 레이블인 location: local을 지정했습니다. pvc에서는 matchLabels뿐만 아니라 다음처럼 matchExpressions를 통해서 원하는 레이블 조건을 명시할 수도 있습니다.
spec:
  selector:
    matchExpressions:
      - {key: stage, operator: In, values: [development]}

포드에서 PVC를 볼륨으로 사용하기
마지막으로 이렇게 만들어진 PVC를 실제 포드에 붙여 보도록 하겠습니다.
다음내용으로 deployment-pvc.yaml 파일을 만들어서 적용합니다.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubernetes-simple-app
  labels:
    app: kubernetes-simple-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kubernetes-simple-app
  template:
    metadata:
      labels:
        app: kubernetes-simple-app
    spec:
      containers:
      - name: kubernetes-simple-app
        image: arisu1000/simple-container-app:latest
        ports:
        - containerPort: 8080
        imagePullPolicy: Always
        volumeMounts:
        - mountPath: "/tmp"
          name: myvolume
      volumes:
      - name: myvolume
        persistentVolumeClaim:
          claimName: pvc-hostpath

이 파일의 내용을 살펴보면 spec.template.spec 부분에 볼륨관련한 설정이 들어가 있는걸 확인할 수 있습니다. 먼저 밑 부분에 보면 volumes라고해서 사용할 볼륨을 myvolume이라는 이름으로 선언했습니다. 이 때 이 myvolume을 persistentVolumeClaim으로 선언했고, 사용할 pvc의 이름은 앞에서 만들었던 pvc-hostpath로 지정해 줬습니다. 이렇게 함으로써 이제 이 디플로이먼트의 포드에서 사용할 myvolume라는 볼륨이 준비가 됐습니다. 이렇게 준비된 볼륨을 실제 컨테이너에 연결하는건 spec.template.spec.containers 하위의 컨테이너 설정에 있는 volumeMounts 설정입니다. 여기보면 마운트 경로를 지정하기 위해 mountPath라는 옵션으로 컨테이너의 “/tmp” 디렉토리에 앞서 생성했던 myvolume 을 마운트하도록 설정한 걸 확인할 수 있습니다. simple-container-app은 /tmp 디렉토리에 app.log라는 이름으로 접속로그를 남기도록 되어 있습니다.
포드 이름을 확인한 다음에 아래 명령으로 포드에 접근 가능한 포트를 설정한 다음에 브라우저에서 localhost:8080으로 몇 번 접속해 봅니다.
kubectl port-forward pods/kubernetes-simple-app-6d7d997c7c-lnwkz 8080:8080
앞에서 우리는 PV를 /tmp/k8s-pv라는 경로에 만들어 지도록 설정했었습니다. 지금까지의 설정에 따르면 로컬머신 내부경로의 /tmp/k8s-pv가 컨테이너의 /tmp 경로에 마운트되어 있을 겁니다. 그래서 kubernetes-simple-app 디플로이먼트의 접속로그인 app.log가 컨테이너의 /tmp/app.log에 남게되고 그 로그의 내용을 다음처럼 로컬머신의 내부경로인 /tmp/k8s-pv/app.log에서 확인할 수 있게 됩니다.
$ cat /tmp/k8s-pv/app.log
[GIN] 2018/08/19 - 07:32:17 | 200 |       777.2µs |       127.0.0.1 | GET      /
[GIN] 2018/08/19 - 07:32:19 | 200 |       241.2µs |       127.0.0.1 | GET      /
[GIN] 2018/08/19 - 07:32:19 | 200 |       138.9µs |       127.0.0.1 | GET      /

PVC 크기 늘리기
한번 할당한 PVC의 크기를 늘리는 것도 가능합니다. gcePersistentDisk, awsElasticBlockStore, Cinder, glusterfs, rbd, Azure File, Azure Disk, Portworx 등의 볼륨 타입을 사용하면 가능합니다. 이 기능을 사용하려면 스토리지클래스에 allowVolumeExpansion 옵션이 true로 설정되어 있어야 합니다. 적용 자체는 기존에 있는 PVC에 있는 스토리지 사이즈를 늘리고 적용하면 됩니다. 볼륨에서 사용중인 파일시스템이  XFS, Ext3, Ext4인 경우에는 파일시스템이 있더라도 볼륨의 크기를 늘리는 것이 가능합니다. 파일시스템이 있는 볼륨의 크기를 늘리는 작업은 그 PVC를 사용하는 새로운 포드가 실행됐을때만 진행됩니다. 그래서 기존에 특정 포드가 사용중인 볼륨의 크기를 늘리려면 포드를 재시작해주어야 합니다. 사용중인 포드를 재시작하는건 아무래도 서비스 운영에 불편한 점이 있습니다. 그래서 쿠버네티스 버전 1.11에서는 사용중인 볼륨의 사이즈를 조절하는 기능이 알파 버전으로 도입되었습니다.


노드별 볼륨 개수 제한
쿠버네티스에서는 하나의 노드에 붙일 수 있는 볼륨 개수에 제한을 두고 있습니다. 스케쥴러에 KUBE_MAX_PD_VOLS 환경변수를 이용해서 설정해 줄 수 있습니다. 클라우드 서비스를 이용하는 경우에는 각 클라우드별로 다음과 같은 제한사항을 가지고 있습니다.
클라우드 서비스
노드당 최대 볼륨개수
Amazon Elastic Block Store (EBS)
39
Google Persistent Disk
16
Microsoft Azure Disk Storage
16





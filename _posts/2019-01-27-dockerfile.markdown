---
layout: post
title: Docker file 작성 방법
date: 2019-01-06
categories: Docker
tags: [A kubernetes, dockerfile]
author: himang10
description: Configmap 사용을 위한 설명
---
Docker File 
============

# Table of Contents
1. [xxx](#xxx)
2. [xxx](#xxx)
3. [xxx](#xxx)

### docker image creation

```yaml
# based image configuration
FROM centos:centos7
```
* docker build command exectuion
```
$ docker build -t sample:1.0 /Users/himang10/ywyi/docker/docker04
Sending build context to Docker daemon  2.048kB
Step 1/1 : FROM centos:centos7
centos7: Pulling from library/centos
a02a4930cb5d: Pull complete
Digest: sha256:184e5f35598e333bfa7de10d8fb1cebb5ee4df5bc0f970bf2b1e7c7345136426
Status: Downloaded newer image for centos:centos7
 ---> 1e1148e4cc2c
Successfully built 1e1148e4cc2c
Successfully tagged sample:1.0
```
* docker image 확인
```
$ docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
luksa/fortune                        args                76ea20483711        3 weeks ago         114MB
ubuntu                               latest              1d9c17228a9e        4 weeks ago         86.7MB
centos                               centos7             1e1148e4cc2c        7 weeks ago         202MB
sample                               1.0                 1e1148e4cc2c        7 weeks ago         202MB
```
* new docker image 생성
```
$ docker build -t sample:2.0 /Users/himang10/ywyi/docker/docker04
Sending build context to Docker daemon  2.048kB
Step 1/1 : FROM centos:centos7
 ---> 1e1148e4cc2c
Successfully built 1e1148e4cc2c
Successfully tagged sample:2.0
```

* docker images 확인
```
$ docker images
REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
luksa/fortune                    args                76ea20483711        3 weeks ago         114MB
ubuntu                           latest              1d9c17228a9e        4 weeks ago         86.7MB
centos                           centos7             1e1148e4cc2c        7 weeks ago         202MB
sample                           1.0                 1e1148e4cc2c        7 weeks ago         202MB
sample                           2.0                 1e1148e4cc2c        7 weeks ago         202MB
```
* docker file name을 지정하여 docker build 실행
```
$ docker build -t sample -f Dockerfile.base .
Sending build context to Docker daemon  3.072kB
Step 1/1 : FROM centos:centos7
 ---> 1e1148e4cc2c
Successfully built 1e1148e4cc2c
Successfully tagged sample:latest

$ docker images
REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
luksa/fortune                    args                76ea20483711        3 weeks ago         114MB
ubuntu                           latest              1d9c17228a9e        4 weeks ago         86.7MB
sample                           1.0                 1e1148e4cc2c        7 weeks ago         202MB
sample                           2.0                 1e1148e4cc2c        7 weeks ago         202MB
sample                           latest              1e1148e4cc2c        7 weeks ago         202MB
```

### Docker Image Layer Structure
* Docker File
```dockerfile
# based image confiugration
FROM centos:latest

# STEP 01: Apache install
RUN yum install -y httpd

# STEP 02: copy file
COPY index.html /var/www/html/

#STEP 03: Apache run
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
```
* docker build 
```
$ docker build -t sample .
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM centos:latest
latest: Pulling from library/centos
Digest: sha256:184e5f35598e333bfa7de10d8fb1cebb5ee4df5bc0f970bf2b1e7c7345136426
Status: Downloaded newer image for centos:latest
 ---> 1e1148e4cc2c
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 ---> Running in 41d375fe007a
Loaded plugins: fastestmirror, ovl
Determining fastest mirrors
 * base: mirror.kakao.com
 * extras: mirror.kakao.com
 * updates: mirror.kakao.com
Resolving Dependencies
--> Running transaction check
---> Package httpd.x86_64 0:2.4.6-88.el7.centos will be installed
--> Processing Dependency: httpd-tools = 2.4.6-88.el7.centos for package: httpd-2.4.6-88.el7.centos.x86_64
--> Processing Dependency: system-logos >= 7.92.1-1 for package: httpd-2.4.6-88.el7.centos.x86_64
--> Processing Dependency: /etc/mime.types for package: httpd-2.4.6-88.el7.centos.x86_64
--> Processing Dependency: libaprutil-1.so.0()(64bit) for package: httpd-2.4.6-88.el7.centos.x86_64
--> Processing Dependency: libapr-1.so.0()(64bit) for package: httpd-2.4.6-88.el7.centos.x86_64
--> Running transaction check
---> Package apr.x86_64 0:1.4.8-3.el7_4.1 will be installed
---> Package apr-util.x86_64 0:1.5.2-6.el7 will be installed
---> Package centos-logos.noarch 0:70.0.6-3.el7.centos will be installed
---> Package httpd-tools.x86_64 0:2.4.6-88.el7.centos will be installed
---> Package mailcap.noarch 0:2.1.41-2.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================
 Package             Arch          Version                    Repository   Size
================================================================================
Installing:
 httpd               x86_64        2.4.6-88.el7.centos        base        2.7 M
Installing for dependencies:
 apr                 x86_64        1.4.8-3.el7_4.1            base        103 k
 apr-util            x86_64        1.5.2-6.el7                base         92 k
 centos-logos        noarch        70.0.6-3.el7.centos        base         21 M
 httpd-tools         x86_64        2.4.6-88.el7.centos        base         90 k
 mailcap             noarch        2.1.41-2.el7               base         31 k

Transaction Summary
================================================================================
Install  1 Package (+5 Dependent packages)

Total download size: 24 M
Installed size: 31 M
Downloading packages:
warning: /var/cache/yum/x86_64/7/base/packages/apr-1.4.8-3.el7_4.1.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for apr-1.4.8-3.el7_4.1.x86_64.rpm is not installed
--------------------------------------------------------------------------------
Total                                               28 MB/s |  24 MB  00:00
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-6.1810.2.el7.centos.x86_64 (@CentOS)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : apr-1.4.8-3.el7_4.1.x86_64                                   1/6
  Installing : apr-util-1.5.2-6.el7.x86_64                                  2/6
  Installing : httpd-tools-2.4.6-88.el7.centos.x86_64                       3/6
  Installing : centos-logos-70.0.6-3.el7.centos.noarch                      4/6
  Installing : mailcap-2.1.41-2.el7.noarch                                  5/6
  Installing : httpd-2.4.6-88.el7.centos.x86_64                             6/6
  Verifying  : mailcap-2.1.41-2.el7.noarch                                  1/6
  Verifying  : apr-util-1.5.2-6.el7.x86_64                                  2/6
  Verifying  : httpd-tools-2.4.6-88.el7.centos.x86_64                       3/6
  Verifying  : httpd-2.4.6-88.el7.centos.x86_64                             4/6
  Verifying  : apr-1.4.8-3.el7_4.1.x86_64                                   5/6
  Verifying  : centos-logos-70.0.6-3.el7.centos.noarch                      6/6

Installed:
  httpd.x86_64 0:2.4.6-88.el7.centos

Dependency Installed:
  apr.x86_64 0:1.4.8-3.el7_4.1
  apr-util.x86_64 0:1.5.2-6.el7
  centos-logos.noarch 0:70.0.6-3.el7.centos
  httpd-tools.x86_64 0:2.4.6-88.el7.centos
  mailcap.noarch 0:2.1.41-2.el7

Complete!
Removing intermediate container 41d375fe007a
 ---> 07b06e9fcb5f
Step 3/4 : COPY index.html /var/www/html/
COPY failed: stat /var/lib/docker/tmp/docker-builder847196187/index.html: no such file or directory
```
### Command RUN in Dockerfile
* Shell 형식으로 RUN 실행
```
#httpd 설치
RUN yum -y install httpd
```
/bin/sh -c 로 cmmand 실행하는 것과 동일

* EXEC 형식으로 실행
이것은 shell을 거치지 않고 바로 실행 시킨다. 그러므로 cmmand 값에 $HOME등 환경 변수 사용 불가
```
#httpd 설치
RUN ["/bin/bash", "-c", "yum -y install httpd"]
```

* Dockerfile로 Run 명령어 실행
RUN은 애플리케이션과 미들웨어 `설치`, `설정`, `command를 통한 환경 구축`을 하고자 하는 경우 RUN을 사용
반면, CMD는 `실행을 하고자 할경우에 사용

```
# based image confiugration
FROM centos:latest

# STEP 01: Apache install
MAINTAINER 0.1 himang10@gmail.com

#RUN TEST
RUN echo hi sehll format
RUN ["echo", "hi EXEC Format"]
RUN ["/bin/bash", "-c", "echo 'hi exec-bach'"]
```
빌드 실행
```
$ docker build -t sample1 .
Sending build context to Docker daemon  9.728kB
Step 1/5 : FROM centos:latest
 ---> 1e1148e4cc2c
Step 2/5 : MAINTAINER 0.1 himang10@gmail.com
 ---> Running in 7bc44205bce8
Removing intermediate container 7bc44205bce8
 ---> 01a970dcf5e1
Step 3/5 : RUN echo hi sehll format
 ---> Running in d42054a8b171
hi sehll format
Removing intermediate container d42054a8b171
 ---> 3ab7522e6dc1
Step 4/5 : RUN ["echo", "hi EXEC Format"]
 ---> Running in 3fdd5d0c706d
hi EXEC Format
Removing intermediate container 3fdd5d0c706d
 ---> 2cdce90634e0
Step 5/5 : RUN ["/bin/bash", "-c", "echo 'hi exec-bach'"]
 ---> Running in a31f1fa17993
hi exec-bach
Removing intermediate container a31f1fa17993
 ---> 9346c7b25f6c
Successfully built 9346c7b25f6c
Successfully tagged sample1:latest

$ docker history sample1
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
9346c7b25f6c        53 seconds ago      /bin/bash -c echo 'hi exec-bach'                0B
2cdce90634e0        54 seconds ago      echo hi EXEC Format                             0B
3ab7522e6dc1        56 seconds ago      /bin/sh -c echo hi sehll format                 0B
01a970dcf5e1        57 seconds ago      /bin/sh -c #(nop)  MAINTAINER 0.1 himang10@g…   0B
1e1148e4cc2c        7 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
<missing>           7 weeks ago         /bin/sh -c #(nop)  LABEL org.label-schema.sc…   0B
<missing>           7 weeks ago         /bin/sh -c #(nop) ADD file:6f877549795f4798a…   202MB
```
> /bin/sh로 실행이 필요한 경우 shell로 실행하고
> shell을 실행하지 않거나 또는 명시적으로 다른 shell을 실행하고자 할 경우에는
> EXEC를 사용하면 됨

### Daemon 실행 (CMD)
```
# http 실행
CMD /usr/sbin/httpd -D FOREGROUND
CMD ["/usr/sbin/httpd". "-D", "FOREGROUND"]
```
* dockerfile build
```
# based image confiugration
FROM centos:latest

# STEP 01: Apache install
RUN yum install -y httpd

# STEP 02: copy file
COPY index.html /var/www/html/

#STEP 03: Apache run
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
```
* docker file build
```
$ docker build -t sample3 -f Dockerfile.origin .
Sending build context to Docker daemon  9.728kB
Step 1/4 : FROM centos:latest
 ---> 1e1148e4cc2c
Step 2/4 : RUN yum install -y httpd
 ---> Using cache
 ---> 07b06e9fcb5f
Step 3/4 : COPY index.html /var/www/html/
 ---> Using cache
 ---> 281344ec39f9
Step 4/4 : CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
 ---> Using cache
 ---> 7f6d384d78ca
Successfully built 7f6d384d78ca
Successfully tagged sample3:latest
```

### docker 실행
```
# -d: detach -p localhost: container port
$ docker run -d -p 80:80 sample3
958ed2960fe9a27e375c8b64c26c5173d84b26ef5afb467d078dc42eb0408795

$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
958ed2960fe9        sample3             "/usr/sbin/httpd -D …"   2 minutes ago       Up 2 minutes        0.0.0.0:80->80/tcp   mystifying_lewin

$ docker kill 958ed2960fe9
958ed2960fe9
```

* forground로 실행
```
docker run -it -p 80:80 sample3
```

### Deamon 실행 (ENTRYPINT)
CMD는 docker run이 실행될때 입력으로 실행 명령이 들어오면 CMD 보다 우선하여 실행됨
Dockerfile에 있는 CMD가 우선으로 실행하게 하려면 ENTRYPOINT를 적용
> CMD와 ENTRYPOINT는 한번만 사용할 수 있으며 여러개를 사용할 경우에는 .sh를 만들어서 호출하면 됨
> ENTRYPINT는 여러개 사용할 수 있지만, 가장 마지막의 명령어가 실행된다. 
> CMD와 ENTRYPOINT를 조합할 수 있다. 

```
$ cat Dockerfile.nginx
# based image confiugration
FROM centos:latest

# STEP 01: Apache install
RUN yum install -y httpd
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum install -y nginx

# STEP 02: copy file
COPY index.html /var/www/html/

#STEP 03: Apache run
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
```

```
$ docker run -d -p 81:80 sample/nginx /usr/sbin/nginx -g "daemon off;"
f47d4151383dbe723b2386e6ce9e8536744afc7f4609a70201a1687b26fafd1a
```

* COMMAND는 고정시키고 파라메터를 가변적으로 설정하고자 할때는 CMD와 ENTRYPOINT를 조합해서 사용
```
ENTRYPOINT ["top"]
CMD ["-d", "10"]

docker run -it sample # top을 10초간격으로 업데이트
docker run -it sample -d 2 # 2초 간격으로 업데이트


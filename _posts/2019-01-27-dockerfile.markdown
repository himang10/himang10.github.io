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
이미지를 생성하기 위해 실행되는 커맨드는 RUN을 사용하고
컨테이너에서 실행되는 커맨드는 CMD 명령어 사용
그리고 한개의 CMD만을 사용할 수 있으며, 만약 여러개인 경우 마지막 커맨드만 적용
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
````

### ONBUIKD
build 완료 후에 실행되는 명령
공통의 도커 이미지를 생성하고 기본으로 시행해야 할 명령어를 ONBUILD로 설정해 놓으면
이 생성된 이미지를 베이스로 해서 각자 도커 이미지를 생성하면 ONBUILD가 기본으로 삽입되어 실행될 수 있음
```
# based image confiugration
FROM centos:latest

# 생성자 정보
MAINTAINER 0.1 himang10@gmail.com

# STEP 01: Apache install
RUN yum install -y httpd

# STEP 02: copy file
ONBUILD ADD index.html /var/www/html/

#STEP 03: Apache run
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
```

```
$ docker build -t ywyi/web-images -f Dockerfile.onbuild .
Sending build context to Docker daemon  11.78kB
Step 1/5 : FROM centos:latest
 ---> 1e1148e4cc2c
Step 2/5 : MAINTAINER 0.1 himang10@gmail.com
 ---> Using cache
 ---> 01a970dcf5e1
Step 3/5 : RUN yum install -y httpd
```

```
# based image confiugration
FROM ywyi/onbuild
```
```
$ docker build -t ywyi/web-images -f Dockerfile.web-image .
Sending build context to Docker daemon   12.8kB
Step 1/1 : FROM ywyi/onbuild
# Executing 1 build trigger
 ---> Using cache
 ---> 4fdd23092ed4
Successfully built 4fdd23092ed4
Successfully tagged ywyi/web-images:latest
```

* onbuild image 상세 확인
```
$ docker inspect --format="{{ .Config.OnBuild }}" ywyi/onbuild
[ADD index.html /var/www/html/]
```

### 환경 변수 (ENV)
* Key Value 형식
```
ENV myName "EUNWHA SHIN"
ENV myOrder Gin Whisky Calvados
ENV myNickName miya
```

* Key=Value 형식
값에 공백이 포함될 때에는 ""나 \를 사용
```
ENV myName="EUNWHA SHIN" \
ENV myOrder=Gin\ Whisk\ Calvados \
ENV myNickName=miya
```
> 변수 앞에 \을 붙이면 escape 할 수 있음.
> \$myName
> docker run command의 env 옵션을 사용해 변경 용이한 구조

### 작업디렉토리 설정 (WORKDIR)
WORKDIR을 Dockerfile에 저장된 다음 명령을 실행하기 위한 작업 디렉토리를 설정함
* RUN
* CMD
* ENTRYPOINT
* COPY
* ADD

Dockerfile에 다음과 같이 설정 시 /first/second/third 가 출력된다
```
WORKDIR /first
WORKDIR second
WORKDIR third
RUN ["pwd"]
```

다음과 같이 실행하면 마지막행이 실행된 두 /first/seoncd가 출력
```
ENV DIRPATH /first
ENV DIRNAME second
WORKDIR $DIRPATH/$DIRNAME
RUN ["pwd"]
````

### 사용자 설정 (RUN)
이미지 실행 또는 Dockerfile 내의 다음 명령어를 실행시ㅣㄹ 사용자를 설정할때에는 USER 명령엇 사용
* RUN
* CMD
* ENTRYPOINT

````
USER Shin
RUN ["whoami"]
````

### LABEL
버전, 커멘트 정보를 이미지에 심을때 LABEL 명령을 사용
```
LABEL title="WebAPServerImage"
LABEL version="1.0"
LABEL description="This image is webapplicationserver \
for JAvaEE"
```
```
$ docker build -t ywyi/sample -f Dockerfile.web-base .
Sending build context to Docker daemon   12.8kB
Step 1/4 : FROM centos:centos7
 ---> 1e1148e4cc2c
Step 2/4 : LABEL title="WebAPServerImage"
 ---> Running in 291637c5e72a
Removing intermediate container 291637c5e72a
 ---> 9576168441c8
Step 3/4 : LABEL version="1.0"
 ---> Running in e8c6acfafaee
Removing intermediate container e8c6acfafaee
 ---> f8a751733bbd
Step 4/4 : LABEL description="This image is webapplicationserver for JAvaEE"
 ---> Running in 2dcdd9dc1d68
Removing intermediate container 2dcdd9dc1d68
 ---> 53ad2e722f42
Successfully built 53ad2e722f42
Successfully tagged ywyi/sample:latest


(⎈ |mycluster-context:default)SKCC18N00029:~ himang10 in ~/ywyi/docker/docker04
$ docker inspect --format="{{ .Config.Labels }}" ywyi/sample
map[org.label-schema.build-date:20181205 org.label-schema.license:GPLv2 org.label-schema.name:CentOS Base Image org.label-schema.schema-version:1.0 org.label-schema.vendor:CentOS title:WebAPServerImage version:1.0 description:This image is webapplicationserver for JAvaEE]
```

### EXPOSE
컨테이너에 공개할 포트번호를 설정. 명시적으로 정보를 보여주는 의미.

```
EXPOSE 8080
```

### ADD
이미지에 호스트의 파일과 디렉토리를 추가하기 위해서 ADD 사용
```
# ADD <호스트 파일 경로> <Docker 이미지 파일 경로>
ADD host.html /docker_dir/
```
* WORKDIR과 ADD의 실행결과
```
WORKDIR /docker_dir
ADD host.html web/
ADD http://www.wings.msn.to/index.php web/
````
> 호스트 파일이 tar , gzip등의 압축파일인 경우에는 디렉토리로 풀린다.
> 단 원격 URL인 경우에는 압축이 풀리지 않는다

### 그외
#### COPY
```
# COPY <호스트 파일 경로> <Docker 이미지 파일 경로>
```

#### VOLUME
```
# VOLUME <\>
```
* log image 생성
```yaml
# based image confiugration
FROM centos:latest

RUN mkdir /var/log/httpd
VOLUME /var/log/httpd
````

* log image build
````
$ docker build -t ywyi/log-images -f Dockerfile.volume .
Sending build context to Docker daemon  13.82kB
Step 1/3 : FROM centos:latest
 ---> 1e1148e4cc2c
Step 2/3 : RUN mkdir /var/log/httpd
 ---> Running in 2d0edb390cc1
Removing intermediate container 2d0edb390cc1
 ---> 3d10e294bfa0
Step 3/3 : VOLUME /var/log/httpd
 ---> Running in ceab7d1be219
Removing intermediate container ceab7d1be219
 ---> cc6abd22a4b6
Successfully built cc6abd22a4b6
Successfully tagged ywyi/log-images:latest
````

* 로그용 컨테이너 구동
```
$ docker run -it --name log-conatiner ywyi/log-images
[root@e6442c475a5a /]# ls
```

* 웹 서버용 이미지 생성
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

* 웹 서버용 컨테이너 구동
구동시 volumes-from으로 기존 volume을 포함하고 있는 log-container를 설정
```
$ docker run -d --name web-container \
→ -p 80:80 \
→ --volumes-from log-container ywyi/web-images
```


* 로그 확인
```
$ docker start -ia log-conatiner
[root@e6442c475a5a httpd]# tail -f access_log
172.17.0.1 - - [29/Jan/2019:13:11:04 +0000] "GET / HTTP/1.1" 304 - "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
172.17.0.1 - - [29/Jan/2019:13:11:04 +0000] "GET /img/icon.png HTTP/1.1" 404 210 "http://localhost/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
```





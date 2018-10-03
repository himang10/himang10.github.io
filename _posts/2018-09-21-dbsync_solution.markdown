---
layout: post
title: DB Synch. Solution: SharePlex and Alternatives
date: 2019-09-19
categories: Data
tags: [db sync, sharePlex, DR]
author: himang10
description: Database Replication Solution에 대한 설명
---
xxx
============

## [SharePlex](https://alternativeto.net/software/shareplex/) - commercial
***Heterogenous Data Replication. Created by Quest Software***

database replication에 대한 완벽한 대안으로써 SharePlex는 critical database의 uptime을 유지하기 위한 모든 기능들을 ***Oracle GoldenGate***의절반비용으로 모든 기능들을 제공하고 있다.
이것을 이용하여 HA를 보장한다. 이를 통해 insight를 도출하고 레포팅하는 것을 거의 실시간으로 통합하고 이전할 수 있다. 시중에 판매되는 최대 규모의 독립 데이터베이스 복제 솔루션인 [SharePlex](https://www.quest.com/products/shareplex/)는 탁월한 수상 경력에 빛나는 지원을 바탕으로 신뢰할 수 있는 업계 최고의 복제 기능을 제공한다. 

### 지원 OS
* Windows
* Linux

### 지원 DB
SharePlex는 다음 플랫폼에 대한 replication을 지원한다.
- SAP
- SQL Server
- SAP HANA
- Oracle
- Postgres
- Teradata
- Tibero

## [SymmetricDS](https://alternativeto.net/software/symmetricds/) - open source
***SymmetricDS는 비동기 데이터베이스 복제 소프트웨어 패키지***이며 Open Source.

SymmetricDS는 여러 subscriber와 양방향 동기화를 지원하는 비동기 데이터베이스 복제 소프트웨어 패키지입니다. 웹 및 데이터베이스 기술을 사용하여 거의 실시간으로 관계형 데이터베이스간에 테이블을 복제합니다. 이 소프트웨어는 많은 수의 데이터베이스에 맞게 확장되고 낮은 대역폭 연결에서도 작동하며 네트워크 중단 시에도 작동할 수 있도록 설계되었습니다. 
### 지원 OS
* MAC
* Windows
* Linux

### 지원 DB
다음 DB를 지원합니다.
- Oracle
- MySQL
- PostgreSQL
- H2
- HSQLDB
- Derby
- MS SQL Server
- Firebird
- IBM DB2
- Informix
- Interbase
- Greenplum

## [Daffodil Replicator](https://alternativeto.net/software/daffodil-replicator-os-/) - open source
***Powerful Open source java tool for data integration, data migration***

Daffodil Replicator는 실시간으로 데이터 통합, 데이터 마이그레이션 및 데이터 보호를위한 강력한 오픈 소스 Java 도구입니다. Oracle 및 MySQL을 포함한 동종 / 이기종 데이터베이스 간 양방향 데이터 복제 및 동기화가 가능합니다.

Daffodil Replicator는 다양한 데이터베이스간에 데이터를 복제하는 다양한 기능을 제공합니다. 

다음과 같은 다양한 기능을 지원합니다.

#### 양방향 데이터 동기화 
Daffodil Replicator는 양방향 데이터 동기화를 지원합니다. 이를 통해 복제 프로세스에서 사용 가능한 모든 데이터 소스를 동기화 할 수 있습니다. 복제 프로세스에서 한쪽 끝에서 다른 쪽 끝으로 변경 한 내용과 다른 쪽 끝에서 변경 한 내용을 모두 적용하여 데이터 무결성을 유지합니다.

#### 이기종 데이터베이스에서 
복제 지원 Daffodil Replicator는 서로 다른 데이터베이스 간의 복제를 지원합니다. 예를 들어 하나의 데이터 소스를 Daffodil DB로 사용하고 다른 데이터 소스를 동일한 복제 프로세스에서 SQL Server로 사용할 수 있습니다.

#### 충돌 탐지기 및 해결 
Daffodil Replicator는 동일한 데이터베이스에서 동시에 변경을 수행 할 수있는 충돌 탐지 및 해결 기능을 제공합니다. 예를 들어, 다른 위치에서 동시에 데이터베이스의 동일한 레코드에 변경 사항이 작성되면 충돌이 발생합니다. 충돌이 발생할 경우 Daffodil Replicator는 작업 또는 구독 생성시 사용자가 지정한 설정을 기반으로 일관성을 자동으로 관리합니다.

#### 부분 복제 
수선화 복제기를 사용하면 전체 데이터베이스를 복제하는 대신 데이터베이스의 일부만 복제 할 수도 있습니다. 예를 들어 테이블 이름을 선택하여 데이터베이스의 일부 테이블을 복제 할 수 있습니다. 또한 필터링을 사용하여 데이터베이스의 일부 행과 열을 복제 할 수 있습니다. 
대형 데이터 유형 지원 Replicator는 지원되는 데이터베이스의 거의 모든 데이터 유형을 지원합니다. 또한 BLOB 및 CLOB 복제를 지원합니다.

### 지원 OS
* Linux

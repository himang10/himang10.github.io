### Mac 

* 파일 위치 정보
```
- Kafka & Zookeeper properties
/usr/local/etc/kafka/
$ ls
connect-console-sink.properties        connect-log4j.properties               ***server-broker1.properties***
connect-console-source.properties      connect-standalone.properties          ***server-broker2.properties***
connect-distributed.properties         connect-standalone.properties.default  server.properties
connect-distributed.properties.default consumer.properties                    tools-log4j.properties
connect-file-sink.properties           log4j.properties                       trogdor.conf
connect-file-source.properties         producer.properties                    ***zookeeper.properties***

$vi server-broker1.properties
broker.id=1 
port=9093
log.dir=/tmp/server-broker1.logs

```

- 실행
```
$ls kafka*
kafka-acls                       kafka-delete-records             kafka-run-class
kafka-broker-api-versions        kafka-dump-log                   kafka-server-start
kafka-configs                    kafka-log-dirs                   kafka-server-stop
kafka-console-consumer           kafka-mirror-maker               kafka-streams-application-reset
kafka-console-producer           kafka-preferred-replica-election kafka-topics
kafka-consumer-groups            kafka-producer-perf-test         kafka-verifiable-consumer
kafka-consumer-perf-test         kafka-reassign-partitions        kafka-verifiable-producer
kafka-delegation-tokens          kafka-replica-verification

$ ls zookeeper*
zookeeper-security-migration zookeeper-server-start       zookeeper-server-stop        zookeeper-shell

$ zookeeper-server-start /usr/local/etc/zookeeper/zoo.cfg
$ kafka-server-start /usr/local/etc/kafka/server-broker1.properties
$ kafka-server-start /usr/local/etc/kafka/server-broker2.properties
```

- topic 생성
```
$ kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic mytestTopic
```
- topic list
```
$ kafka-topics --list --zookeeper localhost:2181 mytestTopic
```

- topic 상세 
```
$ kafka-topics --describe --zookeeper localhost:2181 ?topic mytestTopic
> PartitionCount: 해당 토픽에 존재하는 파티션의 수
> ReplicationFactor: 해당 토픽에 존재하는 복제본의 수
> Leader: 해당 파티션의 읽기와 쓰기에 대한 역할을 하는 노드
> Replicas: 카프카 데이터를 복제하는 브로커 목록. 이중 일부는 못쓰게 되기도 함
> ISR: 현재 동기화되고 있는 복제본의 노드 목록
```

- replicas 생성
```
$ kafka-topics --create --zookeeper localhost:2181 --replication-factor 2 --partitions 1 --topic mytestTopic
```

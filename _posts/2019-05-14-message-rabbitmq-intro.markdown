---
layout: post
title: Rabbit MQ 소개
date: 2019-05-14
categories: MESSAGE
author: himang10
tags: [rabbitmq, message]
---

래빗MQ(RabbitMQ)
===========

RabbitMQ는 AMQP(Advanced Message Queing Protocol)을 구현한 메시지 브로커이다.
AMQP라는 표준MQ 프로토콜로 만들어 져있고 Cluster구성이 쉽고 ManageUI가 제공되며 무엇보다 성능이 뛰어나다고 알려져 현재 많이 사용되고 있다. 또한 ManagementUI, Autocluster, MQTT Convert, STOMP 등의 plugin도 제공되어 확장성이 뛰어나며 Spring에서도 AMQP연동 라이브러리가 제공되어 편리하게 연동하여 사용가능하다.

### 특징
- ISO 표준(ISO/IEC 19464) AMQP 구현
- 비동기처리를 위한 메시지큐 브로커
- erlang과 java 언어로 만들어짐 (clustering 등을 위한 고속 데이터 전송하는 부분에 erlang이 사용된 것으로 추정)
- 분산처리를 고려한 MQ ( Cluster, Federation )
- 고가용성 보장 (High Availability)
- Publish/Subscribe 방식 지원
- 다양한 plugin 지원

## AMQP
여러 MQ들이 존재해왔지만 그들만의 방식으로 구성되어 이기종간에 통신이 어려운 문제로 표준화된 AMQP가 나왔다.
RabbitMQ를 연구하면서 AMQP라는 프로토콜을 접하게 되었는데 예전에 연구했던 MQTT와 Publish/Subscribe를 하며 Reliability처리하는 사상 등에서 많이 닮았다고 느껴졌다.  
(필자가 2011년 모바일 Push 프로젝트를 하며 MQTT를 연구한바 있는데, 최근 IoT로 인해 MQTT가 다시 주목받기 시작하고 있어서 RabbitMQ 다음으로는 MQTT에 대해서 설명올려볼 계획이다.)

[AMQP공식사이트](http://www.amqp.org/)



RabbitMQ기능 (AMQP) 파악하기
-----------

### 주요 용어

**Producer**

: 메시지를 보내는 Application

![Producer 이미지](http://gjchoi.github.io/images/rabbitmq1/producer.png)


**Publish**

: Producer가 메시지를 보냄


**Queue**

: 메시지를 저장하는 버퍼
: Queue는 Exchange에 Binding된다.

![Queue 이미지](http://gjchoi.github.io/images/rabbitmq1/queue.png)


**Consumer**

: 메시지 받는 User Application
: 동일 업무를 처리하는 Consumer는 보통 하나의 Queue를 바라본다. (중복방지)
: 동일 업무를 처리하는 Consumer가 여러개 인 경우 같은 Queue를 바라보게 하면 자동으로 메시지를 분배하여 전달함

![Consumer 이미지](http://gjchoi.github.io/images/rabbitmq1/consumer.png)

**Subscribe**

: Consumer가 메세지를 수신하기 위해 Queue를 실시간으로 리스닝하도록 만듬.

**Exchange**

: Producer가 전달한 메시지를 Queue에 전달하는 역할
: 메시지가 Queue에 직접 전달되지 않고 `exchange type`이라는 속성에 정의된데로 동작


![Exchange 이미지](http://gjchoi.github.io/images/rabbitmq1/exchanges.png)

**Exchange type**

: 특정 Queue에 보낼지, 여러 Queue에 보낼지, 아니면 그냥 제거될지 등을 선택

|type|설명|특징|
|:--------:|:-------|:--------:|
|fanout| 알려진 모든 Queue에 메시지 전달 함|Broadcast|
|direct| 지정된 routingKey를 가진 Queue에만 메시지 전달 함|unicast|
|topic| 지정된 패턴 바인딩 형태에 일치하는 Queue에만 메시지 전달. #(여러단어), *(한단어)를 통한 문자열 패턴 매칭|multicast|
|header| 헤더에 포함된 key=value의 일치조건에 따라서 메시지 전달|multicast|
{: rules="groups"}


**Bindings**

: Exchange와 Queue를 연결해주는 것

![Binding 이미지](http://gjchoi.github.io/images/rabbitmq1/bindings.png)

**Routing**

: Exchange가 Queue에 메시지를 전달하는 과정


**RoutingKey**

: Exchange와 Queue가 Binding될 때 Exchange가 Queue에 메시지를 전달할지를 결정하는 기준

: Publish RoutingKey가 Binding시 설정된 RoutingKey값과 일치하거나 (exchange type=`direct` 경우) 
  RoutingKey값이 Binding시 설정된 패턴에 매칭될 때 (exchange type=`topic` 경우)




### 기본 흐름

Exchange를 별도로 명시하지 않은 요청의 기본 흐름

![P-Queue-C 그림](http://gjchoi.github.io/images/rabbitmq1/python-one.png)


1. Producer가 메시지를 생성하여 전송
2. Queue가 이 메시지를 순차적으로 쌓음
3. Consumer가 Queue에 대한 Binding을 가지고 있다가 메시지를 Queue에서 수신



### 상세 흐름

1. Producer가 메시지를 생성하여 전송
2. Exchange가 어떤 Queue에 전달할지를 Routing
3. Queue들이 메시지를 순차적으로 쌓음
3. Consumer가 Queue에 대한 Binding을 가지고 있다가 메시지를 Queue에서 수신


### 메시지 분배 (Round-robin dispatching)

RabbitMQ는 Consumer가 병렬처리를 쉽게 할 수 있도록 같은 Queue를 바라보고 있는 Consumer에게 메시지를 균등 분배한다.

즉 첫번째 메시지는 Consumer1에게 두번째 메시지는 Consumer2에게 분배(중복 처리하지 않도록 1명에게만 줌)

MQ의 존재 이유를 보여주는 매우 중요한 개념이다. 이로 인해 메시지를 받아 처리하는 프로그램들은 수평 확장이 가능하다.
물론 Producer도 수평 확장이 가능하다. (같은 Queue에 메시지를 던져주기만 하면 됨)


#### Fair dispatch(공평한 분배)

여러 consumer에게 round robin할 때 번갈아가면서 메시지를 전달하지만 완전히 공평하진 않음
(매홀수는 데이터크기가 크고, 매짝수는 데이터크기가 작은 등)  

때문에 busy한 서버에게 메시지를 계속 전달하지 않도록 prefetchCount라는 개념사용.
prefetchCount가 1일때는 아직 ack를 받지 못한 메시지가 1개라도 있으면 다시 그 consumer에게 메시지 할당하지 않음.
즉 prefetchCount는 동시에 보내는 메시지 양임  

![P-Exchange-Queue-C 여러개 그림](http://gjchoi.github.io/images/rabbitmq1/prefetch-count.png)




### 메시지 수신 통보 (Acknowledgment)

많은 프로토콜들이 메시지 전달 보장을 위해 Acknowlegment(ACK)라는 개념을 사용하여 메시지에 대한 응답을 보내주도록 되어있다.
MQTT의 경우는 QoS(Quality of Service) level이라고해서 0=안보냄, 1=전달완료확인, 2=최종목적지까지 처리완료 확인의 개념이 있는데
*RabbitMQ의 경우는 Acknowledgment(Consumer전달확인)와 Confirm(Publish전달확인)을 이용한 level `1`만 지원하는 듯 하다.*(추정)

ACK가 중요한 이유는 Queue는 Consumer에게 데이터를 전달하고나면 Queue에서 메시지를 삭제하므로, Consumer가 전달받았지만 처리도중 오류가 발생하여 재처리해야하는 경우를 위해 보관 유예기간을 두는 용도로 이용된다. 즉 ACK가 온 메시지만 삭제처리하도록 하는 것이다.

※ 주의 basicQos라는 설정은 prefetchCount의 숫자 설정임(!! QoS level 0,1,2의 개념 아님!!)


![P-Queue-C Ack그림](http://gjchoi.github.io/images/rabbitmq1/ack_client.png)


#### 여러 Client(Consumer) 중 일부가 죽었을시 대응방법

앞서 설명했듯이 Consumer가 ACK를 보내지 않으면 Queue에 쌓인 메시지는 지워지지 않고 남아있다.
메시지를 받은 Consumer가 느려서 아직 Processing 중일 수 있어서 다른 Consumer에게 Round Robin하여 재전송 하자니 중복처리 우려가 있고,
그대로 `Unacknowledged` 상태로 마냥 처리 안된채로 남겨 둘 수도 없고 곤란하다.

이 경우에 어떻게 동작하는지 확인해볼 필요가 있다.



###### 테스트 예제

같은 메시지에 대하 바인딩되어있는 Consumer가 2개가 있다. 하나는 ACK를 재대로 보내는 Consumer고 하나는 오류 상황이 발생하여 ACK를 보내지 못하는 상황이다. prefetchCount는 1로 하나라도 `Unacknowledge` 상태라면 재전송을 하지 않도록 설정한다.

![P-Queue-C2개의 1~11 Ack그림](http://gjchoi.github.io/images/rabbitmq1/ack_client_republish1.png)

![P-Queue-C2개의 1~11 Ack그림](http://gjchoi.github.io/images/rabbitmq1/ack_client_republish2.png)

 
위에서 보는 것 처럼 Acknowledge 메시지가 돌아오지 않으면 Queue는 메시지를 삭제하지 않고 보관하고 있다가, Consumer가 이를 처리하지 못한다고 판단했을 때 (Disconnected 되는 등의 상황) 메시지를 다음 순번의 Consumer(Worker)에게 라운드 로빈한다.





#### RabbitMQ가 재기동 됐을때 대응책

메시지를 Queue에 넣은 뒤 Consumer에게 전달하기 전에 RabittMQ 서버가 죽는다면
기본적으로 해당 메시지는 날라가버리게 된다.
이런 상황을 방지 하기 위해 `durable`이라는 개념을 가지고 있다.



##### Message durability   

메시지는 Queue에 보관할 때 file에도 같이 쓰도록 만드는 방법이다.  
아래와 같은 방법으로 설정해야 동작한다.


1. queue생성시 durable속성을 true로 주고 만든다.
2. message publish할때 MessageProperties.PERSISTENT_TEXT_PLAIN을 설정함  

1,2번 모두 만족해야 메시지가 Queue에 남아있을 때 restart해도 날라가지 않는다.  

![P-Queue-C Persistent](http://gjchoi.github.io/images/rabbitmq1/persistent_msg.png)


※ 메시지의 persistent는 완변히 보장되진 않음. 메번 메시지마다 fsync 로 동기화히지 않기 때문에
   짧은시간이나마 아직 Disk에 쓰여지지 않았을 경우가 있다.
   좀더 강력한 방법을 보장하기 위해서는 `publisher confirms`를 사용




### Publish/Subscribe

한 메시지를 여러 Consumer가 동시에 받아 사용해야 하는 경우가 있다. 이러한 Publish/Subscribe 구조를 
RabbitMQ로 구성하여 사용 할 수 있다.


#### 기본 exchanges

: RabbitMQ설치시 기본적으로 세팅된 exchanges

~~~  
    amq.direct      direct
    amq.fanout      fanout
    amq.headers     headers
    amq.match       headers
    amq.rabbitmq.log        topic
    amq.rabbitmq.trace      topic
    amq.topic       topic
~~~


#### 이름없는 exchange

`Producer`가 메시지를 보낼 때 exchange를 지정해서 보낼 수 있는데, 
 이름이없다면 `routingKey`라는 특정 key값으로 Queue에 라우팅 된다.
즉 `exchange`명이 있거나 `routingKey`명이 있어야 한다.

~~~~
channel.basicPublish("", "hello", null, message.getBytes());

channel.basicPublish( "logs", "", null, message.getBytes());
~~~~


#### 임시 Queue

이전에 사용한 Queue를 기억하고 계속적으로 사용하기 위해서는 같은 이름의 Queue를 Worker가 바라보도록 하는 것이 중요하다.
그러나 fanout을 받아 처리하는 Queue인 경우 Consumer가 
임시 이름이라도 지정해줘야하는데 다음 2가지가 고려 되어야 한다.


1. RabbitMQ 연결시마다 서버에서 발급한 random Queue 이름의 사용

2. 연결이 종료 되었을 때 Queue의 자동삭제


![P-Exchange-Queue-C 여러개 그림](http://gjchoi.github.io/images/rabbitmq1/python-three-overall.png)

~~~~
String queueName = channel.queueDeclare().getQueue();
~~~~

이런식의 `amq.gen-JzTY20BRgKO-HjmUJj0wLg`  Random Queue가 사용된다.



#### 바인딩 (Bindings)

생성한 exchange를 queue에 매핑을 해줘야 exchange가 메시지를 받으면 Queue에 메시지를 보낼 수 있는데
이를 `Bindings` 이라고 함

~~~~~
channel.queueBind(queueName, "logs", "");
~~~~~



### Routing

모든 메시지를 받는 것이 아니라 선별정으로 특정 종류의 메시지를 받도록 subset을 설정하여 멀티케스트 함

#### Direct exchange

exchange type 중 `direct`을 이용해서 exchange를 만들면 부분적으로 메시지를 라우팅 하도록 처리 할 수 있다.  

~~~~ java

// 특정 EXCHANGE_NAME 으로 "direct' exchange를 생성
channel.exchangeDeclare(EXCHANGE_NAME, "direct");

~~~~

##### Producer

메시지를 publish할 때 `routingKey`값을 주어 선별적인 Queue에만 메시지를 전달 한다.

~~~~ java

// 특정 EXCHANGE_NAME에 특정 "routingKey"로 binding된 queue에게만 메시지 전송
channel.basicPublish(EXCHANGE_NAME, routingKey, null, message.getBytes());

~~~~

##### Consumer

메시지를 받는 Consumer, Worker에서 queue bind시 `routingKey`값을 주어 선별적으로 수신 한다.

~~~~ java

// 특정 EXCHANGE_NAME의 특정 routingKey만 전달 받도록 binding 함
// 여러 routingKey와 bind 될 수 있다.
channel.queueBind(queueName, EXCHANGE_NAME, routingKey1);
channel.queueBind(queueName, EXCHANGE_NAME, routingKey2);

~~~~



#### Multiple binding

Exchange와 Queue간에 n:m binding이 가능하다.

1개의 Queue는 여러 routingKey와 binging 할 수 있다.
여러개의 Queue는 같은 routingKey와 binding 할 수 있다.



### 패턴매칭 라우팅(Topics)

RabbitMQ는 Topic이라는 개념을 통해 패턴 매칭식 멀티케스트 라우팅을 지원한다.  
`topic` exchange를 생성하여 특정 문자열 패턴에 일치하는 Queue에만 데이터를 보내주도록 구성할 수 있다.


#### Topic exchange

exchange type 중 `topic`을 이용해서 exchange를 만들면 특정 패턴에 일치하는 routingKey로 메시지가 전송된 경우 메시지를 수신 할 수 있다.  
해당 패턴은 다음의 특수 문자를 사용하여 구성한다.

~~~~ java
channel.exchangeDeclare(EXCHANGE_NAME, "topic");
~~~~

##### Topic Pattern

`*` 
: 여러 Word를 나타냄 (1 Word 는 `.`로 구분됨 )

`#` 
: 여러 Word를 나타냄 (1 Word 는 `.`로 구분됨 )


※ Topic이 `#` 으로만 구성되면 `fanout`과 동일하다.
※ Topic에 `*`나 `#` 문자가 하나도 없다면 `direct`와 동일하다.



###### 예제

quick으로 시작되는 `.`으로 구분되는 4개의 Word로 구성된 문자열


~~~~
quick.*.*.*
~~~~

quick.test.good.job => 매칭

front.quick.test.good.job => 비매칭


~~~~
#.end
~~~~

front.mid.end  => 매칭

front.end      => 매칭

front.mid.end.last  => 비매칭



##### Producer

메시지를 publish할 때 `routingKey`값을 주어 선별적인 Queue에만 메시지를 전달 한다.

~~~~ java

// 특정 EXCHANGE_NAME에 특정 "routingKey"로 binding된 queue에게만 메시지 전송 (메시지 전송시는 direct와 별반 다를바 없음)
channel.basicPublish(EXCHANGE_NAME, routingKey, null, message.getBytes());

~~~~

##### Consumer

메시지를 받는 Consumer, Worker에서 queue bind시 `routingKey`의 패턴 값을 주어 선별적으로 수신 한다.

~~~~ java

// 특정 EXCHANGE_NAME의 특정 패턴을 가진 문자열로 routingKey만 전달 받도록 binding 함
// 여러 routingKey와 bind 될 수 있다.

String patternedRoutingKey1 = "kern.*";
String patternedRoutingKey1 = "*.critical";

channel.queueBind(queueName, EXCHANGE_NAME, patternedRoutingKey1);
channel.queueBind(queueName, EXCHANGE_NAME, patternedRoutingKey2);

~~~~




#### 원격 프로시져 호출 (RPC)

RabbitMQ는 Request-Response로 Client와 Server를 이어주기 위해 RPC라는 개념으로 기능을 제공한다.

RPC라는 거창한 이름을 사용하였지만 실제로는 Client의 request를 Server에 전달하고
, Server가 처리한 결과를 알맞은 Client 요청에 대한 응답으로 전달 할 수 있는 방법을 말한다.


##### Message Properties 설명

DeliveryMode
: persistent인지 transient인지 표시 (휘발성인지 비휘발성인지 구분자)
  
  
ContentType
: 내용물의 mime-type
  
  
ReplyTo
: Callback Queue의 이름
  
  
CorrelationID
: 요청을 구분할 수 있는 유일값


##### 처리 흐름


1. Client가 `CorrelationID`, `ReplyTo` 주어서 RabbitMQ의 특정 Request보관용 Queue에 데이터를 Push한다.

2. Request용 Queue에 데이터를 Server에서 Consume하여 요청을 처리한다.

3. 요청처리 후 Request에서 받은 `CorrelationID` 와 `ReplyTo`를 추출하여, 요청ID를 속성으로 갖는 Response를 `ReplyTo` Queue에 Push한다.

4. Client는 `ReplyTo` Queue를 subscribe하고 있다가 Response가 오면 `CorrelationID`를 보고 어떤 요청에 대한 응답인지를 구분하여 처리한다.




##### 샘플 설명

###### Server ( 원격 요청 처리 )

~~~~~~~ java

private static final String RPC_QUEUE_NAME = "rpc_queue";

ConnectionFactory factory = new ConnectionFactory();
factory.setHost("localhost");

Connection connection = factory.newConnection();
Channel channel = connection.createChannel();

// Request를 받아오기 위한 RPC_QUEUE_NAME의 Queue를 사용 (익명의 exchange 사용)
channel.queueDeclare(RPC_QUEUE_NAME, false, false, false, null);

// 다중 worker사용시 메시지 고른 분배를 하도록 1개씩만 서버에서 보낸 Response를 처리하도록 설정
channel.basicQos(1);

// 내부적으로 BlockQueue를 사용하여 순차적으로 메시지를 처리 할 수 있게 해주는 QueueingConsumer사용
QueueingConsumer consumer = new QueueingConsumer(channel);
channel.basicConsume(RPC_QUEUE_NAME, false, consumer);

System.out.println(" [x] Awaiting RPC requests");


//서버는 계속적으로 메시지 수신한다.
while (true) {

    // Consumer통해서 메시지 발생시마다 Delivery라는 객체를 반환한다.
    QueueingConsumer.Delivery delivery = consumer.nextDelivery();

    BasicProperties props = delivery.getProperties();

    // 응답용 Properties를 만든다. client의 응답아이디와 쌍을 맞추기 위해 넘겨받은 CorrelationId를 설정해준다.
    BasicProperties replyProps = new BasicProperties
                                     .Builder()
                                     .correlationId(props.getCorrelationId())
                                     .build();

    // delivery에서 client가 요청한 내용물을 꺼낸다.
    String message = new String(delivery.getBody());
    int n = Integer.parseInt(message);

    System.out.println(" [.] fib(" + message + ")");
    String response = "" + fib(n);

    // Client 응답에 대한 처리를 완료 후 ReplyTo(Client가 메시지 보낼때 임시 생성했던 Response용 임시 Queue)에 메시지를 전달한다.
    channel.basicPublish( "", props.getReplyTo(), replyProps, response.getBytes());


    // Ack를 보낸다. 메시지를 다 처리하고 Request Queue에서 데이터를 지우도록 함
    channel.basicAck(delivery.getEnvelope().getDeliveryTag(), false);
}
~~~~~~~




###### Client ( 원격 프로시져 호출 )

~~~~~~~ java

private Connection connection;
private Channel channel;
private String requestQueueName = "rpc_queue";
private String replyQueueName;
private QueueingConsumer consumer;

public RPCClient() throws Exception {
    ConnectionFactory factory = new ConnectionFactory();
    factory.setHost("localhost");
    connection = factory.newConnection();
    channel = connection.createChannel();

    // Response를 받을 임시 Queue 생성
    replyQueueName = channel.queueDeclare().getQueue(); 
    consumer = new QueueingConsumer(channel);

    // 응답받을 Queue를 Subscribe 함
    channel.basicConsume(replyQueueName, true, consumer);
}

public String call(String message) throws Exception {     
    String response = null;

    // 자신이 여러 Request를 보낼 수 있으므로 이를 구분 할 수 있는 구분값 생성
    String corrId = java.util.UUID.randomUUID().toString();

    // 서버가 응답시 그대로 포함되서 Callback될 Request구분자(coelationID)
    // 서버가 메시지처리 후 응답할 Response Queue(replyTo)를 BasicProperties에 세팅한다.
    BasicProperties props = new BasicProperties
                                .Builder()
                                .correlationId(corrId)
                                .replyTo(replyQueueName)
                                .build();

    // 메시지 전송(RPC)
    channel.basicPublish("", requestQueueName, props, message.getBytes());

    while (true) {
        QueueingConsumer.Delivery delivery = consumer.nextDelivery();

        // 서버사정에 의해 메시지가 중복 발송되거나 순번이 꼬일 수 있다. 
        // 이를 위해 내가 보낸 요청과 같은 Response인지 CorrelationId로 확인해야 한다.

        if (delivery.getProperties().getCorrelationId().equals(corrId)) {
            response = new String(delivery.getBody());
            break;
        }
    }

    return response; 
}

public void close() throws Exception {
    connection.close();
}
~~~~~~~ 


##### RPC의 이점

RPC 구조를 응용하면 아래와 같은 상황에 이점을 얻을 수 있다.

###### 서버처리 이점 

서버 처리속도가 느려서 성능을 증가 시키려고 할 때, RPC 서버를 하나 더 두고 같은 Request Queue를 바라보게 하면 됨 ( Round Robin 하므로 )


###### Client 이점

하나의 메시지를 개별 Round Trip으로 처리를 위해 queueDeclare같은 동기처리 요청이 필요없다. (임시 Queue를 생성하여 Client마다 다른 Queue를 사용하므로)


##### RPC 구성시  고려할 점

- 돌아가는 서버가 없을 때 Client 처리
- 요청 Timeout시 Client 처리
- 서버 Exception이나 오동작시 Client에게 이를 어떻게 전달할지
- Invalid한 데이터가 서버로 전달 되었을 때의 처리

### RabbitMQ Broker를 분산환경하에 사용하는 방법

1) Clustering
-------------

다중 머신을 하나의 논리적인 브로커형태로 연결한다.
Erlang message-passing을 통해서 연결되므로 같은 Erlang cookie를 가지고 있어야 한다.
네트워크도 항상 연결되어있고, 같은 버젼의 RabbitMQ와 Erlang으로 구성되어야 한다.

Virtual hosts, exchanges, permission 들이 복제됨
Queue는 하나의 node에만 있을 수도있고 복제되어 다중 node에 존재 할 수도 있는데
Client는 어떤 node에나 붙어서 모든 Queue를 바라볼 수도 있다.


보통 같은 지역의 여러머신을 고가용성(high availability)와 처리량의 증가하도록 구성하는데 쓰임


2) Federation
-------------
AMQP를 통해서 한 broker의 exchange(or Queue)에서 다른 broker의 exchanges(or Queue)를 연결한다.
두 broker는 적합한 User, permission이 부여되어야 연결 가능하다.

Federation Exchange는 point-to-point link로 단방향성으로 연결됨

보통 인터넷 넘어의 브로커들을 pub/sub메시징처리나 Work Queueing로 연결하는데 사용함


3) The Shovel
-------------

Shovel은 federation과 비슷한데 더 low level로 동작함

한 브로커에 있는 메시지를 Consume해서 다른 브로커의 exchange에 forward 해줌

보통 federation이 제공하지 못하는 세세한 control이 필요할 때 사용

Dynamic Shovel는 하나의 브로커의 ad-hoc환경하에 메시징처리에도 유용함



#### Summary

| 구분 | Federation / Shovel | Clustering |
|:------|:-------------------|:-----------|
| **머신구성** | 브로커가 분리, 브로커 주인이 다르다 | 하나의 논리적인 브로커 |
| **RabbitMQ와 Erlang 버젼** | 달라도 구성가능 | 같아야 구성가능 |
| **Communication 방식** | AMQP | Erlang |
| **네트워크** | WAN,LAN가능 | LAN가능 |
| **연결인증** | user/permissions | erlang cookie |
| **연결구성** | 단방향 or 양방형 Link | 모든 노드들의 연결 |
| **CAP** | AP(Availability & Partition Tolerance) | CP (Consistency & Partition Tolerance) |


실제 서비스시 고려해야할 사항 CheckList
========================================

실제 운영모드에 들어가려면 보안적인 처리나, 서비스별 구분, 성능측면 등을 위해 다음 사항들을 살펴봐야 한다.



1) 서비스 구분 및 User 권한설정
-------------------------------

### Virtual Hosts 설정

##### Single-tenant시

서비스 구분이 1개라면 `/` 만이용해서 서비스하는 것이 좋다.

##### Multi-teanat시

서비스가 여러가지가 있다면 각 tenant별로 vhost를 구분해서 사용하여야 한다.

- /project1_development
- /project1_product
- /project2_development
- /project2_product


### User 및 권한 설정

1. 기본적으로 생기는 계정인 guest를 삭제한다.

2. application이 여러개면 user를 application 별로 따로 가져간다. 접속자별 구분지어 권한 부여나/만료시키기 좋다. (mobile app, web app, data조합하는 appㅇ이 있으면 3개의 user분리)


3. 한 어플리케이션을 많은 client들이 사용하는 경우(ex IoT서비스) 는 편리함을 위해서 
인증을 위한 *x509 certificates*나 IP대역대를 제한하는 *source IP addresse ranges*를 설정하는 것을 고려해야 한다.


2) 리소스 제약 확인/설정
-------------------------------

### Memory

|가용 메모리| Limit설정 |
|:-----|:-----:|
|4GB이하| 75% |
|4~8GB| 80% |
|8~16GB| 85% |
|16GB이상| 90% |

default 40%

최소 128MB, 최대 90%가 넘지 않도록 하는걸 추천

### Disk

|가용 메모리|Disk 여유공간 설정|
|:-----|:-----:|
|1GB~8GB| 50% |
|8GB~32GB| 40% |
|32GB| 30% |


default 최소 50MiB 필요

최소 2GB


### Open File 설정

운영체제의는 network socket을 포함해서  동시에 file open을 제어하는 제한을 가지고 있다.
동시 연결 및 큐를 예측해서 설정해야 함  

추천값 = (동접사 * 0.95 * 2 + 큐의 총수)

**개발환경 : 50K** 면 충분
**운영환경 : 500K** 면 충분(리소스 많이 안먹는 수준에서)



3) 보안처리 
--------------

### User와 권한

vhost, users별로 publish(write), read(consume), confige(queue나 exchange생성) 별로 권한을 준다.  

(자세한건 권한설정 파트 참조)


### 통신간 보안 TLS

TLS를 사용하여 암호화된 패킷을 사용하는 것이 권장됨.

개발 및 QA환경에서는 *자체 인증한 TLS 인증서* 를 사용해도 무방하며, 
운영환경에서도 모든 어플리케이션이 Trusted netwokr에서 운영되거나 내부 환경에서도 *자체 인증한 TLS 인증서*를 사용해도 무방하다.

[self-signed TLS certificates 생성 소스코드](https://github.com/michaelklishin/tls-gen/)


4) 클러스터링 환경
--------------------

예상 부하, 미러의 수, 데이터의 위치 등을 고려하여 클러스터 사이즈를 결정해야 된다.

### 연결할 노드 선정

특히 client가 클러스터링된 어느 노드에도 붙을 수 있기 때문에 클러스터간에 데이터 교환이 필요하다.
그래서 기왕이면 consumer와 producer가 같은 노드에 붙도록 만들면 좋다.  
같은 이유로 기왕이면 큐의 마스터 노드에 consumer가 붙도록 만드는 것이 바람직하다.


### 파티션 전략

cluster 연결간에 문제가 생겼을 때 처리방식인  `cluster_partition_handling` 설정을 확성화 시켜

서버간 통신의 문제가 생겼을 때의 상황에 대비해야 한다.

| 설정 | 특징 | 선택가능 상황 | 비고 |
|ignore| 절대 중지되지 않도록 설정 | 네트웍 신뢰성 높을 때 | rack안에 노드가 있는환경 |
|pause_minority | 과반수 이하만 중지가능 | 비교적 네트웍 신뢰성 낮을 때 | EC2같은 cloud환경 |
|pause_if_all_down | minority를 직접선택 | - | - |
|autoheal | winning partition(주로 client connection이 많은것)을 자동으로 결정해서 나머지를 재기동시킴 | 네트웍 신뢰성 보장 안될 때, 데이터 무결성보다 서비스 가용성이 중요할때 | cluster가 2개인 상황 |
 
애매하면 autoheal을 선택하는 것이 바람직하다.

고가용성 Queue 구성
===================

기본적으로 Cluster구성을 하면 Queue는 단일노드에만 존재하고 복제되지 않는다.
(Exchange, Bindings는 복제됨)

옵션을 지정하여 *mirrored*된 Queue를 만들 수 있으며 하나의 *master*와 한개이상의 *slave*로 구성되며
현 *master*가 사라지면 가장 오래된 *slave*가 *master*로 승급한다.



미러링 구성
-----------

*policy*설정에 의해 미러링을 활성화 시킬 수 있다. (*policy*설정에 의해 특정 패턴의 Queue는 자동 미러링 되도록 설정 할 수 있다.)



### 미러링 종류(ha-mode) 3가지

all
: 클러스터내의 모든 노드를 미러링 함

exactly
: 특정 수 만큼의 노드만 미러링 함
: *ha-params*으로 *count*로 미러링 수 지정

: *count*가 총 노드스보다 많으면 *all*과 동일하게 동작
: 미러링된 노드가 죽었으면 *count*를 채우기 위해 다른 노드를 새 미러로 만듬

nodes
: 특정 이름의 노드들끼리 미러링함
: *ha-params*으로 노드이름(node names) 지정



### Queue master 위치

모든 Queue는 *Queue Master*라 불리는 기준 노드를 가지고 있다.
FIFO보장을 위해 모든 Queue는 master를 먼저 처리하고 다른 mirror들을 처리한다.


#### Queue master 위치 지정 방법

1. Queue를 선언할 때 (queue declare) *x-queue-master-locator* 사용
2. 설정파일의 *queue_master_locator* 키의 값 지정


##### 3가지 설정방법
min-masters
: 최소수의 master로 설정 (현재 가지고 있는 master queue가 가장 적은 노드를 새로운 queue의 마스터로)
: queue를 생성시의 연결이 서버별로 고르게 분상되지 않는다면 이 방법이 바람직해 보임

client-local
: Queue를 선언할때 연결된 client를 지정
: 별다른 설정을 안했다면 이 값이 Default
: queue를 생성시의 연결이 서버별로 고르게 분배된다면 이 방법을 쓰면 서버별로 고르게 master queue가 분배될 듯

random
 : 랜덤


##### 설정방법별 테스트


configuration 파일 (rabbitmq.config)열어 *queue_master_locator* 항목을 추가한다.

~~~
vi /etc/rabbitmq/rabbitmq.config
~~~

~~~~~
[
 {rabbit,
  [
   {queue_master_locator, <<"min-masters">>}
   
   ...

  ]}
].
~~~~~

cluster 노드들을 재기동하여 설정을 반영한다.

※ 주의 : json포맷의 설정이 잘못되거나 .으로 끝나지 않으면 기동시 오류 발생



하나의 서버에 접근하여 *queueDeclare*로 5개의 queue를 생성해보고 master위치지정 방법별로 어떻게 생성되는지 확인해본다.

~~~~
channel.queueDeclare("ha.queue1", false, false, false, null);
		
channel.queueDeclare("ha.queue2", false, false, false, null);
		
channel.queueDeclare("ha.queue3", false, false, false, null);

channel.queueDeclare("ha.queue4", false, false, false, null);
		
channel.queueDeclare("ha.queue5", false, false, false, null);
~~~~



[사진 master_queue_locator_result]








### 설정 샘플

*ha.*으로 시작하는 이름을 가진 Queue를 HA 구성하는 *ha-all*이름의 policy 설정


~~~
rabbitmqctl set_policy ha-all "^ha\." '{"ha-mode":"all"}'
~~~


*two.*으로 시작하는 이름을 가진 Queue를 2개의 미러로 HA 구성하는 *ha-two*이름의 policy 설정
새로운 slave가 join할 때 마다 자동으로 Queue를 Sync하도록 설정

~~~
rabbitmqctl set_policy ha-two "^two\." \
   '{"ha-mode":"exactly","ha-params":2,"ha-sync-mode":"automatic"}'
~~~


*node.*으로 시작하는 이름을 가진 Queue를 rabbit@nodeA,rabbit@nodeB 노드간에 미러링 함

~~~
rabbitmqctl set_policy ha-nodes "^nodes\." \
   '{"ha-mode":"nodes","ha-params":["rabbit@nodeA", "rabbit@nodeB"]}'
~~~



### 새로운 Slave의 추가

slave 노드를 추가하는 것은 어느 때나 가능하지만 새로운 노드는 추가되기 이전의 Queue의 내용을 가지고 있지 못하다.

명시적으로 동기화(*synchronised*) 하는 것은 가능한데 그 순간에 Queue는 응답할 수 없는 상황이 일어나기 때문에
자연스럽게 동기화(*synchronised*) 될 수 있는 active queue가 되도록 하는게 더 좋다.


#### 한번에 동기화하는 Size 설정

위에 언급된 동기화시에 시간이 소요되어 응답 할 수 없는 상황이 일어나므로 RabbitMQ 3.6.0 이후 부터는
*policy*에 *ha-sync-batch-size* 라는 설정을 두어 나누어서 동기화하도록 성능이 향상되었다.


Queue의 데이터량, tick message 시간, 네트워크 대역폭 등을 고려해야 한다.
마냥 size를 높이면 시간이 오래 소요되어 ticktime을 초과하여 네트워크 partition이 깨진 것으로 인지 할 수 있기 때문이다.


    ha-sync-batch-size가 50000이고 큐의 메시지가 건당 1kb라면 net_ticktime이 1초로 설정되어있다면
    네트워크는 50Mb/1초 의 성능을 커버할 수 있어야 한다.


    최소 BatchSize = 네트워크 대역폭 * ticktime / 메시지당 size
    
    ex) 30Mb/s * 2s / 1Kb  = 60,000 이하로 설정해야 함




#### 명시적인 Synchronisation 구성

명시적으로 *Sychronised*하는 방법은 2가지가 있다.


##### 자동으로 설정

*policy*설정에서 "ha-sync-mode":"automatic"로 설정


##### 수동으로 수행

*policy*설정에서 "ha-sync-mode":"manual"로 설정 or 없으면 Default로 수동

이 명령어를 통해 수행

~~~~
rabbitmqctl sync_queue name
~~~~

~~~~
rabbitmqctl cancel_sync_queue name
~~~~


#### 노드가 중지될 때 주의 사항

*master*와 *slave*들로 구성된 cluster를 차례로 중지시킬 때 master가 중지되면 slave가 동기화되어있는 상태라고 가정했을 때
다른 slave 노드들이 차례로 master로 승격된다. 그러다 마지막 노드가 중지될 때 마지막 node가 *durable* 이라면 마지막 노드가
다시 기동되었을 때 Queue안에 메시지들은 살아 있게 된다. (*durable*설정이 안되어있으면 날아감)

이 *slave*들이 다시 살아나도 각자 노드에서 가지고 있는 데이터는 삭제된다. 각자 가지고 있는 데이터들이 *master*를 통해 동기화된
데이터 임을 확신할 수 없으므로 빈상태로 다시 새로 가입된 cluster 노드처럼 동작하게 된다. (동기화를 향후 수행)

또한 *slave*가 동기화되지 않은 상태에서는 설정값에 따라서 master로 승격이 되지 않을 수도 있는데 그 방법은 아래와 같다.


##### Master로 승격 설정

*master*가 중지되고 *slave*가 새로운 *master*가 되는데 동기화상황에 따라서 처리가 다르다.


*ha-promote-on-shutdown* policy 설정값

always
: *slave*가 동기화가 안되어있더라도 무조건 다음 *slave*를 *master*로 승격시킴

when-synced
: *slave*가 동기화가 되어 있지 않다면 메시지 유실방지를 위해 fail over를 하지 않고 전체 Queue를 중지시킴



##### 모든 노드가 중지될 때 master 분실상황

모든 노드가 중지되어있는 동안 master를 분실 할 수 있는 가능성이 있다.
보통은 마지막 노드가 중지되고 마지막 노드가 재기동될 때 master가 되지만 *forget_cluster_node*명령어를 날리면
삭제된 노드를 master로 가지고 있던 slave 중에 하나가 master로 승격된다.

*forget_cluster_node*할 때만 master 승격이 이루어지므로 master를 분실한 상황에서는 slave를 시작하기 전에 
*forget_cluster_node*명령을 수행해야 한다. (그냥 slave를 시작하면 위에 주의사항에 언급된데로 queue데이터를 날리므로)



#### 미러 Queue의 구현과 의미

master와 slave들로 구성된 상황에서 *publish*를 제외한 모든 명령은 master로만 전달되고 master에서 slave들에게 broadcast한다.
그래서 미러 Queue에다 client가 consume하는 일은 사실 master에 consume하는 것이다.


##### slave가 죽었을시 알아야 할 점

사실 slave가 죽으면 master는 그냥 master로 남아있기 때문에 client가 fail신호를 보내거나 하진 않는다. 때문에 slave 문제를
바로 알아차릴 수 없으므로 tick메시지 시간동안 지연이 발생 할 수 있다.


##### master가 죽었을시 알아야 할 점

master가 죽으며 slave가 master로 승급하는데 이 때 일어나는 일들은

1. master가 죽으면 최신 동기화 했을 가능성이 높은 최신 slave가 master가 된다. 하지만 모든 slave가 동기화를 하기전에 죽으면 메시지는 날아갈 수 밖에없다.

2. 메시지를 client에 전달했지만 client가 전송한 ACK를 받지 못한 상황에서 (client-master구간에서 사라졌거나, master-slave구간에서 사라짐)
ACK를 못받은 메시지는 재전송 할 수밖에 없음

3. master가 변경되었으므로 *x-cancel-on-ha-failover=true* 설정 상황에서는 `basic.cancel`의 cancel notification을 받는다.

4. client는 재전송 때문에 이전 받았던 메시지를 또 받게 되며, client는 재전송이란 것을 인지해야 한다.


publish는 모든 master와 slave에 직접되므로 slave가 master가 되는동안 메시지 유실없이 slave에 잘 쌓인다.
또한 publisher confirm도 별문제없이 동작한다. (HA Queues는 publish과정에서는 특별히 고려할 사항없음)


*noAck=true* 인 경우는 consumer에게 메시지가 날라가는 상황에 broker가 갑자기 죽어버리면 메시자가 유실된다.
*Consumer Cancellation Notification*으로 broker에 이상이 생겼음을 인지 시키도록 하면 유용하며,
반드시 전송이 보장되어야 하는 경우 Ack를 반드시 받도록 *noAck=false*로 설정하는걸 권장한다.




※참고자료
[RabbitMQ공식사이트](https://www.rabbitmq.com)
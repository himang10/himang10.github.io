---
layout: post
title: The obstacles to put Istio into production and how we solve them
date: 2019-01-06
categories: istio
author: himang10
feature-img: "assets/img/pexels/desk-messy.jpeg"
thumbnail: "assets/img/thumbnails/desk-messy.jpeg"
tags: [Test, Lorem]
---
[원본](https://istio.io/docs/concepts/what-is-istio/)


### What is Istio?

Cloud platforms provide a wealth of benefits for the organizations that use them. However, there’s no denying that adopting the cloud can put strains on DevOps teams. Developers must use microservices to architect for portability, meanwhile operators are managing extremely large hybrid and multi-cloud deployments. Istio lets you connect, secure, control, and observe services.

At a high level, Istio helps reduce the complexity of these deployments, and eases the strain on your development teams. It is a completely open source service mesh that layers transparently onto existing distributed applications. It is also a platform, including APIs that let it integrate into any logging platform, or telemetry or policy system. Istio’s diverse feature set lets you successfully, and efficiently, run a distributed microservice architecture, and provides a uniform way to secure, connect, and monitor microservices.

#### What is a service mesh?
Istio addresses the challenges developers and operators face as monolithic applications transition towards a distributed microservice architecture. To see how, it helps to take a more detailed look at Istio’s service mesh.

The term service mesh is used to describe the network of microservices that make up such applications and the interactions between them. As a service mesh grows in size and complexity, it can become harder to understand and manage. Its requirements can include discovery, load balancing, failure recovery, metrics, and monitoring. A service mesh also often has more complex operational requirements, like A/B testing, canary rollouts, rate limiting, access control, and end-to-end authentication.

Istio provides behavioral insights and operational control over the service mesh as a whole, offering a complete solution to satisfy the diverse requirements of microservice applications.

#### Why use Istio?
Istio makes it easy to create a network of deployed services with load balancing, service-to-service authentication, monitoring, and more, with few or no code changes in service code. You add Istio support to services by deploying a special sidecar proxy throughout your environment that intercepts all network communication between microservices, then configure and manage Istio using its control plane functionality, which includes:

Automatic load balancing for HTTP, gRPC, WebSocket, and TCP traffic.

Fine-grained control of traffic behavior with rich routing rules, retries, failovers, and fault injection.

A pluggable policy layer and configuration API supporting access controls, rate limits and quotas.

Automatic metrics, logs, and traces for all traffic within a cluster, including cluster ingress and egress.

Secure service-to-service communication in a cluster with strong identity-based authentication and authorization.

Istio is designed for extensibility and meets diverse deployment needs.

#### Core features
Istio provides a number of key capabilities uniformly across a network of services:

#### Traffic management
Istio’s easy rules configuration and traffic routing lets you control the flow of traffic and API calls between services. Istio simplifies configuration of service-level properties like circuit breakers, timeouts, and retries, and makes it a breeze to set up important tasks like A/B testing, canary rollouts, and staged rollouts with percentage-based traffic splits.

With better visibility into your traffic, and out-of-box failure recovery features, you can catch issues before they cause problems, making calls more reliable, and your network more robust – no matter what conditions you face.

#### Security
Istio’s security capabilities free developers to focus on security at the application level. Istio provides the underlying secure communication channel, and manages authentication, authorization, and encryption of service communication at scale. With Istio, service communications are secured by default, letting you enforce policies consistently across diverse protocols and runtimes – all with little or no application changes.

While Istio is platform independent, using it with Kubernetes (or infrastructure) network policies, the benefits are even greater, including the ability to secure pod-to-pod or service-to-service communication at the network and application layers.

#### Observability
Istio’s robust tracing, monitoring, and logging features give you deep insights into your service mesh deployment. Gain a real understanding of how service performance impacts things upstream and downstream with Istio’s monitoring features, while its custom dashboards provide visibility into the performance of all your services and let you see how that performance is affecting your other processes.

Istio’s Mixer component is responsible for policy controls and telemetry collection. It provides backend abstraction and intermediation, insulating the rest of Istio from the implementation details of individual infrastructure backends, and giving operators fine-grained control over all interactions between the mesh and infrastructure backends.

All these features let you more effectively set, monitor, and enforce SLOs on services. Of course, the bottom line is that you can detect and fix issues quickly and efficiently.

#### Platform support
Istio is platform-independent and designed to run in a variety of environments, including those spanning Cloud, on-premise, Kubernetes, Mesos, and more. You can deploy Istio on Kubernetes, or on Nomad with Consul. Istio currently supports:

* Service deployment on Kubernetes

* Services registered with Consul

* Services running on individual virtual machines

#### Integration and customization
The policy enforcement component of Istio can be extended and customized to integrate with existing solutions for ACLs, logging, monitoring, quotas, auditing, and more.

#### Architecture
An Istio service mesh is logically split into a data plane and a control plane.

* The data plane is composed of a set of intelligent proxies (Envoy) deployed as sidecars. These proxies mediate and control all network communication between microservices along with Mixer, a general-purpose policy and telemetry hub.

* The control plane manages and configures the proxies to route traffic. Additionally, the control plane configures Mixers to enforce policies and collect telemetry.

The following diagram shows the different components that make up each plane:


<img src="https://istio.io/docs/concepts/what-is-istio/arch.svg" width="600">

### Envoy
Istio uses an extended version of the Envoy proxy. Envoy is a high-performance proxy developed in C++ to mediate all inbound and outbound traffic for all services in the service mesh. Istio leverages Envoy’s many built-in features, for example:

* Dynamic service discovery
* Load balancing
* TLS termination
* HTTP/2 and gRPC proxies
* Circuit breakers
* Health checks
* Staged rollouts with %-based traffic split
* Fault injection
* Rich metrics

Envoy is deployed as a sidecar to the relevant service in the same Kubernetes pod. This deployment allows Istio to extract a wealth of signals about traffic behavior as attributes. Istio can, in turn, use these attributes in Mixer to enforce policy decisions, and send them to monitoring systems to provide information about the behavior of the entire mesh.

The sidecar proxy model also allows you to add Istio capabilities to an existing deployment with no need to rearchitect or rewrite code. You can read more about why we chose this approach in our Design Goals.

#### Mixer
Mixer is a platform-independent component. Mixer enforces access control and usage policies across the service mesh, and collects telemetry data from the Envoy proxy and other services. The proxy extracts request level attributes, and sends them to Mixer for evaluation. You can find more information on this attribute extraction and policy evaluation in our Mixer Configuration documentation.

Mixer includes a flexible plugin model. This model enables Istio to interface with a variety of host environments and infrastructure backends. Thus, Istio abstracts the Envoy proxy and Istio-managed services from these details.

#### Pilot
Pilot provides service discovery for the Envoy sidecars, traffic management capabilities for intelligent routing (e.g., A/B tests, canary rollouts, etc.), and resiliency (timeouts, retries, circuit breakers, etc.).

Pilot converts high level routing rules that control traffic behavior into Envoy-specific configurations, and propagates them to the sidecars at runtime. Pilot abstracts platform-specific service discovery mechanisms and synthesizes them into a standard format that any sidecar conforming with the Envoy data plane APIs can consume. This loose coupling allows Istio to run on multiple environments such as Kubernetes, Consul, or Nomad, while maintaining the same operator interface for traffic management.

#### Citadel
Citadel enables strong service-to-service and end-user authentication with built-in identity and credential management. You can use Citadel to upgrade unencrypted traffic in the service mesh. Using Citadel, operators can enforce policies based on service identity rather than on relatively unstable layer 3 or layer 4 network identifiers. Starting from release 0.5, you can use Istio’s authorization feature to control who can access your services.

#### Galley
Galley is Istio’s configuration validation, ingestion, processing and distribution component. It is responsible for insulating the rest of the Istio components from the details of obtaining user configuration from the underlying platform (e.g. Kubernetes).

### Design Goals
A few key design goals informed Istio’s architecture. These goals are essential to making the system capable of dealing with services at scale and with high performance.

*  **Maximize Transparency**: To adopt Istio, an operator or developer is required to do the minimum amount of work possible to get real value from the system. To this end, Istio can automatically inject itself into all the network paths between services. Istio uses sidecar proxies to capture traffic and, where possible, automatically program the networking layer to route traffic through those proxies without any changes to the deployed application code. In Kubernetes, the proxies are injected into pods and traffic is captured by programming iptables rules. Once the sidecar proxies are injected and traffic routing is programmed, Istio can mediate all traffic. This principle also applies to performance. When applying Istio to a deployment, operators see a minimal increase in resource costs for the functionality being provided. Components and APIs must all be designed with performance and scale in mind.

* **Extensibility**: As operators and developers become more dependent on the functionality that Istio provides, the system must grow with their needs. While we continue to add new features, the greatest need is the ability to extend the policy system, to integrate with other sources of policy and control, and to propagate signals about mesh behavior to other systems for analysis. The policy runtime supports a standard extension mechanism for plugging in other services. In addition, it allows for the extension of its vocabulary to allow policies to be enforced based on new signals that the mesh produces.

* **Portability**: The ecosystem in which Istio is used varies along many dimensions. Istio must run on any cloud or on-premises environment with minimal effort. The task of porting Istio-based services to new environments must be trivial. Using Istio, you are able to operate a single service deployed into multiple environments. For example, you can deploy on multiple clouds for redundancy.

* **Policy Uniformity**: The application of policy to API calls between services provides a great deal of control over mesh behavior. However, it can be equally important to apply policies to resources which are not necessarily expressed at the API level. For example, applying a quota to the amount of CPU consumed by an ML training task is more useful than applying a quota to the call which initiated the work. To this end, Istio maintains the policy system as a distinct service with its own API rather than the policy system being baked into the proxy sidecar, allowing services to directly integrate with it as needed

### Traffic Management


This page provides an overview of how traffic management works in Istio, including the benefits of its traffic management principles. It assumes that you’ve already read What is Istio? and are familiar with Istio’s high-level architecture.

Using Istio’s traffic management model essentially decouples traffic flow and infrastructure scaling, letting you specify via Pilot what rules they want traffic to follow rather than which specific pods/VMs should receive traffic - Pilot and intelligent Envoy proxies look after the rest. For example, you can specify via Pilot that you want 5% of traffic for a particular service to go to a canary version irrespective of the size of the canary deployment, or send traffic to a particular version depending on the content of the request.

<img src="https://istio.io/docs/concepts/traffic-management/TrafficManagementOverview.svg" width="600">

### Pilot and Envoy
The core component used for traffic management in Istio is Pilot, which manages and configures all the Envoy proxy instances deployed in a particular Istio service mesh. Pilot lets you specify which rules you want to use to route traffic between Envoy proxies and configure failure recovery features such as timeouts, retries, and circuit breakers. It also maintains a canonical model of all the services in the mesh and uses this model to let Envoy instances know about the other Envoy instances in the mesh via its discovery service.

Each Envoy instance maintains [load balancing information](https://istio.io/docs/concepts/traffic-management/#discovery-and-load-balancing) based on the information it gets from Pilot and periodic health-checks of other instances in its load balancing pool, allowing it to intelligently distribute traffic between destination instances while following its specified routing rules.

Pilot is responsible for the lifecycle of Envoy instances deployed across the Istio service mesh.

<img src="https://istio.io/docs/concepts/traffic-management/PilotAdapters.svg" width="600">

As shown in the figure above, Pilot maintains a canonical representation of services in the mesh that is independent of the underlying platform. Platform-specific adapters in Pilot are responsible for populating this canonical model appropriately. For example, the Kubernetes adapter in Pilot implements the necessary controllers to watch the Kubernetes API server for changes to the pod registration information, ingress resources, and third-party resources that store traffic management rules. This data is translated into the canonical representation. An Envoy-specific configuration is then generated based on the canonical representation.

Pilot enables service discovery, dynamic updates to load balancing pools and routing tables.

You can specify high-level traffic management rules through [Pilot’s Rule configuration](https://istio.io/docs/reference/config/networking/). These rules are translated into low-level configurations and distributed to Envoy instances.

### Request routing
As described above, the canonical representation of services in a mesh is maintained by Pilot. The Istio model of a service is independent of how it is represented in the underlying platform (Kubernetes, Mesos, Cloud Foundry, etc.). Platform-specific adapters are responsible for populating the internal model representation with various fields from the metadata found in the platform.

Istio introduces the concept of a service version, which is a finer-grained way to subdivide service instances by versions (v1, v2) or environment (staging, prod). These variants are not necessarily different API versions: they could be iterative changes to the same service, deployed in different environments (prod, staging, dev, etc.). Common scenarios where this is used include A/B testing or canary rollouts. Istio’s [traffic routing rules](https://istio.io/docs/concepts/traffic-management/#rule-configuration) can refer to service versions to provide additional control over traffic between services.

#### Communication between services

<img src="https://istio.io/docs/concepts/traffic-management/ServiceModel_Versions.svg" width="600">

As shown in the figure above, clients of a service have no knowledge of different versions of the service. They can continue to access the services using the hostname/IP address of the service. The Envoy sidecar/proxy intercepts and forwards all requests/responses between the client and the service.

Envoy determines its actual choice of service version dynamically based on the routing rules that you specify by using Pilot. This model enables the application code to decouple itself from the evolution of its dependent services, while providing other benefits as well (see Mixer). Routing rules allow Envoy to select a version based on conditions such as headers, tags associated with source/destination, and/or by weights assigned to each version.

Istio also provides load balancing for traffic to multiple instances of the same service version. See Discovery and Load Balancing for more.

Istio does not provide a DNS. Applications can try to resolve the FQDN using the DNS service present in the underlying platform (kube-dns, mesos-dns, etc.).

#### Ingress and egress
Istio assumes that all traffic entering and leaving the service mesh transits through Envoy proxies. By deploying an Envoy proxy in front of services, you can conduct A/B testing, deploy canary services, etc. for user-facing services. Similarly, by routing traffic to external web services (for instance, accessing a maps API or a video service API) via the Envoy sidecar, you can add failure recovery features such as timeouts, retries, and circuit breakers and obtain detailed metrics on the connections to these services.

<img src="https://istio.io/docs/concepts/traffic-management/ServiceModel_RequestFlow.svg" width="600">

### Discovery and load balancing
Istio load balances traffic across instances of a service in a service mesh.

Istio assumes the presence of a service registry to keep track of the pods/VMs of a service in the application. It also assumes that new instances of a service are automatically registered with the service registry and unhealthy instances are automatically removed. Platforms such as Kubernetes and Mesos already provide such functionality for container-based applications, and many solutions exist for VM-based applications.

Pilot consumes information from the service registry and provides a platform-independent service discovery interface. Envoy instances in the mesh perform service discovery and dynamically update their load balancing pools accordingly.

<img src="https://istio.io/docs/concepts/traffic-management/LoadBalancing.svg" width="600">

As shown in the figure above, services in the mesh access each other using their DNS names. All HTTP traffic bound to a service is automatically re-routed through Envoy. Envoy distributes the traffic across instances in the load balancing pool. While Envoy supports several [sophisticated load balancing algorithms](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/load_balancing/load_balancing), Istio currently allows three load balancing modes: round robin, random, and weighted least request.

In addition to load balancing, Envoy periodically checks the health of each instance in the pool. Envoy follows a circuit breaker pattern to classify instances as unhealthy or healthy based on their failure rates for the health check API call. In other words, when the number of health check failures for a given instance exceeds a pre-specified threshold, it will be ejected from the load balancing pool. Similarly, when the number of health checks that pass exceed a pre-specified threshold, the instance will be added back into the load balancing pool. You can find out more about Envoy’s failure-handling features in Handling Failures.

Services can actively shed load by responding with an HTTP 503 to a health check. In such an event, the service instance will be immediately removed from the caller’s load balancing pool.

#### Locality Load Balancing
A locality defines a geographic location within your mesh using the following triplet:

* Region
* Zone
* Sub-zone

The geographic location typically represents a data center. Istio uses this information to prioritize load balancing pools to control the geographic location where requests are proxied.

For more information and instructions on how to enable this feature see the operations guide.

### Handling failures
Envoy provides a set of out-of-the-box opt-in failure recovery features that can be taken advantage of by the services in an application. Features include:

1. Timeouts

2. Bounded retries with timeout budgets and variable jitter between retries

3. Limits on number of concurrent connections and requests to upstream services

4. Active (periodic) health checks on each member of the load balancing pool

5. Fine-grained circuit breakers (passive health checks) – applied per instance in the load balancing pool

These features can be dynamically configured at runtime through Istio’s [traffic management rules](https://istio.io/docs/concepts/traffic-management/#rule-configuration).

The jitter between retries minimizes the impact of retries on an overloaded upstream service, while timeout budgets ensure that the calling service gets a response (success/failure) within a predictable time frame.

A combination of active and passive health checks (4 and 5 above) minimize the chances of accessing an unhealthy instance in the load balancing pool. When combined with platform-level health checks (such as those supported by Kubernetes or Mesos), applications can ensure that unhealthy pods/containers/VMs can be quickly ejected from the service mesh, minimizing the request failures and impact on latency.

Together, these features enable the service mesh to tolerate failing nodes and prevent localized failures from cascading instability to other nodes.

#### Fine tuning
Istio’s traffic management rules allow you to set defaults for failure recovery per service and version that apply to all callers. However, consumers of a service can also override timeout and retry defaults by providing request-level overrides through special HTTP headers. With the Envoy proxy implementation, the headers are x-envoy-upstream-rq-timeout-ms and x-envoy-max-retries, respectively.

#### Failure handling FAQ
Q: Do applications still handle failures when running in Istio?

Yes. Istio improves the reliability and availability of services in the mesh. However, applications need to handle the failure (errors) and take appropriate fallback actions. For example, when all instances in a load balancing pool have failed, Envoy will return HTTP 503. It is the responsibility of the application to implement any fallback logic that is needed to handle the HTTP 503 error code from an upstream service.

Q: Will Envoy’s failure recovery features break applications that already use fault tolerance libraries (for example Hystrix)?

No. Envoy is completely transparent to the application. A failure response returned by Envoy would not be distinguishable from a failure response returned by the upstream service to which the call was made.

Q: How will failures be handled when using application-level libraries and Envoy at the same time?

Given two failure recovery policies for the same destination service, the more restrictive of the two will be triggered when failures occur. For example, you have two timeouts – one set in Envoy and another in an application’s library. In this example, if the application sets a 5 second timeout for an API call to a service, while you configured a 10 second timeout in Envoy, the application’s timeout will kick in first. Similarly, if Envoy’s circuit breaker triggers before the application’s circuit breaker, API calls to the service will get a 503 from Envoy.

### Fault injection
While the Envoy sidecar/proxy provides a host of failure recovery mechanisms to services running on Istio, it is still imperative to test the end-to-end failure recovery capability of the application as a whole. Misconfigured failure recovery policies (for example, incompatible/restrictive timeouts across service calls) could result in continued unavailability of critical services in the application, resulting in poor user experience.

Istio enables protocol-specific fault injection into the network, instead of deleting pods or delaying or corrupting packets at the TCP layer. The rationale is that the failures observed by the application layer are the same regardless of network level failures, and that more meaningful failures can be injected at the application layer (for example, HTTP error codes) to exercise the resilience of an application.

You can configure faults to be injected into requests that match specific conditions. You can further restrict the percentage of requests that should be subjected to faults. Two types of faults can be injected: delays and aborts. Delays are timing failures, mimicking increased network latency, or an overloaded upstream service. Aborts are crash failures that mimic failures in upstream services. Aborts usually manifest in the form of HTTP error codes or TCP connection failures.

### Canary rollout
The idea behind canary rollout is to introduce a new version of a service by first testing it using a small percentage of user traffic and then, if all goes well, gradually increase the percentage until all the traffic is moved to the new version. If anything goes wrong along the way, the rollout is aborted and the traffic is returned to the old version.

Although container orchestration platforms like Docker, Mesos/Marathon, or Kubernetes provide features that support canary rollout, they are limited by the fact that they use instance scaling to manage the traffic distribution. For example, to send 10% of traffic to a canary version requires 9 instances of the old version to be running for every 1 instance of the canary. This becomes particularly difficult in production deployments where autoscaling is needed. When traffic load increases, the autoscaler needs to scale instances of both versions concurrently, making sure to keep the instance ratio the same.

Another problem with the instance deployment approach is that it only supports a simple (random percentage) canary rollout. It’s not possible to limit the visibility of the canary to requests based on some specific criteria.

With Istio, traffic routing and instance deployment are two completely independent functions. The number of instances implementing services are free to scale up and down based on traffic load, completely orthogonal to the control of version traffic routing. This makes managing a canary version in the presence of autoscaling a much simpler problem. See Canary Deployments using Istio for more about the interoperability of canary deployment and autoscaling when using Istio.

### Rule configuration
Istio provides a simple configuration model to control how API calls and layer-4 traffic flow across various services in an application deployment. The configuration model allows you to configure service-level properties such as circuit breakers, timeouts, and retries, as well as set up common continuous deployment tasks such as canary rollouts, A/B testing, staged rollouts with %-based traffic splits, etc.

There are five traffic management configuration resources in Istio: VirtualService, DestinationRule, ServiceEntry, Gateway, and Sidecar:

* A VirtualService defines the rules that control how requests for a service are routed within an Istio service mesh.

* A DestinationRule configures the set of policies to be applied to a request after VirtualService routing has occurred.

* A ServiceEntry is commonly used to enable requests to services outside of an Istio service mesh.

* A Gateway configures a load balancer operating at the edge of the mesh for HTTP/TCP ingress traffic to a mesh application or egress traffic to external services.

* A Sidecar configures one or more sidecar proxies attached to application workloads running inside the mesh.

For example, you can implement a simple rule to send 100% of incoming traffic for a reviews service to version “v1” by using a VirtualService configuration as follows:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
````

This configuration says that traffic sent to the reviews service (specified in the hosts field) should be routed to the v1 subset of the underlying reviews service instances. The route subset specifies the name of a defined subset in a corresponding destination rule configuration.

A subset specifies one or more labels that identify version-specific instances. For example, in a Kubernetes deployment of Istio, “version: v1” indicates that only pods containing the label “version: v1” will receive traffic.

In a DestinationRule, you can then add additional policies. For example, the following definition specifies to use the random load balancing mode:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
````

Rules can be configured using the kubectl command. See the configuring request routing task for examples.

The following sections provide a basic overview of the traffic management configuration resources. See networking reference for detailed information.

#### Virtual Services
A VirtualService defines the rules that control how requests for a service are routed within an Istio service mesh. For example, a virtual service could route requests to different versions of a service or to a completely different service than was requested. Requests can be routed based on the request source and destination, HTTP paths and header fields, and weights associated with individual service versions.

#### Rule destinations
Routing rules correspond to one or more request destination hosts that are specified in a VirtualService configuration. These hosts may or may not be the same as the actual destination workload and may not even correspond to an actual routable service in the mesh. For example, to define routing rules for requests to the reviews service using its internal mesh name reviews or via host bookinfo.com, a VirtualService could set the hosts field as:

```yaml
hosts:
  - reviews
  - bookinfo.com
````

The hosts field specifies, implicitly or explicitly, one or more fully qualified domain names (FQDN). The short name reviews, above, would implicitly expand to an implementation specific FQDN. For example, in a Kubernetes environment the full name is derived from the cluster and namespace of the VirtualService (for example, reviews.default.svc.cluster.local).

#### Splitting traffic between versions
Each route rule identifies one or more weighted backends to call when the rule is activated. Each backend corresponds to a specific version of the destination service, where versions can be expressed using labels. If there are multiple registered instances with the specified label(s), they will be routed to based on the load balancing policy configured for the service, or round-robin by default.

For example, the following rule will route 25% of traffic for the reviews service to instances with the “v2” label and the remaining 75% of traffic to “v1”:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 75
    - destination:
        host: reviews
        subset: v2
      weight: 25
````

#### Timeouts and retries
By default, the timeout for HTTP requests is 15 seconds, but it can be overridden in a route rule as follows:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
    - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
    timeout: 10s
````

You can also specify the number of retry attempts for an HTTP request in a virtual service. The maximum number of retry attempts, or the number of attempts possible within the default or overridden timeout period, can be set as follows:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
    - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
    retries:
      attempts: 3
      perTryTimeout: 2s
````

Note that request timeouts and retries can also be overridden on a per-request basis.

See the request timeouts task for an example of timeout control.

#### Injecting faults
A virtual service can specify one or more faults to inject while forwarding HTTP requests to the rule’s corresponding request destination. The faults can be either delays or aborts.

The following example introduces a 5 second delay in 10% of the requests to the “v1” version of the ratings microservice:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        percent: 10
        fixedDelay: 5s
    route:
    - destination:
        host: ratings
        subset: v1
````

You can use the other kind of fault, an abort, to prematurely terminate a request. For example, to simulate a failure.

The following example returns an HTTP 400 error code for 10% of the requests to the ratings service “v1”:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - fault:
      abort:
        percent: 10
        httpStatus: 400
    route:
    - destination:
        host: ratings
        subset: v1
````

Sometimes delay and abort faults are used together. For example, the following rule delays by 5 seconds all requests from the reviews service “v2” to the ratings service “v1” and then aborts 10% of them:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - match:
    - sourceLabels:
        app: reviews
        version: v2
    fault:
      delay:
        fixedDelay: 5s
      abort:
        percent: 10
        httpStatus: 400
    route:
    - destination:
        host: ratings
        subset: v1
````

To see fault injection in action, see the fault injection task.

#### Conditional rules
Rules can optionally be qualified to only apply to requests that match some specific condition such as the following:

1. Restrict to specific client workloads using workload labels. For example, a rule can indicate that it only applies to calls from workload instances (pods) implementing the reviews service:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - match:
    - sourceLabels:
        app: reviews
    route:
    ...
````

The value of sourceLabels depends on the implementation of the service. In Kubernetes, for example, it would probably be the same labels that are used in the pod selector of the corresponding Kubernetes service.

The above example can also be further refined to only apply to calls from a workload instance having the “v2” label:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - match:
    - sourceLabels:
        app: reviews
        version: v2
    route:
    ...
````

2. Select rule based on HTTP headers. For example, the following rule only applies to an incoming request if it includes a custom “end-user” header that contains the string “jason”:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    ...
````

If more than one header is specified in the rule, then all of the corresponding headers must match for the rule to apply.

3. Select rule based on request URI. For example, the following rule only applies to a request if the URI path starts with /api/v1:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: productpage
spec:
  hosts:
    - productpage
  http:
  - match:
    - uri:
        prefix: /api/v1
    route:
    ...
````

#### Multiple match conditions
Multiple match conditions can be set simultaneously. In such a case, AND or OR semantics apply, depending on the nesting.

If multiple conditions are nested in a single match clause, then the conditions are ANDed. For example, the following rule only applies if the client workload is “reviews:v2” AND the custom “end-user” header containing “jason” is present in the request:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - match:
    - sourceLabels:
        app: reviews
        version: v2
      headers:
        end-user:
          exact: jason
    route:
    ...
````

If instead, the condition appear in separate match clauses, then only one of the conditions applies (OR semantics):

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - match:
    - sourceLabels:
        app: reviews
        version: v2
    - headers:
        end-user:
          exact: jason
    route:
    ...
````

This rule applies if either the client workload is “reviews:v2” OR the custom “end-user” header containing “jason” is present in the request.

#### Precedence
When there are multiple rules for a given destination, they are evaluated in the order they appear in the VirtualService, meaning the first rule in the list has the highest priority.

Why is priority important? Whenever the routing story for a particular service is purely weight based, it can be specified in a single rule. On the other hand, when other conditions (such as requests from a specific user) are being used to route traffic, more than one rule will be needed to specify the routing. This is where the rule priority must be carefully considered to make sure that the rules are evaluated in the right order.

A common pattern for generalized route specification is to provide one or more higher priority rules that match various conditions, and then provide a single weight-based rule with no match condition last to provide the weighted distribution of traffic for all other cases.

For example, the following VirtualService contains two rules that, together, specify that all requests for the reviews service that includes a header named “Foo” with the value “bar” will be sent to the “v2” instances. All remaining requests will be sent to “v1”:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        Foo:
          exact: bar
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
````

Notice that the header-based rule has the higher priority. If it was lower, these rules wouldn’t work as expected because the weight-based rule, with no specific match condition, would be evaluated first to route all traffic to “v1”, even requests that include the matching “Foo” header. Once a rule is found that applies to the incoming request, it is executed and the rule-evaluation process terminates. That’s why it’s very important to carefully consider the priorities of each rule when there is more than one.

#### Destination rules
A DestinationRule configures the set of policies to be applied to a request after VirtualService routing has occurred. They are intended to be authored by service owners, describing the circuit breakers, load balancer settings, TLS settings, and other settings.

A DestinationRule also defines addressable subsets, meaning named versions, of the corresponding destination host. These subsets are used in VirtualService route specifications when sending traffic to specific versions of the service.

The following DestinationRule configures policies and subsets for the reviews service:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
  - name: v3
    labels:
      version: v3
````

Notice that multiple policies, default and v2-specific in this example, can be specified in a single DestinationRule configuration.

#### Circuit breakers
A simple circuit breaker can be set based on a number of conditions such as connection and request limits.

For example, the following DestinationRule sets a limit of 100 connections to reviews service version “v1” backends:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
    trafficPolicy:
      connectionPool:
        tcp:
          maxConnections: 100
````

See the circuit-breaking task for a demonstration of circuit breaker control.

#### Rule evaluation
Similar to route rules, policies defined in a DestinationRule are associated with a particular host. However if they are subset specific, activation depends on route rule evaluation results.

The first step in the rule evaluation process evaluates the route rules in the VirtualService corresponding to the requested host, if there are any, to determine the subset (meaning specific version) of the destination service that the current request will be routed to. Next, the set of policies corresponding to the selected subset, if any, are evaluated to determine if they apply.

> One subtlety of the algorithm to keep in mind is that policies that are defined for specific subsets will only be applied if the corresponding subset is explicitly routed to. For example, consider the following configuration as the one and only rule defined for the reviews service, meaning there are no route rules in the corresponding VirtualService definition:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
    trafficPolicy:
      connectionPool:
        tcp:
          maxConnections: 100
```

Since there is no specific route rule defined for the reviews service, default round-robin routing behavior will apply, which will presumably call “v1” instances on occasion, maybe even always if “v1” is the only running version. Nevertheless, the above policy will never be invoked since the default routing is done at a lower level. The rule evaluation engine will be unaware of the final destination and therefore unable to match the subset policy to the request.

You can fix the above example in one of two ways. You can either move the traffic policy up a level in the DestinationRule to make it apply to any version:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
  subsets:
  - name: v1
    labels:
      version: v1
````

Or, better yet, define proper route rules for the service in the VirtualService definition. For example, add a simple route rule for “reviews:v1”:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
````

Although the default Istio behavior conveniently sends traffic from any source to all versions of a destination service without any rules being set, as soon as version discrimination is desired rules are going to be needed. Therefore, setting a default rule for every service, right from the start, is generally considered a best practice in Istio.

#### Service entries
A ServiceEntry is used to add additional entries into the service registry that Istio maintains internally. It is most commonly used to enable requests to services outside of an Istio service mesh. For example, the following ServiceEntry can be used to allow external calls to services hosted under the *.foo.com domain:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: foo-ext-svc
spec:
  hosts:
  - *.foo.com
  ports:
  - number: 80
    name: http
    protocol: HTTP
  - number: 443
    name: https
    protocol: HTTPS
````

The destination of a ServiceEntry is specified using the hosts field, which can be either a fully qualified or wildcard domain name. It represents a white listed set of one or more services that services in the mesh are allowed to access.

A ServiceEntry is not limited to external service configuration. It can be of two types: mesh-internal or mesh-external. Mesh-internal entries are like all other internal services but are used to explicitly add services to the mesh. They can be used to add services as part of expanding the service mesh to include unmanaged infrastructure (for example, VMs added to a Kubernetes-based service mesh). Mesh-external entries represent services external to the mesh. For them, mutual TLS authentication is disabled and policy enforcement is performed on the client-side, instead of on the server-side as it is for internal service requests.

Service entries work well in conjunction with virtual services and destination rules as long as they refer to the services using matching hosts. For example, the following rule can be used in conjunction with the above ServiceEntry rule to set a 10s timeout for calls to the external service at bar.foo.com:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bar-foo-ext-svc
spec:
  hosts:
    - bar.foo.com
  http:
  - route:
    - destination:
        host: bar.foo.com
    timeout: 10s
````

Rules to redirect and forward traffic, to define retry, timeout, and fault injection policies are all supported for external destinations. Weighted (version-based) routing is not possible, however, since there is no notion of multiple versions of an external service.

See the egress task for a more about accessing external services.

#### Gateways
A Gateway configures a load balancer for HTTP/TCP traffic operating at the edge of the mesh, most commonly to enable ingress traffic for an application.

Unlike Kubernetes Ingress, Istio Gateway only configures the L4-L6 functions (for example, ports to expose, TLS configuration). Users can then use standard Istio rules to control HTTP requests as well as TCP traffic entering a Gateway by binding a VirtualService to it.

For example, the following simple Gateway configures a load balancer to allow external HTTPS traffic for host bookinfo.com into the mesh:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - bookinfo.com
    tls:
      mode: SIMPLE
      serverCertificate: /tmp/tls.crt
      privateKey: /tmp/tls.key
````

To configure the corresponding routes, you must define a VirtualService for the same host and bound to the Gateway using the gateways field in the configuration:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
    - bookinfo.com
  gateways:
  - bookinfo-gateway # <---- bind to gateway
  http:
  - match:
    - uri:
        prefix: /reviews
    route:
    ...
````

See the [ingress task](https://istio.io/docs/tasks/traffic-management/ingress/) for a complete ingress gateway example.

Although most often used to manage ingress traffic, a Gateway can also be used to model an egress proxy. Irrespective of the location, all gateways can be configured and controlled in the same way. See gateway reference for details.

#### Sidecars
By default, Istio configures every sidecar proxy to accept traffic on all the ports of its associated workload and to reach every workload in the mesh when forwarding traffic. A Sidecar configuration can be used to fine tune the set of ports and protocols that a proxy will accept and to limit the set of services that the proxy can reach.

A Sidecar resource can be used to configure one or more sidecar proxies selected using workload labels, or to configure all sidecars in a particular namespace. For example, the following Sidecar configures all services in the bookinfo namespace to only reach services running in the same namespace:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Sidecar
metadata:
  name: default
  namespace: bookinfo
spec:
  egress:
  - hosts:
    - "./*"
````

Limiting sidecar reachability this way can be used to significantly reduce memory usage, which by default can become a major problem for large applications where every sidecar is provided with the configuration necessary to reach every other service in the mesh.

A Sidecar resource can also be used in many more ways. Refer to the sidecar reference for details.



[참고](https://zhaohuabing.com/post/2018-12-27-the-obstacles-to-put-istio-into-production/)
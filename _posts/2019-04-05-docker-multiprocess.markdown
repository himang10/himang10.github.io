---
layout: post
title: Run Multiple Processes in a Conatiner
date: 2019-04-05
categories: docker
author: himang10
tags: [docker, multiprocess]
---

# Table of Contents
1. [xxx](#xxx)
2. [xxx](#xxx)
3. [xxx](#xxx)

[원보-Run Multiple Processes in a Conatiner](https://runnable.com/docker/rails/run-multiple-processes-in-a-container)

## Run Multiple Processes in a Container
Most web applications consist of more than just a set of MVC components. They include rake tasks, may rely on system services like cron and syslog, and often require persistent worker processes. Lack of appropriate functionality in standard single-process Docker containers is a common source of confusion.

This article describes ways to run additional services and workers that are compatible with the recommended single-process-per-container architecture. Using a customized Docker image to bring multiprocessing back into the game is discussed as an alternative.

### Architecture concerns
Implementing the UNIX philosophy “do one thing well,” Docker runs one process per container by default. Consequently, most base images lack support for standard system services and do not provide a standard way to run several commands simultaneously.

Although running multiple processes in a container is technically possible, a single-process architecture has significant advantages:

1. *Containers without moving parts do not have a complex internal state*. This allows effective container orchestration and automation of infrastructure tasks such as horizontal scaling, dynamic upgrades, and disaster recovery.

2. Without internal complexity, complicated, time-consuming startup scripts are unnecessary. The initial state of the container can be prepared during the image build and fine-tuned by container launch parameters, which minimizes startup time.

3. The lifecycles of different logical components (services and workers) can be most appropriately managed when components are isolated in their own containers.
So, refactoring application architecture (placing appropriate components into separate containers) is recommended whenever the application needs to run an additional process or use a system daemon.

Let’s go through various use cases, from system services to background workers, and consider the available options.

### Services
By default, the Rails server in an application container runs as a foreground process that is directly controlled by Docker.

Running additional daemons inside a container is a bit tricky. A fully powered Linux environment typically includes an ​init​ process that spawns and supervises other processes, such as system daemons. The command defined in the CMD instruction of the Dockerfile is the only process launched inside the Docker container, so ​system daemons do not start automatically, even if properly installed.

There are several solutions to this problem:

1. Update CMD to run a custom script that explicitly launches necessary services before running an application. This may seem like the simplest option, but the script should track the status of launched services, re-run them after failures, and ensure a graceful shutdown when the container terminates. Proper implementation requires familiarity with Linux process management and is effectively a sub-optimal custom replication of existing system supervisors.

2. Update CMD to run a system supervisor and configure the application as a service. The​ first thing that comes to mind is ​upstart, but it will not work properly because /sbin/init is customized by Docker. There are alternative Docker­-compatible supervisors, such as runit​, which is used in a family of phusion ​base images​ designed for multi­processing. Example usage of such an image is considered later in this article.

3. Refactor application architecture, eliminating the need for some services and separating the rest into their own containers.
The third approach requires a shift in thinking as well as higher-­level container orchestration with ​docker-­compose​ or a similar tool. Such refactoring pays off, however, in the form of consistent, ready-­to­-scale architecture that conforms to best practices and utilizes the advantages of Docker.

Below is an overview of the available alternatives for the most commonly used system services.



### SSH security warning
Think twice before running SSHd in a container. The SSH access provided by traditional Linux servers includes various security mechanisms: permissions separation, identity management, authentication logs, and trusted host keys. In ephemeral Docker containers, these features may not exist or work as expected.

Therefore, enabling SSH access to a container exposes it to a powerful method of attack. Appropriate risks should be carefully weighed against the expected benefits.

### Initialization and background tasks
Docker does not impose any explicit restrictions on running initialization and background tasks in the container where the application exists.

However, a few issues should be considered:

* Complicated initialization logic may pose a problem if it significantly delays application startup.​ Docker knows when the container process starts but has no idea when the application will be ready to serve traffic.

* Automatic global operations (like db:migrate) inside application containers may be subject to race conditions in scalable environments.​ For example, if the container is configured to check the state of the database and automatically apply pending migrations before the application starts, all simultaneously launched containers will try to do the same.

* The lifecycles of a worker process and a web application may differ.​ For example, shutting down or replacing a web application container for scaling or upgrade is generally safe. In contrast, interrupting multimedia file encoding or losing the files users have uploaded is unacceptable.

* The cron daemon does not run inside the container by default. Moreover, any kind of persistent scheduler or worker process will be part of the aforementioned problem with daemon management.
The tactics described below bypass these problems without compromising required functionality.

### Initialization
To initialize before Rails starts, a custom bootstrap script must be created and the CMD instruction in the Dockerfile must be updated so that CMD, rather than the Rails server, runs the script.

If the bootstrap script is implemented in bash, the signals the running script receives are not automatically propagated to child processes. Invoked with a shell command, the Rails server will not be able to exit gracefully when SIGTERM is sent to the container. To prevent this situation, the last command in the script should be exec rails server -­b 0.0.0.0. instead of rails server -­b 0.0.0.0.. The Rails server will then run inside the main process instead of being spawned.

### Scheduled tasks
Action	Recommended approach
Sending out logs and health metrics	Instead of buffering data on an internal filesystem, consider pushing each piece of data to external persistent storage as soon as it is available.

The external storage may be a shared filesystem or a message queue.

Performing these operations in a separate thread that utilizes non­-blocking I/O is recommended.
Global tasks (such as recalculation of database aggregates or data imports)	Implement the appropriate logic as a rake task and use an external scheduler to run rake tasks in separate one-­off containers.

Using gems such as clockwork is possible, but the scheduler process should run in its own container.
Instance-­specific tasks (such as re­-fetching data from external sources)	Consider launching new containers instead of updating the state of existing containers.

Options are available for the rare cases in which this solution is unacceptable:
Trigger task execution with external schedulers by sending custom signals to the application container, either through the HTTP API or by invoking rake​ with docker exec.
Implement a scheduler inside the Rails application (using EventMachine​, for example) and initialize it when Rails starts.
Run a scheduler process with multiprocessing support inside the application container.


### Asynchronous background tasks
Common examples of asynchronous background tasks include processing multimedia files and sending emails.

In Rails, these tasks implement a queue­-based workflow and are typically handled by gems like sidekiq​ or delayed_job:

Client code inside an application submits task definitions to a queue in DB-­like storage.
Worker code (running as either as a persistent process or a regularly invoked rake task) picks up and performs tasks from the queue.
This architecture fits into a single-­process-­per­-container pattern relatively well as long as the following conditions are met:

The worker process is running in a separate container.
Both the application and worker containers are configured to use an external database for the tasks queue.
Any additional data (such as uploaded files) is stored on a shared filesystem that is available to all containers.


## Containers with multi­processing support
While single-­process-­per­-container architecture is a powerful and consistent solution, sometimes it makes sense to abandon puristic approaches in the name of project-specific goals.

As mentioned above, a multi­process container should run a custom bootstrap script that is in turn responsible for executing initialization steps and running required services.

We will start with a simple example of a custom bootstrap script, then turn it into a service on a runit­-powered image.

Custom bootstrap script
Let’s create a very simple script that allows arbitrary commands to be executed before application launch. The last command invokes the Rails server in standard fashion.

docker/start.sh (Do not forget to set the file’s executable bit.):

```
#!/bin/sh

# use application directory, regardless of WORKDIR defined by container
cd /usr/src/app

## add custom steps here, such as:
##   fetching secrets from the remote service and exporting them to the environment
##   downloading frequently changing files from the data provider
##   and basically anything else

# exec and the absence of the -d option are important
exec rails server -b 0.0.0.0
````

To run a custom script as the default process, the Dockerfile must be modified slightly:

```
## old CMD instruction is removed
# CMD [ "rails", "server", "-b" , "0.0.0.0" ]

# install start script
COPY docker/start.sh /start.sh
# make the start script a default command -- double-quotes and brackets are important
CMD [ "/start.sh" ]
````

This is sufficient to add custom steps before the application starts.

### Phusion base image
If you need to use system services (such as cron) inside a container or run multiple persistent processes, it makes sense to use a base image that is compatible with multiprocesses. The Docker Hub image phusion/passenger­ruby22 is a good candidate because it includes standard system services and a configurable service supervisor (runit) along with Ruby.

The example Dockerfile installs docker/start.sh (shown in the previous section) as a runit-controlled service:

```
FROM phusion/passenger-­ruby22

RUN mkdir ­-p /usr/src/app
WORKDIR /usr/src/app
EXPOSE 3000


COPY Gemfile /usr/src/app/
RUN bundle install
COPY . /usr/src/app

# install custom bootstrap script as runit service
COPY docker/start.sh /etc/service/myapp/run
````

Note that the instruction from the base image is used because the CMD instruction is not explicitly defined. The container is therefore configured to execute runit​ as a default process and thereby allowed to start and supervise other services.

docker/start.sh is installed as a startup script for the runit service myapp​, so the web application will be launched with other services, such as cron. If you need to run more services (Redis or worker processes, for example), add their startup scripts to the runit configuration with /etc/service/<servicename>/run​. Make sure that the scripts are executable (chmod +x) and that they run services in foreground mode through exec. ​

For more customizations, read ​the image documentation. The runit site describes managing services with runit.

### Summary
Single-­process-­per-­container is a recommended design pattern for Docker applications.
Consider isolating every logical component (daemon, worker, or shared storage) in a separate type of container. Always try to externalize databases, message queues, and schedulers.
Use one-­off containers for one­-off global tasks.
Prioritize rebuilding images and re­-running containers over updating container configuration at run time.
Minimize run-time provisioning to prevent delayed application startup from causing orchestration issues.
Do not expect system daemons to be running in standard Docker containers.
Phusion ​images are the recommended base for necessary multiprocessing support, but enabling SSH access should be avoided.

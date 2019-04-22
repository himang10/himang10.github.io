---
layout: post
title: Introduce Kustomize
date: 2019-04-22
categories: kubernetes
author: himang10

tags: [kubstomize, kubernetes]
---


## Kustomize - The right way to do templating in Kubernetes

We always need to customize our deployment with Kubernetes and, I don’t know why but the main tool around for now is HELM which throws away all the logic we learn on docker and Kubernetes. Here I will introduce to you an alternative called Kustomize ❤️

Kustomize isn’t a new tool, it is under construction since 2017 and has been introduced as a native kubectl sub-command in the version 1.14. Yeah, you’ve heard correctly, this is now embedded directly inside the tool you use everyday… so you will be able to throw that helm command away 😉.

### Philosophy
Kustomize tries to follow the philosophy you are using in your everyday job when using Git as VCS, creating Docker images or declaring your resources inside Kubernetes.

So, first of all, Kustomize is like Kubernetes, it is totally declarative ! You say what you want and the system provides it to you. You don’t have to follow the imperative way and describe how you want it to build the thing.

Secondly, it works like Docker. You have many layers and each of those is modifying the previous ones. Thanks to that, you can constantly write things above others without adding complexity inside your configuration. The result of the build will be the addition of the base and the different layers you applied over it.

Lastly, like Git, you can use a remote base as the start of your work and add some customization on it.

### Installation
Of course, for 🍎 Mac users, you can use brew to install it :
```
$ brew install kustomize
````

If you are on another operating system, you can directly download the binary from the release page and add it to your path.

For the others, you also can build it from source, why not 😅.

### Your base
To start with Kustomize, you need to have your original yaml files describing any resources you want to deploy into your cluster. Those files will be stored for this example in the folder ./k8s/base/.

Those files will NEVER (EVER) be touched, we will just apply customization above them to create new resources definitions

> Note: You can build base templates (e.g. for dev environment) at any point in time using the command kubectl apply -f ./k8s/base/.

In this example, we will work with a service and a deployment resources:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
    - name: http
      port: 8080
  selector:
    app: sl-demo-app
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  selector:
    matchLabels:
      app: sl-demo-app
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - name: app
        image: foo/bar:latest
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
````

We wil add a new file inside this folder, named kustomization.yaml :
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - service.yaml
  - deployment.yaml
````

This file will be the central point of your base and it describes the resources you use. Those resources are the path to the files relatively to the current file.

> Note: This kustomization.yaml file could lead to errors when running kubectl apply -f ./k8s/base/, you can either run it with the parameter --validate=false or simply not running the command against the whole folder

To apply your base template to your cluster, you just have to execute the following command:

```
$ kubectl apply -k k8s/base
````

To see what will be applied in your cluster, we will mainly use in this article the command kustomize build instead of kubectl apply -k.

The result of kustomize build k8s/base command will be the following, which is for now only the two files previously seen, concatenated:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  selector:
    matchLabels:
      app: sl-demo-app
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
````

### Kustomization
Now, we want to kustomize our app for a specific case, for example, for our prod environement. In each step, we will see how to enhance our base with some modification.

The main goal of this article is not to cover the whole set of functionnalities of Kustomize but to be a standard example to show you the phiplosophy behind this tool.

First of all, we will create the folder k8s/overlays/prod with a kustomization.yaml inside it.

The k8s/overlays/prod/kustomization.yaml has the following content:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base
````

If we build it, we will see the same result as before when building the base.

```
$ kustomize build k8s/overlays/prod
````

This will output the following yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  selector:
    matchLabels:
      app: sl-demo-app
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
````

We are now ready to apply kustomization for our prod env

### Define Env variables for our deployment
In our base, we didn’t define any env variable. We will now add those env variables above our base. To do so, it’s very simple, we just have to create the chunk of yaml we would like to apply above our base and referece it inside the kustomization.yaml.

This file custom-env.yaml containing env variables will look like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  template:
    spec:
      containers:
        - name: app # (1)
          env:
            - name: CUSTOM_ENV_VARIABLE
              value: Value defined by Kustomize ❤️
````

> Note: The name (1) key here is very important and allow Kustomize to find the right container which need to be modified.

You can see this yaml file isn’t valid by itself but it describes only the addition we would like to do on our previous base.

We just have to add this file to a specific entry in the k8s/overlays/prod/kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- custom-env.yaml
````

If we build this one, we will have the following result:

```
$ kustomize build k8s/overlays/prod
````

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  selector:
    matchLabels:
      app: sl-demo-app
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - env:
        - name: CUSTOM_ENV_VARIABLE # (1)
          value: Value defined by Kustomize ❤️
        image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
````

You can see our env block has been applied above our base and now the CUSTOM_ENV_VARIABLE (1) will be defined inside our deployment.yaml.

### Change the number of replica
Like in our previous example, we will extend our base to define variables not already defined

> Note: You can also override some variables already present in your base files.

Here, we would like to add information about the number of replica. Like before, a chunk or yaml with just the extra info needed for defining replica will be enought:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
````

And like before, we add it to the list of patchesStrategicMerge in the kustomization.yaml:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- custom-env.yaml
- replica-and-rollout-strategy.yaml
````

The result of the command kustomize build k8s/overlays/prod give us the following result

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: sl-demo-app
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - env:
        - name: CUSTOM_ENV_VARIABLE
          value: Value defined by Kustomize ❤️
        image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
````

And you can see the replica number and rollingUpdate strategy have been applied above our base.

### Use a secret define through command line
One of the things we often do is to set some variables as secret from command-line. In our case, we are doing this directly from our Gitlab-CI on Gitlab.com.

But you can do this from anywhere else, the main purpose here is to define Kubernetes Secret without putting them inside Git 😱.

To do so, kustomize has a sub-command to edit a kustomization.yaml and create a secret for you. You just have to use it in your deployment like if it already exists.

```
$ cd k8s/overlays/prod
$ kustomize edit add secret sl-demo-app --from-literal=my-literal=12345
````

These commands will modify your kustomization.yaml and add a SecretGenerator inside it.

> Note: You can also use secret comming from properties file (with --from-file=file/path) or from env file (with --from-env-file=env/path.env)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- custom-env.yaml
- replica-and-rollout-strategy.yaml

secretGenerator:
- literals:
  - db-password=12345
  name: sl-demo-app
  type: Opaque
If you run the kustomize build k8s/overlays/prod from the root folder of the example project, you will have the following output

apiVersion: v1
data:
  db-password: MTIzNDU=
kind: Secret
metadata:
  name: sl-demo-app-6ft88t2625
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: sl-demo-app
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - env:
        - name: CUSTOM_ENV_VARIABLE
          value: Value defined by Kustomize ❤️
        image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
````

> Note: The secret name is sl-demo-app-6ft88t2625 instead of sl-demo-app, it’s normal and this is made to trigger a rolling update of the deployment if secrets content is changed.

If we want to use this secret from our deployment, we just have, like before, to add a new layer definition which uses the secret.

For example, this file will mount the db-password value as environement variables

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: "DB_PASSWORD"
          valueFrom:
            secretKeyRef:
              name: sl-demo-app
              key: db.password
````

And, like before, we add this to the k8s/overlays/prod/kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- custom-env.yaml
- replica-and-rollout-strategy.yaml
- database-secret.yaml

secretGenerator:
- literals:
  - db-password=12345
  name: sl-demo-app
  type: Opaque
If we build the whole prod files, we now have

apiVersion: v1
data:
  db-password: MTIzNDU=
kind: Secret
metadata:
  name: sl-demo-app-6ft88t2625
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: sl-demo-app
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              key: db.password
              name: sl-demo-app-6ft88t2625 # (1)
        -  name: CUSTOM_ENV_VARIABLE
          value: Value defined by Kustomize ❤️
        image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
````

You can see the secretKeyRef.name used is automatically modified to follow the name defined by Kustomize (1)

> Note: Don’t forget, the command to put the secret inside the kustomization.yaml file should be made only from safe env and should not be commited.

The same logic exists with ConfigMap with hash at the end to allow redeployement of your app if ConfigMap changes.

### Change the image of a deployment
Like for secret, there is a custom directive to allow changing of image or tag directly from the command line. This is very useful if you need to deploy the image previously tagged by your continuous build system.

To do that, you can use the following command:

```
$ cd k8s/overlays/prod
$ TAG_VERSION=3.4.5 # (1)
$ kustomize edit add secret sl-demo-app --from-literal=my-literal=12345 # To create my required secret
$ kustomize edit set image foo/bar=foo/bar:$TAG_VERSION
````

> Note: the TAG_VERSION here is usualy defined by your CI/CD system

The k8s/overlays/prod/kustomization.yaml will be modified with those values:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- custom-env.yaml
- replica-and-rollout-strategy.yaml
- database-secret.yaml

secretGenerator:
- literals:
  - db-password=12345
  name: sl-demo-app
  type: Opaque

images:
- name: foo/bar
  newName: foo/bar
  newTag: 3.4.5
And if we build it, with the kustomize build k8s/overlays/prod/ we have the following result:

apiVersion: v1
data:
  db-password: MTIzNDU=
kind: Secret
metadata:
  name: sl-demo-app-6ft88t2625
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: sl-demo-app
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              key: db.password
              name: sl-demo-app-6ft88t2625
        - name: CUSTOM_ENV_VARIABLE
          value: Value defined by Kustomize ❤️
        image: foo/bar:3.4.5 # (1)
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
````

You see the first container.image of the deployment have been modified to be run with the version 3.4.5 (1).

### Conclusion
We see in these examples how we can leverage the power of Kustomize to define your Kubernetes files without even using a templating system. All the modification files you made will be applied above the original files without altering it with curly braces and imperative modification.

There is a lot of advanced topic in Kustomize, like the mixins and inheritance logic or other directive allowing to define a name, label or namespace to every created object… You can follow the official Kustomize github repository to see advanced examples and documentation.

[원문](https://blog.stack-labs.com/code/kustomize-101/)
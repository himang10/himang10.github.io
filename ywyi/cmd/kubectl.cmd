kubectl cluster-info
kubectl config current-context
kubectl config use-context
kubectl get node --show-labels

#change namespace
kubectl config view | grep current-context
kubectl config set-context <current-context> --namespace=study

# docker exec
kubectl exec -it [pod name] -- bash
kubectl exec -it [pod name] -c [container name] -- bash -il
# example
kubectl exec -it node-js-pod sh

## add context
kubectl config view
kubectl config set-context testk --namespace=testkafka --cluster=k8s.nogada.dev --user=admin
## change current-context
kubectl config use-context testk
kubectl config current-context

kubectl get ns
kubectl get [resources] --namespace=kube-system or --all-namespaces

## pending  status checking method
kubectl --namespace=testkafka describe pod [pod-name]
kubectl describe node <node-name>

kubectl create configmap $map_name --from-file /PATH/filename or /PATH/
kubectl create configmap literal-data --from-literal key1=value1 --from-literal key2=val2
kubectl describe configmaps $name
kubectl get configmaps  $nam [-o yaml]

## 
kubectl create -f ./my-manifest.yaml           # create resource(s)
kubectl create -f ./my1.yaml -f ./my2.yaml     # create from multiple files
kubectl create -f ./dir                        # create resource(s) in all manifest files in dir
kubectl create -f https://git.io/vPieo         # create resource(s) from url
kubectl run nginx --image=nginx                # start a single instance of nginx
kubectl explain pods,svc                       # get the documentation for pod and svc manifests

## delete
kubectl delete -f ./pod.json                                              # Delete a pod using the type and name specified in pod.json
kubectl delete pod,service baz foo                                        # Delete pods and services with same names "baz" and "foo"
kubectl delete pods,services -l name=myLabel                              # Delete pods and services with label name=myLabel
kubectl delete pods,services -l name=myLabel --include-uninitialized      # Delete pods and services, including uninitialized ones, with label name=myLabel
kubectl -n my-ns delete po,svc --all                                      # Delete all pods and services, including uninitialized ones, in namespace my-ns,

## PV & PVC & StorageClass 
kubectl -n testkafka describe pvc
kubectl get storageclass | sc

#kube label view
kubectl get <nodes, pods> --show-labels

#kube info widw
kubectl get <nodes | pods> -o wide

kubectl create configmap game-config-env-file --from-env-file=docs/tasks/configure-pod-container/game-env-file.properties
------ game-env-file.properties
# Env-files contain a list of environment variables.
# These syntax rules apply:
#   Each line in an env file has to be in VAR=VAL format.
#   Lines beginning with # (i.e. comments) are ignored.
#   Blank lines are ignored.
#   There is no special handling of quotation marks (i.e. they will be part of the ConfigMap value)).


cat docs/tasks/configure-pod-container/game-env-file.properties
enemies=aliens
lives=3
allowed="true"

# This comment and the empty line above it are ignored
-----

## env
kubectl -n kube-system  exec tiller-deploy-759cb9df9-jhgvc -- printenv

# service info & DNS infos
kubectl -n kube-system describe svc kubernetes-dashboard
kubectl -n kube-system exec [pod name] -- yaml cmd execution
kubectl -n kube-system exec [pod-name with command flag] -- nslookup hue-reminders

helm init
helm search : search for charts
helm fetch : download a chart to your local directory to view
helm install: upload the chart to kube
helm list: list release of charts
option ----
      --debug                           enable verbose output
      --home string                     location of your Helm config. Overrides $HELM_HOME (default "~/.helm")
      --host string                     address of Tiller. Overrides $HELM_HOST
      --kube-context string             name of the kubeconfig context to use
      --kubeconfig string               absolute path to the kubeconfig file to use
      --tiller-connection-timeout int   the duration (in seconds) Helm will wait to establish a connection to tiller (default 300)
      --tiller-namespace string         namespace of Tiller (default "kube-system"

helm delete <release name>
if Error: a release named cp-helm-charts already exists.
 - helm ls --all cp-helm-charts; to check the status of the release
 - helm del --purge cp-helm-charts; to delete it

repository registring

helm repo add [repo_name] [url | chart name]
helm repo list
helm dep update kafka
helm install --name test-kafka --namespace testkafka incubator/kafka

test
NOTES:
### Connecting to Kafka from inside Kubernetes

You can connect to Kafka by running a simple pod in the K8s cluster like this with a configuration like this:

  apiVersion: v1
  kind: Pod
  metadata:
    name: testclient
    namespace: testkafka
  spec:
    containers:
    - name: kafka
      image: confluentinc/cp-kafka:4.1.1-2
      command:
        - sh
        - -c
        - "exec tail -f /dev/null"


if helm was broken down
helm reset
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account tiller --upgrade

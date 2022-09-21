export RP_VERSION=v22.2.2

minikube start

# make sure we're pointed to the minikube context
kubectl config use-context minikube

helm repo add redpanda https://charts.vectorized.io/
helm repo add jetstack https://charts.jetstack.io
helm repo update

# install cert manager
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.0 \
  --set installCRDs=true \
  --debug

# wait until cert-manager has finished rolling out
kubectl -n cert-manager rollout status -w deployment/cert-manager

# install the Redpanda CRDs
kubectl apply -k "https://github.com/redpanda-data/redpanda/src/go/k8s/config/crd?ref=$RP_VERSION"

# install the Redpanda Operator
helm install \
  redpanda-operator \
  redpanda/redpanda-operator \
  --namespace redpanda-system \
  --create-namespace \
  --version $RP_VERSION \
  --debug

# wait for the deployment to complete
kubectl -n redpanda-system rollout status -w deployment/redpanda-operator

# pre-pull the images for the Redpanda cluster
docker pull vectorized/configurator:$RP_VERSION
docker pull vectorized/redpanda:$RP_VERSION

# deploy a Redpanda cluster
kubectl config set-context --current --namespace=redpanda-system
cd charts/my-redpanda-cluster
helm install my-redpanda-cluster .

# set the rpk alias
alias rpk="kubectl exec -ti redpanda-cluster-0 -n redpanda-system -c redpanda -- rpk"


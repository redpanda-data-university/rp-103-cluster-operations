export RP_VERSION=v22.2.2

minikube start

# make sure we're pointed to the minikube context
kubectl config use-context minikube

helm repo add redpanda https://charts.redpanda.com/
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

# deploy Redpanda
helm upgrade redpanda redpanda/redpanda \
   --install \
   --namespace redpanda \
   --create-namespace \
   --values values.yaml \
   --debug

# wait for the deployment to complete
kubectl -n redpanda rollout status -w statefulset/redpanda

# set the rpk alias
alias rpk="kubectl exec -ti redpanda-0 -c redpanda -n redpanda -- rpk"

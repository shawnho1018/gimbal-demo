context=$1
# create account, role, and rolebindings
kubectl apply -f gimbal-sa.yaml,gimbal-admin-cb.yaml --context=$context

# Start producing kubeconfig
server=https://"$context.syspks.com:8443"
# the name of the secret containing the service account token goes here
name=$(kubectl describe sa gimbal-sa --context=$context | grep Tokens | awk '{print $2}')

ca=$(kubectl get secret/$name -o jsonpath='{.data.ca\.crt}' --context=$context)
token=$(kubectl get secret/$name -o jsonpath='{.data.token}' --context=$context | base64 --decode)
namespace=$(kubectl get secret/$name -o jsonpath='{.data.namespace}' --context=$context | base64 --decode)

echo "
apiVersion: v1
kind: Config
clusters:
- name: $context
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: $context
  context:
    cluster: $context
    namespace: default
    user: default-user
current-context: $context
users:
- name: default-user
  user:
    token: ${token}
" > "${context}-kube-config"
# save it as generic secret
kubectl -n gimbal-discovery create secret generic "${context}-discover-kubecfg" --from-file=config="./${context}-kube-config" --from-literal=backend-name=$context
# produce discover yaml
sed "s/ remote-discover-kubecfg/ ${context}-discover-kubecfg/g" ./02-kubernetes-discoverer.yaml > "${context}-discoverer.yaml"
sed -i "s/k8s-kubernetes-discoverer/${context}-kubernetes-discoverer/g" "${context}-discoverer.yaml"

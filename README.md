## This Project is a showcase for joint service between two K8S clusters.

## 1. Prepare three K8s Clusters and its corresponding context
* Create 3 K8S clusters: frontend, gimbal1, gimbal2. 
* Get their individual kubeconfig. If you're using Enterprise pks, use 
```
pks get-credentials gimbal1
pks get-credentials gimbal2
pks get-credentials frontend
```
## 2. Deploy hello-kubernetes in the backends
```
kubectl apply -f 02-deploy-hello.yaml --context gimbal1 
  kubectl apply -f 02-deploy-hello.yaml --context gimbal2
```
## 3. Deploy contour and gimbal-discovery common objects
```
kubectl apply -f contour/
kubectl apply -f install/01-common.yaml
```

## 4. Deploy secrets at each clusters:
* Run install/01-add-secret.sh gimbal1
* Run install/01-add-secret.sh gimbal2
### Two files will be produced: gimbal1-discoverer.yaml and gimbal2-discoverer.yaml
```
kubectl apply -f gimbal1-discoverer.yaml,gimbal2-discoverer.yaml --context frontend
```
## 5. Deploy ingressroute
```
kubectl apply -f gimbal-ir.yaml --context frontend
```
### Prepare to view the results: 
```
kubectl port-forward $(kubectl get pods -n gimbal-contour -l app=envoy -o jsonpath='{.items[0].metadata.name}') 9000:80 -n gimbal-contour
```
* Test with curl: curl -H “Host:hello.syspks.com” localhost:9000

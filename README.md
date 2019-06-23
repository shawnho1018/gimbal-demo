## This Project is a showcase for joint service between two K8S clusters.

## Prepare 3 K8s Clusters and its corresponding context
1. Create 3 K8S clusters: frontend, gimbal1, gimbal2. 
2. Get their individual kubeconfig. If you're using Enterprise pks, use pks get-credentials gimbal1

## Deploy hello-kubernetes in the backends
1. kubectl apply -f 02-deploy-hello.yaml --context gimbal1 
   kubectl apply -f 02-deploy-hello.yaml --context gimbal2

## Deploy secrets at each clusters:
1. Run install/01-add-secret.sh gimbal1
2. Run install/01-add-secret.sh gimbal2
### two files will be produced: gimbal1-discoverer.yaml and gimbal2-discoverer.yaml
3. kubectl apply -f gimbal1-discoverer.yaml,gimbal2-discoverer.yaml --context frontend

## Deploy ingressroute
1. kubectl apply -f gimbal-ir.yaml --context frontend
### Prepare to view the results: 
2. kubectl port-forward $(kubectl get pods -n gimbal-contour -l app=envoy -o jsonpath='{.items[0].metadata.name}') 9000:80 -n gimbal-contour
3. Test with curl: curl -H “Host:hello.syspks.com” localhost:9000

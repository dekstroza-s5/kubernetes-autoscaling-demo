# Kubernetes Autoscaling Demo

CPU-driven Horizontal Pod Autoscaler demonstration with a controllable HTTP workload.

```bash
kubectl apply -f k8s/
kubectl -n autoscaling run load --rm -it --image=busybox:1.37 -- /bin/sh
while true; do wget -q -O- http://demo-api; done
kubectl -n autoscaling get hpa,pods -w
```

Requires metrics-server. The deployment has explicit CPU requests because percentage-based HPA metrics depend on them.

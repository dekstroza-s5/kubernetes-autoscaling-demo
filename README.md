# Kubernetes Autoscaling Demo

CPU-driven Horizontal Pod Autoscaler demonstration with a controllable HTTP workload.

## Architecture

```text
load pod -> Service -> application pods
                         ^
metrics-server -> HPA ---|
```

The Deployment defines CPU requests because utilization percentage is calculated relative to requested CPU. The HPA scales from one to ten replicas and uses a five-minute scale-down stabilization window.

## Prerequisites

- Kubernetes 1.27+
- metrics-server returning pod metrics
- kubectl access

```bash
kubectl top nodes
kubectl top pods -A
```

Fix metrics-server before continuing if these commands fail.

## Deploy and verify

```bash
kubectl apply -f k8s/
kubectl -n autoscaling rollout status deployment/demo-api
kubectl -n autoscaling get deploy,pods,svc,hpa
```

At idle, the target normally stays close to one replica.

## Generate load

In one terminal:

```bash
kubectl -n autoscaling run load --rm -it --image=busybox:1.37 --   sh -c 'while true; do wget -q -O- http://demo-api >/dev/null; done'
```

In another:

```bash
bash scripts/watch.sh
kubectl -n autoscaling describe hpa demo-api
```

Example transition:

```text
TARGETS   MINPODS   MAXPODS   REPLICAS
180%/50%  1         10        1
160%/50%  1         10        4
70%/50%   1         10        8
```

Values depend on the cluster. Stop the load and observe gradual scale-down.

## Troubleshooting

- `TARGETS <unknown>`: inspect metrics-server and ensure CPU requests exist.
- no scale-up: confirm sustained load and HPA events.
- pods Pending after scale-up: inspect node capacity and scheduling constraints.
- rapid replica changes: tune stabilization windows and scaling policies.

## Cleanup

```bash
kubectl delete namespace autoscaling
```

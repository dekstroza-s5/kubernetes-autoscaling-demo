#!/usr/bin/env bash
set -euo pipefail
kubectl -n autoscaling get hpa,pods -w

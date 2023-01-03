#!/usr/bin/env bash
[ -z "$DEBUG" ] || set -x
set -eo pipefail

make prometheus_alerts.yaml
make prometheus_rules.yaml
make dashboards_out
cp $(which gojsontoyaml) tmp/bin/

cat << EOF > ./kustomize-base/rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kubernetes-mixin-rules
spec:
EOF
cat prometheus_rules.yaml | gojsontoyaml | sed 's|^|  |' >> ./kustomize-base/rules.yaml

cat << EOF > ./kustomize-base/alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kubernetes-mixin-alerts
spec:
EOF
cat prometheus_alerts.yaml | gojsontoyaml | sed 's|^|  |' >> ./kustomize-base/alerts.yaml

cp -rv dashboards_out/* ./dashboards-kustomize-base
cat << EOF > ./dashboards-kustomize-base/kustomization.yaml
# It should be possible to extend this set of dashboards using the "replace" behavior
# Meant to be used with kubectl create -k and kubectl replace -k
# (unless we learn how to get rid of last-applied-configuration with apply)
generatorOptions:
  disableNameSuffixHash: true
configMapGenerator:
- name: kubernetes-mixin-grafana-dashboards
  files:
EOF
find ./dashboards-kustomize-base -name \*.json | sed 's|.*/\(.*\)|  - \1=\1|' >> ./dashboards-kustomize-base/kustomization.yaml

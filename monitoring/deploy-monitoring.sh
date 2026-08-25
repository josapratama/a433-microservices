#!/bin/bash

# =============================================================
# deploy-monitoring.sh
# Deskripsi: Script helper untuk men-deploy semua komponen
#            monitoring (Prometheus + Grafana) ke Kubernetes.
#
# Cara penggunaan:
#   bash deploy-monitoring.sh
#
# Setelah deploy, akses:
#   - Prometheus: http://<Node_IP>:30090
#   - Grafana   : http://<Node_IP>:30300 (admin/admin)
# Dapatkan Node IP dengan: minikube ip
# =============================================================

echo ">>> Membuat namespace monitoring..."
# Buat namespace monitoring terlebih dahulu sebelum deploy komponen lain
kubectl apply -f monitoring-namespace.yml

echo ">>> Deploy RBAC untuk Prometheus..."
# RBAC diperlukan agar Prometheus bisa query Kubernetes API
kubectl apply -f prometheus-rbac.yml

echo ">>> Deploy ConfigMap Prometheus..."
# ConfigMap berisi file konfigurasi prometheus.yml
kubectl apply -f prometheus-configmap.yml

echo ">>> Deploy Prometheus (Deployment + Service)..."
kubectl apply -f prometheus-deployment.yml

echo ">>> Deploy Secret Grafana..."
# Secret berisi kredensial login Grafana
kubectl apply -f grafana-secret.yml

echo ">>> Deploy Datasource ConfigMap Grafana..."
# ConfigMap provisioning datasource Prometheus ke Grafana
kubectl apply -f grafana-datasource-configmap.yml

echo ">>> Deploy Grafana (Deployment + Service)..."
kubectl apply -f grafana-deployment.yml

echo ""
echo ">>> Semua komponen monitoring berhasil di-deploy!"
echo ">>> Tunggu beberapa menit hingga semua Pod Running..."
echo ""
echo ">>> Cek status Pod:"
echo "    kubectl get pods -n monitoring"
echo ""
echo ">>> Setelah semua Pod Running, catat semua object monitoring:"
echo "    kubectl get all -n monitoring > monitoring.txt"
echo ""

# Tampilkan Node IP untuk kemudahan akses
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
echo ">>> Node IP      : ${NODE_IP}"
echo ">>> Prometheus UI: http://${NODE_IP}:30090"
echo ">>> Grafana UI   : http://${NODE_IP}:30300 (login: admin/admin)"

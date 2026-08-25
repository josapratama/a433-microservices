#!/bin/bash

# =============================================================
# Script: build_push_image_karsajobs_ui.sh
# Deskripsi: Script untuk build dan push Docker image frontend
#            Karsa Jobs (Vue.js) ke GitHub Container Registry.
# Penggunaan:
#   1. Set environment variable GITHUB_TOKEN sebelum menjalankan:
#      export GITHUB_TOKEN=<personal_access_token_anda>
#   2. Pastikan nilai VUE_APP_BACKEND di file .env sudah diisi
#      dengan Node IP dan Node Port yang sesuai.
#   3. Jalankan script: bash build_push_image_karsajobs_ui.sh
# =============================================================

# Variabel konfigurasi
GITHUB_USERNAME="josapratama"
IMAGE_NAME="ghcr.io/${GITHUB_USERNAME}/karsajobs-ui"
IMAGE_TAG="latest"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

# ------------------------------------------------------------------
# Langkah 1: Build Docker image dari Dockerfile yang tersedia
# Flag:
#   -t  : memberi nama (tag) pada image yang dibangun
#   .   : konteks build adalah direktori saat ini
# ------------------------------------------------------------------
echo ">>> [1/3] Building Docker image: ${FULL_IMAGE}"
docker build -t "${FULL_IMAGE}" .

# Cek apakah perintah build berhasil (exit code 0)
if [ $? -ne 0 ]; then
  echo "ERROR: Docker build gagal. Proses dihentikan."
  exit 1
fi

echo ">>> Build berhasil."

# ------------------------------------------------------------------
# Langkah 2: Login ke GitHub Container Registry (GHCR)
# - Menggunakan environment variable GITHUB_TOKEN agar password
#   tidak tersimpan di plain text dalam script ini.
# - Flag --password-stdin membaca password dari stdin (lebih aman).
# ------------------------------------------------------------------
echo ">>> [2/3] Login ke GHCR sebagai ${GITHUB_USERNAME}..."
echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_USERNAME}" --password-stdin

# Cek apakah login berhasil
if [ $? -ne 0 ]; then
  echo "ERROR: Login ke GHCR gagal. Pastikan GITHUB_TOKEN sudah di-set dengan benar."
  exit 1
fi

echo ">>> Login berhasil."

# ------------------------------------------------------------------
# Langkah 3: Push image ke GitHub Container Registry
# Perintah ini mengunggah image yang sudah di-build ke GHCR
# agar dapat digunakan oleh Kubernetes (atau environment lain).
# ------------------------------------------------------------------
echo ">>> [3/3] Pushing image ke GHCR: ${FULL_IMAGE}"
docker push "${FULL_IMAGE}"

# Cek apakah push berhasil
if [ $? -ne 0 ]; then
  echo "ERROR: Docker push gagal."
  exit 1
fi

echo ">>> Push berhasil! Image tersedia di: ${FULL_IMAGE}"

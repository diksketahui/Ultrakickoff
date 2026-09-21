#!/bin/bash
# Jalankan di LAPTOP anda, bukan di sini. Jangan paste output ke chat public.
# Usage: ./make-keystore.sh
set -e
read -s -p "Password BARU keystore: " KS_PASS; echo
read -p "Alias [ultrakickoff]: " ALIAS; ALIAS=${ALIAS:-ultrakickoff}
read -s -p "Password key (samakan saja): " KEY_PASS; echo
keytool -genkey -v -keystore ultrakickoff-release.jks -alias "$ALIAS" -keyalg RSA -validity 10000 -storepass "$KS_PASS" -keypass "$KEY_PASS" -dname "CN=Ultrakickoff, OU=Game, O=Fanmade, C=ID"
base64 -w0 ultrakickoff-release.jks > keystore.b64
echo "--- Paste ke GitHub Secrets ---"
echo "ANDROID_KEYSTORE_BASE64 <= isi file keystore.b64"
echo "KEYSTORE_PASSWORD <= password tadi"
echo "KEY_ALIAS <= $ALIAS"
echo "KEY_PASSWORD <= password key tadi"
echo "Hapus file lokal setelah disimpan di password manager: rm ultrakickoff-release.jks keystore.b64"

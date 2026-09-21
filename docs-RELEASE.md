# Release signing aman (tanpa keystore di repo)

Jangan taruh `.jks` dan password di repo, walau repo nanti private.
Password lama yang pernah tertulis di chat sudah terekspos, jangan dipakai lagi.

## 1x setup di laptop (sekali saja)
```bash
keytool -genkey -v -keystore ultrakickoff-release.jks -alias ultrakickoff -keyalg RSA -validity 10000
# masukkan password BARU yang kuat, jangan pakai yang lama
base64 -w0 ultrakickoff-release.jks > keystore.b64
# hapus file asli setelah disimpan di password manager
rm ultrakickoff-release.jks
```

## Isi GitHub Secrets (Settings > Secrets > Actions)
- `ANDROID_KEYSTORE_BASE64` = isi `keystore.b64`
- `KEYSTORE_PASSWORD` = password baru
- `KEY_ALIAS` = `ultrakickoff`
- `KEY_PASSWORD` = password key baru

## Hasil di Action
- Tanpa secrets: job `debug` hijau, job `release` skip.
- Dengan secrets lengkap: job `release` hijau, artifact `ultrakickoff-release` signed.

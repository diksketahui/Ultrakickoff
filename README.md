# Ultrakickoff — Manager Simulasi Liga Indonesia
Fan-made, non-afiliasi. Nama klub/stadion pakai nama asli sebagai data faktual, rating + pemain adalah estimasi sendiri (dimanipulasi), avatar prosedural teks saja, tanpa foto/logo asli.

## Main cepat (Web)
Repo ini statis, tanpa build step. GitHub Action `web.yml` langsung deploy ke Pages.

## Struktur
- `index.html` — UI dashboard, squad, taktik, live, inbox, board, akademi
- `css/style.css`
- `js/config.js` — konstanta (RATING_MIN=30)
- `js/teams.js` — 18 Liga Super + 20 Championship + stadion
- `js/engine.js` — simulasi per-menit berbasis rating + taktik
- `js/tactics.js` — model taktik bebas (garis, arah umpan, pergerakan)
- `js/manager.js` — board, pecat, sponsor, fans, media, insider, akademi, stamina, wasit
- `js/app.js` — glue UI + save localStorage

## Android
- Debug APK otomatis via `android.yml` (Capacitor di CI saja, bukan di sini).
- Release: JANGAN commit `.jks`/password ke repo public. Set Secrets:
  `ANDROID_KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
  Workflow akan decode saat build saja. Password yang pernah tertulis di chat harus diganti.

## Kompetisi
- Liga Super: 18 tim, 34 matchday, 3 degradasi
- Championship: 20 tim, 2 grup, playoff promosi/degradasi, 3 promosi/3 degradasi
- Piala Presiden: 8 tim, 2 grup isi 4, semifinal-final (configurable)

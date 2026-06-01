# Mono 🎵

Музыкальное приложение на базе Яндекс Музыки с Liquid Glass UI.

[![Build IPA](https://github.com/slehes/Mono/actions/workflows/build-ipa.yml/badge.svg)](https://github.com/slehes/Mono/actions/workflows/build-ipa.yml)

## Стек

| Часть | Технологии |
|-------|-----------|
| iOS клиент | SwiftUI + LiquidGlassKit + AVPlayer |
| Бэкенд | FastAPI + yandex-music-api |
| Auth | Яндекс Device Flow OAuth |
| Стриминг | Полные треки 320kbps (с Яндекс Плюс) |

## Быстрый старт

### Бэкенд
```bash
cd mono-backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### iOS
```bash
brew install xcodegen
cd MonoApp && xcodegen generate
open Mono.xcodeproj
```

## Сборка IPA через GitHub Actions

### Нужные Secrets (Settings → Secrets → Actions)

| Secret | Описание |
|--------|----------|
| `BUILD_CERTIFICATE_BASE64` | Apple Distribution .p12 в base64 |
| `P12_PASSWORD` | Пароль от .p12 |
| `BUILD_PROVISION_PROFILE_BASE64` | .mobileprovision в base64 |
| `PROVISIONING_PROFILE_NAME` | Имя профиля (из Apple Developer Portal) |
| `CODE_SIGN_IDENTITY` | `iPhone Distribution: Your Name (TEAMID)` |
| `APPLE_TEAM_ID` | 10-символьный Team ID |
| `KEYCHAIN_PASSWORD` | Любой произвольный пароль |

### Как получить base64 из файла
```bash
# Certificate
base64 -i certificate.p12 | pbcopy

# Provisioning Profile
base64 -i profile.mobileprovision | pbcopy
```

После добавления secrets — нажми **Actions → Build iOS IPA → Run workflow**.  
IPA появится в артефактах через ~10 минут.

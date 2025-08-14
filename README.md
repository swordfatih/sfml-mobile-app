# SFML Mobile Template

A minimal cross-platform SFML template targeting **Desktop**, **iOS**, and **Android**.

## 🚀 Getting Started
1. Clone the repo.
2. Update `config.json` with your `APP_NAME`, `APP_ID`, and `MOBILE_ICON`.
3. Build using CMake or the included GitHub Actions workflows.

## 🖥 Platforms
- **Desktop**: Windows, Linux (GCC/Clang), macOS.
- **iOS**: Produces an unsigned `.ipa`.
- **Android**: Produces an `.apk` (unsigned or signed if secrets are set).

## 📱 Android Signing Notes
To enable APK signing in GitHub Actions, add these repository secrets:
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Generate a keystore locally:

```bash
keytool -genkeypair -v -keystore my-release-key.keystore -alias my-key-alias \
  -keyalg RSA -keysize 2048 -validity 10000
```

Then base64 encode and set it as `ANDROID_KEYSTORE_BASE64`.

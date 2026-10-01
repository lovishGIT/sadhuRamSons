# GitHub Pages Deep Linking & Universal Links Setup

This directory contains the required verification files for Android App Links (`assetlinks.json`) and iOS Universal Links (`apple-app-site-association`), pre-configured for the **Kisan Mitra (Sadhu Ram & Sons)** app.

---

## Directory Structure

```text
public/
├── .nojekyll                           # CRITICAL: Forces GitHub Pages to serve .well-known/
├── .well-known/
│   ├── assetlinks.json                 # Android App Links configuration
│   └── apple-app-site-association      # iOS Universal Links configuration (NO .json extension)
├── apple-app-site-association          # Root fallback for legacy iOS devices
├── index.html                          # Web fallback landing page with deep link detection
└── README.md
```

---

## 1. Android Configuration (`assetlinks.json`)

File: `public/.well-known/assetlinks.json`

### Step A: Extract your Keystore SHA256 Fingerprint

Run the following command in terminal to get your SHA256 certificate fingerprint:

#### For Debug Keystore:
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

#### For Production Release Keystore:
```bash
keytool -list -v -keystore path/to/your/upload-keystore.jks -alias your-key-alias
```

#### From Google Play Console (if using Play App Signing):
Go to: **Release** > **Setup** > **App integrity** > **App signing key certificate** > Copy **SHA-256 certificate fingerprint**.

### Step B: Update `assetlinks.json`
Replace `REPLACE_WITH_YOUR_RELEASE_KEYSTORE_SHA256_FINGERPRINT` in `public/.well-known/assetlinks.json` with your uppercase colon-separated fingerprint:
```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.sadhuram.app.sadhuramsons",
      "sha256_cert_fingerprints": [
        "14:6D:E9:7D:0F:52:CC:CF:66:E8:13:95:C0:AE:03:03:68:55:A6:61:9D:69:B6:33:CA:9D:88:51:71:3B:54:19",
        "YOUR_COPIED_RELEASE_SHA256_FINGERPRINT_HERE"
      ]
    }
  }
]
```

---

## 2. iOS Configuration (`apple-app-site-association`)

File: `public/.well-known/apple-app-site-association` and `public/apple-app-site-association`

### Step A: Find Your Apple Team ID
1. Log in to [developer.apple.com](https://developer.apple.com).
2. Go to **Membership Details** > Note your 10-character **Team ID** (e.g., `A1B2C3D4E5`).

### Step B: Update the File
Replace `YOUR_APPLE_DEVELOPER_TEAM_ID` with your Team ID:
```json
"appIDs": [
  "A1B2C3D4E5.com.sadhuram.app.sadhuramsons"
]
```

*Note: The file must have NO `.json` extension and must be served over valid HTTPS with Content-Type `application/json`.*

---

## 3. GitHub Pages Deployment Steps

### Option 1: Deploying via GitHub Actions (Recommended)
Add a workflow file `.github/workflows/pages.yml`:
```yaml
name: Deploy Deep Links to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v4
      - uses: actions/upload-pages-artifact@v3
        with:
          path: 'public'
      - id: deployment
        uses: actions/deploy-pages@v4
```

### Option 2: Deploying from Branch
1. Push this repository to GitHub.
2. In your repository on GitHub, go to **Settings** > **Pages**.
3. Under **Build and deployment** > **Source**, choose **Deploy from a branch**.
4. Select `main` (or `gh-pages`) branch and `/docs` or configure a custom action pointing to `/public`.

---

## 4. Verification Checklists

Once GitHub Pages is live, verify the files are accessible via HTTPS:

1. **Android AssetLinks endpoint**:
   ```
   https://<your-username>.github.io/.well-known/assetlinks.json
   ```
   Verify with Google API:
   ```
   https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://<your-username>.github.io&relation=delegate_permission/common.handle_all_urls
   ```

2. **iOS Universal Links endpoint**:
   ```
   https://<your-username>.github.io/.well-known/apple-app-site-association
   ```
   Verify with Apple CDN:
   ```
   https://app-site-association.cdn-apple.com/a/v1/<your-username>.github.io
   ```

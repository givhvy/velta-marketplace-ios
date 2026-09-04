# Velta Marketplace (iOS)

Native SwiftUI app for the **Velta beat store** — same catalog and branding as
`/Users/huy/Desktop/Developer/beat-marketplace`.

## What it is

- Dark zinc storefront, blue lease CTAs
- Explore / Library / Account + trailing Search orb (iOS 26 Liquid Glass tabs)
- Live catalog from `http://127.0.0.1:3000/api/catalog` when the website is running
- Bundled `beats.json` fallback
- **Buy now** opens the website Whop checkout in Safari

## Run

```bash
cd /Users/huy/Desktop/Developer/VeltaMarketplace
xcodegen generate
xcodebuild -project VeltaMarketplace.xcodeproj -scheme VeltaMarketplace \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build build
```

# Velta Marketplace (iOS)

Native SwiftUI store for [Velta](https://github.com/givhvy/prodvince). Browse beats, watch For You clips, and license in-app — nothing opens Safari.

## Run

```bash
cd VeltaMarketplace
xcodegen generate
xcodebuild -project VeltaMarketplace.xcodeproj -scheme VeltaMarketplace \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO build
```

Catalog comes from `http://127.0.0.1:3000/api/catalog` when the website is running, otherwise bundled `beats.json`.

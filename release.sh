#!/bin/bash

# ============================================================
# release.sh — Build, tag, and publish a new Wishlist release
# Usage: ./release.sh v1.0.0 "What changed in this version"
# ============================================================

set -e

# ── Arguments ───────────────────────────────────────────────
VERSION=$1
NOTES=$2

if [ -z "$VERSION" ]; then
  echo "❌  Usage: ./release.sh v1.0.0 \"Release notes\""
  exit 1
fi

if [ -z "$NOTES" ]; then
  NOTES="Wishlist $VERSION"
fi

# ── Confirm ─────────────────────────────────────────────────
echo ""
echo "🚀  Releasing Wishlist $VERSION"
echo "📝  Notes: $NOTES"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# ── 1. Check for uncommitted changes ────────────────────────
echo ""
echo "📋  Checking for uncommitted changes..."
if ! git diff-index --quiet HEAD --; then
  echo "❌  You have uncommitted changes. Please commit or stash them first."
  exit 1
fi
echo "✅  Working directory is clean."

# ── 2. Build binary with swift build ───────────────────────
echo ""
echo "🔨  Building release binary..."
swift build -c release 2>&1

BINARY=".build/release/Wishlist"
if [ ! -f "$BINARY" ]; then
  echo "❌  Build failed — binary not found at $BINARY"
  exit 1
fi
echo "✅  Build succeeded."

# ── 3. Assemble .app bundle ──────────────────────────────
echo ""
echo "📦  Assembling Wishlist.app bundle..."

APP="./dist/Wishlist.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

# Copy binary
cp "$BINARY" "$APP/Contents/MacOS/Wishlist"

# Copy icon if it exists
ICON_PATH="Sources/Wishlist/AppIcon.icns"
if [ -f "$ICON_PATH" ]; then
  cp "$ICON_PATH" "$APP/Contents/Resources/AppIcon.icns"
  ICON_ENTRY="
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>"
  echo "🎨  Icon included."
else
  ICON_ENTRY=""
  echo "⚠️  No icon found at $ICON_PATH — skipping."
fi

# Write Info.plist
cat > "$APP/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Wishlist</string>
    <key>CFBundleIdentifier</key>
    <string>com.casperkangas.wishlist</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleExecutable</key>
    <string>Wishlist</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>${ICON_ENTRY}
</dict>
</plist>
EOF

# Sign it locally
codesign --force --deep --sign "-" "$APP"

echo "✅  Wishlist.app assembled at $APP"

# ── 4. Zip ──────────────────────────────────────────────────
echo ""
echo "🗜️  Zipping..."
ZIP="./dist/Wishlist.zip"
rm -f "$ZIP"
cd ./dist
zip -r Wishlist.zip Wishlist.app
cd ..
echo "✅  Zipped to $ZIP"

# ── 5. Tag ──────────────────────────────────────────────────
echo ""
echo "🏷   Tagging $VERSION..."
if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "❌  Tag $VERSION already exists. Use a different version number."
  exit 1
fi
git tag "$VERSION"
git push origin "$VERSION"
echo "✅  Tag pushed."

# ── 6. GitHub Release ──────────────────────────────────────
echo ""
echo "🐙  Creating GitHub release..."
gh release create "$VERSION" \
  "$ZIP" \
  --title "Wishlist $VERSION" \
  --notes "$NOTES"

echo ""
echo "🎉  Done! Wishlist $VERSION is live."
echo "🔗  https://github.com/casperkangas/wishlist/releases/tag/$VERSION"

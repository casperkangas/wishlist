#!/bin/bash

# ============================================================
# release.sh — Build, tag, and publish a new Wishlist release
# Usage: ./release.sh v1.0.0 "What changed in this version"
# ============================================================

set -e  # Exit immediately if any command fails

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

# ── 2. Build ────────────────────────────────────────────────
echo ""
echo "🔨  Building release..."
xcodebuild \
  -scheme Wishlist \
  -configuration Release \
  -derivedDataPath ./build \
  -destination "platform=macOS" \
  CODE_SIGN_IDENTITY="-" \
  build | grep -E "(error:|warning:|Build succeeded|Build FAILED)"

APP_PATH="./build/Build/Products/Release/Wishlist.app"

if [ ! -d "$APP_PATH" ]; then
  echo "❌  Build failed — Wishlist.app not found."
  exit 1
fi
echo "✅  Build succeeded."

# ── 3. Zip ──────────────────────────────────────────────────
echo ""
echo "📦  Zipping Wishlist.app..."
ZIP_PATH="./build/Build/Products/Release/Wishlist.zip"
rm -f "$ZIP_PATH"
cd ./build/Build/Products/Release
zip -r Wishlist.zip Wishlist.app
cd ../../../../
echo "✅  Zipped to $ZIP_PATH"

# ── 4. Tag ──────────────────────────────────────────────────
echo ""
echo "🏷   Tagging $VERSION..."
if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "❌  Tag $VERSION already exists. Use a different version number."
  exit 1
fi
git tag "$VERSION"
git push origin "$VERSION"
echo "✅  Tag pushed."

# ── 5. GitHub Release ───────────────────────────────────────
echo ""
echo "🐙  Creating GitHub release..."
gh release create "$VERSION" \
  "$ZIP_PATH" \
  --title "Wishlist $VERSION" \
  --notes "$NOTES"

echo ""
echo "🎉  Done! Wishlist $VERSION is live."
echo "🔗  https://github.com/casperkangas/wishlist/releases/tag/$VERSION"

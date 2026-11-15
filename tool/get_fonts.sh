#!/bin/bash
# Downloads the Fira Sans font (NASA Space Apps brand guidelines, SIL Open Font
# License) and registers it in pubspec.yaml. Run by GitHub Actions before the build.
# If a download fails, nothing is registered and the app uses the system font.
set -e
mkdir -p assets/fonts
echo "AstroCare" > assets/about.txt
base="https://raw.githubusercontent.com/google/fonts/main/ofl/firasans"
for name in Regular Bold Black; do
  curl -fsSL --retry 3 -o "assets/fonts/FiraSans-$name.ttf" "$base/FiraSans-$name.ttf"
done
# Each "_" below becomes one space: this keeps the YAML indentation exact.
printf '%s\n' \
  "" \
  "__fonts:" \
  "____-_family:_FiraSans" \
  "______fonts:" \
  "________-_asset:_assets/fonts/FiraSans-Regular.ttf" \
  "________-_asset:_assets/fonts/FiraSans-Bold.ttf" \
  "__________weight:_700" \
  "________-_asset:_assets/fonts/FiraSans-Black.ttf" \
  "__________weight:_900" \
  | tr '_' ' ' >> pubspec.yaml
echo "Fira Sans registered."

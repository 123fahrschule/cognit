#!/usr/bin/env sh
# Fetches the Open Sans variable fonts from google/fonts and builds the
# static latin-subset woff2 files Cognit.Static declares: one per weight,
# upright and italic, at width 100.
# Requires: curl, uv (https://docs.astral.sh/uv/).
set -eu

dir=$(cd "$(dirname "$0")" && pwd)
out_dir="$dir/../../../priv/static/fonts/open_sans"
base='https://raw.githubusercontent.com/google/fonts/main/ofl/opensans'
weights='300 400 500 600 700 800'
latin='U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0300-0301,U+0303-0304,U+0308-0309,U+0323,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD'
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fonttools() { uvx --from 'fonttools[woff]' fonttools "$@"; }
pyftsubset() { uvx --from 'fonttools[woff]' pyftsubset "$@"; }

echo "Downloading upstream fonts..."
curl -sSfL -o "$tmp/upright.ttf" "$base/OpenSans%5Bwdth%2Cwght%5D.ttf"
curl -sSfL -o "$tmp/italic.ttf" "$base/OpenSans-Italic%5Bwdth%2Cwght%5D.ttf"

rm -f "$out_dir"/*.woff2
for style in upright italic; do
  suffix=''
  [ "$style" = italic ] && suffix=italic
  for weight in $weights; do
    out="$out_dir/open-sans-$weight$suffix.woff2"
    echo "Building $(basename "$out")..."
    fonttools varLib.instancer -q -o "$tmp/static.ttf" "$tmp/$style.ttf" "wght=$weight" wdth=100
    pyftsubset "$tmp/static.ttf" --unicodes="$latin" --layout-features='*' \
      --flavor=woff2 --output-file="$out"
  done
done

version=$(fonttools ttx -q -t head -o - "$tmp/upright.ttf" |
  sed -n 's/.*fontRevision value="\([0-9.]*\)".*/\1/p')
echo "$version" > "$dir/VERSION"

echo "Open Sans $version, $(cat "$out_dir"/*.woff2 | wc -c | tr -d ' ') bytes total"

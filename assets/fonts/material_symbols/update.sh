#!/usr/bin/env sh
# Fetches the latest Material Symbols Outlined variable font from
# google/material-design-icons and strips it down to the FILL axis,
# baking in wght 400, GRAD 0, opsz 24 (the values the CSS pins).
# Requires: curl, uv (https://docs.astral.sh/uv/).
set -eu

dir=$(cd "$(dirname "$0")" && pwd)
target="$dir/MaterialSymbolsOutlined.woff2"
upstream='https://raw.githubusercontent.com/google/material-design-icons/master/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.woff2'
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading upstream font..."
curl -sSfL -o "$tmp/full.woff2" "$upstream"

echo "Instancing to FILL-only..."
uvx --from 'fonttools[woff]' fonttools varLib.instancer -q \
  -o "$target" "$tmp/full.woff2" wght=400 GRAD=0 opsz=24

version=$(uvx --from 'fonttools[woff]' fonttools ttx -q -t head -o - "$target" |
  sed -n 's/.*fontRevision value="\([0-9.]*\)".*/\1/p')
echo "$version" > "$dir/VERSION"

echo "Material Symbols Outlined $version, $(wc -c < "$target" | tr -d ' ') bytes"

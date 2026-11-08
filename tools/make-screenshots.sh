#!/bin/sh
# Turns the native captures in _captures/ into the JPEGs the pages use.
#
#   tools/make-screenshots.sh
#
# Each capture is a native 1206x2622 iPhone PNG. It is resized by WIDTH to
# 1020px (sips gives 1020x2217) and encoded as JPEG at quality 86, into screenshots/.
# The originals are never touched: sips writes to a new file every time, and
# _captures/ is ignored by git, so a second pass always has the natives to
# work from.
#
# Two traps this avoids (see README):
#   - sips -Z fits the LONGEST side, which on a portrait capture sets the
#     height and leaves the width far too small. --resampleWidth is used.
#   - sips --out <same file> overwrites in place. Input and output differ.
set -eu

cd "$(dirname "$0")/.."
src=_captures
out=screenshots
names="het-home het-home-dark het-included het-exporting het-done het-share het-overlimit files-zip"

[ -d "$src" ] || { echo "no $src/ folder: put the native PNG captures there first" >&2; exit 1; }
mkdir -p "$out"

missing=0
for name in $names; do
  in="$src/$name.png"
  if [ ! -f "$in" ]; then
    echo "missing: $in" >&2; missing=1; continue
  fi
  w=$(sips -g pixelWidth "$in" | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$in" | awk '/pixelHeight/{print $2}')
  if [ "$w" != 1206 ] || [ "$h" != 2622 ]; then
    echo "warning: $in is ${w}x${h}, expected 1206x2622; the pages assume that shape" >&2
  fi
  sips --resampleWidth 1020 -s format jpeg -s formatOptions 86 "$in" --out "$out/$name.jpg" >/dev/null
  echo "$out/$name.jpg  $(sips -g pixelWidth -g pixelHeight "$out/$name.jpg" | awk '/pixel/{printf "%s ", $2}')$(du -k "$out/$name.jpg" | cut -f1)KB"
done

exit $missing

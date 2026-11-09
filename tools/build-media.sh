#!/usr/bin/env bash
# Makes assets/ for links.alinabun.com, small enough for a phone on mobile data.
# Sources: the main site's originals and web photos (../alinabun-site/assets), one store photo, Fraunces from Google Fonts.
# Needs: ffmpeg with libx264, avifenc; for fonts, python3 with fonttools + brotli.
#   tools/build-media.sh                  # everything
#   tools/build-media.sh videos           # or: images | fonts
set -euo pipefail
cd "$(dirname "$0")/.."
SITE=${SITE:-../alinabun-site}
SRC=$SITE/assets          # originals (MOV, HEIC; not in git there)
WEB=$SITE/assets/img      # the main site's web photos and bun cut-outs
PY=${PY:-python3}
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p assets/img assets/video assets/fonts

# Still → AVIF (most phones) + a small JPEG for the rest. $1 source image, $2 output name, $3 width, [$4 crop w:h:x:y].
still() {
  local vf="scale=$3:-2:flags=lanczos"
  [ -n "${4:-}" ] && vf="crop=$4,$vf"
  ffmpeg -v error -y -i "$1" -vf "$vf" "$TMP/$2.png"
  avifenc -q 52 -s 6 -j all "$TMP/$2.png" "assets/img/$2.avif" >/dev/null
  ffmpeg -v error -y -i "$TMP/$2.png" -q:v 6 "assets/img/$2.jpg"
}

# Silent loop. name, original, start s, length s, crop (w:h:x:y in the upright frame, or -), width, height, fps, boomerang (0|1).
# The first frame becomes the poster (assets/img/<name>.avif/.jpg), shown until the video plays (or instead of it).
clip() {
  local name=$1 src=$SRC/$2 ss=$3 t=$4 crop=$5 w=$6 h=$7 fps=$8 boom=$9
  local chain="scale=$w:$h:flags=lanczos,fps=$fps,format=yuv420p"
  [ "$crop" != - ] && chain="crop=$crop,$chain"
  local enc=(-an -c:v libx264 -profile:v high -crf 30 -preset veryslow -movflags +faststart -tag:v avc1 "assets/video/$name.mp4")
  if [ "$boom" = 1 ]; then # forward then back: loops without a jump
    ffmpeg -v error -y -ss "$ss" -t "$t" -i "$src" -filter_complex "[0:v]$chain,split[a][b];[b]reverse[r];[a][r]concat=n=2:v=1[v]" -map "[v]" "${enc[@]}"
  else
    ffmpeg -v error -y -ss "$ss" -t "$t" -i "$src" -vf "$chain" "${enc[@]}"
  fi
  ffmpeg -v error -y -ss "$ss" -i "$src" -frames:v 1 -vf "${chain%,fps=*}" "$TMP/$name.png"
  avifenc -q 52 -s 6 -j all "$TMP/$name.png" "assets/img/$name.avif" >/dev/null
  ffmpeg -v error -y -i "$TMP/$name.png" -q:v 6 "assets/img/$name.jpg"
  printf '%-10s %4d KB video, %3d KB poster\n' "$name" $(( $(wc -c < "assets/video/$name.mp4") / 1024 )) $(( $(wc -c < "assets/img/$name.avif") / 1024 ))
}

videos() {
  clip hero    IMG_2930.mov                                    0    4.6 -                  432 768 24 1
  clip filling copy_63F2D79E-9C1F-44D6-AF81-5F343B8E2D6D.MOV   1.0  4.9 1080:1350:0:330    480 600 30 0
  clip shaping "1022(1).MOV"                                   4.0  6.0 1024:1280:28:640   480 600 30 0  # below the burned-in caption
  clip glazing IMG_7580.MOV                                    0    5.4 1080:1350:0:285    480 600 30 0
  clip packing IMG_2925.MOV                                    0    5.8 1080:1350:0:285    480 600 30 0
  clip beach   copy_FB66E253-1D72-4EE6-AADC-A9500C26E1BC.MOV   16.9 6.7 1080:1350:0:150    480 600 30 0  # beach only
  # A sharper still of the hero for the first paint (it is the largest thing on screen).
  ffmpeg -v error -y -i "$SRC/IMG_2930.mov" -frames:v 1 -vf "scale=540:960:flags=lanczos" "$TMP/hero-540.png"
  avifenc -q 50 -s 6 -j all "$TMP/hero-540.png" assets/img/hero-540.avif >/dev/null
  ffmpeg -v error -y -i "$TMP/hero-540.png" -q:v 6 assets/img/hero-540.jpg
}

images() {
  # Photos the main site already made (AVIF 480 wide); a 480-wide JPEG beside each for older phones.
  for p in flowers-cream oven beach-cream beach-chocolate ixora-tuna box-cream-hand sesame-top; do
    cp "$WEB/$p-480.avif" assets/img/
    ffmpeg -v error -y -i "$WEB/$p-960.jpg" -vf "scale=480:-2:flags=lanczos" -q:v 7 "assets/img/$p-480.jpg"
  done
  for b in tuna cream chocolate; do cp "$WEB/cut-$b-400.avif" "$WEB/cut-$b-400.webp" assets/img/; done
  # Lava creme cheese has no cut-out yet: the store's photo, cropped to the bun on its plate.
  curl -fsS -o "$TMP/lava.jpg" "https://vosokllmaifbcdfbfvdt.supabase.co/storage/v1/object/public/products/lava-creme-cheese/b09ec523-8cda-4365-bb9c-ee41df788863.jpg"
  still "$TMP/lava.jpg" lava-400 400 680:680:315:310
  cp "$SITE/assets/og.jpg" "$SITE/assets/apple-touch-icon.png" assets/
}

# Fraunces (SIL OFL): only the two styles and the characters the page uses. ~26 KB instead of ~140 KB from Google.
fonts() {
  local ua="Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
  local css style url
  css=$(curl -fsS -A "$ua" "https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght,SOFT,WONK@0,9..144,100..900,0..100,0..1;1,9..144,100..900,0..100,0..1")
  # The latin file of each style, by its font-style (Google lists italic first).
  while read -r style url; do
    curl -fsS -o "$TMP/$style.woff2" "$url"
  done < <(printf '%s\n' "$css" | awk '/\/\* latin \*\//{f=1} f&&/font-style/{gsub(/[;[:space:]]/,"",$2); s=$2} f&&/src:/{match($0,/https:[^)]*/); print s, substr($0,RSTART,RLENGTH); f=0}')
  local chars="U+0020-007E,U+00A0,U+00B7,U+00C9,U+00E9,U+2013,U+2014,U+2018,U+2019,U+201C,U+201D,U+2026"
  # Same look as alinabun.com (SOFT 100, WONK on), fixed at headline size.
  $PY -m fontTools.varLib.instancer "$TMP/normal.woff2" wght=600 opsz=52 SOFT=100 WONK=1 -q -o "$TMP/r.ttf"
  $PY -m fontTools.varLib.instancer "$TMP/italic.woff2" wght=480 opsz=52 SOFT=100 WONK=1 -q -o "$TMP/i.ttf"
  $PY -m fontTools.subset "$TMP/r.ttf" --unicodes="$chars" --layout-features='kern,liga,calt' --no-hinting --desubroutinize --flavor=woff2 --output-file=assets/fonts/fraunces-600.woff2
  $PY -m fontTools.subset "$TMP/i.ttf" --unicodes="$chars" --layout-features='kern,liga,calt' --no-hinting --desubroutinize --flavor=woff2 --output-file=assets/fonts/fraunces-480i.woff2
  ls -la assets/fonts
}

for job in "${@:-videos images fonts}"; do
  for j in $job; do "$j"; done
done

# links.alinabun.com

The link-in-bio page. **This is the URL printed in the QR code on every
box of buns**, so treat it as load-bearing: it must stay fast, stay up,
and never depend on anything that can break.

| | |
|---|---|
| **Live** | https://links.alinabun.com |
| **Repo type** | project site |
| **Branch** | `main`, served from `/` (root) |
| **Custom domain** | `links.alinabun.com` (see `CNAME`) |

## Design rules

Because this page is behind a physical QR code:

1. **One page, nothing outside this repo.** CSS and JS are inlined in `index.html`;
   fonts, photos and videos are in `assets/` on the same server. No CDNs, no Google Fonts.
2. **Never change the URL.** Printed boxes can't be recalled. Add links,
   don't move the page.
3. **Mobile first, and light.** Essentially every visitor arrives from a phone camera,
   often on mobile data. Keep the first load under ~100 KB (today: HTML 16 KB gzipped,
   fonts 26 KB, hero still 27 KB). Videos load only after the page has, only on a good
   connection, and never with data saver or "reduce motion" on.
4. **Everything degrades.** Without JavaScript, or when the store can't be reached,
   it is still a page of working links with neutral wording.

## What's on it

From the top: the hero (video of the buns, the label's line "Softest bun you will ever touch",
a live status line), the **Order buns** button (the one gold-arrow action; a dock with the same
button appears once you scroll past it), Instagram / TikTok / Facebook tiles, alinabun.com,
"Questions? Message us" (Instagram DM), the buns on sale (squish them), five tap-through clips
from the kitchen, "Got one of our boxes?" with a share button, and the footer.

## Live data from the store

Like alinabun.com, the page reads the store's public API (`/catalog`, `/delivery-dates`):
the pre-order countdown, extras left today or tomorrow, prices, which buns are on sale (a new
bun gets a card with its store photo), the delivery fees and minimum, and the Instagram handle.
Change those in the store admin, never here. The store allows this origin in its CORS list
(`allowedOrigins` in the `store` function); if the page moves, add the new origin there.

Locally, serve this folder on port 5173 (the store's dev origin) to see live data:

```bash
python3 -m http.server 5173
```

## Editing

- **Links**: the `<nav class="links">` block in `index.html`. Photo tiles are `<a class="tile">`,
  plain rows are `<a class="row">`.
- **Clips**: each `<figure class="slide">` in the kitchen section (poster, video, caption).
- **Brand**: colours mirror `brand/tokens.css` in [`alinabun/alinabun`](https://github.com/alinabun/alinabun),
  inlined in the `:root` block (rule 1); if a token changes there, change it here too.
  Headlines use Fraunces like alinabun.com; body text uses the phone's own font, so there is
  nothing else to download.

## Media

`tools/build-media.sh` makes everything in `assets/` from the main site's originals
(`../alinabun-site/assets`), the store's lava bun photo and Fraunces from Google Fonts:
AVIF photos with small JPEG fallbacks, H.264 clips (432–480 px wide, no sound) with their
first frame as the poster, and Fraunces cut down to two styles and the characters we use.
To change a clip, edit its line in `videos()` and run:

```bash
tools/build-media.sh videos    # or: images | fonts (fonts needs python3 with fonttools + brotli)
```

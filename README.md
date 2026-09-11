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

1. **Single file.** Everything is inlined in `index.html`. No external CSS
   or JS that could fail.
2. **Never change the URL.** Printed boxes can't be recalled. Add links,
   don't move the page.
3. **Mobile first.** Essentially every visitor arrives from a phone camera.

## Editing the links

Each link is an `<a class="link">` block in `index.html`. The first one has
`class="link primary"` — that's the gold ordering button; there should only
ever be one. A commented-out block for `store.alinabun.com` is ready to
uncomment when the store exists.

## Brand

Colours mirror `brand/tokens.css` in the
[`alinabun/alinabun`](https://github.com/alinabun/alinabun) repo. They're
inlined here deliberately (rule 1). If a token changes there, update the
`:root` block here too.

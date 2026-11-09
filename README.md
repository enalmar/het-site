# het-site

The marketing site for **Health Export Tool**, a static page with no build step.
It is the sibling of `hit-site` (Health Import Tool): the same structure, the
same phone frame and the same scroll behaviour, re-tinted green.

Open `index.html` in a browser, or serve the folder:

```bash
python3 -m http.server 8765
```

## What is here

| | |
|---|---|
| `index.html` | The whole front page |
| `privacy/` | Privacy policy. The App Store requires a reachable URL for this |
| `support/` | Support page. The App Store requires one of these too |
| `assets/site.css` | All the styling. The accent and the gradient are the app's own |
| `assets/brands/` | Garmin and Strava logos (the two the HIT site's set already had), and Apple's official App Store badge. Intervals.icu and TrainingPeaks are set as plain words |
| `screenshots/` | Real captures of the shipped interface. 1020px wide, JPEG. The phone frame round each is drawn in CSS |
| `404.html`, `robots.txt`, `sitemap.xml`, `CNAME` | Housekeeping |
| `tools/og-source.html` | Source for the social card, `assets/og.png`. Not served as a page |
| `tools/make-screenshots.sh` | Turns the native captures into the JPEGs in `screenshots/` |

## Going live (done)

1. **DNS** is live: GoDaddy has `het CNAME enalmar.github.io`, Pages has the
   custom domain, and HTTPS is enforced (certificate approved 8 Nov 2026).
2. **The App Store link** is live since approval on 9 Nov 2026: the nav badge,
   the hero and the price panel link to
   `https://apps.apple.com/gb/app/health-export-tool/id6832320729`, the Smart App
   Banner carries `app-id=6832320729`, and the structured data has `installUrl`.
3. **The price** is £4.99 (US$4.99), the purchase's base price in the UK as
   set in App Store Connect, matching HIT. The structured data's
   `priceCurrency` is GBP.

The support address is already `support@enalmar.uk` on both prose pages.

## Where it serves

`https://het.enalmar.uk/`, from `main` at the root of
[enalmar/het-site](https://github.com/enalmar/het-site), served by GitHub Pages.

## About the screenshots

The captures are the real app, HET 1.0, on an iPhone simulator with the status
bar set to 9:41, against **invented showcase data** seeded into the simulator's
Health. Unlike the HIT site's reference archive, the numbers they show (576
workouts, 731 days, 20 kinds, and so on) are not anyone's history and are not
claims. Do not quote them in the page copy. The interface is in light mode
except `het-home-dark.jpg`, the hero's front phone. The Files captures are
Apple's own app showing that same export. None is a composite. If the app's
interface changes, retake them rather than editing them.

**Never put a bare screenshot on the page.** Every capture goes inside the CSS
phone frame:

```html
<figure class="device">
  <div class="screen"><img src="screenshots/….jpg" width="1020" height="2217" alt="…"></div>
</figure>
```

The frame draws the titanium edge, the bezel, the Dynamic Island and the side
buttons, all as a share of the phone's width, so it holds at any size. The
island is always drawn because simulator captures only sometimes include it.
Add `sm` for the smaller phones in the four-step flow.

Captured at native resolution (1206 x 2622), then resized **by width** to
1020px and encoded as JPEG at quality 86. `sips` rounds the height down, so the
JPEGs are 1020 x 2217 and the `<img>` tags say so. 1020px is 3x the largest size
a phone is displayed at. The originals live in `_captures/`, which is ignored.
Run `tools/make-screenshots.sh` to regenerate the JPEGs from them.

Two traps, both of which caught the HIT site:

- `sips -Z` fits the **longest** side. On a portrait screenshot that sets the
  height and leaves the width far too small. Use `sips --resampleWidth`.
- `sips ... --out <same file>` overwrites in place. Keep the natives somewhere
  else, or a second pass has nothing good to work from. The script never
  writes into `_captures/`.

The light-mode captures come out at 120 to 300KB each, larger than HIT's dark
ones. Everything below the hero is `loading="lazy"`, so a first view fetches the
two hero phones and nothing else.

## Claims on this page

Everything stated here is either verifiable in the app's repository
(`FIT2health`, the `HET` target and `HITKit/Sources/HITKit/HealthExport`) or
was observed in a run. Specifically:

- **The zip's layout** (`README.txt`, `Workouts/`, `Health Data/`,
  `manifest.json`, a `readme.txt` per folder, monthly files for busy kinds) is
  what `HealthExportRun.swift` writes. The folder names in the file tree are the
  app's own, from `HealthTypeCatalog`: note that the weight folder is
  **Weight**, blood oxygen is **Oxygen Saturation** and water is **Hydration
  Log**. File names follow the app's namer (`2026-10-09_0712_running.fit`,
  `heart_rate_2026-10.csv`); the dates are examples.
- **206 kinds of data, except clinical records** is the app's catalogue for
  iOS 27. It never requests Health Records. Prescriptions and medications come
  only through Apple's per-record picker.
- **FIT files import into Garmin Connect, Strava, Intervals.icu and
  TrainingPeaks.** The page says they *import FIT files*; it does not claim any
  upload has been verified. The support page's directions are deliberately
  general.
- **Never writes to Health**: the release build asks for read access only.
- **Restore**: the page says the export *keeps everything needed to restore
  it* (Health's record ID, source, device and metadata on every row). It does
  not promise any app that restores it.
- **100 workouts and 100 days free** is `ExportAllowance.workoutLimit` and
  `dayLimit`. The free part takes the most recent. The ledger is in the
  Keychain (`ExportLedgerStore`), so reinstalling does not reset it, and a
  workout or day already counted is never counted again.
- **US$4.99, Unlimited exports, not a subscription** is the non-consumable in
  `HET.storekit`.
- **The zip** is written to the app's temporary directory and deleted on the
  next export or the next launch (`HETExportFiles`).
- No speed claim, rating, review or download count appears anywhere, because
  none has been measured.

Do not add a number here that has not been measured.

## The scroll animation

Sections fade and lift as they are scrolled to, via `IntersectionObserver` in
`index.html`, exactly as on the HIT site. It carries the same two safety
properties:

- The CSS shows every section by default. The script opts into hiding them, and
  only once it knows it can reveal them again, so the page reads fully with
  scripting off.
- A backstop runs for the first fifteen seconds. If anything more than halfway
  up the viewport is still hidden, the effect is abandoned and every section
  goes back to plainly visible.

In a headless Chrome driven over the DevTools protocol, scrolling the page did
fire the observer and every one of the 30 sections ended up revealed, at both
1440px and 390px. That is a check, not a person watching it in a normal
window; look at it once in Safari before relying on the effect.

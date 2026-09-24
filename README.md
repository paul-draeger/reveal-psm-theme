# reveal-psm-theme

A dark reveal.js theme built on the TUD Dresden corporate design (Noto Sans,
CD colours), with a runtime that handles the things a deck shouldn't have to
write by hand: the title-slide logo band, per-slide footers, MathJax macros
resolved from a shared symbol table, numbered citations, and a nomenclature
and bibliography generated from what the slides actually use.

**[Live example →](https://paul-draeger.github.io/reveal-psm-theme/)**
([`index.html`](index.html)) — four slides that are themselves the style
documentation: type scale, colour roles, line weights and arrows, each shown
at the value the stylesheet actually assigns it.

```text
reveal-psm-theme/
  index.html             the example deck — open this first
  theme/
    tud-dark.css          the theme: CD colours, Noto Sans, the footer
    fonts/                Noto Sans, subset, WOFF2
    logos/                TUD wordmarks (white) and the ISM logo
  lib/
    tud-slides.js          the runtime: TUD.init(), citations, back matter
    shared_data.js          symbol table and bibliography the runtime reads
    mathjax/                MathJax 3, vendored
  reveal/                   reveal.js 5.2.1, vendored (dist/ and plugin/)
  template/
    presentation.html.in    the skeleton new_presentation.sh copies
  build/
    serve.py                the static server behind serve.sh, caching off
    check.html               load a deck and report what is wrong with it
  STYLE_LOG.md              corrections made after reviewing a deck
  new_presentation.sh
  serve.sh
```

Nothing is fetched from a CDN at runtime. reveal.js, MathJax and the fonts are
vendored, so a deck works on a machine with no network — a lecture hall, a
plane, a conference beamer.

## Try it locally

```sh
./serve.sh                 # http://127.0.0.1:8000/
```

A deck has to be served rather than opened as a `file://` page — the runtime
fetches the theme, the fonts and MathJax, and a `file://` origin blocks that.

## Start a new deck

```sh
./new_presentation.sh my_talk "My talk title"
./serve.sh                                    # then open decks/my_talk/
```

This symlinks `theme/`, `lib/` and `reveal/` into `decks/my_talk/`, so an
edit to the theme reaches every deck made this way at once, and copies
[`template/presentation.html.in`](template/presentation.html.in) as the
starting slide file.

## Writing a deck

A deck is one HTML file that ends with

```html
<script>
  TUD.init({ language: 'en' });
</script>
```

which replaces `Reveal.initialize()`: it configures reveal, hands MathJax the
macros known to `lib/shared_data.js`, resolves the citations, builds the back
matter, and draws the logo band and the footer.

The logos go under the title of the title slide and nowhere else; every
slide's footer carries its number and nothing else. Both are the runtime's
business, so a deck writes neither.

### Options

| Option | Default | Meaning |
|---|---|---|
| `language` | `'en'` | the wordmark and the name under it; `'de'` for a German talk |
| `assets` | `'..'` | path from the deck to `theme/` and `lib/` |
| `macros` | `{}` | extra MathJax macros for this deck |
| `includeSymbols` | `[]` | symbols to list although no slide writes them |
| `includeReferences` | `[]` | references to list although no slide cites them |
| `expandNomenclature` | `true` | also list the symbols a listed description refers to |
| `backMatterRows` | `11` | rows per back-matter slide before it breaks to the next |
| `reveal` | `{}` | merged into the reveal.js configuration |

### Slide kinds

```html
<section class="title-slide">   <!-- three rows: see below -->
<section class="section-slide"> <!-- divider; h2 and an optional p.lead -->
<section>                       <!-- content; h2 first gets the blue rule -->
<section data-layout="fill">     <!-- the figure takes the height left under
                                     the heading, caption included -->
<section data-generate="nomenclature">
<section data-generate="bibliography">
```

The title slide is three rows: the `h1`, the authors, and the logos beside
the grey imprint. Only the first two are written by hand:

```html
<section class="title-slide">
  <h1>Title</h1>
  <div class="authors">
    <div class="author-block">
      <p class="author">Jane Doe</p>
      <p class="email">jane.doe@example.edu</p>
    </div>
    <!-- one .author-block per author; they lay out as columns, three across -->
  </div>
  <p class="affiliation">Institute … <br> University</p>
  <p class="occasion">26 August 2026</p>
</section>
```

— and `TUD.init()` builds the third: it injects the logo band and moves
`.affiliation` and `.occasion` in beside it. A `.subtitle` after the `h1` is
still styled, for a deck that has a real one. A single author may also be
written as a bare `.author` and `.email`; the runtime wraps them.

Leave out a `data-generate` slide the deck has nothing for: a deck that
writes no symbol has no nomenclature, and the placeholder would print "No
symbols used". `build/check.html` reports an empty one.

### Layout classes

`.cols` is a grid, `--n` its column count, `.w-2-1` and `.w-1-2` the two
lopsided splits, `.center` aligns the columns on their middles. `.box`, with
`.warn` or `.good`, is a bordered aside. `.sm` and `.xs` step the type down,
`.muted`, `.accent` and `.accent2` recolour it. `table .num` right-aligns a
column of numbers. A `figure > img` gets a white plate unless it carries
`.transparent`, because most exported plots are drawn on white.

Every CD colour is a variable named the way the corporate design names it:
`var(--tud-blau-2)`, `var(--tud-gruen-1)`, `var(--tud-grau-60)`.

### Maths

Write the symbol commands `lib/shared_data.js` knows, e.g.

```html
<p>\[ \re = \frac{\ub \, \db}{\vis} \]</p>
```

`\(...\)` is inline maths and `\[...\]` display; `$…$` is deliberately *not*
a delimiter, so a dollar sign in prose stays a dollar sign. Every symbol a
slide writes lands in the nomenclature, together with the symbols its own
description refers to.

### Citations

`[@bibtex_key]` in prose, or `<cite data-key="a,b">` where the markup is
easier. They are numbered in order of first appearance and resolved against
the bibliography in `lib/shared_data.js`; the bibliography slide lists
exactly what was cited, in that order.

### Videos

A video is a figure that moves, not a recording someone plays, so it carries
no controls:

```html
<video data-src="lauf.mp4" data-autoplay loop muted playsinline
       aria-label="what the run shows"></video>
```

reveal starts it when the slide comes up and stops it when the slide goes;
the `data-src` form loads the file then rather than at the start of the deck.

### Speaker notes

`<aside class="notes">…</aside>`, shown in the speaker view (`S`).

## After reviewing a deck

Corrections to the style are recorded in [STYLE_LOG.md](STYLE_LOG.md), with
the reason and the file they were made in. Add an entry when you change the
style after looking at a deck — a fix in `theme/` or `lib/` reaches every
deck at once, a fix in `template/` only the ones made afterwards, so the log
is what keeps the two from drifting apart.

## Known limits

External `data-markdown` files are fetched by reveal after `TUD.init()` has
already scanned the slides, so symbols and citations inside them are not
collected. Write slides inline, or in a `<script type="text/template">`
block, or name what is missing with `includeSymbols` and `includeReferences`.

The `?print-pdf` handout is reveal's own export and depends on the browser's
print dialog.

## License

The theme and runtime code in `theme/` and `lib/tud-slides.js` are this
repository's own. Vendored dependencies keep their own licenses:
reveal.js ([MIT](reveal/LICENSE)), MathJax
([Apache 2.0](lib/mathjax/LICENSE)), and Noto Sans
([SIL OFL](theme/fonts/OFL.txt)). The TUD wordmarks and colour palette follow
TU Dresden's corporate design.

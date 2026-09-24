# Style log

Formal corrections made to the presentation style after reviewing a deck, so
that the next deck starts from the corrected version instead of repeating the
mistake. One entry per review.

Each rule says **what** was wrong, **why**, and **where** it was fixed — because
the two places behave differently:

- a fix in `S00_main` (`theme/tud-dark.css`, `lib/tud-slides.js`) reaches every
  deck the moment it is saved, old ones included;
- a fix in `template/presentation.html.in` reaches only decks created *after*
  it, since a deck's slides are its own file;
- a fix in a deck's own `versions/*.html` reaches that deck alone.

So a rule about how the style *looks* belongs in `S00_main`, and a rule about
what a deck *says* belongs in the template — with the existing decks corrected
by hand.

---

## 2026-09-16 — der Strich unter dem Folientitel ist weg

### Zwei von drei Decks haben ihn abgeschaltet, also gehoert das ins Theme

Der Folientitel trug einen 3 px starken Strich in Blau 2. `beispiel/` und S02
haben ihn beide mit `border-bottom-color: transparent` wieder ausgeschaltet,
jedes mit eigener Begruendung und eigenem Kommentar; nur S01 zeigte ihn noch.
Damit stand dieselbe Entscheidung an drei Stellen und in zwei Fassungen --
genau der Zustand, gegen den dieses Log geschrieben ist.

Der Strich ist jetzt im Theme weg. Was er getragen hat, bleibt: seine 3 px
stehen im `padding-bottom` der Titelregel, `calc(0.35em + 3px)`. Ohne das
rueckte der Inhalt jeder Folie drei Punkte hoch und jede gemessene Hoehe waere
hin -- die Ueberlaufpruefung in `build/check.html` misst gegen die Fusszeile,
nicht gegen einen festen Wert, aber die Folien selbst sind auf diese Hoehen
gesetzt.

Warum ueberhaupt weg: ein Strich quer ueber eine dunkle Folie zieht den Blick
auf den Rahmen statt auf den Inhalt, und wozu die Folie gehoert, sagt schon das
Thema links im Titel.

**S01 verliert ihn damit auch.** Das ist der Punkt an der Sache -- ein Deck soll
nicht seinen eigenen Folienkopf mitbringen.

*Fixed in:* `theme/tud-dark.css`. Der Override in `beispiel/` ist mit raus, der
in S02 war beim Umbau auf v2 schon gefallen.

---

## 2026-09-15 — the back matter learned the second language

### A German talk had an English nomenclature

`language` switched the wordmark on the title slide and nothing else, so a deck
written in German ended with a slide headed "Nomenclature", its groups called
"Latin" and "Greek", and a bibliography headed "References". None of that text
is written by an author — it is set at load time, which also means an author
could not correct it: the words did not exist anywhere in the deck.

`lib/tud-slides.js` now carries a two-language table (`TEXTS`) and reads it
through `say()`; `language: 'de'` picks it. Covered are both back-matter
headings, the three group headings plus "Other", and the two empty states
("No symbols used.", "Nothing cited.").

**A heading the author wrote still wins** — `fillBackMatter` takes a `h1`–`h3`
from the placeholder before it falls back to the table, as it always did.

Fixed in `S00_main`, so it reaches every deck: an English deck says exactly what
it said before, because `en` is the default and holds the old wording.

**What this does not reach: the descriptions themselves.** They come from
`shared/variables.tex`, which every report of the repository links, so the text
beside a symbol is English wherever it appears. Translating it there would
change every LaTeX document at once; a per-deck override does not exist.

---

## 2026-08-27 (later) — the sketches became files

### A symbol inside an image is not in the nomenclature

The FLUIDICS sketches moved out of the deck into `Figures/*.svg`, which they
could do once their labels were `<text>` with tspans instead of MathJax. The
slides are `<img>` now and are much simpler for it.

What breaks silently: `collectSymbols` reads the slide's own markup, so a
symbol drawn inside an image is not seen, and the nomenclature loses it without
saying so. `includeSymbols` in `TUD.init()` is the counterweight — S01 lists
the eleven the two sketches write.

So the rule is: **a sketch that becomes a file takes its symbols out of the
deck's reach, and they have to be named back in.** The alternative — keeping a
sketch inline for the sake of the collector — is the wrong trade once the
labels no longer need MathJax.

*Applied in:* `S01_cosmic_kick_off`. No change to `lib/tud-slides.js`;
`includeSymbols` already existed for exactly this.

### A row of figures with unlike aspects is bottom-aligned, not centred

FLUIDICS (1) puts three panels across the width whose aspects are 0.57, 1.52
and 1.59. Centring each on the slide's middle put their captions at three
different heights and the row read as three unrelated pictures.

Bottom-aligning the images — one caption line across the slide — is what makes
them a row. It also means a caption must fit its panel's width on one line: at
0.6em the narrowest panel's caption wrapped and broke the line the alignment
exists to make, so `.stage figcaption` is 0.55em.

The other half of the fix was to the figure rather than the layout: the forcing
plot was 2.4:1 and far shorter than anything beside it. Redrawn at 1.6:1 it
matches the photograph's height, and a panel scaled down by a fifth needs its
labels set up by the same fifth to come out the size of its neighbours'.

*Applied in:* `S01_cosmic_kick_off`, `Figures/make_sketches.py`.

### A drawing beside a photograph agrees with the photograph

The deck's colour code makes the warm colour the gas phase. On the simulation
setup sketch Orange 2 is the liquid instead, because that sketch sits next to a
photograph of the real tank and the real liquid is amber. A reader comparing
the two should not have to invert the colours to do it.

A code is worth keeping until keeping it costs more than breaking it. This is
the exception that says so; it is written at the head of the builder that draws
it, not left to be rediscovered.

*Applied in:* `S01_cosmic_kick_off`, `Figures/make_sketches.py`.

## 2026-08-27 — restructuring S01, and drawing what was screenshotted

### The background is #191919, not black

CD Schwarz is #000000, and a beamer renders it as a dead patch: the projector
has no black, so the screen shows whatever the room lights leave, and every
figure that is not quite black shows its own rectangle against it. #191919 is
dark enough that the CD's light accents keep their contrast and light enough to
hide the edge of a dark figure.

Only the `--tud-bg` role changed; the palette is still the CD's, so a light
variant of this theme would still redefine the roles and leave the colours
alone.

*Fixed in:* `theme/tud-dark.css`.

### The slide title is smaller

1.35em put the title of a content slide at almost two thirds the size of the
title on the title slide, which made every slide look like it was announcing
something. 1.05em is a heading over a body, which is what it is. The blue rule
under it does the work of marking the slide's top.

*Fixed in:* `theme/tud-dark.css`.

### A diagram is drawn, not screenshotted

Three of the source deck's figures were screenshots of white documents: the
structure plan, the work and time plan, the two sketches of the rig. On a dark
slide a white screenshot is a white rectangle, its 12 pt text is unreadable at
slide width, and neither can be fixed without redrawing it. All four are
drawings now — one generated (`Figures/make_gantt.py`), three inline in the
deck.

Inline rather than a file for the three: they carry MathJax labels, they appear
a piece at a time, and — since the repository ignores `*.svg` — an inline
drawing is versioned with the deck while a file is not.

*Applied in:* `S01_cosmic_kick_off`.

### A sketch is an svg with its labels laid over it

MathJax renders into HTML and cannot typeset into SVG, so a sketch that wants
\(\rotrate\) on it cannot put the label in an `<svg><text>`. A `.vg` box holds
the svg and positions HTML labels on top of it.

The one rule that makes it work: **the box's width and height must equal the
viewBox's**. Give the box a different aspect and the svg is letterboxed inside
it — the drawing no longer sits where its coordinates say, and every label is
off by the same silent amount, which looks like a hand-placement error rather
than a scaling one. Resize a sketch by editing the viewBox and the box together.

*Fixed in:* `theme/tud-dark.css` (`.vg`, `.lbl`).

### A leader between two things needs one coordinate system

An arrow from a photo to a point of a sketch beside it cannot be drawn by
either of them: it belongs to the slide. `.stage` positions its children in
slide units and carries one `svg.leaders` over the whole area, in the same
units, so a leader's endpoint is read straight off the sketch it points into.

The leaders svg is sized in px rather than percentages for the reason above —
a percentage would let its viewBox scale with the stage and move every endpoint.

*Fixed in:* `theme/tud-dark.css` (`.stage`), `lib/tud-slides.js` is untouched;
a stage is opted into with `data-layout="fill"`, which gives it the height left
under the slide title.

### A deck picks one colour code and keeps it

The plan, the structure diagram and the bars all name the same two partners.
Blau 2 is FMR and Gelb 2 is PSM on every slide, so the reader learns the code
once. A colour that means something is then not free for anything else: the gas
phase on the setup sketch is Orange 2 precisely because Gelb 2 is taken.

Set as two variables at the top of the deck's own stylesheet rather than
written out, so the code is stated in one place.

*Applied in:* `S01_cosmic_kick_off`.

### A symbol on a sketch is a glossary entry, not TeX in the slide

Writing `\(\Omega\)` into a sketch would have kept it out of the nomenclature
and out of the reports. The ten quantities the FLUIDICS sketches name are
entries in `shared/variables.tex`, so the slide writes `data-sym="tankdia"`,
the runtime fills in the formula, and the nomenclature builds itself — the same
bargain the reports get from `\glsadd`.

One clash worth knowing about: `\Omega` was already the spatial domain, so the
rotation rate is a separate entry whose note says so. Two entries can share a
glyph; they cannot share a command.

*Applied in:* `shared/variables.tex`, `S01_cosmic_kick_off`.

## 2026-08-26 — building the COSMIC content into S01

### The server sends no-store

A citation added to `literatur.bib` came out as `[?]`, and the deck looked
broken. It was not: `sync_shared.py` had regenerated `shared_data.js`, and the
browser was still holding the copy from before. `python3 -m http.server` sends
no cache headers, so a browser applies its own heuristic and keeps a file that
was regenerated behind its back.

`serve.sh` now runs `build/serve.py`, which sends
`Cache-Control: no-store` on everything. Nothing served while authoring is
worth caching, and a stale file costs far more than a re-fetch.

*Fixed in:* `build/serve.py` (new), `serve.sh`.

### A figure slide can be told to fill the height

A full-width plan with a caption under it took the whole slide for the image
and pushed its caption past the footer. Writing the slide as
`<section data-layout="fill">` wraps it in a flex column: the figure takes the
height left under the heading, the image is contained inside it, and the caption
keeps its line.

The heading rule had to learn about the wrapper — `.reveal section > h2:first-child`
stopped matching once the heading became a child of the wrapper instead of the
section, and the slide title lost its top margin. Any future wrapper needs the
same treatment.

*Fixed in:* `lib/tud-slides.js`, `theme/tud-dark.css`.

### A figure in a column is capped at 400 px

Without a cap a tall figure takes the whole slide, and whatever shares the
column with it — or follows it — lands under the footer. The deck is a fixed
1280 × 720 with a 546 px type area, so this is a slide measurement, not a guess.
A slide that needs a different height overrides it, as the validation slide of
S01 does.

*Fixed in:* `theme/tud-dark.css`.

### An empty back-matter slide is left out, not left empty

A deck that writes no symbol has no nomenclature. The placeholder prints
"No symbols used", which is worse than not printing the slide, so the deck drops
the placeholder instead. The check reports an empty back-matter slide for
exactly this reason.

*Applied in:* `S01_cosmic_kick_off`.

## 2026-08-26 — review of S01_cosmic_kick_off

### The title slide carries no subtitle

A line under the title repeating the deck's identifier said nothing the title
and the footer did not already say.

*Fixed in:* `template/presentation.html.in`, `S01_cosmic_kick_off`. The `.subtitle` class
stays in the theme for a deck that has a real subtitle to give.

### The wordmark follows the language of the talk; English is the default

`language: 'en'` gives the English wordmark and "TUD Dresden University of
Technology" under it, `'de'` gives the German wordmark and "Technische
Universität Dresden". The institute and chair lines stay English either way —
they are an address, and the English form is the one used abroad.

English is what a new deck starts with, because most of them are given in
English. Switch a German talk over in one word.

*Set in:* `template/presentation.html.in` (`language: 'en'`). `S01_cosmic_kick_off` is on
`'de'`, as a deliberate exception that also shows the German variant works.

### The title slide is three rows

Title, then the authors, then the logos beside the grey imprint. The logos began
as a band across the top, above the heading: the audience reads the title first,
and who is speaking is the second question, not the first. Putting them on the
imprint's line makes that one block — who, where, when — instead of two.

The authors row is a set of columns, one `.author-block` each, so a deck with
three authors reads across rather than down. The runtime wraps a bare `.author`
and `.email` into one block, so a single-author deck needs no extra markup.

*Fixed in:* `theme/tud-dark.css`, `lib/tud-slides.js`,
`template/presentation.html.in`, `S01_cosmic_kick_off`.

### The bottom row is tight and unruled

The logos and the imprint were far apart with a vertical rule between them,
which read as two separate blocks rather than one line of provenance. The rule
is gone, the logos are larger (100 px and 90 px), the space between the two
logos is smaller than the space between the pair and the text, and the text sits
close enough to belong to them.

The nesting of the gaps is what makes the row read as one thing: logo-to-logo
tighter than logos-to-text, and logos-to-text tighter than the row's distance
from the authors above.

*Fixed in:* `theme/tud-dark.css`.

### The title takes the accent blue, the address takes white

The two colours were the wrong way round: the title was white and the e-mail
address the accent blue, so the eye landed on the address first. Swapped —
title in Blau 2, address in white. The author's name stays white and is told
apart from the address by weight and size rather than by hue.

This is the title slide only. A slide title on a content slide stays white above
its blue rule.

*Fixed in:* `theme/tud-dark.css`.

### One margin on all four edges, and the rows fill the height

The type area was inset 60 px at the sides and 40 px at the top, and the footer
band took 56 px at the bottom — three different edges. It is one margin now,
72 px all the way round, with the slide number as the last line *inside* it
rather than a band beneath it. So the frame is the same wherever you look, and
there is a little more air on the left.

On the title slide the three rows are spread over the full height by a flex
column on an inner wrapper — not on the `<section>`, for the reason in the entry
below. Top and bottom are used instead of the block sitting in the upper half
with dead space under it.

The deck check measured the old 56 px footer as a constant and would have
silently allowed 46 px of overrun after this change. It measures the slide
number's actual position now, so the limit follows the margins by itself.

*Fixed in:* `theme/tud-dark.css`, `lib/tud-slides.js`, `build/check.html`.

### The title slide is centred

Title, authors, logos and imprint all sit on the middle axis. Half-centring —
the title over a left-aligned foot — reads as a mistake rather than a choice,
so the whole page moved. The imprint keeps its own lines flush left inside the
centred row, because three ragged-right lines set centred look accidental.

The gap between the authors and the foot was reduced by taking `2.6em` off the
top of the free space before the two auto margins split it: what is left splits
into a larger gap above the title and a smaller one below the authors. The
figure is kept well under the free space a full title slide has, so a long title
with wrapped authors runs the gaps down to nothing instead of overflowing.

One trap: the wrapper is a plain `<div>`, and reveal's reset does not set
`box-sizing`, so its `padding-top` was added to `height: 100%` instead of coming
out of it, and pushed the foot 51 px past the bottom margin. It is `border-box`
now.

*Fixed in:* `theme/tud-dark.css`.

### The title slide is two groups, spaced by the type rather than by pixels

Spreading the three rows evenly over the height put as much air between the
title and the authors as between the authors and the logos, which is wrong:
the title and the authors are one thought, the logos and the imprint another.

So the title carries `margin-top: auto` and the authors `margin-bottom: auto`.
The two autos split whatever space is left, which centres the title group above
a foot block that stays on the bottom margin — and the gap inside the group is
`0.42em` of the title, so it follows the type instead of a pixel count. The
composition holds for a one-line title and a three-line one without a number
being retuned.

Two traps met on the way, both worth remembering:

- An `auto` margin written in a separate rule loses to the `margin` shorthand
  in the rule that styles the element, which silently resets it to zero. The
  autos have to live in that same rule.
- The section dividers were centred with a hand-measured `padding-top`, which
  had to be recomputed every time the margins moved. They use the same
  wrapper-with-a-flex-column trick as the title slide now, and centre by
  themselves.

*Fixed in:* `theme/tud-dark.css`, `lib/tud-slides.js`.

### Back matter keeps a row in hand

`backMatterRows` was 11, which fitted exactly and then overran by 12–28 px once
the margins grew. A nomenclature row is not a fixed height — a description that
wraps to a second line costs more — so the budget is 10 now and the pages have
room to breathe. One extra slide at the back is cheaper than a table running
into the slide number.

*Fixed in:* `lib/tud-slides.js`.

### Vertical placement is padding, not a centred flex column

The title slide and the section dividers were written as centred flex columns
and were silently top-aligned instead: reveal's own
`.reveal .slides>section.present { display: block }` is more specific than
`.reveal section.title-slide`, and a rule specific enough to win would also
override the `display: none` that hides every other slide. Both are placed by a flex column on an inner
wrapper now, which is not subject to that rule at all — see the entry above.
Anything that still needs a fixed offset uses `padding`, which behaves the same
on screen, in the overview and in the PDF export.

*Fixed in:* `theme/tud-dark.css`.

### Logos appear on the title slide only

Every slide repeated a small TUD mark and the institute logo in the footer.
Nobody looks at them twice, and they cost the width that content could use.

*Fixed in:* `lib/tud-slides.js`, `theme/tud-dark.css`.

### The footer is the slide number and nothing else

The running title and the rule above the footer went with the logos. A rule
across the bottom of a dark slide draws the eye to the frame instead of the
content, and the running title duplicates the section divider.

The `title` option of `TUD.init()` was removed with it — it named the running
title and now names nothing. A deck's `<title>` element still names the browser
tab.

*Fixed in:* `lib/tud-slides.js`, `theme/tud-dark.css`,
`template/presentation.html.in`, `S01_cosmic_kick_off`.

### Continued back matter is numbered, not marked "(cont.)"

A nomenclature over three slides read "Nomenclature", "Nomenclature (cont.)",
"Nomenclature (cont.)" — which does not say how far in the reader is. It reads
"Nomenclature 2 / 3" now, and only when there is more than one page. Applies to
the bibliography too. The group heading inside a continued table ("Latin",
"Greek") simply repeats, without a marker of its own.

*Fixed in:* `lib/tud-slides.js`, `theme/tud-dark.css`.

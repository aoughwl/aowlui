# aowlui

**The aoughwl lab UI, as nimony values.** The design tokens, the component
stylesheet and the base layer of the original lab — ported out of 3055 lines of
flat CSS into typed values, with a round-trip gate proving the port did not
change the design.

```nim
import aowlui

for c in labComponents():
  echo c.name, "  (", c.family, ", ", c.rules.len, " rules)"

echo render(labComponents()[0])     # back to exactly the CSS the lab shipped
```

## Why this is not just a stylesheet in a string

The lab's `styles.css` was 3055 flat lines. Which rules belonged together, which
were *states* of the same thing, and which were *parts* of it lived only in the
ordering and in whoever last edited the file. Here a component is a value:

```nim
Component(name: "ghost-button", family: "controls", rules: @[
  Rule(kind: stBase,  decls: "…"),
  Rule(kind: stHover, decls: "…"),
  Rule(kind: stFlag, flag: "active", decls: "…"),
  Rule(part: " .icon", kind: stBase, decls: "…")])
```

which buys three things the stylesheet could not have:

1. **States are declared, not spelled.** `.ghost-button:hover` and
   `.ghost-button.active` were unrelated selectors five lines apart. Here they
   are states *of the same component*, so "what are this thing's states" is a
   query rather than a reading exercise.
2. **Parts are owned.** `.owl-mark .owl-eye` belongs to the owl, so the owl moves
   or is deleted as one piece.
3. **It is content-addressed.** `digest` hashes a component's rules, so identical
   components collapse to one identity regardless of what a human called them —
   the seam where aowlui meets the aoughwl store.

Tokens are values too: one `TokenDef` per token carrying both themes' readings,
so the `:root` blocks are *emitted* rather than maintained in two places, and a
component names a colour by an enum instead of by spelling `var(--name)`.

## The port is proven, not asserted

`tools/ingest` reads `reference/styles.css`, classifies all **429 selectors**, and
generates `aowlui/lab/components.nim` — **195 components** plus **64 raw** rules
(at-rules, `:root`, bare element selectors) carried verbatim.

Nothing is dropped and nothing is guessed: a selector the component model does
not explain becomes a `stRaw` rule rather than a plausible-looking invention, so
the raw count is an honest measure of how much of the sheet the model actually
explains.

`tests/tround.nim` then renders the components back and compares against the
original **declaration by declaration, in both directions**:

```
original declarations: 1739
ported declarations:   1739
missing:  0
invented: 0
ROUND-TRIP OK
```

The comparison is on the declaration multiset rather than on text, because the
port deliberately regroups rules by component — byte equality would fail for a
*faithful* port and prove nothing. What must hold is that every
`(selector, property, value)` the lab shipped is still emitted, and that none
were invented.

This gate earns its keep. It caught the port silently turning every
`.owner .part` descendant selector into a `.owner.part` compound one — the
declaration counts matched exactly (1739 = 1739) while the design was broken,
which is precisely the failure a count-based or eyeball check would have passed.

## The component pack

The pack proper — 27 components, all spelled with the `web:` DSL, public API
without the old `ui` prefix:

`button` `iconButton` `textInput` `badge` `pill` `avatar` `divider` `card`
`surface` `stack` `cluster` `sidebar` `toolbar` `menuItem` `sectionHeader`
`formField` `stat` `meter` `progressBar` `callout` `toast` `dialog`
`emptyState` `codeBlock` `tab` `tabs` `breadcrumb`

plus `renderTheme()` for the token stylesheet, `renderStylesheet()` for the
scoped component styles, and `styleErrors()` for CSS validation feedback.

New components should reuse the existing `web:` DSL shape so styling and
pseudo-state handling stay consistent across the pack.

## Layout

| path | what |
| --- | --- |
| `ui.nim` | the component pack |
| `theme.nim` | the pack's theme tokens |
| `variants.nim` | variant/size vocabulary |
| `components/` | the pack's components, by family |
| `aowlui/tokens.nim` | the palette, per theme, as data |
| `aowlui/base.nim` | the ground layer: box model, scrollbars, selection, page gradient |
| `aowlui/component.nim` | what a component *is* — states, parts, digest, render |
| `aowlui/lab/components.nim` | **generated** — the ported lab components |
| `tools/ingest.nim` | the CSS → components ingester |
| `reference/` | the original lab `styles.css` / `index.html` / `lab.js` |

## Run the gates

```sh
./tests/run.sh        # regenerates from reference/, then proves the round-trip
```

## The page

`aowlui/lab/shell.nim` is the port of `reference/index.html` — the boot overlay,
the mount point, the head and the ordered kernel scripts, as `component`s:

```nim
import aowlui
echo labPage()      # the whole lab page, byte-faithful to the original
```

Three details of the original are load-bearing and preserved exactly:

- **The boot overlay is not decoration.** It paints on the first byte so a cold
  load reads as "working" rather than a dead colour while the kernel parses. It
  is `role="status" aria-live="polite"`, and the pulse is `aria-hidden` because
  three bouncing dots are noise to announce.
- **The boot CSS is the only CSS in the page**, inline and self-contained so it
  cannot block on a request. It is carried verbatim rather than built from
  `Style` values, because it is mostly `@keyframes` and `@media` — at-rules are
  not declarations, and pretending otherwise would emit CSS that does not say
  what the original said. `labPage()` passes `useStyles = false` for the same
  reason: the real theme loads from the substrate, so shipping the generated
  component stylesheet here would defeat that.
- **`data-cfasync="false"` on every script.** Rocket Loader re-injects classic
  scripts, double-executing their top-level `const`; these are ordered,
  interdependent kernel scripts that must run once, in order.

`tests/tshell.nim` gates it the same way the CSS is gated — not on bytes (the
reference is hand-written, with comments and its own attribute order, so a
faithful port would fail that and prove nothing) but on every element the
reference's body declares, plus the kernel scripts **in the reference's own
order**. The script list is read out of `reference/index.html` at test time
rather than transcribed, so the gate cannot drift from what it checks.

## Status

Done: tokens, the base layer, the component model, the full CSS port with its
round-trip gate, and the page markup with its own gate.

Not ported: `reference/lab.js`. That file is bootstrap *behaviour* — SSE
hydration, the keyed reconciler, widget/style bundle loading — not markup. It
belongs on the JS backend with [`web-state`](https://github.com/aoughwl/web-state),
whose reactive DOM binding now exists but is not yet wired to these components.

## Built on

- [`css`](https://github.com/aoughwl/css) — the CSS parser the ingester reads with.
- [`web`](https://github.com/aoughwl/web) — the HTML+CSS DSL the markup port will target.

## License

MIT.
>>>>>>> eabbf23 (aowlui: the lab UI as values, with the port proven)

## aowlui/kit/theme — the whole design system as a handful of globals.
##
## Two colour ramps and two numbers. Everything else is derived.
##
## * **Colour is primary / secondary / tertiary**, twice: once for ink
##   (`primary`, `secondary`, `tertiary`) and once for surfaces (`background`,
##   `backgroundSecondary`, `backgroundTertiary`). The tertiary of each is
##   OPTIONAL — leave it `""` and it is not emitted, and anything that would
##   have used it falls back to the secondary. A kit with three surface levels
##   and three ink levels covers window / panel / inset and text / label / hint
##   without inventing a role per component.
##
## * **`scale` multiplies every length in the system.** Every spacing, radius,
##   control height and font size derives from `--u`, and `--u` is
##   `scale × unit`. Setting `--scale: 1.25` on `:root` makes the entire UI 25%
##   larger — at runtime, with no recompile and no component touched, because
##   the multiplication happens in `calc()` in the browser rather than here.
##
## * **`roundness` multiplies every corner.** `--round: 0` squares the entire
##   kit; `--round: 2` doubles every radius. Same mechanism.
##
## This is why the per-component CSS is small: a component declares what is
## structurally true of it (it is a row, it has a border, it clips) and takes
## every number from a token. A rule that hard-codes `8px` has opted out of the
## scale and is a defect.

type
  Theme* = object
    ## The complete design system. Every field is a CSS value, so a theme can
    ## carry `color-mix(…)`, a gradient, or a custom property reference.
    primary*: string              ## principal ink — body text
    secondary*: string            ## secondary ink — labels, metadata
    tertiary*: string             ## optional third ink — hints, disabled
    accent*: string               ## the one saturated colour: selection, focus
    danger*: string

    background*: string           ## the page / window surface
    backgroundSecondary*: string  ## panels, toolbars — one level in
    backgroundTertiary*: string   ## optional inset: code wells, inputs

    border*: string               ## hairline
    shadow*: string

    scale*: string                ## unitless multiplier over every length
    roundness*: string            ## unitless multiplier over every radius
    unit*: string                 ## the length `scale` multiplies (default 4px)
    fontSize*: string             ## base font size, before `scale`
    fontUi*: string
    fontMono*: string

proc darkTheme*(): Theme =
  ## The lab's palette, re-expressed in the three-level system.
  Theme(
    primary: "#f4f1ea", secondary: "#aaa39a", tertiary: "#8e877d",
    accent: "#5bd49c", danger: "#ff6b61",
    background: "#101214", backgroundSecondary: "#191b20",
    backgroundTertiary: "#0c0d0f",
    border: "rgba(244,241,234,.12)",
    shadow: "0 22px 70px rgba(0,0,0,.34)",
    scale: "1", roundness: "1", unit: "4px", fontSize: "13px",
    fontUi: "Inter, ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif",
    fontMono: "'SFMono-Regular', ui-monospace, Menlo, Consolas, monospace")

proc lightTheme*(): Theme =
  ## Same geometry, inverted ramps. `scale`/`roundness`/`unit` are deliberately
  ## identical: they are structure, not palette, and a theme switch that also
  ## resized the UI would be a bug.
  Theme(
    primary: "#1d1d1f", secondary: "#72706b", tertiary: "#8c887f",
    accent: "#178f5c", danger: "#b42318",
    background: "#f7f4ef", backgroundSecondary: "#ffffff",
    backgroundTertiary: "#eee9df",
    border: "rgba(30,28,24,.12)",
    shadow: "0 18px 60px rgba(34,28,20,.12)",
    scale: "1", roundness: "1", unit: "4px", fontSize: "13px",
    fontUi: "Inter, ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif",
    fontMono: "'SFMono-Regular', ui-monospace, Menlo, Consolas, monospace")

## ── MORE THAN TWO ─────────────────────────────────────────────────────────────
##
## `dark` and `light` were the whole set, and "toggle the theme" was a boolean.
## Nothing in the system required that: a theme is fifteen strings, the sheet
## reads them through `var()`, and `data-theme` is already an arbitrary name.
## The base theme is emitted as `:root`; every other one is emitted as
## `:root[data-theme="NAME"]` and overrides only the COLOUR ramp, because the
## metrics are structure and a theme switch that resized the UI would be a bug.
##
## A theme adds a row here and appears in every picker that reads `themeNames()`.
## No component changes, and nothing recompiles on the browser's side.

const
  Mono* = "'SFMono-Regular', ui-monospace, Menlo, Consolas, monospace"
  Ui* = "Inter, ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif"

type
  NamedTheme* = object
    name*: string        ## the `data-theme` value; "" for the base
    label*: string       ## what a picker shows
    theme*: Theme

proc geom(t: var Theme) =
  t.scale = "1"; t.roundness = "1"; t.unit = "4px"; t.fontSize = "13px"
  t.fontUi = Ui; t.fontMono = Mono

proc nordTheme*(): Theme =
  result = Theme(
    primary: "#eceff4", secondary: "#a9b3c2", tertiary: "#7f8b9c",
    accent: "#88c0d0", danger: "#bf616a",
    background: "#2e3440", backgroundSecondary: "#3b4252",
    backgroundTertiary: "#272c36",
    border: "rgba(236,239,244,.13)",
    shadow: "0 22px 70px rgba(0,0,0,.40)")
  geom result

proc gruvboxTheme*(): Theme =
  result = Theme(
    primary: "#ebdbb2", secondary: "#bdae93", tertiary: "#928374",
    accent: "#b8bb26", danger: "#fb4934",
    background: "#1d2021", backgroundSecondary: "#282828",
    backgroundTertiary: "#16181a",
    border: "rgba(235,219,178,.14)",
    shadow: "0 22px 70px rgba(0,0,0,.45)")
  geom result

proc solarizedTheme*(): Theme =
  result = Theme(
    primary: "#073642", secondary: "#586e75", tertiary: "#93a1a1",
    accent: "#268bd2", danger: "#dc322f",
    background: "#fdf6e3", backgroundSecondary: "#ffffff",
    backgroundTertiary: "#eee8d5",
    border: "rgba(7,54,66,.14)",
    shadow: "0 18px 60px rgba(101,123,131,.18)")
  geom result

proc contrastTheme*(): Theme =
  ## Not a taste. Pure black on pure white with a full-strength accent and a
  ## border that is actually visible — for anyone the low-contrast palettes lock
  ## out. A kit with a themable border colour gets this nearly for free, and a
  ## kit without one cannot have it at all.
  result = Theme(
    primary: "#ffffff", secondary: "#e0e0e0", tertiary: "#bdbdbd",
    accent: "#ffd400", danger: "#ff5252",
    background: "#000000", backgroundSecondary: "#0d0d0d",
    backgroundTertiary: "#000000",
    border: "rgba(255,255,255,.55)",
    shadow: "0 0 0 1px rgba(255,255,255,.5)")
  geom result

proc themes*(): seq[NamedTheme] =
  ## The base FIRST. Order is the order a picker shows them in.
  @[NamedTheme(name: "", label: "dark", theme: darkTheme()),
    NamedTheme(name: "light", label: "light", theme: lightTheme()),
    NamedTheme(name: "nord", label: "nord", theme: nordTheme()),
    NamedTheme(name: "gruvbox", label: "gruvbox", theme: gruvboxTheme()),
    NamedTheme(name: "solarized", label: "solarized", theme: solarizedTheme()),
    NamedTheme(name: "contrast", label: "high contrast",
               theme: contrastTheme())]

proc themeNames*(): seq[string] =
  ## What a picker cycles through. The base is spelled `dark` here even though
  ## it is emitted as bare `:root`, because a picker needs a name for it.
  result = @[]
  let ts = themes()
  var i = 0
  while i < ts.len:
    if ts[i].name.len == 0: result.add ts[i].label
    else: result.add ts[i].name
    inc i

proc isDarkTheme*(name: string): bool =
  ## Whether a theme's page surface is dark, so anything that has to pick a
  ## light/dark VARIANT of something it does not own -- an embedded editor, a
  ## syntax theme -- can ask rather than assume there are only two answers.
  name != "light" and name != "solarized"

proc orElse(a, b: string): string =
  ## An optional token falls back rather than vanishing, so a component that
  ## references the third level still renders when a theme only defines two.
  if a.len > 0: a else: b

proc colorVars(t: Theme): string =
  result = ""
  result.add "--primary:" & t.primary & ";"
  result.add "--secondary:" & t.secondary & ";"
  result.add "--tertiary:" & orElse(t.tertiary, t.secondary) & ";"
  result.add "--accent:" & t.accent & ";"
  result.add "--danger:" & t.danger & ";"
  result.add "--bg:" & t.background & ";"
  result.add "--bg-2:" & t.backgroundSecondary & ";"
  result.add "--bg-3:" & orElse(t.backgroundTertiary, t.backgroundSecondary) & ";"
  result.add "--border:" & t.border & ";"
  result.add "--shadow:" & t.shadow & ";"

proc metricVars(t: Theme): string =
  ## The derived scale. `--u` is the ONE length every other length is built from,
  ## so `--scale` reaches all of them through `calc()` at render time.
  result = ""
  result.add "--scale:" & t.scale & ";"
  result.add "--round:" & t.roundness & ";"
  result.add "--unit:" & t.unit & ";"
  result.add "--u:calc(var(--scale) * var(--unit));"
  # spacing steps
  result.add "--s1:var(--u);"
  result.add "--s2:calc(var(--u) * 2);"
  result.add "--s3:calc(var(--u) * 3);"
  result.add "--s4:calc(var(--u) * 4);"
  result.add "--s6:calc(var(--u) * 6);"
  result.add "--s8:calc(var(--u) * 8);"
  # radii — the second global
  result.add "--r1:calc(var(--round) * var(--u));"
  result.add "--r2:calc(var(--round) * var(--u) * 2);"
  result.add "--r3:calc(var(--round) * var(--u) * 3);"
  result.add "--r-pill:calc(var(--round) * 999px);"
  # Hairline and selection rail are the ONLY lengths not multiplied by --scale.
  # A border that scales stops reading as a hairline — it goes soft and the
  # surface stops looking precise — so these stay crisp at every scale. They are
  # still tokens, so a theme can thicken them deliberately; what is forbidden is
  # a rule spelling `2px` itself and quietly opting out of the system.
  result.add "--hair:1px;"
  result.add "--rail:2px;"
  # Stacking order, as three named steps rather than magic numbers scattered
  # through the sheet. A floating window is above the tiles; the drop feedback
  # is above the floating windows, because you drop ONTO them; the thing
  # following the cursor is above everything, because it is the cursor.
  result.add "--z-float:40;"
  result.add "--z-drop:60;"
  result.add "--z-drag:80;"
  # type and controls, also scaled
  result.add "--fs:calc(var(--scale) * " & t.fontSize & ");"
  result.add "--fs-sm:calc(var(--fs) * 0.85);"
  result.add "--fs-lg:calc(var(--fs) * 1.3);"
  result.add "--ctl:calc(var(--u) * 7);"     ## control height: buttons, rows
  result.add "--bar:calc(var(--u) * 9);"     ## chrome height: title bars
  result.add "--font-ui:" & t.fontUi & ";"
  result.add "--font-mono:" & t.fontMono & ";"

proc renderThemeBase*(base: Theme): string =
  ## `:root` (the base) plus one override block per named theme. Metrics are
  ## emitted once, in `:root` only — they are theme-independent, and repeating
  ## them per theme would invite the copies drifting apart. `base` is separate
  ## from `themes()[0]` so the metric knobs (`scale`, `roundness`) can be driven
  ## without touching the palette table.
  let ts = themes()
  result = ""
  var i = 0
  while i < ts.len:
    let t = ts[i]
    if t.name.len == 0:
      result.add ":root{color-scheme:dark;"
      result.add colorVars(base)
      result.add metricVars(base)
      result.add "}\n"
    else:
      var scheme = "dark"
      if not isDarkTheme(t.name): scheme = "light"
      result.add ":root[data-theme=\"" & t.name & "\"]{color-scheme:" &
                 scheme & ";"
      result.add colorVars(t.theme)
      result.add "}\n"
    inc i

proc renderTheme*(): string = renderThemeBase(darkTheme())

proc renderReset*(): string =
  ## The ground layer. Everything here is a consequence of the token system:
  ## the page takes its font size from `--fs`, so `--scale` resizes text too.
  result = "*{box-sizing:border-box}\n"
  result.add "html,body{margin:0;height:100%}\n"
  result.add "body{font-family:var(--font-ui);font-size:var(--fs);" &
             "background:var(--bg);color:var(--primary)}\n"
  result.add "@media (prefers-reduced-motion:reduce){*{animation-duration:1ms!important;" &
             "transition-duration:1ms!important}}\n"
  # ── SCROLLBARS, everywhere, from the tokens ─────────────────────────────────
  #
  # In the RESET rather than as a component, because a scrollbar is not
  # something you place — it appears on whatever overflows, and a kit that
  # themes its panels and leaves the browser's default bars on top of them is a
  # kit that stops looking themed the moment anything is longer than its box.
  # Nothing has to opt in and nothing can forget to.
  #
  # Both standards, deliberately. `scrollbar-color` is the interoperable one and
  # Firefox supports only it; the `::-webkit-` pseudo-elements are what Chrome
  # and Safari honour, and they allow the rounded, inset look. A browser applies
  # whichever it understands and ignores the other.
  result.add "*{scrollbar-color:var(--border) transparent;scrollbar-width:thin}\n"
  result.add "::-webkit-scrollbar{width:var(--s3);height:var(--s3)}\n"
  result.add "::-webkit-scrollbar-track{background:transparent}\n"
  # A thumb built from `--border` follows every theme without naming a colour,
  # and the transparent border plus background-clip is what insets it from the
  # track so it reads as a slim bar rather than filling the gutter.
  result.add "::-webkit-scrollbar-thumb{background:var(--border);" &
             "border-radius:var(--r-pill);border:var(--s1) solid transparent;" &
             "background-clip:padding-box}\n"
  result.add "::-webkit-scrollbar-thumb:hover{background:var(--secondary);" &
             "border:var(--s1) solid transparent;background-clip:padding-box}\n"
  # Where two scrollbars meet, the browser fills a small square with its own
  # default grey; it is the one part that stays visibly un-themed otherwise.
  result.add "::-webkit-scrollbar-corner{background:transparent}\n"

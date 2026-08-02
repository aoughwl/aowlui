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
  # type and controls, also scaled
  result.add "--fs:calc(var(--scale) * " & t.fontSize & ");"
  result.add "--fs-sm:calc(var(--fs) * 0.85);"
  result.add "--fs-lg:calc(var(--fs) * 1.3);"
  result.add "--ctl:calc(var(--u) * 7);"     ## control height: buttons, rows
  result.add "--bar:calc(var(--u) * 9);"     ## chrome height: title bars
  result.add "--font-ui:" & t.fontUi & ";"
  result.add "--font-mono:" & t.fontMono & ";"

proc renderTheme*(dark = darkTheme(); light = lightTheme()): string =
  ## `:root` plus the light override. Metrics are emitted once, in `:root` only —
  ## they are theme-independent, and repeating them in the light block would
  ## invite the two drifting apart.
  result = ":root{color-scheme:dark;"
  result.add colorVars(dark)
  result.add metricVars(dark)
  result.add "}\n"
  result.add ":root[data-theme=\"light\"]{color-scheme:light;"
  result.add colorVars(light)
  result.add "}\n"

proc renderReset*(): string =
  ## The ground layer. Everything here is a consequence of the token system:
  ## the page takes its font size from `--fs`, so `--scale` resizes text too.
  result = "*{box-sizing:border-box}\n"
  result.add "html,body{margin:0;height:100%}\n"
  result.add "body{font-family:var(--font-ui);font-size:var(--fs);" &
             "background:var(--bg);color:var(--primary)}\n"
  result.add "@media (prefers-reduced-motion:reduce){*{animation-duration:1ms!important;" &
             "transition-duration:1ms!important}}\n"

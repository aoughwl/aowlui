## ui/theme — the design system as DATA. Two layers:
##   (1) semantic color roles (bg/text/accent/danger/…) with dark + light values,
##   (2) primitive scales (space/radius/font/weight/z/motion) — theme-independent.
##
## Everything a component references is a NAMED token → `var(--token)`. A user
## overrides or extends the theme by appending rows here (or in a sibling pack)
## and re-running `renderTheme()`; no component changes. This follows the W4/graph
## "swap the file → different look, no recompile" rule.

type
  Token* = object
    name*: string        ## css var name without the leading `--`
    dark*: string        ## value in the base (dark) theme
    light*: string       ## value in the light theme ("" ⇒ inherit dark)

var gTokens*: seq[Token] = @[]

proc tok*(name, dark: string; light = "") =
  ## register (or override — last write wins) a token
  var i = 0
  while i < gTokens.len:
    if gTokens[i].name == name:
      gTokens[i] = Token(name: name, dark: dark, light: light)
      return
    inc i
  gTokens.add Token(name: name, dark: dark, light: light)

# ---- semantic colors (dark, light) ----------------------------------------
tok "bg",            "#101214",               "#f7f4ef"
tok "page-start",    "#17191d",               "#fbfaf7"
tok "page-end",      "#0c0d0f",               "#eee9df"
tok "panel",         "rgba(24,26,31,.86)",    "rgba(255,255,255,.86)"
tok "panel-solid",   "#191b20",               "#ffffff"
tok "assistant",     "#202228",               "#ffffff"
tok "trace",         "#17191d",               "#f1eee8"
tok "text",          "#f4f1ea",               "#1d1d1f"
tok "muted",         "#aaa39a",               "#72706b"
tok "copy",          "#d6d0c6",               "#53504a"
tok "placeholder",   "#8e877d",               "#8c887f"
tok "hairline",      "rgba(244,241,234,.12)", "rgba(30,28,24,.12)"
tok "user",          "#0a84ff",               "#0a84ff"
tok "accent",        "#5bd49c",               "#178f5c"
tok "warning",       "#ffc66d",               "#a0641b"
tok "danger",        "#ff6b61",               "#b42318"
tok "link",          "#7ab7ff",               "#0a66d8"
tok "control-bg",    "rgba(255,255,255,.07)", "rgba(255,255,255,.62)"
tok "control-hover", "rgba(255,255,255,.12)", "#ffffff"
tok "control-color", "#f2eee7",               "#35322d"
tok "chip-bg",       "rgba(255,255,255,.08)", "#ffffff"
tok "chip-color",    "#eee8df",               "#302d28"
tok "tab-bg",        "rgba(255,255,255,.06)", "#f0ede6"
tok "tab-active-bg", "rgba(255,255,255,.14)", "#ffffff"
tok "tab-color",     "#c9c0b6",               "#5d5951"
tok "send-bg",       "#f4f1ea",               "#161513"
tok "send-color",    "#111214",               "#ffffff"
tok "mark-bg",       "#f4f1ea",               "#141412"
tok "mark-color",    "#101214",               "#fff8ec"
tok "shadow",        "0 22px 70px rgba(0,0,0,.34)",   "0 18px 60px rgba(34,28,20,.12)"
tok "bubble-shadow", "0 1px 0 rgba(255,255,255,.04)", "0 1px 0 rgba(0,0,0,.04)"
tok "ease",          "cubic-bezier(.2,.8,.2,1)"        # light == dark
tok "radius",        "24px"

# ---- primitive scales (theme-independent ⇒ light left "") -----------------
tok "font-ui",   "Inter, ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif"
tok "font-mono", "'SFMono-Regular', ui-monospace, Menlo, Consolas, monospace"
tok "sp-1", ".22rem"
tok "sp-2", ".35rem"
tok "sp-3", ".5rem"
tok "sp-4", ".7rem"
tok "sp-5", ".95rem"
tok "sp-6", "1.35rem"
tok "rad-1", ".4rem"
tok "rad-2", ".55rem"
tok "rad-3", ".9rem"
tok "rad-pill", "999px"
tok "rad-lg", "24px"
tok "z-topbar", "10"
tok "z-panel", "40"
tok "z-tip", "80"

# ---- functional state tokens (encode the lab's color-mix pattern) ----------
proc washes*(role: string) =
  ## surface washes (`role`-tinted transparent) and edges (`role`-tinted hairline)
  for p in @["6", "10", "12", "14", "16", "18"]:
    tok role & "-wash-" & p,
        "color-mix(in srgb, var(--" & role & ") " & p & "%, transparent)"
  for p in @["40", "45", "48", "55", "60", "65"]:
    tok role & "-edge-" & p,
        "color-mix(in srgb, var(--" & role & ") " & p & "%, var(--hairline))"

washes "accent"
washes "user"
washes "link"
washes "danger"
washes "warning"

proc renderTheme*(): string =
  ## Emit `:root` (dark) and `:root[data-theme=light]` from the token DATA, plus
  ## the static resets (box-sizing, ui font, reduced-motion clamp).
  var dark = ":root{color-scheme:dark;"
  var light = ":root[data-theme=\"light\"]{color-scheme:light;"
  var i = 0
  while i < gTokens.len:
    let t = gTokens[i]
    dark.add "--" & t.name & ":" & t.dark & ";"
    if t.light.len > 0:
      light.add "--" & t.name & ":" & t.light & ";"
    inc i
  dark.add "}"
  light.add "}"
  result = dark & "\n" & light & "\n"
  result.add "*{box-sizing:border-box}\n"
  result.add "body{font-family:var(--font-ui);background:var(--bg);color:var(--text)}\n"
  result.add "@media (prefers-reduced-motion:reduce){*{animation-duration:1ms!important;transition-duration:1ms!important}}\n"

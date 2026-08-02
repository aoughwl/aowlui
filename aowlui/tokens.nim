## aowlui/tokens — the design tokens, as data.
##
## Ingested verbatim from the original lab stylesheet (`aoughwl_old/web/public/
## styles.css`, `:root` + `:root[data-theme="light"]`). That file hard-coded the
## palette twice, once per theme, and every component referred to it by
## `var(--name)` string. Here the token set is a value: one `TokenDef` per token
## carrying both theme's readings, so the stylesheet is *emitted* rather than
## maintained, and a component names a token by an enum instead of by spelling.
##
## A token whose `light` is the empty string is theme-invariant — it is declared
## once in `:root` and the light block does not override it (`--user`, `--radius`,
## `--ease` in the original).

type
  TokenId* = enum
    ## Every token, in stylesheet order. `ord` indexes `tokenDefs()`.
    tkBg, tkBgGlow, tkPageStart, tkPageEnd,
    tkPanel, tkPanelSolid,
    tkText, tkMuted, tkHairline,
    tkUser, tkAssistant, tkAssistantBorder,
    tkTrace, tkTraceInk,
    tkAccent, tkWarning, tkDanger,
    tkShadow, tkTopbarBg,
    tkControlBg, tkControlHover, tkControlColor,
    tkMarkBg, tkMarkColor, tkCopy,
    tkChipBg, tkChipColor,
    tkBubbleShadow, tkSystemBg, tkSystemBorder, tkTypingDot,
    tkTraceBorder, tkTracePanel, tkTraceToggleBg, tkTraceItemBorder, tkTraceCode,
    tkComposerBg,
    tkTabBg, tkTabActiveBg, tkTabColor,
    tkSendBg, tkSendColor,
    tkPlaceholder, tkLink,
    tkRadius, tkEase

  TokenDef* = object
    name*: string    ## the custom-property name, without the leading `--`
    dark*: string    ## the `:root` reading
    light*: string   ## the `[data-theme="light"]` reading; "" = invariant

  Theme* = enum
    themeDark, themeLight

proc tokenDefs*(): seq[TokenDef] =
  ## The palette. Order must match `TokenId`.
  result = @[
    TokenDef(name: "bg", dark: "#101214", light: "#f7f4ef"),
    TokenDef(name: "bg-glow", dark: "rgba(75, 117, 255, 0.16)",
             light: "rgba(255, 255, 255, 0.8)"),
    TokenDef(name: "page-start", dark: "#17191d", light: "#fbfaf7"),
    TokenDef(name: "page-end", dark: "#0c0d0f", light: "#eee9df"),
    TokenDef(name: "panel", dark: "rgba(24, 26, 31, 0.86)",
             light: "rgba(255, 255, 255, 0.86)"),
    TokenDef(name: "panel-solid", dark: "#191b20", light: "#ffffff"),
    TokenDef(name: "text", dark: "#f4f1ea", light: "#1d1d1f"),
    TokenDef(name: "muted", dark: "#aaa39a", light: "#72706b"),
    TokenDef(name: "hairline", dark: "rgba(244, 241, 234, 0.12)",
             light: "rgba(30, 28, 24, 0.12)"),
    # --user is the one hue the light theme deliberately keeps: the user bubble
    # stays iOS blue in both themes.
    TokenDef(name: "user", dark: "#0a84ff", light: ""),
    TokenDef(name: "assistant", dark: "#202228", light: "#ffffff"),
    TokenDef(name: "assistant-border", dark: "rgba(244, 241, 234, 0.1)",
             light: "rgba(30, 28, 24, 0.1)"),
    TokenDef(name: "trace", dark: "#17191d", light: "#f1eee8"),
    TokenDef(name: "trace-ink", dark: "#e8e2d8", light: "#35322d"),
    TokenDef(name: "accent", dark: "#5bd49c", light: "#178f5c"),
    TokenDef(name: "warning", dark: "#ffc66d", light: "#a0641b"),
    TokenDef(name: "danger", dark: "#ff6b61", light: "#b42318"),
    TokenDef(name: "shadow", dark: "0 22px 70px rgba(0, 0, 0, 0.34)",
             light: "0 18px 60px rgba(34, 28, 20, 0.12)"),
    TokenDef(name: "topbar-bg", dark: "rgba(16, 18, 20, 0.72)",
             light: "rgba(247, 244, 239, 0.72)"),
    TokenDef(name: "control-bg", dark: "rgba(255, 255, 255, 0.07)",
             light: "rgba(255, 255, 255, 0.62)"),
    TokenDef(name: "control-hover", dark: "rgba(255, 255, 255, 0.12)",
             light: "#fff"),
    TokenDef(name: "control-color", dark: "#f2eee7", light: "#35322d"),
    TokenDef(name: "mark-bg", dark: "#f4f1ea", light: "#141412"),
    TokenDef(name: "mark-color", dark: "#101214", light: "#fff8ec"),
    TokenDef(name: "copy", dark: "#d6d0c6", light: "#53504a"),
    TokenDef(name: "chip-bg", dark: "rgba(255, 255, 255, 0.08)", light: "#fff"),
    TokenDef(name: "chip-color", dark: "#eee8df", light: "#302d28"),
    TokenDef(name: "bubble-shadow", dark: "0 1px 0 rgba(255, 255, 255, 0.04)",
             light: "0 1px 0 rgba(0, 0, 0, 0.04)"),
    TokenDef(name: "system-bg", dark: "rgba(255, 198, 109, 0.12)",
             light: "#fff7e8"),
    TokenDef(name: "system-border", dark: "rgba(255, 198, 109, 0.22)",
             light: "rgba(160, 100, 27, 0.2)"),
    TokenDef(name: "typing-dot", dark: "#aaa39a", light: "#9b9890"),
    TokenDef(name: "trace-border", dark: "rgba(244, 241, 234, 0.1)",
             light: "rgba(30, 28, 24, 0.1)"),
    TokenDef(name: "trace-panel", dark: "rgba(0, 0, 0, 0.18)",
             light: "rgba(255, 255, 255, 0.62)"),
    TokenDef(name: "trace-toggle-bg", dark: "rgba(255, 255, 255, 0.06)",
             light: "rgba(241, 238, 232, 0.82)"),
    TokenDef(name: "trace-item-border", dark: "rgba(244, 241, 234, 0.08)",
             light: "rgba(30, 28, 24, 0.08)"),
    TokenDef(name: "trace-code", dark: "#f0eadf", light: "#27231f"),
    TokenDef(name: "composer-bg", dark: "rgba(24, 26, 31, 0.86)",
             light: "rgba(255, 255, 255, 0.86)"),
    TokenDef(name: "tab-bg", dark: "rgba(255, 255, 255, 0.06)", light: "#f0ede6"),
    TokenDef(name: "tab-active-bg", dark: "rgba(255, 255, 255, 0.14)",
             light: "#fff"),
    TokenDef(name: "tab-color", dark: "#c9c0b6", light: "#5d5951"),
    TokenDef(name: "send-bg", dark: "#f4f1ea", light: "#161513"),
    TokenDef(name: "send-color", dark: "#111214", light: "#fff"),
    TokenDef(name: "placeholder", dark: "#8e877d", light: "#8c887f"),
    TokenDef(name: "link", dark: "#7ab7ff", light: "#0a66d8"),
    # Shape and motion: one radius and one easing curve for the whole surface.
    # The lab's Settings widget rewrote --radius at runtime ("roundness").
    TokenDef(name: "radius", dark: "24px", light: ""),
    TokenDef(name: "ease", dark: "cubic-bezier(0.2, 0.8, 0.2, 1)", light: "")]

proc def*(t: TokenId): TokenDef =
  ## The definition behind a token id.
  tokenDefs()[ord(t)]

proc varName*(t: TokenId): string =
  ## `--bg` — the custom property this token declares.
  "--" & def(t).name

proc cssVar*(t: TokenId): string =
  ## `var(--bg)` — how a component refers to the token. Components should never
  ## spell a literal colour; they name a token and get theming for free.
  "var(" & varName(t) & ")"

proc value*(t: TokenId, th: Theme): string =
  ## The token's reading under a theme. Invariant tokens read the same in both.
  let d = def(t)
  if th == themeLight and d.light.len > 0: d.light else: d.dark

proc isInvariant*(t: TokenId): bool =
  ## True when the light theme deliberately inherits the dark reading.
  def(t).light.len == 0

# --- stylesheet emission ----------------------------------------------------

const rootFont* =
  "Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, " &
  "\"Segoe UI\", sans-serif"

proc renderRoot*(): string =
  ## The `:root` block: every token at its dark reading, plus the base font.
  ## This is what the original stylesheet's first 50 lines were.
  result = ":root {\n  color-scheme: dark;\n"
  let defs = tokenDefs()
  var i = 0
  while i < defs.len:
    result.add "  --" & defs[i].name & ": " & defs[i].dark & ";\n"
    inc i
  result.add "  font-family: " & rootFont & ";\n}\n"

proc renderLight*(): string =
  ## The `:root[data-theme="light"]` override block — only the tokens that
  ## actually differ, which is how the original was written by hand.
  result = ":root[data-theme=\"light\"] {\n  color-scheme: light;\n"
  let defs = tokenDefs()
  var i = 0
  while i < defs.len:
    if defs[i].light.len > 0:
      result.add "  --" & defs[i].name & ": " & defs[i].light & ";\n"
    inc i
  result.add "}\n"

proc renderTokens*(): string =
  ## Both theme blocks — the whole palette as CSS.
  renderRoot() & "\n" & renderLight()

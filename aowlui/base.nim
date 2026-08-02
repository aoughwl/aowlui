## aowlui/base — the global layer beneath every component.
##
## Ingested from the original lab stylesheet, lines 99-181: the box model, the
## invisible-track scrollbars, the selection colour, the deliberate
## `user-select: none` on the whole document with a small allow-list of places
## text *is* selectable, and the page gradient.
##
## This layer is not a component and has no states — it is the ground the
## components stand on, so it is emitted once and never scoped to a class.

import tokens

const selectableSelectors* = [
  ## The lab is a devtools-style surface: chrome is not selectable, content is.
  ## This is the exact allow-list the original carried.
  "input", "textarea", ".bubble", ".markdown-body", ".trace-item pre",
  ".activity-body pre", ".memory-item", ".code-main", ".code-block",
  ".code-meta", ".monaco-host"]

proc renderReset*(): string =
  ## Box model + scrollbars + selection.
  result = ""
  result.add "* {\n  box-sizing: border-box;\n}\n\n"
  # Invisible scrollbar track everywhere; subtle thumb only.
  result.add "* {\n  scrollbar-width: thin;\n  scrollbar-color: " &
    "color-mix(in srgb, " & cssVar(tkMuted) & " 38%, transparent) transparent;\n}\n\n"
  result.add "*::-webkit-scrollbar {\n  width: 10px;\n  height: 10px;\n" &
    "  background: transparent;\n}\n\n"
  result.add "*::-webkit-scrollbar-track {\n  background: transparent;\n}\n\n"
  result.add "*::-webkit-scrollbar-thumb {\n  background: " &
    "color-mix(in srgb, " & cssVar(tkMuted) & " 34%, transparent);\n" &
    "  border-radius: 999px;\n  border: 3px solid transparent;\n" &
    "  background-clip: padding-box;\n}\n\n"
  result.add "*::-webkit-scrollbar-thumb:hover {\n  background: " &
    "color-mix(in srgb, " & cssVar(tkMuted) & " 60%, transparent);\n" &
    "  background-clip: padding-box;\n}\n\n"
  result.add "*::-webkit-scrollbar-corner {\n  background: transparent;\n}\n\n"
  result.add "::selection {\n  background: color-mix(in srgb, " &
    cssVar(tkAccent) & " 36%, " & cssVar(tkUser) & " 24%);\n  color: " &
    cssVar(tkText) & ";\n}\n"

proc renderSelection*(): string =
  ## The chrome-is-not-selectable rule and its allow-list.
  result = "html {\n  user-select: none;\n}\n\n"
  var i = 0
  while i < selectableSelectors.len:
    result.add selectableSelectors[i]
    if i < selectableSelectors.len - 1: result.add ",\n"
    inc i
  result.add " {\n  user-select: text;\n}\n"

proc renderPage*(): string =
  ## The page itself: a radial glow over a three-stop vertical gradient. This is
  ## the single most theme-defining rule in the lab — it is why the surface reads
  ## as depth rather than a flat fill.
  result = "html,\nbody {\n  margin: 0;\n  min-height: 100%;\n  background:\n" &
    "    radial-gradient(circle at 18% -10%, " & cssVar(tkBgGlow) &
    ", transparent 32rem),\n    linear-gradient(180deg, " & cssVar(tkPageStart) &
    " 0%, " & cssVar(tkBg) & " 56%, " & cssVar(tkPageEnd) & " 100%);\n" &
    "  color: " & cssVar(tkText) & ";\n}\n\n"
  result.add "body {\n  min-height: 100vh;\n  overflow: hidden;\n}\n\n"
  result.add "button,\ntextarea {\n  font: inherit;\n}\n\n"
  result.add "button {\n  -webkit-tap-highlight-color: transparent;\n}\n"

proc renderBase*(): string =
  ## The whole ground layer.
  renderReset() & "\n" & renderSelection() & "\n" & renderPage()

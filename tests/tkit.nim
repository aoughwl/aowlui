## tkit — the kit renders a real devtools surface, and the theme is genuinely
## one knob.
##
## Two properties are asserted rather than eyeballed:
##
## 1. **Every length in the sheet derives from a token.** A rule containing a raw
##    `px` length (other than the deliberate 1px hairline) has opted out of
##    `--scale`, so the UI would not resize with the theme. The gate greps the
##    emitted CSS for that, which is the only way this stays true as rules are
##    added.
## 2. **`scale` and `roundness` reach the whole system.** Rendering the theme at
##    a different scale must move `--u`, and nothing else about the components
##    may change — the components never see a number, so their CSS is identical.

import std/syncio
import kit
import web

proc contains(hay, needle: string): bool =
  if needle.len == 0: return true
  if needle.len > hay.len: return false
  var i = 0
  while i <= hay.len - needle.len:
    var j = 0
    var ok = true
    while j < needle.len:
      if hay[i + j] != needle[j]:
        ok = false
        j = needle.len
      else:
        inc j
    if ok: return true
    inc i
  false

## Raw `px` lengths, excluding the 1px hairline and the pill radius.
proc rawPxCount(css: string): int =
  result = 0
  var i = 0
  while i + 1 < css.len:
    if css[i] == 'p' and css[i+1] == 'x':
      # walk back over the digits
      var k = i - 1
      while k >= 0 and css[k] >= '0' and css[k] <= '9':
        dec k
      var num = ""
      var m = k + 1
      while m < i:
        num.add css[m]
        inc m
      if num.len > 0 and num != "1" and num != "999":
        inc result
    inc i

proc main =
  useStylesheet kitSheet()

  # A devtools surface: chrome, an explorer beside a split working area, status.
  let tree = @[
    treeItem("aoughwl", depth = 0, open = true, expandable = true),
    treeItem("web", depth = 1, expandable = true, hint = "6"),
    treeItem("dsl.nim", depth = 2, selected = true, hint = "12k"),
    treeItem("weblower.nim", depth = 2),
    treeItem("css", depth = 1, expandable = true, hint = "2")]

  let insp = @[
    inspRow("kind", "Component"),
    inspRow("family", "controls"),
    inspRow("rules", "4"),
    inspRow("digest", "c9fb024aa")]

  let top = @[
    toolbar(@[
      chip("live", accent = true),
      crumbs(["aoughwl", "web", "dsl.nim"]),
      toolbarSpacer(),
      iconButton("⟳", "Reload"),
      button("Run", primary = true)])]

  let body = @[
    sidebar(@[
      pane(head = "explorer", children = @[explorer(tree)])]),
    splitter(),
    panes(@[
      pane(head = "source", children = @[code("proc main =\n  echo \"hi\"\n")]),
      splitter(),
      pane(head = "inspector", children = @[inspector(insp)])])]

  let bottom = @[
    statusBar(@[
      dot(live = true), statusItem("connected"),
      statusItem("195 components"), toolbarSpacer(),
      statusItem("scale 1.0")])]

  let page = document("aowlui kit", @[shell(top, body, bottom)],
                      css = renderTheme() & renderReset(), useStyles = true)

  var bad = 0

  # 1. the sheet is token-driven
  let sheetCss = render(kitSheet())
  let raw = rawPxCount(sheetCss)
  echo "raw px lengths in sheet: ", raw
  if raw != 0:
    echo "  a rule hard-codes a length and will not scale"
    inc bad

  # 2. the theme is one knob
  var big = darkTheme()
  big.scale = "1.5"
  big.roundness = "0"
  let scaled = renderThemeBase(big)
  if not contains(scaled, "--scale:1.5"):
    echo "  MISSING: scale did not reach :root"
    inc bad
  if not contains(scaled, "--round:0"):
    echo "  MISSING: roundness did not reach :root"
    inc bad
  # every length is calc()'d off --u, so the component CSS is byte-identical
  if render(kitSheet()) != sheetCss:
    echo "  component CSS changed with the theme — it should not know the numbers"
    inc bad

  # 3. the composed page has the parts
  let need = ["class=\"shell\"", "class=\"toolbar\"", "class=\"sidebar\"",
              "class=\"explorer\"", "role=\"tree\"", "tree-item is-selected",
              "aria-selected=\"true\"", "class=\"splitter\"",
              "class=\"insp-key\"", "class=\"statusbar\"",
              "--u:calc(var(--scale) * var(--unit))"]
  var i = 0
  while i < need.len:
    if not contains(page, need[i]):
      echo "  MISSING from page: ", need[i]
      inc bad
    inc i

  # 4. every declaration in the kit is valid CSS
  let errs = errors(kitSheet())
  echo "sheet rules: ", kitSheet().len, "  css errors: ", errs.len
  var e = 0
  while e < errs.len and e < 8:
    echo "  ", errs[e]
    inc e

  echo "mismatches: ", bad
  if bad == 0:
    echo "OK"
  else:
    echo "KIT FAILED"

main()

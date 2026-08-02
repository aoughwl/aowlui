## tools/ingest — turn the legacy lab stylesheet into typed components.
##
## The lab shipped 3055 lines of flat CSS. Hand-porting 195 classes into
## `Component` values would be a transcription exercise with no way to prove it
## faithful, so this reads `reference/styles.css`, classifies every selector, and
## emits nimony source. What makes it trustworthy is the round-trip: `tests/`
## renders the generated components back to CSS and compares against the original
## declaration by declaration, so a mis-ingested rule fails rather than silently
## changing the design.
##
## The classification is deliberately conservative. A selector that does not fit
## the component model — an at-rule, a multi-element descendant chain, `:root` —
## becomes a `stRaw` rule carrying the selector verbatim. Nothing is dropped and
## nothing is guessed: coverage is 100% by construction, and the raw count is the
## honest measure of how much of the sheet the model actually explains.
##
##   nimony c tools/ingest.nim && ./tools/ingest > /dev/null
##
## Regenerates `aowlui/lab/*.nim`.

import std/syncio
import css/parse

# ── small string helpers (nimony's stdlib is deliberately thin) ──────────────

proc trimmed(s: string): string =
  var a = 0
  var b = s.len
  while a < b and (s[a] == ' ' or s[a] == '\t' or s[a] == '\n' or s[a] == '\r'):
    inc a
  while b > a and (s[b-1] == ' ' or s[b-1] == '\t' or s[b-1] == '\n' or s[b-1] == '\r'):
    dec b
  result = ""
  var i = a
  while i < b:
    result.add s[i]
    inc i

proc splitOn(s: string; sep: char): seq[string] =
  result = @[]
  var cur = ""
  var i = 0
  while i < s.len:
    if s[i] == sep:
      result.add trimmed(cur)
      cur = ""
    else:
      cur.add s[i]
    inc i
  result.add trimmed(cur)

proc contains(s: string; c: char): bool =
  var i = 0
  while i < s.len:
    if s[i] == c: return true
    inc i
  false

proc startsWith(s, pre: string): bool =
  if pre.len > s.len: return false
  var i = 0
  while i < pre.len:
    if s[i] != pre[i]: return false
    inc i
  true

proc isIdentChar(c: char): bool =
  (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or
  (c >= '0' and c <= '9') or c == '-' or c == '_'

proc escapeNim(s: string): string =
  ## A nimony string literal body.
  result = ""
  var i = 0
  while i < s.len:
    let c = s[i]
    if c == '"': result.add "\\\""
    elif c == '\\': result.add "\\\\"
    elif c == '\n': result.add "\\n"
    elif c == '\r': discard
    else: result.add c
    inc i

# ── selector classification ─────────────────────────────────────────────────

type
  Classified = object
    root: string      ## the component's root class, "" when unclassifiable
    part: string      ## descendant suffix belonging to the root
    kind: string      ## a StateKind enum literal
    flag: string
    sel: string       ## verbatim selector, for stRaw

proc leadingClass(sel: string): string =
  ## The class name a selector starts with: `.memory-item.active` -> "memory-item".
  if sel.len < 2 or sel[0] != '.': return ""
  var i = 1
  var name = ""
  while i < sel.len and isIdentChar(sel[i]):
    name.add sel[i]
    inc i
  name

proc classify(sel: string): Classified =
  ## Split a selector into (root component, part, state). Anything that does not
  ## fit becomes a raw rule rather than a guess.
  result = Classified(root: "", part: "", kind: "stRaw", flag: "", sel: sel)
  let root = leadingClass(sel)
  if root.len == 0: return
  let restStart = 1 + root.len
  var rest = ""
  var i = restStart
  while i < sel.len:
    rest.add sel[i]
    inc i
  rest = trimmed(rest)

  if rest.len == 0:
    return Classified(root: root, part: "", kind: "stBase", flag: "", sel: "")

  # A DESCENDANT must be decided before anything else, on the untrimmed text.
  # Trimming collapses `.a .b` and `.a.b` to the same `.b`, and they mean
  # different things — the first is a part of `.a`, the second a state of it.
  # Deciding this later let every `.owner .part` in the sheet be misread as a
  # modifier class, which is what the round-trip gate caught.
  if sel[restStart] == ' ':
    return Classified(root: root, part: " " & rest, kind: "stBase", flag: "", sel: "")

  # `.name:hover` and friends
  if rest == ":hover":
    return Classified(root: root, part: "", kind: "stHover", flag: "", sel: "")
  if rest == ":focus":
    return Classified(root: root, part: "", kind: "stFocus", flag: "", sel: "")
  if rest == ":focus-visible":
    return Classified(root: root, part: "", kind: "stFocusVisible", flag: "", sel: "")
  if rest == ":active":
    return Classified(root: root, part: "", kind: "stActive", flag: "", sel: "")
  if rest == ":disabled":
    return Classified(root: root, part: "", kind: "stDisabled", flag: "", sel: "")
  if rest == ":checked":
    return Classified(root: root, part: "", kind: "stChecked", flag: "", sel: "")
  if rest == ":empty":
    return Classified(root: root, part: "", kind: "stEmpty", flag: "", sel: "")
  if rest == "::before":
    return Classified(root: root, part: "", kind: "stBefore", flag: "", sel: "")
  if rest == "::after":
    return Classified(root: root, part: "", kind: "stAfter", flag: "", sel: "")

  # `.name.flag` — an application state on the same element
  if rest[0] == '.':
    let flag = leadingClass(rest)
    if flag.len > 0 and flag.len + 1 == rest.len:
      return Classified(root: root, part: "", kind: "stFlag", flag: flag, sel: "")

  result

proc familyOf(name: string): string =
  ## The first hyphen segment groups the sheet the way it was actually written:
  ## `memory-*` is one family, `code-*` another.
  result = ""
  var i = 0
  while i < name.len and name[i] != '-':
    result.add name[i]
    inc i
  if result.len == 0: result = "misc"

# ── declarations back to text ───────────────────────────────────────────────

proc declText(decls: seq[Declaration]): string =
  result = ""
  var i = 0
  while i < decls.len:
    if i > 0: result.add "; "
    result.add decls[i].prop
    result.add ": "
    result.add decls[i].value
    if decls[i].important: result.add " !important"
    inc i

# ── the emitted model ───────────────────────────────────────────────────────

type
  OutRule = object
    part, kind, flag, sel, decls: string
  OutComponent = object
    name, family: string
    rules: seq[OutRule]

proc findComp(comps: seq[OutComponent]; name: string): int =
  result = -1
  var i = 0
  while i < comps.len:
    if comps[i].name == name:
      result = i
      i = comps.len
    else:
      inc i

proc main =
  var src = ""
  try:
    src = readFile("reference/styles.css")
  except:
    echo "cannot read reference/styles.css — run from the repo root"
    return
  let sheet = parseStylesheet(src)

  var comps: seq[OutComponent] = @[]
  var raws: seq[OutRule] = @[]
  var styleRules = 0
  var rawCount = 0

  var r = 0
  while r < sheet.rules.len:
    let rule = sheet.rules[r]
    if rule.isAtRule:
      # @media / @keyframes / @font-face keep their head verbatim; the model has
      # nothing to say about them and inventing a shape would be a lie.
      raws.add OutRule(part: "", kind: "stRaw", flag: "",
                       sel: "@" & rule.atKeyword & " " & rule.prelude,
                       decls: declText(rule.decls))
      inc rawCount
    else:
      let body = declText(rule.decls)
      let sels = splitOn(rule.prelude, ',')
      var s = 0
      while s < sels.len:
        let sel = sels[s]
        if sel.len > 0:
          inc styleRules
          let c = classify(sel)
          if c.root.len == 0:
            raws.add OutRule(part: "", kind: "stRaw", flag: "", sel: sel, decls: body)
            inc rawCount
          else:
            var idx = findComp(comps, c.root)
            if idx < 0:
              comps.add OutComponent(name: c.root, family: familyOf(c.root), rules: @[])
              idx = comps.len - 1
            var cs = comps[idx]
            cs.rules.add OutRule(part: c.part, kind: c.kind, flag: c.flag,
                                 sel: c.sel, decls: body)
            comps[idx] = cs
        inc s
    inc r

  # ── emit ──
  var buf = ""
  buf.add "## aowlui/lab/components — GENERATED by tools/ingest from\n"
  buf.add "## reference/styles.css. Do not edit by hand; edit the ingester or the\n"
  buf.add "## reference sheet and regenerate. tests/tround.nim proves this renders\n"
  buf.add "## back to the original declarations.\n\n"
  buf.add "import ../component\nexport component\n\n"
  buf.add "proc labComponents*(): seq[Component] =\n  result = @[\n"
  var i = 0
  while i < comps.len:
    let c = comps[i]
    buf.add "    Component(name: \"" & c.name & "\", family: \"" & c.family &
            "\", doc: \"\", element: \"\", rules: @[\n"
    var j = 0
    while j < c.rules.len:
      let ru = c.rules[j]
      buf.add "      Rule(part: \"" & escapeNim(ru.part) & "\", kind: " & ru.kind &
              ", flag: \"" & escapeNim(ru.flag) & "\", sel: \"" & escapeNim(ru.sel) &
              "\", decls: \"" & escapeNim(ru.decls) & "\", note: \"\"),\n"
      inc j
    buf.add "    ]),\n"
    inc i
  buf.add "  ]\n\n"

  buf.add "proc labRaw*(): seq[Rule] =\n"
  buf.add "  ## Selectors the component model does not explain: at-rules, `:root`,\n"
  buf.add "  ## element and multi-element selectors. Carried verbatim so the port is\n"
  buf.add "  ## complete, and counted so the gap is visible rather than hidden.\n"
  buf.add "  result = @[\n"
  var k = 0
  while k < raws.len:
    let ru = raws[k]
    buf.add "    Rule(part: \"\", kind: stRaw, flag: \"\", sel: \"" & escapeNim(ru.sel) &
            "\", decls: \"" & escapeNim(ru.decls) & "\", note: \"\"),\n"
    inc k
  buf.add "  ]\n"

  try:
    writeFile("aowlui/lab/components.nim", buf)
  except:
    echo "cannot write aowlui/lab/components.nim"
    return

  echo "selectors:  ", styleRules
  echo "components: ", comps.len
  echo "raw:        ", rawCount

main()

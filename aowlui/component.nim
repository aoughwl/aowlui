## aowlui/component — what a UI component *is*, as a value.
##
## The original lab had no component concept at all: `styles.css` was 3055 lines
## of flat selectors, and the knowledge of which rules belonged together, which
## were states of the same thing, and which were parts of it lived only in the
## ordering and in whoever last edited the file.
##
## Here a component is a value:
##
##   Component(name: "ghost-button", family: "controls",
##             rules: @[Rule(...base...), Rule(state: stHover, ...)])
##
## That buys three things the stylesheet could not have:
##
## 1. **States are declared, not spelled.** `.ghost-button:hover` and
##    `.ghost-button.active` were two unrelated selectors 5 lines apart. Here
##    they are `stHover` and a `stFlag "active"` rule *of the same component*, so
##    "what are this thing's states" is a query, not a reading exercise.
## 2. **Parts are owned.** `.owl-mark .owl-eye` belongs to the owl; `.trace-item
##    pre` belongs to the trace item. A `part` is a rule of its owner, so a
##    component moves or is deleted as one piece.
## 3. **It is content-addressed.** `digest` hashes the component's rules, so
##    identical components collapse to one identity regardless of what module
##    declared them or what a human called them. This is the seam where aowlui
##    meets the aoughwl store: the digest is what an atom would be keyed by.
##
## `render` turns the value back into exactly the CSS the lab shipped.

type
  StateKind* = enum
    ## How a rule is selected relative to its component's root class.
    stBase            ## the component itself: `.name`
    stHover           ## `:hover`
    stFocus           ## `:focus`
    stFocusVisible    ## `:focus-visible`
    stActive          ## `:active`
    stDisabled        ## `:disabled`
    stChecked         ## `:checked`
    stEmpty           ## `:empty`
    stFlag            ## an application state: `.name.flag` — needs `flag` set
    stAncestor        ## selected by an ancestor's flag: `.flag .name`
    stBefore          ## `::before`
    stAfter           ## `::after`
    stRaw             ## an escape hatch: `sel` is used verbatim

  Rule* = object
    ## One declaration block belonging to a component.
    part*: string      ## descendant suffix, e.g. " .owl-eye"; "" = the root
    kind*: StateKind
    flag*: string      ## the modifier/ancestor class for stFlag / stAncestor
    sel*: string       ## verbatim selector for stRaw
    decls*: string     ## `prop: value; …` — the block body
    note*: string      ## why this rule exists, when it isn't obvious

  Component* = object
    name*: string      ## the root class, without the dot: "ghost-button"
    family*: string    ## grouping: "controls", "memory", "code", …
    doc*: string       ## what it is and where it was used in the lab
    element*: string   ## the HTML element it is normally spelled on
    rules*: seq[Rule]

# --- construction helpers ---------------------------------------------------

proc base*(decls: string, note: string = ""): Rule =
  Rule(part: "", kind: stBase, flag: "", sel: "", decls: decls, note: note)

proc part*(p, decls: string, note: string = ""): Rule =
  Rule(part: p, kind: stBase, flag: "", sel: "", decls: decls, note: note)

proc state*(k: StateKind, decls: string, note: string = ""): Rule =
  Rule(part: "", kind: k, flag: "", sel: "", decls: decls, note: note)

proc partState*(p: string, k: StateKind, decls: string, note: string = ""): Rule =
  Rule(part: p, kind: k, flag: "", sel: "", decls: decls, note: note)

proc flagged*(f, decls: string, note: string = ""): Rule =
  ## An application state — a modifier class on the component itself.
  Rule(part: "", kind: stFlag, flag: f, sel: "", decls: decls, note: note)

proc partFlagged*(p, f, decls: string, note: string = ""): Rule =
  Rule(part: p, kind: stFlag, flag: f, sel: "", decls: decls, note: note)

proc under*(f, decls: string, note: string = ""): Rule =
  ## Styled because some ancestor carries `f` (`.developer-mode .trace`).
  Rule(part: "", kind: stAncestor, flag: f, sel: "", decls: decls, note: note)

proc raw*(s, decls: string, note: string = ""): Rule =
  Rule(part: "", kind: stRaw, flag: "", sel: s, decls: decls, note: note)

# --- selector construction --------------------------------------------------

proc suffix(k: StateKind, flag: string): string =
  case k
  of stBase: ""
  of stHover: ":hover"
  of stFocus: ":focus"
  of stFocusVisible: ":focus-visible"
  of stActive: ":active"
  of stDisabled: ":disabled"
  of stChecked: ":checked"
  of stEmpty: ":empty"
  of stFlag: "." & flag
  of stAncestor: ""
  of stBefore: "::before"
  of stAfter: "::after"
  of stRaw: ""

proc selectorOf*(c: Component, r: Rule): string =
  ## The CSS selector this rule compiles to.
  if r.kind == stRaw:
    return r.sel
  if r.kind == stAncestor:
    # `.flag .name<part>` — the ancestor gates the whole thing.
    return "." & r.flag & " ." & c.name & r.part
  # A state on a *part* attaches to the part; a state on the root attaches to
  # the root. `.owl-mark.awake` vs `.owl-mark .owl-eye:hover`.
  if r.part.len > 0:
    "." & c.name & r.part & suffix(r.kind, r.flag)
  else:
    "." & c.name & suffix(r.kind, r.flag)

# --- rendering --------------------------------------------------------------

proc indentDecls(decls: string): string =
  ## Re-indent a `prop: value;`-separated block into the two-space house style
  ## the original stylesheet used, one declaration per line.
  result = ""
  var cur = ""
  var i = 0
  var depth = 0
  while i < decls.len:
    let ch = decls[i]
    if ch == '(':
      inc depth
      cur.add ch
    elif ch == ')':
      dec depth
      cur.add ch
    elif ch == ';' and depth == 0:
      var t = ""
      var j = 0
      # trim
      var a = 0
      var b = cur.len
      while a < b and (cur[a] == ' ' or cur[a] == '\n' or cur[a] == '\t'): inc a
      while b > a and (cur[b-1] == ' ' or cur[b-1] == '\n' or cur[b-1] == '\t'): dec b
      j = a
      while j < b:
        t.add cur[j]
        inc j
      if t.len > 0:
        result.add "  " & t & ";\n"
      cur = ""
    else:
      cur.add ch
    inc i
  var a = 0
  var b = cur.len
  while a < b and (cur[a] == ' ' or cur[a] == '\n' or cur[a] == '\t'): inc a
  while b > a and (cur[b-1] == ' ' or cur[b-1] == '\n' or cur[b-1] == '\t'): dec b
  var t = ""
  var j = a
  while j < b:
    t.add cur[j]
    inc j
  if t.len > 0:
    result.add "  " & t & ";\n"

proc renderRule*(c: Component, r: Rule): string =
  result = ""
  if r.note.len > 0:
    result.add "/* " & r.note & " */\n"
  result.add selectorOf(c, r) & " {\n" & indentDecls(r.decls) & "}\n"

proc render*(c: Component): string =
  ## Every rule of the component, in declaration order.
  result = ""
  var i = 0
  while i < c.rules.len:
    result.add renderRule(c, c.rules[i])
    if i < c.rules.len - 1: result.add "\n"
    inc i

proc renderAll*(cs: seq[Component]): string =
  result = ""
  var i = 0
  while i < cs.len:
    result.add "/* --- " & cs[i].name & " --- */\n"
    result.add render(cs[i])
    result.add "\n"
    inc i

# --- identity ---------------------------------------------------------------

proc fnv1a64(s: string, seed: uint64): uint64 =
  result = seed
  var i = 0
  while i < s.len:
    result = result xor uint64(ord(s[i]))
    result = result * 1099511628211'u64
    inc i

proc toHex16(x: uint64): string =
  const digits = "0123456789abcdef"
  result = ""
  var i = 15
  while i >= 0:
    let nib = int((x shr uint64(i * 4)) and 0xF'u64)
    result.add digits[nib]
    dec i

proc digest*(c: Component): string =
  ## A content address over the component's *rules* — not its name, not its
  ## family, not its documentation. Two components that style the same way have
  ## the same digest even if one is called `ghost-button` and the other
  ## `nav-btn`, which is exactly the question "are these the same thing?".
  ##
  ## FNV-1a/64 for now. The aoughwl store keys atoms by SHA-256; when aowlui is
  ## ingested this becomes a truncation of the real atom hash, and the digest and
  ## the store address become one value.
  var h = 14695981039346656037'u64
  var i = 0
  while i < c.rules.len:
    let r = c.rules[i]
    h = fnv1a64(r.part, h)
    h = fnv1a64($ord(r.kind), h)
    h = fnv1a64(r.flag, h)
    h = fnv1a64(r.sel, h)
    h = fnv1a64(r.decls, h)
    inc i
  toHex16(h)

proc statesOf*(c: Component): seq[string] =
  ## Every state the component distinguishes — the question the flat stylesheet
  ## could not answer.
  result = @[]
  var i = 0
  while i < c.rules.len:
    let r = c.rules[i]
    if r.kind != stBase and r.kind != stRaw:
      let s = (if r.kind == stFlag or r.kind == stAncestor: r.flag
               else: suffix(r.kind, ""))
      var seen = false
      var j = 0
      while j < result.len:
        if result[j] == s: seen = true
        inc j
      if not seen: result.add s
    inc i

proc partsOf*(c: Component): seq[string] =
  ## The descendants the component owns.
  result = @[]
  var i = 0
  while i < c.rules.len:
    if c.rules[i].part.len > 0:
      var seen = false
      var j = 0
      while j < result.len:
        if result[j] == c.rules[i].part: seen = true
        inc j
      if not seen: result.add c.rules[i].part
    inc i

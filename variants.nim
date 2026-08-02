## ui/style — the variant engine: StyleSpec-as-DATA + a generic merge + ONE
## content-addressed class.
##
## A component never authors a stylesheet. It registers a `ComponentStyles`
## table (base + variant + size + state specs, all referencing tokens) as DATA.
## At call time `variantClass` merges `base ⊕ variant ⊕ size ⊕ states` (later wins
## per (suffix, prop)), encodes the result, and hands it to `webClass` (web/dsl)
## → one content-addressed class shared across the whole app.
##
##   Adding a variant  = append one row to the DATA table (even from another pack).
##   Adding a component = register a spec table + write a thin proc.
## The engine, merge, encoder and token layer never change.

import aoughwl/web            # webClass, renderStylesheet, styleErrors
import aoughwl/ui/theme       # ensures the tokens exist
export web
export theme

type
  Decl* = object
    prop*: string
    value*: string
  Section* = object
    suffix*: string          ## "" = base, ":hover", "::before", "@media <q>"
    decls*: seq[Decl]
  Spec* = object
    sections*: seq[Section]

proc d*(prop, value: string): Decl = Decl(prop: prop, value: value)

proc spec*(decls: seq[Decl]): Spec =
  ## a base-only spec from a declaration list
  Spec(sections: @[Section(suffix: "", decls: decls)])

proc spec*(): Spec =
  ## an empty spec (a state that only adds pseudo/media sections uses this)
  Spec(sections: @[])

proc pseudo*(s: Spec, suffix: string, decls: seq[Decl]): Spec =
  ## attach a pseudo/media section (":hover", "::placeholder", "@media <q>")
  result = s
  result.sections.add Section(suffix: suffix, decls: decls)

# ---- merge (later wins per (suffix, prop)) --------------------------------

proc findSection(secs: seq[Section], suffix: string): int =
  var i = 0
  while i < secs.len:
    if secs[i].suffix == suffix: return i
    inc i
  -1

proc mergeDecls(base: seq[Decl], over: seq[Decl]): seq[Decl] =
  result = base
  for od in over:
    var found = false
    var i = 0
    while i < result.len:
      if result[i].prop == od.prop:
        result[i] = od
        found = true
      inc i
    if not found: result.add od

proc merge*(a, b: Spec): Spec =
  ## `b` overrides `a` per (suffix, prop); a's section order is preserved, new
  ## suffixes from b are appended.
  result = a
  for bs in b.sections:
    let idx = findSection(result.sections, bs.suffix)
    if idx < 0:
      result.sections.add bs
    else:
      result.sections[idx] = Section(suffix: bs.suffix,
        decls: mergeDecls(result.sections[idx].decls, bs.decls))

proc encode*(s: Spec): string =
  ## Spec → the RS/US wire format `webClass` content-addresses.
  result = ""
  var si = 0
  while si < s.sections.len:
    let sec = s.sections[si]
    if sec.suffix.len == 0:
      for de in sec.decls: result.add de.prop & ":" & de.value & ";"
    else:
      result.add "\x1e" & sec.suffix & "\x1f"
      for de in sec.decls: result.add de.prop & ":" & de.value & ";"
    inc si

proc classOf*(s: Spec): string = webClass(encode(s))   ## one content-addressed class

# ---- the per-component registry (DATA) ------------------------------------

type
  KeyedSpec* = object
    key*: string
    spec*: Spec
  ComponentStyles* = object
    base*: Spec
    variants*: seq[KeyedSpec]
    sizes*: seq[KeyedSpec]
    states*: seq[KeyedSpec]
  RegEntry = object
    component: string
    styles: ComponentStyles

proc ks*(key: string, s: Spec): KeyedSpec = KeyedSpec(key: key, spec: s)

var gReg: seq[RegEntry] = @[]

proc regIndex(component: string): int =
  var i = 0
  while i < gReg.len:
    if gReg[i].component == component: return i
    inc i
  -1

proc mergeKeyed(base: seq[KeyedSpec], extra: seq[KeyedSpec]): seq[KeyedSpec] =
  ## append extra rows, overriding an existing key's spec in place
  result = base
  for e in extra:
    var found = false
    var i = 0
    while i < result.len:
      if result[i].key == e.key:
        result[i] = e
        found = true
      inc i
    if not found: result.add e

proc register*(component: string, cs: ComponentStyles) =
  ## register — or merge-into-existing (open decision 7): a later `register` for
  ## the same component overrides base decls by prop and appends/overrides
  ## variant/size/state rows by key, so third-party packs extend without editing
  ## the original component file.
  let idx = regIndex(component)
  if idx < 0:
    gReg.add RegEntry(component: component, styles: cs)
  else:
    let cur = gReg[idx].styles
    gReg[idx] = RegEntry(component: component, styles: ComponentStyles(
      base: merge(cur.base, cs.base),
      variants: mergeKeyed(cur.variants, cs.variants),
      sizes: mergeKeyed(cur.sizes, cs.sizes),
      states: mergeKeyed(cur.states, cs.states)))

proc pick(tbl: seq[KeyedSpec], key: string): Spec =
  for kv in tbl:
    if kv.key == key: return kv.spec
  Spec(sections: @[])                                    # unknown key ⇒ no-op

proc variantClass*(component, variant, size: string; states: seq[string]): string =
  ## resolve params → merged spec → one content-addressed class.
  ## Unknown component ⇒ "".
  let idx = regIndex(component)
  if idx < 0: return ""
  let cs = gReg[idx].styles
  var s = cs.base
  s = merge(s, pick(cs.variants, variant))
  s = merge(s, pick(cs.sizes, size))
  for st in states:
    s = merge(s, pick(cs.states, st))
  classOf(s)

## tround — the port is FAITHFUL, proven by round-trip.
##
## The ingester turned 3055 lines of legacy CSS into typed components. The only
## way to know it did that without changing the design is to render the
## components back and compare against the original, declaration by declaration.
##
## The comparison is on the DECLARATION MULTISET, not on text: the port
## deliberately regroups rules by component, so byte equality would fail for a
## faithful port and prove nothing. What must hold is that every
## (selector, property, value) the lab shipped is still emitted, and that
## nothing was invented. Both directions are checked — a port that dropped a
## rule and a port that added one both fail.

import std/syncio
import css/parse
import ../aowlui/component
import ../aowlui/lab/components

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

proc has(xs: seq[string]; s: string): bool =
  var i = 0
  while i < xs.len:
    if xs[i] == s: return true
    inc i
  false

proc countOf(xs: seq[string]; s: string): int =
  result = 0
  var i = 0
  while i < xs.len:
    if xs[i] == s: inc result
    inc i

## Every `selector{prop:value}` the ORIGINAL sheet declares.
proc originalPairs(src: string): seq[string] =
  result = @[]
  let sheet = parseStylesheet(src)
  var r = 0
  while r < sheet.rules.len:
    let rule = sheet.rules[r]
    let head = if rule.isAtRule: "@" & rule.atKeyword & " " & rule.prelude
               else: rule.prelude
    let sels = if rule.isAtRule: @[head] else: splitOn(rule.prelude, ',')
    var s = 0
    while s < sels.len:
      if sels[s].len > 0:
        var d = 0
        while d < rule.decls.len:
          result.add sels[s] & "{" & rule.decls[d].prop & ":" & rule.decls[d].value & "}"
          inc d
      inc s
    inc r

## Every `selector{prop:value}` the PORT emits.
proc portedPairs(): seq[string] =
  result = @[]
  let comps = labComponents()
  var i = 0
  while i < comps.len:
    let c = comps[i]
    var j = 0
    while j < c.rules.len:
      let sel = selectorOf(c, c.rules[j])
      let decls = splitOn(c.rules[j].decls, ';')
      var d = 0
      while d < decls.len:
        if decls[d].len > 0:
          let kv = splitOn(decls[d], ':')
          if kv.len >= 2:
            var value = ""
            var k = 1
            while k < kv.len:
              if k > 1: value.add ":"
              value.add kv[k]
              inc k
            result.add sel & "{" & kv[0] & ":" & trimmed(value) & "}"
        inc d
      inc j
    inc i
  let raws = labRaw()
  var q = 0
  while q < raws.len:
    let decls = splitOn(raws[q].decls, ';')
    var d = 0
    while d < decls.len:
      if decls[d].len > 0:
        let kv = splitOn(decls[d], ':')
        if kv.len >= 2:
          var value = ""
          var k = 1
          while k < kv.len:
            if k > 1: value.add ":"
            value.add kv[k]
            inc k
          result.add raws[q].sel & "{" & kv[0] & ":" & trimmed(value) & "}"
      inc d
    inc q

proc main =
  var src = ""
  try:
    src = readFile("reference/styles.css")
  except:
    echo "FAIL: cannot read reference/styles.css (run from the repo root)"
    return

  let orig = originalPairs(src)
  let port = portedPairs()

  echo "original declarations: ", orig.len
  echo "ported declarations:   ", port.len

  var missing = 0
  var i = 0
  while i < orig.len:
    if countOf(port, orig[i]) < countOf(orig, orig[i]):
      if missing < 10: echo "  MISSING: ", orig[i]
      inc missing
    inc i

  var invented = 0
  var j = 0
  while j < port.len:
    if not has(orig, port[j]):
      if invented < 10: echo "  INVENTED: ", port[j]
      inc invented
    inc j

  echo "missing:  ", missing
  echo "invented: ", invented
  if missing == 0 and invented == 0:
    echo "ROUND-TRIP OK"
  else:
    echo "ROUND-TRIP FAILED"

main()

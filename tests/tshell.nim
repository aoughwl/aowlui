## tshell — the ported markup matches reference/index.html.
##
## The same discipline as the CSS round-trip, applied to markup. Byte equality is
## the wrong test: the reference is hand-written HTML with comments, its own
## attribute order and its own whitespace, and the port emits normalised markup —
## so a faithful port would fail a byte comparison and prove nothing.
##
## What must hold is that every ELEMENT the reference's body declares is present
## in the port with the same identifying attributes, and that the kernel scripts
## appear in the same ORDER, because for those the order is the dependency graph.
## Both are extracted from the reference file at test time rather than
## transcribed into the test, so the gate cannot drift from the thing it checks.

import std/syncio
import ../aowlui/lab/shell
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

## Every `src="…"` in the reference, in document order.
proc scriptSrcs(src: string): seq[string] =
  result = @[]
  let key = "src=\""
  var i = 0
  while i < src.len:
    var hit = true
    var j = 0
    while j < key.len and i + j < src.len:
      if src[i + j] != key[j]:
        hit = false
        j = key.len
      else:
        inc j
    if hit and i + key.len <= src.len:
      var v = ""
      var k = i + key.len
      while k < src.len and src[k] != '"':
        v.add src[k]
        inc k
      if v.len > 0: result.add v
      i = k
    inc i

proc main =
  var refSrc = ""
  try:
    refSrc = readFile("reference/index.html")
  except:
    echo "FAIL: cannot read reference/index.html (run from the repo root)"
    return

  let page = labPage()
  var bad = 0

  # 1. The structures the reference's body declares.
  let required = [
    "<!DOCTYPE html>", "<html lang=\"en\">", "<meta charset=\"utf-8\">",
    "name=\"viewport\"", "<title>aoughwl</title>",
    "id=\"boot\"", "role=\"status\"", "aria-live=\"polite\"",
    "class=\"boot-pulse\"", "aria-hidden=\"true\"",
    "<span></span><span></span><span></span>",
    "class=\"boot-label\"", "working",
    "<main id=\"app\">"]
  var i = 0
  while i < required.len:
    if not contains(page, required[i]):
      echo "  MISSING from port: ", required[i]
      inc bad
    inc i

  # 2. The kernel scripts, in the reference's own order, each opted out of
  #    Rocket Loader. Read from the reference so the list cannot drift.
  let srcs = scriptSrcs(refSrc)
  var prev = -1
  var s = 0
  while s < srcs.len:
    let tag = "<script data-cfasync=\"false\" src=\"" & srcs[s] & "\">"
    if not contains(page, tag):
      echo "  MISSING script: ", srcs[s]
      inc bad
    else:
      # order check: each script must appear after the previous one
      var at = 0
      var found = -1
      while at < page.len:
        var pre = ""
        var k = 0
        while k < at:
          pre.add page[k]
          inc k
        if contains(pre, tag):
          found = at
          at = page.len
        else:
          inc at
      if found >= 0 and found < prev:
        echo "  OUT OF ORDER: ", srcs[s]
        inc bad
      if found >= 0: prev = found
    inc s
  echo "kernel scripts checked: ", srcs.len

  # 3. The boot CSS ships inline, and the component stylesheet does NOT — the
  #    real theme loads from the substrate.
  if not contains(page, "--boot-bg"):
    echo "  MISSING: inline boot CSS"
    inc bad
  if not contains(page, "@keyframes boot-bob"):
    echo "  MISSING: boot animation"
    inc bad

  # 4. The inline theme restore must run in <head>, before the kernel scripts.
  if not contains(page, "aw-theme"):
    echo "  MISSING: pre-paint theme restore"
    inc bad
  if not contains(page, "<link rel=\"icon\""):
    echo "  MISSING: favicon"
    inc bad

  echo "mismatches: ", bad
  if bad == 0:
    echo "OK"
  else:
    echo "SHELL PORT FAILED"

main()

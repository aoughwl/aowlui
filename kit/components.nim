## aowlui/kit/components — the kit.
##
## Every component returns an `HTMLNode`, takes its children as `HTML`, and
## carries only kit classes — no inline styling except the one place a value is
## genuinely dynamic (tree indent, meter fill). That is what lets them nest
## arbitrarily: a `pane` does not care whether it holds an `explorer`, an
## `inspector` or another `panes`, because none of them assume a parent.
##
## The API is uniform on purpose:
##
## * containers take `children: HTML` last, so `web:` blocks drop straight in;
## * every component takes `extra = ""` — extra classes — so a caller can attach
##   a state (`is-selected`) or a layout helper (`grow`) without the kit needing
##   a parameter for every combination;
## * state is a `bool` parameter, never a pre-spelled class string, so the
##   selection language stays the kit's business rather than the caller's.

import web

proc cx*(base: string; extra = ""): string =
  ## Join a component's own class with any the caller added.
  if extra.len > 0: base & " " & extra else: base

proc node(tag, cls: string; kids: HTML = @[]): HTMLNode =
  result = el(tag)
  if cls.len > 0: result.setAttr("class", cls)
  var i = 0
  while i < kids.len:
    result.add kids[i]
    inc i

proc textNode(tag, cls, s: string): HTMLNode =
  result = node(tag, cls)
  if s.len > 0: result.add text(s)

# ── layout primitives ───────────────────────────────────────────────────────
#
# The two directions plus padding, because almost every composition is one of
# them and spelling a `div` with a class at each call site is how a kit's markup
# drifts. Gap comes from `--s2`, so layout breathes with `--scale` too.

proc row*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("row", extra), children)

proc col*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("col", extra), children)

proc pad*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("pad", extra), children)

proc spacer*(): HTMLNode = node("div", "grow")

# ── application shell ───────────────────────────────────────────────────────

proc shell*(top: HTML = @[]; body: HTML = @[]; bottom: HTML = @[]; extra = ""): HTMLNode =
  ## Three rows: chrome, the working area, status. The middle row is the only
  ## one that grows, so nothing else can push the layout past the viewport.
  result = node("div", cx("shell", extra))
  var i = 0
  while i < top.len:
    result.add top[i]
    inc i
  result.add node("div", "shell-body", body)
  var j = 0
  while j < bottom.len:
    result.add bottom[j]
    inc j

# ── window ──────────────────────────────────────────────────────────────────

proc window*(title: string; children: HTML = @[]; actions: HTML = @[];
             extra = ""): HTMLNode =
  ## A titled surface. The one component that floats, so the one that has a
  ## shadow.
  result = node("div", cx("win", extra))
  var bar = node("div", "win-bar")
  bar.add textNode("div", "win-title", title)
  if actions.len > 0:
    bar.add node("div", "win-actions", actions)
  result.add bar
  result.add node("div", "win-body", children)

# ── panes ───────────────────────────────────────────────────────────────────

proc panes*(children: HTML = @[]; column = false; extra = ""): HTMLNode =
  var c = "panes"
  if column: c.add " panes-col"
  node("div", cx(c, extra), children)

proc pane*(head = ""; children: HTML = @[]; extra = ""): HTMLNode =
  result = node("div", cx("pane", extra))
  if head.len > 0:
    result.add textNode("div", "pane-head", head)
  result.add node("div", "pane-body", children)

proc splitter*(row = false; extra = ""): HTMLNode =
  ## A hairline with an invisible grab area wider than itself.
  var c = "splitter"
  if row: c.add " is-row"
  result = node("div", cx(c, extra))
  result.setAttr("role", "separator")

# ── chrome ──────────────────────────────────────────────────────────────────

proc toolbar*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("toolbar", extra), children)

proc toolbarSep*(): HTMLNode = node("div", "toolbar-sep")
proc toolbarSpacer*(): HTMLNode = node("div", "toolbar-spacer")

proc statusBar*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("statusbar", extra), children)

proc statusItem*(label: string; extra = ""): HTMLNode =
  textNode("span", cx("status-item", extra), label)

# ── sidebar and explorer ────────────────────────────────────────────────────

proc sidebar*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("sidebar", extra), children)

proc explorer*(children: HTML = @[]; extra = ""): HTMLNode =
  result = node("div", cx("explorer", extra), children)
  result.setAttr("role", "tree")

proc treeItem*(label: string; depth = 0; selected = false; open = false;
               expandable = false; hint = ""; extra = ""): HTMLNode =
  ## One row of the explorer.
  ##
  ## Indent is the only inline style in the kit, because it is genuinely per-node
  ## and a class per depth would be a class per depth. It is still expressed in
  ## `--u`, so the tree keeps its alignment when `--scale` changes.
  var c = "tree-item"
  if selected: c.add " is-selected"
  if open: c.add " is-open"
  result = node("div", cx(c, extra))
  result.setAttr("role", "treeitem")
  if depth > 0:
    result.setAttr("style",
      "padding-left:calc(var(--s3) + var(--u) * 3 * " & $depth & ")")
  if selected: result.setAttr("aria-selected", "true")
  if expandable:
    result.setAttr("aria-expanded", if open: "true" else: "false")
    result.add textNode("span", "tree-twisty", "›")
  else:
    result.add node("span", "tree-twisty")
  result.add textNode("span", "tree-label", label)
  if hint.len > 0:
    result.add textNode("span", "tree-hint", hint)

# ── tabs ────────────────────────────────────────────────────────────────────

proc tabs*(children: HTML = @[]; extra = ""): HTMLNode =
  result = node("div", cx("tabs", extra), children)
  result.setAttr("role", "tablist")

proc tab*(label: string; active = false; extra = ""): HTMLNode =
  var c = "tab"
  if active: c.add " is-active"
  result = textNode("button", cx(c, extra), label)
  result.setAttr("type", "button")
  result.setAttr("role", "tab")
  result.setAttr("aria-selected", if active: "true" else: "false")

# ── breadcrumbs ─────────────────────────────────────────────────────────────

proc crumbs*(parts: openArray[string]; extra = ""): HTMLNode =
  result = node("nav", cx("crumbs", extra))
  result.setAttr("aria-label", "Breadcrumb")
  var i = 0
  while i < parts.len:
    if i > 0: result.add textNode("span", "crumb-sep", "/")
    result.add textNode("span", "crumb", parts[i])
    inc i

# ── menu ────────────────────────────────────────────────────────────────────

proc menu*(children: HTML = @[]; extra = ""): HTMLNode =
  result = node("div", cx("menu", extra), children)
  result.setAttr("role", "menu")

proc menuItem*(label: string; hint = ""; selected = false; extra = ""): HTMLNode =
  var c = "menu-item"
  if selected: c.add " is-selected"
  result = node("button", cx(c, extra))
  result.setAttr("type", "button")
  result.setAttr("role", "menuitem")
  result.add text(label)
  if hint.len > 0:
    result.add textNode("span", "menu-hint", hint)

proc menuSep*(): HTMLNode = node("div", "menu-sep")

# ── inspector ───────────────────────────────────────────────────────────────

proc inspector*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("inspector", extra), children)

proc inspRow*(key, value: string; extra = ""): HTMLNode =
  result = node("div", cx("insp-row", extra))
  result.add textNode("div", "insp-key", key)
  result.add textNode("div", "insp-val", value)

# ── lists ───────────────────────────────────────────────────────────────────

proc list*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("list", extra), children)

proc listItem*(children: HTML = @[]; selected = false; extra = ""): HTMLNode =
  var c = "list-item"
  if selected: c.add " is-selected"
  node("div", cx(c, extra), children)

# ── inset content ───────────────────────────────────────────────────────────

proc well*(children: HTML = @[]; extra = ""): HTMLNode =
  node("div", cx("well", extra), children)

proc code*(source: string; extra = ""): HTMLNode =
  result = node("pre", cx("code", extra))
  result.add text(source)

# ── controls ────────────────────────────────────────────────────────────────

proc button*(label: string; primary = false; danger = false; ghost = false;
             extra = ""): HTMLNode =
  ## The unmodified button is the SECONDARY style: the common case should not
  ## need a modifier, and a screen where everything is primary has no primary.
  var c = "btn"
  if primary: c.add " is-primary"
  elif danger: c.add " is-danger"
  elif ghost: c.add " is-ghost"
  result = textNode("button", cx(c, extra), label)
  result.setAttr("type", "button")

proc iconButton*(glyph, label: string; ghost = true; extra = ""): HTMLNode =
  ## `label` is required, not optional: an icon-only control with no accessible
  ## name is unusable by anything that cannot see the icon.
  var c = "btn btn-icon"
  if ghost: c.add " is-ghost"
  result = textNode("button", cx(c, extra), glyph)
  result.setAttr("type", "button")
  result.setAttr("aria-label", label)
  result.setAttr("title", label)

proc input*(placeholder = ""; value = ""; kind = "text"; extra = ""): HTMLNode =
  result = node("input", cx("input", extra))
  result.setAttr("type", kind)
  if placeholder.len > 0: result.setAttr("placeholder", placeholder)
  if value.len > 0: result.setAttr("value", value)

proc textarea*(placeholder = ""; value = ""; rows = 3; extra = ""): HTMLNode =
  result = node("textarea", cx("input textarea", extra))
  result.setAttr("rows", $rows)
  if placeholder.len > 0: result.setAttr("placeholder", placeholder)
  if value.len > 0: result.add text(value)

proc field*(label: string; children: HTML = @[]; help = ""; extra = ""): HTMLNode =
  result = node("label", cx("field", extra))
  result.add textNode("span", "field-label", label)
  var i = 0
  while i < children.len:
    result.add children[i]
    inc i
  if help.len > 0:
    result.add textNode("span", "field-help", help)

# ── status objects ──────────────────────────────────────────────────────────

proc chip*(label: string; accent = false; danger = false; extra = ""): HTMLNode =
  var c = "chip"
  if accent: c.add " is-accent"
  elif danger: c.add " is-danger"
  textNode("span", cx(c, extra), label)

proc dot*(live = false; danger = false; extra = ""): HTMLNode =
  var c = "dot"
  if live: c.add " is-live"
  elif danger: c.add " is-danger"
  result = node("span", cx(c, extra))
  result.setAttr("aria-hidden", "true")

proc meter*(percent: int; extra = ""): HTMLNode =
  ## Clamped here rather than trusted: a fill past 100% overflows its track and
  ## a negative one disappears, and both are easy to pass by accident.
  var p = percent
  if p < 0: p = 0
  if p > 100: p = 100
  result = node("div", cx("meter", extra))
  result.setAttr("role", "progressbar")
  result.setAttr("aria-valuenow", $p)
  var fill = node("div", "meter-fill")
  fill.setAttr("style", "width:" & $p & "%")
  result.add fill

# ── overlays ────────────────────────────────────────────────────────────────

proc scrim*(extra = ""): HTMLNode = node("div", cx("scrim", extra))

proc dialog*(title: string; children: HTML = @[]; actions: HTML = @[];
             extra = ""): HTMLNode =
  result = node("div", cx("dialog", extra))
  result.setAttr("role", "dialog")
  result.setAttr("aria-modal", "true")
  result.add textNode("div", "dialog-title", title)
  var i = 0
  while i < children.len:
    result.add children[i]
    inc i
  if actions.len > 0:
    result.add node("div", "dialog-actions", actions)

proc toast*(title, body: string; extra = ""): HTMLNode =
  result = node("div", cx("toast", extra))
  result.setAttr("role", "status")
  var col = node("div", "col")
  col.add textNode("div", "", title)
  if body.len > 0: col.add textNode("div", "hint", body)
  result.add col

proc callout*(title, body: string; extra = ""): HTMLNode =
  result = node("div", cx("callout", extra))
  result.add textNode("div", "", title)
  if body.len > 0: result.add textNode("div", "hint", body)

proc empty*(title, body: string; action: HTML = @[]; extra = ""): HTMLNode =
  ## An empty screen is an instruction, not a mood: it says what is missing and
  ## offers the action that fixes it.
  result = node("div", cx("empty", extra))
  result.add textNode("div", "empty-title", title)
  if body.len > 0: result.add textNode("div", "", body)
  var i = 0
  while i < action.len:
    result.add action[i]
    inc i

## ui/components/panel — the Panel (DockPanel) style table (DATA) + builder proc.

import aoughwl/ui/variants

register("Panel", ComponentStyles(
  base: spec(@[
    d("border", "1px solid var(--hairline)"), d("border-radius", "var(--rad-3)"),
    d("background", "var(--panel-solid)"), d("box-shadow", "var(--bubble-shadow)"),
    d("overflow", "hidden"), d("display", "flex"), d("flex-direction", "column")]),
  variants: @[
    ks("accent", spec(@[d("border-color", "var(--accent-edge-45)"),
                        d("background", "var(--accent-wash-6)")])),
    ks("plain",  spec(@[d("box-shadow", "none")])),
  ],
  sizes: @[],
  states: @[
    ks("collapsed", spec()),
    ks("active",    spec(@[d("border-color", "var(--accent-edge-60)")])),
  ],
))

proc panel*(title = ""; variant = ""; collapsed = false; active = false;
            children: HTML = @[]): HTMLNode =
  ## Build a panel: a header (title) over a body that slots `children`.
  var states: seq[string] = @[]
  if collapsed: states.add "collapsed"
  if active: states.add "active"
  let cls = variantClass("Panel", variant, "", states)
  result = webEl("section")
  result = webAttr(result, "class", cls)
  if title.len > 0:
    var head = webEl("header")
    head = webChild(head, webText(title))
    result = webChild(result, head)
  var body = webEl("div")
  body = webSlot(body, children)
  result = webChild(result, body)

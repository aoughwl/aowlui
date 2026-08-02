## ui/components/menuitem — the MenuItem style table (DATA) + builder proc.

import aoughwl/ui/variants

register("MenuItem", ComponentStyles(
  base: pseudo(
    spec(@[
      d("display", "flex"), d("align-items", "center"), d("gap", "var(--sp-2)"),
      d("padding", "var(--sp-2) var(--sp-3)"), d("border-radius", "var(--rad-1)"),
      d("color", "var(--text)"), d("cursor", "pointer")]),
    ":hover", @[d("background", "var(--control-hover)")]),
  variants: @[
    ks("danger", pseudo(spec(@[d("color", "var(--danger)")]),
                        ":hover", @[d("background", "var(--danger-wash-14)")])),
  ],
  sizes: @[],
  states: @[
    ks("active",   spec(@[d("background", "var(--accent-wash-12)"), d("color", "var(--text)")])),
    ks("disabled", spec(@[d("opacity", ".45"), d("cursor", "default")])),
  ],
))

proc menuitem*(label: string; variant = ""; active = false; disabled = false): HTMLNode =
  ## Build a menu item row with the resolved variant class.
  var states: seq[string] = @[]
  if active: states.add "active"
  if disabled: states.add "disabled"
  let cls = variantClass("MenuItem", variant, "", states)
  result = webEl("div")
  result = webAttr(result, "class", cls)
  result = webChild(result, webText(label))

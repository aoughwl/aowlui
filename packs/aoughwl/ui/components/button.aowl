## ui/components/button — reference source for the button widget.
##
## This file keeps the component syntax shape we want to author against:
## `component button:` with inline `style:` and bracketed pseudos.
##
## Inline styling: `v(token)` references a theme token (→ `var(--send-bg)` etc.),
## and bracketed pseudo sub-blocks `[hover]:` / `[disabled]:` compile to
## `:hover` / `:disabled` rules on the one content-addressed class.

import aoughwl/web            # HTMLNode, webEl/webAttr/…, and the `web:` markup DSL

component button:
  input label: string
  button:
    style:
      display: "inline-flex"
      alignItems: center
      gap: 6.px
      padding: 8.px 18.px
      border: 1.px solid v(hairline)
      borderRadius: 999.px
      background: v(sendBg)
      color: v(sendColor)
      cursor: pointer
      [hover]:
        opacity: 0.9
      [disabled]:
        opacity: 0.48
        cursor: default
    label                             # bare ident → embeds the prop's value as text

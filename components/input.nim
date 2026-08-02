## ui/components/input — reference source for the text input widget.
##
## This keeps the component syntax shape we want to author against:
## `component textInput:` with a keyword-free `field:` element alias.
##
## Styling is inline: `v(token)` tokens, and `[focus]:` / `[placeholder]:`
## bracketed pseudos.

import web            # HTMLNode, webEl/webAttr/…, and the `web:` markup DSL

component textInput:
  input placeholder: string
  input value: string
  field:
    placeholder = placeholder         # runtime prop → attribute value
    value = value
    style:
      width: 100.percent
      minHeight: 38.px
      padding: 8.px 10.px
      border: 1.px solid v(hairline)
      borderRadius: 8.px
      background: v(controlBg)
      color: v(text)
      outline: 0.px
      [focus]:
        borderColor: v(controlColor)
        background: v(controlHover)
      [placeholder]:
        color: v(placeholder)

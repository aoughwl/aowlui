## ui/components/layout — reference sources for layout primitives.
##
## These files document the component shape we author against; the shipped
## implementation in `packs/aoughwl/ui.aowl` is the runtime surface.

import web

component stack:
  input children: HTML = @[]
  box:
    style:
      display: flex
      flexDirection: column
      gap: 12.px
    slot(children)

component cluster:
  input children: HTML = @[]
  box:
    style:
      display: flex
      flexWrap: wrap
      alignItems: center
      gap: 8.px
    slot(children)

component surface:
  input children: HTML = @[]
  box:
    style:
      padding: 16.px
      border: 1.px solid v(hairline)
      borderRadius: 12.px
      background: v(panel)
    slot(children)

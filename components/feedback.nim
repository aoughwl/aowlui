## ui/components/feedback — reference sources for empty-state and alert-like UI.

import web

component toast:
  input title: string
  input body: string
  box:
    style:
      display: flex
      flexDirection: column
      gap: 4.px
      padding: 12.px 14.px
      borderRadius: 12.px
      background: v(accentWash10)
      border: 1.px solid v(accentEdge45)
    box:
      style:
        color: v(accent)
        fontWeight: 700
      title
    box:
      style:
        color: v(text)
      body

component emptyState:
  input title: string
  input body: string
  box:
    style:
      display: grid
      gap: 8.px
      padding: 20.px
      borderRadius: 14.px
      border: 1.px dashed v(hairline)
      background: v(trace)
      textAlign: center
    box:
      style:
        color: v(text)
        fontWeight: 700
      title
    box:
      style:
        color: v(muted)
      body

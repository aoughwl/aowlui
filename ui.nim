## ui — the builtin UI component library + styling system.
##
##   import aoughwl/ui
##
##   echo renderTheme()
##   echo render(button("Send"))
##   echo render(textInput(placeholder = "Search…", value = ""))
##   echo renderStylesheet()
##
## The pack surface is plain exported procs authored with the `web:` DSL.
## The component syntax itself is demonstrated in `scripts/component.aowl`.

import theme
import web

proc button*(label: string): HTMLNode =
  let frag = web:
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
        fontWeight: 600
        [hover]:
          opacity: 0.9
        [disabled]:
          opacity: 0.48
          cursor: default
      label
  result = frag[0]

proc iconButton*(glyph: string; title = ""): HTMLNode =
  let frag = web:
    button:
      attr:
        title: title
      style:
        display: "inline-grid"
        placeItems: center
        width: 38.px
        height: 38.px
        padding: 0.px
        border: 1.px solid v(hairline)
        borderRadius: 10.px
        background: v(panel)
        color: v(text)
        cursor: pointer
        fontWeight: 700
        [hover]:
          background: v(controlHover)
      glyph
  result = frag[0]

proc textInput*(placeholder = ""; value = ""): HTMLNode =
  let frag = web:
    field:
      placeholder = placeholder
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
  result = frag[0]

proc badge*(label: string; tone = "neutral"): HTMLNode =
  case tone
  of "danger":
    let frag = web:
      box:
        style:
          display: "inline-flex"
          alignItems: center
          gap: 6.px
          padding: 4.px 10.px
          borderRadius: 999.px
          background: v(dangerWash14)
          color: v(danger)
          border: 1.px solid v(dangerEdge45)
          fontSize: 0.78.rem
          fontWeight: 600
        label
    result = frag[0]
  of "warning":
    let frag = web:
      box:
        style:
          display: "inline-flex"
          alignItems: center
          gap: 6.px
          padding: 4.px 10.px
          borderRadius: 999.px
          background: v(warningWash14)
          color: v(warning)
          border: 1.px solid v(warningEdge45)
          fontSize: 0.78.rem
          fontWeight: 600
        label
    result = frag[0]
  of "accent":
    let frag = web:
      box:
        style:
          display: "inline-flex"
          alignItems: center
          gap: 6.px
          padding: 4.px 10.px
          borderRadius: 999.px
          background: v(accentWash14)
          color: v(accent)
          border: 1.px solid v(accentEdge45)
          fontSize: 0.78.rem
          fontWeight: 600
        label
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "inline-flex"
          alignItems: center
          gap: 6.px
          padding: 4.px 10.px
          borderRadius: 999.px
          background: v(chipBg)
          color: v(chipColor)
          border: 1.px solid v(hairline)
          fontSize: 0.78.rem
          fontWeight: 600
        label
    result = frag[0]

proc avatar*(label: string; tone = "accent"): HTMLNode =
  case tone
  of "danger":
    let frag = web:
      box:
        attr:
          ariaLabel: label
        style:
          display: "grid"
          placeItems: center
          width: 2.4.rem
          height: 2.4.rem
          borderRadius: 999.px
          background: v(dangerWash16)
          color: v(danger)
          border: 1.px solid v(dangerEdge45)
          fontWeight: 700
        label
    result = frag[0]
  of "warning":
    let frag = web:
      box:
        attr:
          ariaLabel: label
        style:
          display: "grid"
          placeItems: center
          width: 2.4.rem
          height: 2.4.rem
          borderRadius: 999.px
          background: v(warningWash16)
          color: v(warning)
          border: 1.px solid v(warningEdge45)
          fontWeight: 700
        label
    result = frag[0]
  else:
    let frag = web:
      box:
        attr:
          ariaLabel: label
        style:
          display: "grid"
          placeItems: center
          width: 2.4.rem
          height: 2.4.rem
          borderRadius: 999.px
          background: v(accentWash16)
          color: v(accent)
          border: 1.px solid v(accentEdge45)
          fontWeight: 700
        label
    result = frag[0]

proc divider*(): HTMLNode =
  let frag = web:
    box:
      style:
        width: 100.percent
        height: 1.px
        background: v(hairline)
  result = frag[0]

proc card*(title: string; children: HTML = @[]): HTMLNode =
  let frag = web:
    box:
      style:
        display: "flex"
        flexDirection: column
        gap: 12.px
        padding: 16.px
        border: 1.px solid v(hairline)
        borderRadius: 12.px
        background: v(panelSolid)
        boxShadow: v(bubbleShadow)
      box:
        style:
          display: "flex"
          alignItems: center
          justifyContent: "space-between"
          gap: 12.px
        h3 title
      box:
        slot(children)
  result = frag[0]

proc toolbar*(children: HTML = @[]): HTMLNode =
  let frag = web:
    box:
      style:
        display: "flex"
        flexWrap: wrap
        alignItems: center
        gap: 8.px
        padding: 8.px
        border: 1.px solid v(hairline)
        borderRadius: 10.px
        background: v(panel)
      slot(children)
  result = frag[0]

proc menuItem*(label: string; hint = ""): HTMLNode =
  if hint.len > 0:
    let frag = web:
      button:
        attr:
          title: hint
        style:
          display: "flex"
          alignItems: center
          justifyContent: "space-between"
          gap: 12.px
          width: 100.percent
          padding: 8.px 12.px
          border: 0.px
          borderRadius: 8.px
          background: "transparent"
          color: v(text)
          cursor: pointer
          textAlign: left
          [hover]:
            background: v(controlHover)
        box:
          style:
            display: "flex"
            alignItems: center
            gap: 10.px
          label
        box:
          style:
            color: v(muted)
            fontSize: 0.85.rem
          hint
    result = frag[0]
  else:
    let frag = web:
      button:
        style:
          display: "flex"
          alignItems: center
          justifyContent: "space-between"
          gap: 12.px
          width: 100.percent
          padding: 8.px 12.px
          border: 0.px
          borderRadius: 8.px
          background: "transparent"
          color: v(text)
          cursor: pointer
          textAlign: left
          [hover]:
            background: v(controlHover)
        box:
          style:
            display: "flex"
            alignItems: center
            gap: 10.px
          label
    result = frag[0]

proc stat*(label, value: string): HTMLNode =
  let frag = web:
    box:
      style:
        display: "flex"
        flexDirection: column
        gap: 4.px
        padding: 12.px
        borderRadius: 10.px
        background: v(trace)
        border: 1.px solid v(hairline)
      box:
        style:
          color: v(muted)
          fontSize: 0.82.rem
        label
      box:
        style:
          color: v(text)
          fontSize: 1.15.rem
          fontWeight: 700
        value
  result = frag[0]

proc callout*(title, body: string; tone = "accent"): HTMLNode =
  case tone
  of "danger":
    let frag = web:
      box:
        style:
          display: "flex"
          flexDirection: column
          gap: 8.px
          padding: 14.px 16.px
          borderRadius: 12.px
          background: v(dangerWash10)
          border: 1.px solid v(dangerEdge45)
        box:
          style:
            color: v(danger)
            fontWeight: 700
          title
        box:
          style:
            color: v(text)
          body
    result = frag[0]
  of "warning":
    let frag = web:
      box:
        style:
          display: "flex"
          flexDirection: column
          gap: 8.px
          padding: 14.px 16.px
          borderRadius: 12.px
          background: v(warningWash10)
          border: 1.px solid v(warningEdge45)
        box:
          style:
            color: v(warning)
            fontWeight: 700
          title
        box:
          style:
            color: v(text)
          body
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "flex"
          flexDirection: column
          gap: 8.px
          padding: 14.px 16.px
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
    result = frag[0]

proc codeBlock*(code: string; lang = ""): HTMLNode =
  let frag = web:
    box:
      attr:
        dataLang: lang
      style:
        padding: 14.px 16.px
        borderRadius: 12.px
        background: v(markBg)
        color: v(markColor)
        border: 1.px solid v(hairline)
        fontFamily: v(fontMono)
        fontSize: 0.92.rem
        whiteSpace: "pre-wrap"
        overflowX: auto
      pre:
        code
  result = frag[0]

proc tab*(label: string; active = false): HTMLNode =
  if active:
    let frag = web:
      button:
        style:
          padding: 8.px 14.px
          borderRadius: 999.px
          border: 1.px solid v(tabActiveBg)
          background: v(tabActiveBg)
          color: v(tabColor)
          fontWeight: 600
          cursor: pointer
        label
    result = frag[0]
  else:
    let frag = web:
      button:
        style:
          padding: 8.px 14.px
          borderRadius: 999.px
          border: 1.px solid v(hairline)
          background: v(tabBg)
          color: v(tabColor)
          fontWeight: 600
          cursor: pointer
        label
    result = frag[0]

proc tabs*(children: HTML = @[]): HTMLNode =
  let frag = web:
    box:
      attr:
        role: "tablist"
      style:
        display: "flex"
        flexWrap: wrap
        gap: 8.px
        padding: 8.px
        borderRadius: 12.px
        background: v(panel)
        border: 1.px solid v(hairline)
      slot(children)
  result = frag[0]

proc stack*(children: HTML = @[]): HTMLNode =
  let frag = web:
    box:
      style:
        display: "flex"
        flexDirection: column
        gap: 12.px
      slot(children)
  result = frag[0]

proc cluster*(children: HTML = @[]; wrap = true): HTMLNode =
  if wrap:
    let frag = web:
      box:
        style:
          display: "flex"
          flexWrap: "wrap"
          alignItems: center
          gap: 8.px
        slot(children)
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "flex"
          flexWrap: "nowrap"
          alignItems: center
          gap: 8.px
        slot(children)
    result = frag[0]

proc surface*(children: HTML = @[]; tone = "panel"): HTMLNode =
  if tone == "solid":
    let frag = web:
      box:
        style:
          padding: 16.px
          border: 1.px solid v(hairline)
          borderRadius: 12.px
          background: v(panelSolid)
        slot(children)
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          padding: 16.px
          border: 1.px solid v(hairline)
          borderRadius: 12.px
          background: v(panel)
        slot(children)
    result = frag[0]

proc sectionHeader*(title: string; detail = ""; action = ""): HTMLNode =
  if detail.len > 0 and action.len > 0:
    let frag = web:
      box:
        style:
          display: "flex"
          alignItems: center
          justifyContent: "space-between"
          gap: 12.px
        box:
          style:
            display: "flex"
            flexDirection: column
            gap: 2.px
          box:
            style:
              color: v(text)
              fontWeight: 700
            title
          box:
            style:
              color: v(muted)
              fontSize: 0.85.rem
            detail
        button:
          style:
            padding: 6.px 10.px
            borderRadius: 999.px
            border: 1.px solid v(hairline)
            background: "transparent"
            color: v(text)
          action
    result = frag[0]
  elif detail.len > 0:
    let frag = web:
      box:
        style:
          display: "flex"
          alignItems: center
          justifyContent: "space-between"
          gap: 12.px
        box:
          style:
            display: "flex"
            flexDirection: column
            gap: 2.px
          box:
            style:
              color: v(text)
              fontWeight: 700
            title
          box:
            style:
              color: v(muted)
              fontSize: 0.85.rem
            detail
    result = frag[0]
  elif action.len > 0:
    let frag = web:
      box:
        style:
          display: "flex"
          alignItems: center
          justifyContent: "space-between"
          gap: 12.px
        box:
          style:
            display: "flex"
            flexDirection: column
            gap: 2.px
          box:
            style:
              color: v(text)
              fontWeight: 700
            title
        button:
          style:
            padding: 6.px 10.px
            borderRadius: 999.px
            border: 1.px solid v(hairline)
            background: "transparent"
            color: v(text)
          action
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "flex"
          alignItems: center
          justifyContent: "space-between"
          gap: 12.px
        box:
          style:
            display: "flex"
            flexDirection: column
            gap: 2.px
          box:
            style:
              color: v(text)
              fontWeight: 700
            title
    result = frag[0]

proc progressBar*(value: int; max = 100): HTMLNode =
  if value <= max div 4:
    let frag = web:
      box:
        attr:
          role: "progressbar"
        style:
          display: "grid"
          gap: 6.px
        box:
          style:
            height: 8.px
            borderRadius: 999.px
            background: v(hairline)
            overflow: hidden
          box:
            style:
              width: 25.percent
              height: 100.percent
              borderRadius: 999.px
              background: v(accent)
        box:
          style:
            color: v(muted)
            fontSize: 0.82.rem
          $value & "/" & $max
    result = frag[0]
  elif value <= max div 2:
    let frag = web:
      box:
        attr:
          role: "progressbar"
        style:
          display: "grid"
          gap: 6.px
        box:
          style:
            height: 8.px
            borderRadius: 999.px
            background: v(hairline)
            overflow: hidden
          box:
            style:
              width: 50.percent
              height: 100.percent
              borderRadius: 999.px
              background: v(accent)
        box:
          style:
            color: v(muted)
            fontSize: 0.82.rem
          $value & "/" & $max
    result = frag[0]
  elif value <= (max * 3) div 4:
    let frag = web:
      box:
        attr:
          role: "progressbar"
        style:
          display: "grid"
          gap: 6.px
        box:
          style:
            height: 8.px
            borderRadius: 999.px
            background: v(hairline)
            overflow: hidden
          box:
            style:
              width: 75.percent
              height: 100.percent
              borderRadius: 999.px
              background: v(accent)
        box:
          style:
            color: v(muted)
            fontSize: 0.82.rem
          $value & "/" & $max
    result = frag[0]
  else:
    let frag = web:
      box:
        attr:
          role: "progressbar"
        style:
          display: "grid"
          gap: 6.px
        box:
          style:
            height: 8.px
            borderRadius: 999.px
            background: v(hairline)
            overflow: hidden
          box:
            style:
              width: 100.percent
              height: 100.percent
              borderRadius: 999.px
              background: v(accent)
        box:
          style:
            color: v(muted)
            fontSize: 0.82.rem
          $value & "/" & $max
    result = frag[0]

proc meter*(label: string; value: string; detail = ""): HTMLNode =
  if detail.len > 0:
    let frag = web:
      box:
        style:
          display: "flex"
          flexDirection: column
          gap: 6.px
          padding: 12.px 14.px
          borderRadius: 12.px
          border: 1.px solid v(hairline)
          background: v(trace)
        box:
          style:
            display: "flex"
            alignItems: center
            justifyContent: "space-between"
            gap: 12.px
          box:
            style:
              color: v(muted)
              fontSize: 0.84.rem
            label
          box:
            style:
              color: v(text)
              fontWeight: 700
            value
        box:
          style:
            color: v(muted)
            fontSize: 0.82.rem
          detail
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "flex"
          flexDirection: column
          gap: 6.px
          padding: 12.px 14.px
          borderRadius: 12.px
          border: 1.px solid v(hairline)
          background: v(trace)
        box:
          style:
            display: "flex"
            alignItems: center
            justifyContent: "space-between"
            gap: 12.px
          box:
            style:
              color: v(muted)
              fontSize: 0.84.rem
            label
          box:
            style:
              color: v(text)
              fontWeight: 700
            value
    result = frag[0]

proc toast*(title, body: string; tone = "accent"): HTMLNode =
  case tone
  of "danger":
    let frag = web:
      box:
        style:
          display: "flex"
          alignItems: "flex-start"
          gap: 10.px
          padding: 12.px 14.px
          borderRadius: 12.px
          border: 1.px solid v(dangerEdge45)
          background: v(dangerWash10)
        box:
          style:
            display: "flex"
            flexDirection: column
            gap: 4.px
          box:
            style:
              color: v(danger)
              fontWeight: 700
            title
          box:
            style:
              color: v(text)
            body
    result = frag[0]
  of "warning":
    let frag = web:
      box:
        style:
          display: "flex"
          alignItems: "flex-start"
          gap: 10.px
          padding: 12.px 14.px
          borderRadius: 12.px
          border: 1.px solid v(warningEdge45)
          background: v(warningWash10)
        box:
          style:
            display: "flex"
            flexDirection: column
            gap: 4.px
          box:
            style:
              color: v(warning)
              fontWeight: 700
            title
          box:
            style:
              color: v(text)
            body
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "flex"
          alignItems: "flex-start"
          gap: 10.px
          padding: 12.px 14.px
          borderRadius: 12.px
          border: 1.px solid v(accentEdge45)
          background: v(accentWash10)
        box:
          style:
            display: "flex"
            flexDirection: column
            gap: 4.px
          box:
            style:
              color: v(accent)
              fontWeight: 700
            title
          box:
            style:
              color: v(text)
            body
    result = frag[0]

proc dialog*(title, body: string; action = "Close"): HTMLNode =
  let frag = web:
    box:
      attr:
        role: "dialog"
        ariaModal: "true"
      style:
        display: "grid"
        gap: 12.px
        padding: 18.px
        borderRadius: 16.px
        border: 1.px solid v(hairline)
        background: v(panelSolid)
        boxShadow: v(shadow)
      box:
        style:
          display: "flex"
          alignItems: center
          justifyContent: "space-between"
          gap: 12.px
        box:
          style:
            color: v(text)
            fontSize: 1.1.rem
            fontWeight: 700
          title
        button:
          style:
            padding: 6.px 10.px
            borderRadius: 999.px
            border: 1.px solid v(hairline)
            background: "transparent"
            color: v(text)
          action
      box:
        style:
          color: v(text)
        body
  result = frag[0]

proc emptyState*(title, body: string; action = ""): HTMLNode =
  if action.len > 0:
    let frag = web:
      box:
        style:
          display: "grid"
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
        button:
          style:
            justifySelf: "center"
            padding: 8.px 14.px
            borderRadius: 999.px
            border: 1.px solid v(hairline)
            background: v(panelSolid)
            color: v(text)
          action
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "grid"
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
    result = frag[0]

proc pill*(label: string; tone = "accent"): HTMLNode =
  case tone
  of "danger":
    let frag = web:
      box:
        style:
          display: "inline-flex"
          alignItems: center
          gap: 4.px
          padding: 3.px 8.px
          borderRadius: 999.px
          background: v(dangerWash10)
          color: v(danger)
          border: 1.px solid v(dangerEdge45)
          fontSize: 0.74.rem
          fontWeight: 700
        label
    result = frag[0]
  of "warning":
    let frag = web:
      box:
        style:
          display: "inline-flex"
          alignItems: center
          gap: 4.px
          padding: 3.px 8.px
          borderRadius: 999.px
          background: v(warningWash10)
          color: v(warning)
          border: 1.px solid v(warningEdge45)
          fontSize: 0.74.rem
          fontWeight: 700
        label
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "inline-flex"
          alignItems: center
          gap: 4.px
          padding: 3.px 8.px
          borderRadius: 999.px
          background: v(accentWash10)
          color: v(accent)
          border: 1.px solid v(accentEdge45)
          fontSize: 0.74.rem
          fontWeight: 700
        label
    result = frag[0]

proc breadcrumb*(children: HTML = @[]): HTMLNode =
  let frag = web:
    box:
      attr:
        ariaLabel: "Breadcrumb"
      style:
        display: "flex"
        flexWrap: wrap
        alignItems: center
        gap: 6.px
        color: v(muted)
      slot(children)
  result = frag[0]

proc sidebar*(children: HTML = @[]): HTMLNode =
  let frag = web:
    box:
      style:
        display: "flex"
        flexDirection: column
        gap: 10.px
        padding: 14.px
        borderRadius: 14.px
        border: 1.px solid v(hairline)
        background: v(trace)
      slot(children)
  result = frag[0]

proc formField*(label: string; help = ""; children: HTML = @[]): HTMLNode =
  if help.len > 0:
    let frag = web:
      box:
        style:
          display: "grid"
          gap: 6.px
        box:
          style:
            color: v(text)
            fontWeight: 700
          label
        box:
          style:
            display: "grid"
            gap: 8.px
          slot(children)
        box:
          style:
            color: v(muted)
            fontSize: 0.82.rem
          help
    result = frag[0]
  else:
    let frag = web:
      box:
        style:
          display: "grid"
          gap: 6.px
        box:
          style:
            color: v(text)
            fontWeight: 700
          label
        box:
          style:
            display: "grid"
            gap: 8.px
          slot(children)
    result = frag[0]

export theme
export web

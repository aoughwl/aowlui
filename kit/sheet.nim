## aowlui/kit/sheet — the kit's stylesheet: one rule per component.
##
## Every number here is a token. A declaration that hard-codes a length has
## opted out of `--scale` and is a defect — the only deliberate exception is the
## 1px hairline, because a border that scales stops reading as a hairline and
## the crispness is what makes the surface look precise rather than soft.
##
## Three ideas hold the kit together:
##
## * **Three surfaces, no more.** `--bg` is the page, `--bg-2` a panel or window,
##   `--bg-3` an inset (input, code well). Depth beyond that comes from a
##   hairline, never from another grey. `--shadow` is spent ONLY on things that
##   genuinely float — dialog, menu, toast — so a shadow always means "above the
##   page" instead of meaning nothing.
##
## * **Selection is one language.** `.is-selected` puts a 2px accent rail on the
##   leading edge over a 12% accent wash, and it is the SAME rule for a tree row,
##   a tab, a list item and a menu item. Learn it once and it holds everywhere,
##   which is what makes these compose.
##
## * **Focus is never invisible.** One `:focus-visible` rule covers every
##   interactive element in the kit.
##
## Ink follows the same three levels as surfaces: `--primary` for content,
## `--secondary` for labels, `--tertiary` for hints — so "how important is this
## text" has three answers rather than a colour per component.

import css

const
  # The kit's motion. Short, and only on colour-ish properties: moving layout on
  # hover is what makes an interface feel unstable.
  ease* = "cubic-bezier(.2,.8,.2,1)"
  motion* = "transition:background-color .12s " & ease &
            ",color .12s " & ease & ",border-color .12s " & ease

proc kitSheet*(): Stylesheet =
  ## The whole kit. Rules are grouped the way they compose, not alphabetically.
  result = initStylesheet()

  # ── application shell ────────────────────────────────────────────────────
  result.rule ".shell", styleOf(
    "display:grid;grid-template-rows:auto 1fr auto;height:100%;min-height:0")
  result.rule ".shell-body", styleOf(
    "display:flex;min-height:0;min-width:0;overflow:hidden")

  # ── window ───────────────────────────────────────────────────────────────
  # A window is the one component that floats on the page, so it is the one that
  # carries the shadow.
  result.rule ".win", styleOf(
    "display:flex;flex-direction:column;min-height:0;overflow:hidden;" &
    "background:var(--bg-2);border:var(--hair) solid var(--border);" &
    "border-radius:var(--r2);box-shadow:var(--shadow)")
  result.rule ".win-bar", styleOf(
    "display:flex;align-items:center;gap:var(--s2);flex:0 0 auto;" &
    "height:var(--bar);padding:0 var(--s3);" &
    "border-bottom:var(--hair) solid var(--border);" &
    "background:var(--bg-2);user-select:none")
  result.rule ".win-title", styleOf(
    "font-weight:600;letter-spacing:-.01em;white-space:nowrap;" &
    "overflow:hidden;text-overflow:ellipsis")
  result.rule ".win-actions", styleOf(
    "display:flex;align-items:center;gap:var(--s1);margin-left:auto")
  result.rule ".win-body", styleOf(
    "flex:1 1 auto;min-height:0;overflow:auto")

  # ── panes and splitting ──────────────────────────────────────────────────
  result.rule ".panes", styleOf(
    "display:flex;flex:1 1 auto;min-height:0;min-width:0")
  result.rule ".panes-col", styleOf("flex-direction:column")
  result.rule ".pane", styleOf(
    "display:flex;flex-direction:column;flex:1 1 0;min-width:0;min-height:0;" &
    "overflow:hidden")
  result.rule ".pane-head", styleOf(
    "display:flex;align-items:center;gap:var(--s2);flex:0 0 auto;" &
    "height:var(--ctl);padding:0 var(--s3);" &
    "border-bottom:var(--hair) solid var(--border);" &
    "color:var(--secondary);font-size:var(--fs-sm);font-weight:500;" &
    "text-transform:uppercase;letter-spacing:.08em;user-select:none")
  result.rule ".pane-body", styleOf("flex:1 1 auto;min-height:0;overflow:auto")
  # A CONSOLE: the pane docked along the bottom edge, holding output. It needs a
  # height of its own because its row in the shell grid is `auto`, so without
  # one it collapses to its head and the output is invisible.
  #
  # This exists because two call sites were already writing `console` as an
  # extra class the kit had never heard of, and it therefore matched nothing.
  # A class invented at a call site does not fail -- it silently does nothing,
  # which is why the rule is that the kit owns every name.
  result.rule ".console", styleOf(
    "flex:0 0 auto;height:calc(var(--u) * 40);min-height:calc(var(--u) * 16)")
  # A pane whose body must LAY OUT its children rather than scroll them: an
  # editor, a canvas, anything that fills. Without this a mounted component has
  # no height to stretch against and collapses to zero -- which looks like the
  # component failing to load rather than the container failing to size it.
  result.rule ".pane.is-column > .pane-body", styleOf(
    "display:flex;flex-direction:column;overflow:hidden")
  # the child that takes the remaining space in such a body
  result.rule ".fill", styleOf("flex:1 1 auto;min-height:0;min-width:0")
  # A splitter is a hairline with a generous grab area, and the grab area must
  # not COST anything.
  #
  # It used to get its target size from transparent left/right borders, which
  # are real box width: the divider occupied nine pixels of layout to show one,
  # and between two panes that reads as a gap rather than as a seam. The grab
  # area is an absolutely-positioned overlay now, so it is just as easy to hit
  # and takes no space at all.
  result.rule ".splitter", styleOf(
    "flex:0 0 auto;position:relative;width:var(--hair);" &
    "background:var(--border);cursor:col-resize")
  result.rule ".splitter::before", styleOf(
    "content:'';position:absolute;top:0;bottom:0;" &
    "left:calc(-1 * var(--s2));right:calc(-1 * var(--s2))")
  result.rule ".splitter:hover", styleOf("background:var(--accent)")
  result.rule ".splitter.is-row", styleOf(
    "width:auto;height:var(--hair);cursor:row-resize")
  result.rule ".splitter.is-row::before", styleOf(
    "left:0;right:0;top:calc(-1 * var(--s2));bottom:calc(-1 * var(--s2))")

  # ── chrome: toolbar, status bar ──────────────────────────────────────────
  result.rule ".toolbar", styleOf(
    "display:flex;align-items:center;gap:var(--s2);flex:0 0 auto;" &
    "height:var(--bar);padding:0 var(--s3);" &
    "border-bottom:var(--hair) solid var(--border);background:var(--bg-2)")
  result.rule ".toolbar-sep", styleOf(
    "width:var(--hair);align-self:stretch;margin:var(--s2) var(--s1);" &
    "background:var(--border)")
  result.rule ".toolbar-spacer", styleOf("margin-left:auto")
  result.rule ".statusbar", styleOf(
    "display:flex;align-items:center;gap:var(--s3);flex:0 0 auto;" &
    "height:var(--ctl);padding:0 var(--s3);" &
    "border-top:var(--hair) solid var(--border);background:var(--bg-2);" &
    "color:var(--secondary);font-size:var(--fs-sm)")
  result.rule ".status-item", styleOf(
    "display:inline-flex;align-items:center;gap:var(--s1);" &
    "font-variant-numeric:tabular-nums")

  # ── sidebar / explorer ───────────────────────────────────────────────────
  result.rule ".sidebar", styleOf(
    "display:flex;flex-direction:column;flex:0 0 auto;min-height:0;" &
    "width:calc(var(--u) * 56);background:var(--bg-2);" &
    "border-right:var(--hair) solid var(--border)")
  result.rule ".explorer", styleOf(
    "flex:1 1 auto;min-height:0;overflow:auto;padding:var(--s1) 0")
  # A tree row's indent is a token multiple, so the whole tree reflows with
  # --scale instead of drifting out of alignment with the rest of the UI.
  result.rule ".tree-item", styleOf(
    "display:flex;align-items:center;gap:var(--s2);" &
    "height:var(--ctl);padding:0 var(--s3);" &
    "border-left:var(--rail) solid transparent;" &
    "color:var(--primary);cursor:default;user-select:none;" & motion)
  result.rule ".tree-item:hover", styleOf(
    "background:color-mix(in srgb, var(--primary) 6%, transparent)")
  result.rule ".tree-twisty", styleOf(
    "flex:0 0 auto;width:var(--s3);color:var(--tertiary);" &
    "transition:transform .12s " & ease)
  result.rule ".tree-item.is-open .tree-twisty", styleOf("transform:rotate(90deg)")
  result.rule ".tree-label", styleOf(
    "overflow:hidden;text-overflow:ellipsis;white-space:nowrap")
  result.rule ".tree-hint", styleOf(
    "margin-left:auto;color:var(--tertiary);font-size:var(--fs-sm);" &
    "font-variant-numeric:tabular-nums")

  # ── the selection language — ONE rule, every list-like component ─────────
  result.rule ".is-selected", styleOf(
    "background:color-mix(in srgb, var(--accent) 12%, transparent);" &
    "border-left-color:var(--accent);color:var(--primary)")
  result.rule ".is-disabled", styleOf(
    "opacity:.45;pointer-events:none")
  result.rule ":focus-visible", styleOf(
    "outline:var(--rail) solid color-mix(in srgb, var(--accent) 55%, transparent);" &
    "outline-offset:1px;border-radius:var(--r1)")

  # ── tabs ─────────────────────────────────────────────────────────────────
  result.rule ".tabs", styleOf(
    "display:flex;align-items:stretch;gap:var(--s1);flex:0 0 auto;" &
    "padding:0 var(--s2);border-bottom:var(--hair) solid var(--border);" &
    "background:var(--bg-2);user-select:none")
  result.rule ".tab", styleOf(
    "display:inline-flex;align-items:center;gap:var(--s2);" &
    "height:var(--ctl);padding:0 var(--s3);" &
    "border:0;border-bottom:var(--rail) solid transparent;background:transparent;" &
    "color:var(--secondary);font:inherit;cursor:pointer;" & motion)
  result.rule ".tab:hover", styleOf("color:var(--primary)")
  result.rule ".tab.is-active", styleOf(
    "color:var(--primary);border-bottom-color:var(--accent)")

  # ── breadcrumbs ──────────────────────────────────────────────────────────
  result.rule ".crumbs", styleOf(
    "display:flex;align-items:center;gap:var(--s1);min-width:0;" &
    "color:var(--secondary);font-size:var(--fs-sm)")
  result.rule ".crumb", styleOf(
    "white-space:nowrap;overflow:hidden;text-overflow:ellipsis")
  result.rule ".crumb:last-child", styleOf("color:var(--primary)")
  result.rule ".crumb-sep", styleOf("color:var(--tertiary)")

  # ── menu (floats ⇒ shadow) ───────────────────────────────────────────────
  result.rule ".menu", styleOf(
    "min-width:calc(var(--u) * 44);padding:var(--s1);" &
    "background:var(--bg-2);border:var(--hair) solid var(--border);" &
    "border-radius:var(--r2);box-shadow:var(--shadow)")
  result.rule ".menu-item", styleOf(
    "display:flex;align-items:center;gap:var(--s2);width:100%;" &
    "height:var(--ctl);padding:0 var(--s2);" &
    "border:0;border-left:var(--rail) solid transparent;background:transparent;" &
    "border-radius:var(--r1);color:var(--primary);font:inherit;" &
    "text-align:left;cursor:pointer;" & motion)
  result.rule ".menu-item:hover", styleOf(
    "background:color-mix(in srgb, var(--primary) 6%, transparent)")
  result.rule ".menu-hint", styleOf(
    "margin-left:auto;color:var(--tertiary);font-size:var(--fs-sm)")
  result.rule ".menu-sep", styleOf(
    "height:var(--hair);margin:var(--s1) 0;background:var(--border)")

  # ── inspector: key/value, the devtools staple ────────────────────────────
  result.rule ".inspector", styleOf("display:flex;flex-direction:column")
  result.rule ".insp-row", styleOf(
    "display:grid;grid-template-columns:minmax(0,calc(var(--u) * 30)) 1fr;" &
    "gap:var(--s3);padding:var(--s2) var(--s3);" &
    "border-bottom:var(--hair) solid var(--border)")
  result.rule ".insp-key", styleOf(
    "color:var(--secondary);font-size:var(--fs-sm);" &
    "overflow:hidden;text-overflow:ellipsis")
  result.rule ".insp-val", styleOf(
    "font-family:var(--font-mono);font-size:var(--fs-sm);" &
    "overflow-wrap:anywhere;user-select:text")

  # ── lists ────────────────────────────────────────────────────────────────
  result.rule ".list", styleOf("display:flex;flex-direction:column;min-height:0")
  result.rule ".list-item", styleOf(
    "display:flex;align-items:center;gap:var(--s2);" &
    "min-height:var(--ctl);padding:var(--s1) var(--s3);" &
    "border-left:var(--rail) solid transparent;cursor:default;" & motion)
  result.rule ".list-item:hover", styleOf(
    "background:color-mix(in srgb, var(--primary) 6%, transparent)")

  # ── inset content: wells and code ────────────────────────────────────────
  result.rule ".well", styleOf(
    "background:var(--bg-3);border:var(--hair) solid var(--border);" &
    "border-radius:var(--r2);padding:var(--s3)")
  result.rule ".code", styleOf(
    "margin:0;padding:var(--s3);background:var(--bg-3);" &
    "border:var(--hair) solid var(--border);border-radius:var(--r2);" &
    "font-family:var(--font-mono);font-size:var(--fs-sm);line-height:1.55;" &
    "overflow:auto;user-select:text")

  # ── log view ─────────────────────────────────────────────────────────────
  result.rule ".logview", styleOf(
    "display:flex;flex-direction:column;min-height:0;overflow:auto;" &
    "padding:var(--s2) var(--s3);background:var(--bg-3);" &
    "font-family:var(--font-mono);font-size:var(--fs-sm);line-height:1.7")
  result.rule ".log-line", styleOf(
    "display:flex;gap:var(--s3);align-items:baseline;color:var(--ink-2)")
  result.rule ".log-time", styleOf(
    "flex:none;color:var(--ink-3);font-variant-numeric:tabular-nums")
  result.rule ".log-msg", styleOf("white-space:pre-wrap;word-break:break-word")
  result.rule ".log-line.is-ok .log-msg", styleOf("color:var(--ok)")
  result.rule ".log-line.is-warn .log-msg", styleOf("color:var(--warn)")
  result.rule ".log-line.is-err .log-msg", styleOf("color:var(--danger)")

  # ── controls ─────────────────────────────────────────────────────────────
  # The base button is the secondary style: the common case should not need a
  # modifier, and a page of primary buttons has no primary action.
  result.rule ".btn", styleOf(
    "display:inline-flex;align-items:center;justify-content:center;" &
    "gap:var(--s2);height:var(--ctl);padding:0 var(--s3);" &
    "border:var(--hair) solid var(--border);border-radius:var(--r1);" &
    "background:var(--bg-3);color:var(--primary);" &
    "font:inherit;font-weight:500;cursor:pointer;white-space:nowrap;" & motion)
  result.rule ".btn:hover", styleOf(
    "background:color-mix(in srgb, var(--primary) 8%, var(--bg-3))")
  result.rule ".btn:active", styleOf("transform:translateY(1px)")
  result.rule ".btn.is-primary", styleOf(
    "background:var(--accent);border-color:var(--accent);color:var(--bg)")
  result.rule ".btn.is-primary:hover", styleOf(
    "background:color-mix(in srgb, var(--accent) 88%, var(--primary))")
  result.rule ".btn.is-danger", styleOf(
    "background:var(--danger);border-color:var(--danger);color:var(--bg)")
  result.rule ".btn.is-ghost", styleOf(
    "background:transparent;border-color:transparent;color:var(--secondary)")
  result.rule ".btn.is-ghost:hover", styleOf(
    "background:color-mix(in srgb, var(--primary) 8%, transparent);" &
    "color:var(--primary)")
  result.rule ".btn-icon", styleOf(
    "width:var(--ctl);padding:0;flex:0 0 auto")

  result.rule ".field", styleOf(
    "display:flex;flex-direction:column;gap:var(--s1);min-width:0")
  result.rule ".field-label", styleOf(
    "color:var(--secondary);font-size:var(--fs-sm);font-weight:500")
  result.rule ".field-help", styleOf(
    "color:var(--tertiary);font-size:var(--fs-sm)")
  result.rule ".input", styleOf(
    "height:var(--ctl);padding:0 var(--s2);min-width:0;" &
    "background:var(--bg-3);border:var(--hair) solid var(--border);" &
    "border-radius:var(--r1);color:var(--primary);font:inherit;" & motion)
  result.rule ".input:hover", styleOf(
    "border-color:color-mix(in srgb, var(--primary) 24%, var(--border))")
  result.rule ".input::placeholder", styleOf("color:var(--tertiary)")
  result.rule ".textarea", styleOf(
    "height:auto;padding:var(--s2);line-height:1.5;resize:vertical")

  # ── small status objects ─────────────────────────────────────────────────
  result.rule ".chip", styleOf(
    "display:inline-flex;align-items:center;gap:var(--s1);" &
    "padding:0 var(--s2);height:calc(var(--u) * 5);" &
    "background:var(--bg-3);border:var(--hair) solid var(--border);" &
    "border-radius:var(--r-pill);color:var(--secondary);" &
    "font-size:var(--fs-sm);white-space:nowrap")
  result.rule ".chip.is-accent", styleOf(
    "background:color-mix(in srgb, var(--accent) 14%, transparent);" &
    "border-color:color-mix(in srgb, var(--accent) 45%, var(--border));" &
    "color:var(--accent)")
  result.rule ".chip.is-danger", styleOf(
    "background:color-mix(in srgb, var(--danger) 14%, transparent);" &
    "border-color:color-mix(in srgb, var(--danger) 45%, var(--border));" &
    "color:var(--danger)")
  # A dot reads as a state light; it is the smallest possible status object.
  result.rule ".dot", styleOf(
    "width:var(--s2);height:var(--s2);border-radius:var(--r-pill);" &
    "background:var(--tertiary);flex:0 0 auto")
  result.rule ".dot.is-live", styleOf("background:var(--accent)")
  result.rule ".dot.is-danger", styleOf("background:var(--danger)")

  result.rule ".meter", styleOf(
    "height:var(--s1);background:var(--bg-3);border-radius:var(--r-pill);" &
    "overflow:hidden")
  result.rule ".meter-fill", styleOf(
    "height:100%;background:var(--accent);border-radius:var(--r-pill)")

  # ── overlays (float ⇒ shadow) ────────────────────────────────────────────
  result.rule ".scrim", styleOf(
    "position:fixed;inset:0;background:color-mix(in srgb, var(--bg) 68%, transparent)")
  result.rule ".dialog", styleOf(
    "display:flex;flex-direction:column;gap:var(--s3);" &
    "width:min(calc(var(--u) * 120), 92vw);padding:var(--s4);" &
    "background:var(--bg-2);border:var(--hair) solid var(--border);" &
    "border-radius:var(--r3);box-shadow:var(--shadow)")
  result.rule ".dialog-title", styleOf(
    "font-size:var(--fs-lg);font-weight:600;letter-spacing:-.01em")
  result.rule ".dialog-actions", styleOf(
    "display:flex;gap:var(--s2);justify-content:flex-end")
  result.rule ".toast", styleOf(
    "display:flex;align-items:flex-start;gap:var(--s2);" &
    "padding:var(--s3);background:var(--bg-2);" &
    "border:var(--hair) solid var(--border);border-left:var(--rail) solid var(--accent);" &
    "border-radius:var(--r2);box-shadow:var(--shadow)")
  result.rule ".callout", styleOf(
    "display:flex;flex-direction:column;gap:var(--s1);padding:var(--s3);" &
    "background:color-mix(in srgb, var(--accent) 8%, transparent);" &
    "border:1px solid color-mix(in srgb, var(--accent) 40%, var(--border));" &
    "border-radius:var(--r2)")

  # ── empty state: a screen with nothing on it should say what to do ───────
  result.rule ".empty", styleOf(
    "display:flex;flex-direction:column;align-items:center;justify-content:center;" &
    "gap:var(--s2);padding:var(--s8) var(--s4);text-align:center;" &
    "color:var(--secondary)")
  result.rule ".empty-title", styleOf("color:var(--primary);font-weight:600")

  # ── typography helpers, used everywhere ──────────────────────────────────
  result.rule ".mono", styleOf(
    "font-family:var(--font-mono);font-variant-numeric:tabular-nums")
  result.rule ".muted", styleOf("color:var(--secondary)")
  result.rule ".hint", styleOf("color:var(--tertiary);font-size:var(--fs-sm)")
  result.rule ".row", styleOf(
    "display:flex;align-items:center;gap:var(--s2);min-width:0")
  result.rule ".col", styleOf(
    "display:flex;flex-direction:column;gap:var(--s2);min-width:0")
  # `flex-basis:0`, NOT `auto`. With `auto` a flex child's share starts from its
  # CONTENT, so a pane holding a lot of text took the room and a pane holding an
  # editor — which reports almost no intrinsic width — got squeezed to nothing.
  # The symptom is an editor with no width beside an oversized neighbour, and
  # nothing in either pane's own CSS is wrong. `grow` should mean "share the
  # SPACE", which is what basis 0 says.
  result.rule ".grow", styleOf("flex:1 1 0;min-width:0")
  # Twice the share of its siblings. The editor is the subject of this window,
  # not a peer of the panes beside it, and saying so needs a token rather than a
  # width — a width would stop being right at the next viewport.
  result.rule ".is-wide", styleOf("flex:2 1 0")
  result.rule ".pad", styleOf("padding:var(--s3)")
  # A row that WRAPS rather than overflowing. Same story as `.console`: call
  # sites were already writing `wrap`, and it matched nothing.
  result.rule ".wrap", styleOf("flex-wrap:wrap")

  # ── s-expression structure ────────────────────────────────────────────────
  # A rendered ATOM: nested regions, each an atom in its own right. The hover
  # highlight is not decoration -- it is how you see where one atom ends and its
  # parent begins, which is the whole content of "an atom is composed of atoms".
  result.rule ".sx", styleOf(
    "font-family:var(--font-mono);font-size:var(--fs-sm);line-height:1.5;" &
    "white-space:pre;overflow:auto;padding:var(--s2) var(--s3);" &
    "min-height:0;color:var(--primary)")
  result.rule ".sx-node", styleOf(
    "border-radius:var(--r1);cursor:pointer;" &
    "box-shadow:inset 0 0 0 var(--hair) transparent")
  result.rule ".sx-node:hover", styleOf(
    "background:var(--bg-2);box-shadow:inset 0 0 0 var(--hair) var(--border)")
  result.rule ".sx-tag", styleOf("color:var(--accent);font-weight:600")
  result.rule ".sx-leaf", styleOf("color:var(--secondary)")
  result.rule ".sx-str", styleOf("color:var(--ok)")
  # An atom something ELSE also contains. Sharing is the store's central claim
  # and it was invisible; this is what makes it visible.
  # ── inside the editor: mark TOKENS, never areas ─────────────────────────────
  #
  # Three attempts got this wrong the same way, so the rule is worth stating.
  # An atom's region runs from its first character to its last, which for a
  # nested term crosses line ends and indentation. Every treatment applied to
  # that region -- one tint, alternating tints, an outline -- draws over
  # whitespace, and because atoms nest it draws over the same whitespace many
  # times. The result reads as a smear whatever colour it is.
  #
  # So nothing here styles a region. Each rule styles the atom's HEAD: the one
  # token that names it, always on a single line, never blank.
  #
  # `.sx-here` is the atom the caret is in. There is no `.sx-parent` any more --
  # indentation guides already draw containment continuously, for every level at
  # once, without covering anything, so a second weaker answer to the same
  # question was competing with a better one.
  result.rule ".sx-here", styleOf(
    "background:color-mix(in srgb, var(--accent) 22%, transparent);" &
    "border-radius:var(--r1);font-weight:600")
  # EVERY region at once, shown only while a modifier is held. Painting them all
  # permanently cannot work — they nest, so the fills stack into one flat wash —
  # but an OUTLINE is an edge rather than a tint, and a momentary reveal is
  # exactly the moment you need it: while ctrl is down you are about to click
  # one, and this is what says which runs of text are things you can open.
  #
  # An UNDERLINE, on the head token, which is what a ctrl-hover link is
  # everywhere else — and it is the only treatment that cannot smear, because a
  # rule under one word has nowhere to spread. An outline was tried and boxed
  # the indentation; a background was tried and stacked into a wash. Both were
  # drawing an area when the thing being marked is a word.
  result.rule ".sx-region", styleOf(
    "cursor:pointer;text-decoration:underline;" &
    "text-decoration-color:var(--accent);text-decoration-thickness:var(--hair);" &
    "text-underline-offset:calc(var(--u) * 0.75)")
  # A token that HAS A DEFINITION somewhere else -- a kind whose meaning is a
  # rule in a catalog. Dotted rather than solid, because it leads out of this
  # document rather than to another part of it, which is the same distinction
  # every editor draws between a reference and a definition.
  result.rule ".sx-def", styleOf(
    "cursor:pointer;text-decoration:underline dotted;" &
    "text-decoration-color:var(--secondary);" &
    "text-underline-offset:calc(var(--u) * 0.75)")
  # A tab holding a PREVIEW: opened with one click, replaced by the next one,
  # made permanent by a double click. Italic is the convention and it is worth
  # keeping -- it is the only cue that the tab is about to be reused.
  result.rule ".tab.is-preview", styleOf("font-style:italic")
  result.rule ".crumb.is-current", styleOf(
    "color:var(--primary);font-weight:600")
  result.rule ".crumb", styleOf("cursor:pointer")
  # ── settings controls ───────────────────────────────────────────────────────
  # A checkbox that is a BUTTON. The real `<input type=checkbox>` carries state
  # the DOM owns, and this kit's state lives in the view -- so a control whose
  # checkedness the reconciler cannot patch would drift from the view that
  # derived it. The box is drawn, the class says whether it is on.
  result.rule ".check", styleOf(
    "display:inline-flex;align-items:center;gap:var(--s2);" &
    "background:none;border:0;color:var(--secondary);cursor:pointer;" &
    "font:inherit;padding:var(--s1) var(--s2);border-radius:var(--r1);" &
    motion)
  result.rule ".check:hover", styleOf(
    "color:var(--primary);background:var(--bg-3)")
  result.rule ".check-box", styleOf(
    "width:var(--s3);height:var(--s3);border-radius:var(--r1);flex:0 0 auto;" &
    "border:var(--hair) solid var(--border);background:var(--bg-3)")
  result.rule ".check-label", styleOf("white-space:nowrap")
  result.rule ".check.is-on", styleOf("color:var(--primary)")
  result.rule ".check.is-on .check-box", styleOf(
    "background:var(--accent);border-color:var(--accent)")
  result.rule ".range", styleOf(
    "flex:0 0 auto;width:calc(var(--u) * 30);accent-color:var(--accent);" &
    "cursor:pointer")
  # ── the dock: a TILING window manager ───────────────────────────────────────
  #
  # This is the lab's dock, rebuilt on the model a real window manager uses. The
  # lab had four fixed regions — left, right, bottom, and a centre holding the
  # page — and a panel could only be a member of one of them. That is a special
  # case of something simpler: a SPLIT TREE. A split is a row or a column of
  # weighted children, a child is either another split or a leaf holding one
  # window, and the lab's layout is one particular tree. i3, sway and BSPWM all
  # work this way, and it costs less code than the four-region version did
  # because there is one recursive rule instead of four cases.
  #
  # Everything here is geometry and chrome. WHICH windows exist and where they
  # sit is data the host holds; the kit only says what a split, a leaf, a
  # divider and a floating window LOOK like.
  result.rule ".dock", styleOf(
    "position:relative;display:flex;flex:1 1 auto;min-width:0;min-height:0")
  # A split is a flex box, and that is the whole tiling engine: weights are
  # `flex-grow`, so a divider moves size between two siblings and every other
  # branch of the tree is untouched. No pixel arithmetic, no reflow pass.
  result.rule ".dock-split", styleOf(
    "display:flex;flex:1 1 auto;min-width:0;min-height:0")
  result.rule ".dock-split.is-col", styleOf("flex-direction:column")
  result.rule ".dock-leaf", styleOf(
    "display:flex;flex-direction:column;min-width:0;min-height:0;" &
    "overflow:hidden")
  # A divider is a hit target first and a line second. Two units wide reads as a
  # hairline and is still catchable with a mouse; the accent only appears on
  # hover, so a resting layout shows structure without showing controls.
  result.rule ".dock-res", styleOf(
    "flex:0 0 auto;background:transparent;position:relative;z-index:2;" &
    motion)
  result.rule ".dock-res.is-x", styleOf("width:var(--s2);cursor:col-resize")
  result.rule ".dock-res.is-y", styleOf("height:var(--s2);cursor:row-resize")
  result.rule ".dock-res:hover", styleOf("background:var(--accent)")
  # ── a window ────────────────────────────────────────────────────────────────
  # `.win` above is the floating card. A DOCKED window is the same thing without
  # the shadow: a shadow means "above the page", and a tile is not above
  # anything. Sharing the rule and overriding the shadow would say they are the
  # same component; they are not, and the difference is the whole point of the
  # shadow token.
  result.rule ".dock-win", styleOf(
    "display:flex;flex-direction:column;flex:1 1 auto;min-height:0;" &
    "min-width:0;overflow:hidden;background:var(--bg-2);" &
    "border:var(--hair) solid var(--border);border-radius:var(--r2)")
  result.rule ".dock-bar", styleOf(
    "display:flex;align-items:center;gap:var(--s2);flex:0 0 auto;" &
    "height:var(--ctl);padding:0 var(--s2);user-select:none;cursor:grab;" &
    "border-bottom:var(--hair) solid var(--border);color:var(--secondary)")
  result.rule ".dock-bar:hover", styleOf("color:var(--primary)")
  result.rule ".dock-ico", styleOf(
    "flex:0 0 auto;opacity:.7;font-size:var(--fs-sm)")
  result.rule ".dock-title", styleOf(
    "font-weight:600;white-space:nowrap;overflow:hidden;" &
    "text-overflow:ellipsis;font-size:var(--fs-sm)")
  result.rule ".dock-actions", styleOf(
    "display:flex;align-items:center;gap:var(--s1);margin-left:auto")
  result.rule ".dock-body", styleOf(
    "flex:1 1 auto;min-height:0;min-width:0;overflow:auto")
  # Collapsed keeps the bar and drops the body, so a collapsed window is a title
  # strip you can still drag — which is what makes collapsing useful rather than
  # a worse close.
  result.rule ".dock-win.is-collapsed", styleOf("flex:0 0 auto")
  result.rule ".dock-win.is-collapsed .dock-body", styleOf("display:none")
  result.rule ".dock-win.is-active", styleOf("border-color:var(--accent)")
  # ── the floating layer ──────────────────────────────────────────────────────
  # UNBOUND windows: outside the tree, positioned absolutely, above the tiles.
  # The layer ignores the pointer so the tiling below stays usable, and each
  # window takes it back — otherwise a floating layer covering the app would
  # swallow every click that missed a window.
  result.rule ".dock-float-layer", styleOf(
    "position:absolute;inset:0;pointer-events:none;z-index:var(--z-float)")
  result.rule ".dock-float", styleOf(
    "position:absolute;pointer-events:auto;display:flex;flex-direction:column;" &
    "min-width:calc(var(--u) * 30);min-height:calc(var(--u) * 20);" &
    "box-shadow:var(--shadow);border-radius:var(--r2)")
  # The resize corner. A floating window has no divider to drag, so it needs its
  # own grip, and it is drawn rather than themed so it reads at any scale.
  result.rule ".dock-grip", styleOf(
    "position:absolute;right:0;bottom:0;width:var(--s4);height:var(--s4);" &
    "cursor:nwse-resize;z-index:3")
  result.rule ".dock-grip::after", styleOf(
    "content:'';position:absolute;right:var(--s1);bottom:var(--s1);" &
    "width:var(--s2);height:var(--s2);border-right:var(--rail) solid " &
    "var(--border);border-bottom:var(--rail) solid var(--border)")
  # ── drag feedback ───────────────────────────────────────────────────────────
  # Three separate marks, because they answer three different questions: the
  # GHOST says what you are carrying, the ZONE says which leaf you are over, and
  # the EDGE says which side of it you will split. The lab had the first two and
  # a bar for insert position; a tiling tree needs the third instead, because
  # dropping is a direction rather than an index.
  result.rule ".dock-ghost", styleOf(
    "position:fixed;z-index:var(--z-drag);pointer-events:none;" &
    "display:flex;align-items:center;gap:var(--s2);" &
    "padding:var(--s1) var(--s3);border-radius:var(--r1);" &
    "background:var(--bg-2);border:var(--hair) solid var(--accent);" &
    "box-shadow:var(--shadow);font-size:var(--fs-sm)")
  result.rule ".dock-zone", styleOf(
    "position:fixed;z-index:var(--z-drop);pointer-events:none;opacity:0;" &
    "border-radius:var(--r2);background:color-mix(in srgb, var(--accent) " &
    "10%, transparent);border:var(--rail) solid var(--accent);" &
    "transition:left .12s " & ease & ",top .12s " & ease &
    ",width .12s " & ease & ",height .12s " & ease & ",opacity .12s " & ease)
  result.rule ".dock-zone.is-on", styleOf("opacity:1")
  result.rule ".dock-edge", styleOf(
    "position:fixed;z-index:var(--z-drop);pointer-events:none;opacity:0;" &
    "border-radius:var(--r1);background:var(--accent);" &
    "transition:left .12s " & ease & ",top .12s " & ease &
    ",width .12s " & ease & ",height .12s " & ease & ",opacity .12s " & ease)
  result.rule ".dock-edge.is-on", styleOf("opacity:1")
  # While a drag or a resize is live the cursor must not change under the
  # pointer as it crosses other elements, or the gesture reads as having ended.
  # A drag sets one of these on <body>. The cursor also has to stop changing as
  # the pointer crosses other elements mid-gesture, and the usual way to do that
  # is `* { cursor: X !important }` -- which this kit's own CSS validator
  # rejects, because it does not parse `!important`. Filed rather than worked
  # around with a hand-written stylesheet: a kit whose validator cannot express
  # a declaration the kit needs is a gap in the validator.
  #
  # Until then the overlay below does the job without `!important`: an element
  # covering the viewport during a drag owns the cursor for the whole gesture,
  # and it has to exist anyway to catch pointer events over iframes.
  result.rule "body.is-dragging", styleOf("cursor:grabbing")
  result.rule ".drag-shield", styleOf(
    "position:fixed;inset:0;z-index:var(--z-drag);display:none")
  result.rule "body.is-dragging .drag-shield", styleOf("display:block")
  result.rule "body.is-resizing-x .drag-shield", styleOf(
    "display:block;cursor:col-resize")
  result.rule "body.is-resizing-y .drag-shield", styleOf(
    "display:block;cursor:row-resize")
  # ── an overlay tool cluster ─────────────────────────────────────────────────
  #
  # Controls that belong to what you are LOOKING at rather than to the app:
  # filters over a reading, a zoom level, a view mode. They sit over the content
  # in a corner, the way an editor's find widget or a map's zoom control does,
  # because a permanent strip for them costs a row of height on every document
  # whether or not anyone is filtering.
  #
  # The host positions the anchor; this only says what the cluster looks like.
  result.rule ".tools", styleOf(
    "position:absolute;top:var(--s2);right:var(--s3);z-index:var(--z-float);" &
    "display:flex;align-items:center;gap:var(--s1);" &
    "padding:var(--s1);border-radius:var(--r2);" &
    "background:var(--bg-2);border:var(--hair) solid var(--border);" &
    "box-shadow:var(--shadow)")
  # Collapsed: only the handle shows, and it fades until pointed at, so a long
  # document is not read past a permanent control.
  result.rule ".tools.is-collapsed", styleOf(
    "background:transparent;border-color:transparent;box-shadow:none;" &
    "opacity:.45")
  result.rule ".tools.is-collapsed:hover", styleOf("opacity:1")
  result.rule ".tools-body", styleOf(
    "display:flex;align-items:center;gap:var(--s2)")
  result.rule ".tools.is-collapsed .tools-body", styleOf("display:none")
  # An element that must sit under an overlay cluster: `position:relative` is
  # the anchor, and a pane body that scrolls would otherwise scroll the tools
  # away with the content.
  #
  # It is also a FLEX COLUMN, and that is not decoration. An anchor wraps the
  # content it floats over, so whatever is inside it was already sized with
  # `.fill` — `flex:1 1 auto`, which does nothing at all in a plain block. The
  # symptom is a mounted editor exactly 0px tall inside a container that looks
  # correct in every other respect.
  result.rule ".anchored", styleOf(
    "position:relative;display:flex;flex-direction:column;" &
    "min-height:0;min-width:0")
  # ── loading ─────────────────────────────────────────────────────────────────
  #
  # A page whose content arrives from a server starts as an empty box, and an
  # empty box styled with the page background is indistinguishable from a
  # broken one. This is meant to be rendered INTO THE HTML — before any script
  # runs, so the first paint already says "working" — and removed once the app
  # has something to show. That is the only reason it is a plain overlay rather
  # than a component in the view: a view cannot draw itself before the code that
  # draws views has loaded.
  result.rule ".loading", styleOf(
    "position:fixed;inset:0;z-index:var(--z-drag);display:flex;" &
    "flex-direction:column;align-items:center;justify-content:center;" &
    "gap:var(--s4);background:var(--bg);color:var(--secondary);" &
    "transition:opacity .25s " & ease)
  result.rule ".loading.is-done", styleOf("opacity:0;pointer-events:none")
  result.rule ".spinner", styleOf(
    "width:var(--s8);height:var(--s8);border-radius:50%;" &
    "border:var(--rail) solid var(--border);" &
    "border-top-color:var(--accent);" &
    "animation:aowl-spin .8s linear infinite")
  result.rule ".loading-label", styleOf(
    "font-size:var(--fs-sm);letter-spacing:.08em;text-transform:uppercase")

  # ── the performance panel's chrome ──────────────────────────────────────────
  # The widget itself is `widgets/perf.js` — imperative, because it samples
  # counters ten times a second and none of that is a fact about a store. What
  # it looks like is still the kit's business.
  result.rule ".perf", styleOf(
    "display:flex;flex-direction:column;gap:var(--s1);padding:var(--s2);" &
    "font-size:var(--fs-sm);color:var(--secondary);user-select:none")
  result.rule ".perf-head", styleOf(
    "display:flex;align-items:baseline;justify-content:space-between;gap:var(--s2)")
  result.rule ".perf-title", styleOf(
    "font-weight:600;color:var(--primary);text-transform:uppercase;" &
    "letter-spacing:.08em")
  result.rule ".perf-note", styleOf(
    "color:var(--tertiary);font-variant-numeric:tabular-nums")
  result.rule ".perf-rows", styleOf(
    "display:flex;flex-direction:column;gap:var(--s1)")
  result.rule ".perf-row", styleOf(
    "display:flex;align-items:center;gap:var(--s2)")
  result.rule ".perf-label", styleOf(
    "flex:0 0 auto;width:calc(var(--u) * 12);color:var(--tertiary)")
  result.rule ".perf-track", styleOf(
    "flex:1 1 auto;height:var(--s2);border-radius:var(--r-pill);" &
    "background:var(--bg-3);overflow:hidden")
  # Width is set inline by the widget; everything else is the theme's. The
  # transition is what makes it read as a meter rather than as a redraw.
  result.rule ".perf-fill", styleOf(
    "height:100%;width:0;border-radius:var(--r-pill);background:var(--accent);" &
    "transition:width .2s " & ease & ",background-color .2s " & ease)
  result.rule ".perf-fill.is-warn", styleOf("background:var(--warning)")
  result.rule ".perf-fill.is-danger", styleOf("background:var(--danger)")
  # Tabular figures, so a number changing ten times a second does not make the
  # row jitter sideways -- which is the difference between a reading and a
  # distraction.
  result.rule ".perf-val", styleOf(
    "flex:0 0 auto;width:calc(var(--u) * 16);text-align:right;" &
    "font-variant-numeric:tabular-nums;color:var(--primary)")
  result.rule ".perf-val.is-wide", styleOf(
    "flex:1 1 auto;width:auto;color:var(--secondary)")
  result.rule ".perf-val.is-warn", styleOf("color:var(--warning)")
  result.rule ".perf-val.is-danger", styleOf("color:var(--danger)")
  result.rule ".sr-only", styleOf(
    "position:absolute;width:1px;height:1px;padding:0;margin:-1px;" &
    "overflow:hidden;clip-path:inset(50%);white-space:nowrap")

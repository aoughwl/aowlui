## tdemo — write a browsable page of the kit to demo.html.
##
## The gate (`tkit`) asserts properties; this produces the artifact you can open,
## so a visual regression is visible rather than only measurable.
import std/syncio
import kit
import web

proc main =
  useStylesheet kitSheet()

  let tree = @[
    treeItem("aoughwl", open = true, expandable = true),
    treeItem("web", depth = 1, open = true, expandable = true, hint = "6"),
    treeItem("dsl.nim", depth = 2, selected = true, hint = "12k"),
    treeItem("weblower.nim", depth = 2, hint = "9k"),
    treeItem("css", depth = 1, expandable = true, hint = "2"),
    treeItem("aowlui", depth = 1, expandable = true, hint = "4")]

  let insp = @[
    inspRow("kind", "Component"),
    inspRow("family", "controls"),
    inspRow("rules", "4"),
    inspRow("digest", "c9fb024aa"),
    inspRow("scale", "1.0")]

  let gallery = @[
    well(@[
      col(@[
        row(@[
          button("Run", primary = true), button("Format"),
          button("Delete", danger = true), button("Cancel", ghost = true),
          iconButton("⟳", "Reload")]),
        row(@[
          chip("live", accent = true), chip("3 errors", danger = true),
          chip("nimony"), dot(live = true), meter(64)]),
        field("Filter", @[input(placeholder = "name or content")],
              help = "Matches names and bodies."),
        callout("Round-trip proven",
                "1739 declarations, 0 missing, 0 invented."),
        toast("Compiled", "6 gates green in 2.4s"),
        empty("No selection", "Choose a component in the explorer.",
              @[button("Browse all", primary = true)])])])]

  let body = @[
    sidebar(@[pane(head = "explorer", children = @[explorer(tree)])]),
    splitter(),
    panes(@[
      pane(head = "gallery", children = gallery),
      splitter(),
      pane(head = "inspector", children = @[inspector(insp)])])]

  let page = document("aowlui kit",
    @[shell(
        top = @[toolbar(@[
          chip("live", accent = true),
          crumbs(["aoughwl", "web", "dsl.nim"]),
          toolbarSpacer(),
          tabs(@[tab("Design", active = true), tab("Code"), tab("Tokens")]),
          toolbarSep(),
          iconButton("⟳", "Reload"),
          button("Run", primary = true)])],
        body = body,
        bottom = @[statusBar(@[
          dot(live = true), statusItem("connected"),
          statusItem("93 rules"), toolbarSpacer(),
          statusItem("scale 1.0")])])],
    css = renderTheme() & renderReset())

  try:
    writeFile("demo.html", page)
    echo "wrote demo.html (", page.len, " bytes)"
  except:
    echo "could not write demo.html"
    return
  echo "OK"

main()

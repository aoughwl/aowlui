## aowlui/lab/shell — the lab page itself, as nimony.
##
## The port of `reference/index.html`: the boot overlay, the mount point, the
## head, and the ordered kernel scripts. `reference/lab.js` is deliberately NOT
## ported here — it is the bootstrap *behaviour* (SSE hydration, the keyed
## reconciler, bundle loading), which belongs on the JS backend with web-state,
## not in the markup layer. What this module owns is everything the first byte
## paints.
##
## Three details of the original are load-bearing and are preserved exactly:
##
## * **The boot overlay is not decoration.** It paints immediately so a cold load
##   reads as "working" rather than as a dead flat colour while the kernel
##   parses. It is `role="status" aria-live="polite"` so a screen reader
##   announces it, and the pulse itself is `aria-hidden` because three bouncing
##   dots are noise to announce.
## * **The boot CSS is the only CSS in the page**, inline and self-contained, so
##   it cannot be blocked on a stylesheet request. It is carried verbatim rather
##   than built from `Style` values because it is mostly `@keyframes` and
##   `@media` — at-rules are not declarations, and pretending otherwise would
##   mean emitting CSS that does not say what the original said.
## * **`data-cfasync="false"` on every script.** Cloudflare Rocket Loader
##   re-injects classic scripts, which double-executes their top-level `const`
##   and throws "Identifier already declared". These are ordered, interdependent
##   kernel scripts: they must run once, in order, untouched.

import web

const bootCss* = """
:root { --boot-bg:#101214; --boot-fg:#f4f1ea; --boot-accent:#f4f1ea; }
html, body { margin:0; height:100%; }
body { background:var(--boot-bg); color:var(--boot-fg);
       font:14px/1.5 ui-sans-serif,system-ui,-apple-system,"Segoe UI",sans-serif; }
#boot { position:fixed; inset:0; z-index:9999; background:var(--boot-bg);
        display:flex; flex-direction:column; align-items:center; justify-content:center; gap:18px;
        transition:opacity .32s ease; }
#boot.is-done { opacity:0; pointer-events:none; }
.boot-pulse { display:flex; gap:8px; }
.boot-pulse span { width:9px; height:9px; border-radius:50%; background:var(--boot-accent);
                   opacity:.22; animation:boot-bob 1.1s ease-in-out infinite; }
.boot-pulse span:nth-child(2) { animation-delay:.18s; }
.boot-pulse span:nth-child(3) { animation-delay:.36s; }
.boot-label { margin:0; font-size:13px; letter-spacing:.06em; text-transform:lowercase; opacity:.55; }
@keyframes boot-bob { 0%,80%,100% { opacity:.22; transform:translateY(0); }
                      40% { opacity:.9; transform:translateY(-5px); } }
@media (prefers-reduced-motion:reduce) {
  .boot-pulse span { animation:boot-fade 1.5s ease-in-out infinite; transform:none; }
  @keyframes boot-fade { 0%,100% { opacity:.25; } 50% { opacity:.85; } }
}
"""

const themeRestoreJs* = """
  try {
    var d = document.documentElement, L = localStorage, t = L.getItem("aw-theme");
    if (t) d.setAttribute("data-theme", t);
    [["--boot-bg","aw-boot-bg"],["--boot-fg","aw-boot-fg"],["--boot-accent","aw-boot-accent"]]
      .forEach(function (p) { var v = L.getItem(p[1]); if (v != null) d.style.setProperty(p[0], v); });
  } catch (e) {}
"""
  ## Restores the per-app boot look BEFORE first paint. It runs in `<head>`,
  ## earlier than the kernel downloads, so a themed reload never flashes the
  ## default palette first.

const kernelScripts* = ["/awcore.js", "/widgets.js", "/host.js", "/engine.js", "/lab.js"]
  ## Ordered and interdependent — the order IS the dependency graph.

component bootPulse:
  ## The three bouncing dots. `aria-hidden`: it is a decoration, and announcing
  ## it would just interrupt the label.
  box:
    @class "boot-pulse"
    @ariaHidden "true"
    span()
    span()
    span()

component bootOverlay:
  ## The agnostic boot overlay. `lab.js` fades it out on the first real render.
  ## The default lives on an `input` line because a header parameter list is
  ## parsed as a call and cannot carry `= default`.
  input label: string = "working…"
  let pulse = bootPulse()
  box:
    @id "boot"
    @role "status"
    @ariaLive "polite"
    pulse
    p:
      @class "boot-label"
      label

component appMount:
  ## No top chrome: this is a devtools-style surface. Branding, session actions
  ## and theme/roundness all live in the Settings panel, which is substrate. The
  ## whole UI is the one composed `page` view rendered into here.
  main:
    @id "app"

proc kernelScriptTags*(): HTML =
  ## The ordered kernel scripts, each opted out of Rocket Loader.
  result = @[]
  var i = 0
  while i < kernelScripts.len:
    let s = el("script", @[attr("data-cfasync", "false"),
                           attr("src", kernelScripts[i])], @[])
    result.add s
    inc i

proc labHead*(): HTML =
  ## Favicon links and the pre-paint theme restore. `document()` already emits
  ## the charset, viewport and title.
  result = @[]
  result.add el("link", @[attr("rel", "icon"), attr("type", "image/x-icon"),
                          attr("href", "/favicon.ico?v=2"), attr("sizes", "any")], @[])
  result.add el("link", @[attr("rel", "shortcut icon"), attr("type", "image/x-icon"),
                          attr("href", "/favicon.ico?v=2")], @[])
  result.add el("script", @[], @[rawNode(themeRestoreJs)])

proc labBody*(label = "working…"): HTML =
  ## Everything the first byte paints, in order.
  result = @[]
  var i = 0
  let overlay = bootOverlay(label = label)
  while i < overlay.len:
    result.add overlay[i]
    inc i
  let mount = appMount()
  var j = 0
  while j < mount.len:
    result.add mount[j]
    inc j
  let scripts = kernelScriptTags()
  var k = 0
  while k < scripts.len:
    result.add scripts[k]
    inc k

proc labPage*(title = "aoughwl"; label = "working…"): string =
  ## The whole lab page.
  ##
  ## `useStyles = false` is deliberate: the real theme loads from the substrate
  ## (`theme.pack` → `loads_style "/styles/base.css"`), so the page must ship the
  ## boot CSS and nothing else. Emitting the generated component stylesheet here
  ## would put the entire design in the document and defeat that.
  document(title, labBody(label), lang = "en", head = labHead(),
           css = bootCss, useStyles = false)

// aoughwl lab — the bootstrap, and nothing more. The ENTIRE UI is one composed
// view tree stored in the substrate (`unit app` → a tree of `{kind:"view",…}`
// nodes pulling in browser/detail/graph/overview/authoring). This file names
// exactly ONE view — "app", the entry point, like main() — and otherwise only:
// hydrate the store from SSE, re-render on change, load pack-declared widget +
// style bundles, and wire the host-shell buttons. No view names, no pane logic,
// no vocabulary, no CSS. Everything visual + structural lives in the substrate.

const core = globalThis.awcore;
const engine = globalThis.awEngine;
const host = globalThis.aw;                 // foreign-widget + asset host (host.js)
const $ = id => document.getElementById(id);
const $app = $("app");
const ROOT = { kind: "view", props: { name: "page" } };   // the one entry view (app + docked devtools)

// Actions (assert/run/relation) POST to the server; the resulting delta flows
// back over SSE and re-renders. Selection/search never POST — they're local.
engine.setActionHandler(cmd => {
  fetch("/api/aw", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ command: cmd }) }).catch(() => {});
});

// The host shell is now chrome-free (a devtools surface). Session actions
// (export/import/reset) and theme/roundness live in the Settings panel, which is
// substrate (packs/views.pack → `settings` view → widgets/env.js). The only
// host-level signal left is liveness, which rides on the document title.

// --- render the whole UI (one view) through the engine's keyed reconciler -------
// renderInto patches the live DOM in place (no full swap), so heavy widgets aren't
// remounted and a focused input keeps its element — and therefore its focus and
// caret — for free. The save/restore below is a belt-and-suspenders for the rare
// case where a re-render genuinely replaces the focused element's subtree.
function renderShell() {
  const a = document.activeElement;
  const bind = a && a.dataset ? a.dataset.bind : null;
  const start = a ? a.selectionStart : null, end = a ? a.selectionEnd : null;
  const el = engine.renderInto("root", ROOT, { scopeJson: "null", item: null });
  if (el.parentNode !== $app) $app.replaceChildren(el);
  if (bind && document.activeElement !== a) {
    // Re-find the bound input and refocus it. The dock rebuilds its chrome each
    // render and re-parents preserved panel content (pn.append(body)); moving a
    // focused element in the DOM blurs it — even though it's the SAME node. So we
    // must refocus whenever focus was lost, including when `next === a`.
    const next = $app.querySelector(`[data-bind="${bind}"]`);
    if (next) { next.focus(); try { next.setSelectionRange(start, end); } catch {} }
  }
}
engine.setStateHandler(renderShell);     // local state changed (select/search/pane)
host.setOnWidget(renderShell);           // a foreign widget registered → mount it

// --- dismiss the agnostic boot overlay once real content exists -----------------
// The overlay (index.html #boot) paints on the first byte so the cold load reads
// as "working", not a dead color. We fade it out exactly once, after the first
// render has put the app's view tree on screen.
let booted = false;
function bootDone() {
  if (booted) return; booted = true;
  const b = document.getElementById("boot");
  if (!b) return;
  b.classList.add("is-done");
  b.addEventListener("transitionend", () => b.remove(), { once: true });
  setTimeout(() => b.remove(), 600);   // fallback if transitionend doesn't fire
}

// --- pack-declared native imports: widget JS + stylesheets, both data-driven ---
const loadedW = new Set(), loadedS = new Set();
function loadBundles() {
  let widgets = [], styles = [];
  try { widgets = JSON.parse(core.widgetBundles()); } catch {}
  try { styles = JSON.parse(core.styleBundles()); } catch {}
  for (const u of styles) if (!loadedS.has(u)) { loadedS.add(u); host.loadStyle(u).catch(() => {}); }
  for (const u of widgets) if (!loadedW.has(u)) { loadedW.add(u); host.loadScript(u).then(renderShell).catch(e => console.warn("widget bundle", u, e)); }
}

function setLive(on, text) { document.title = (on ? "● " : "○ ") + "aoughwl · " + text; }

let hydrated = false, unitCount = 0;
const es = new EventSource("/api/stream");
es.addEventListener("snapshot", e => {
  core.hydrate(e.data);
  unitCount = (JSON.parse(e.data).units || []).length;
  engine.clearCache();
  loadBundles();
  hydrated = true;
  setLive(true, `live · ${unitCount} units`);
  renderShell();
  bootDone();          // first paint of real content → drop the boot overlay
});
es.addEventListener("delta", e => {
  if (!hydrated) return;
  core.applyDelta(e.data);
  unitCount = (JSON.parse(e.data).units || []).length || unitCount;
  engine.clearCache();              // store changed → invalidate binding + view memo
  loadBundles();
  setLive(true, `live · ${unitCount} units`);
  renderShell();
});
es.onerror = () => setLive(false, "disconnected — retrying…");

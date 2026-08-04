// aowlui/widgets/memory — a live memory monitor, as a FOREIGN WIDGET.
//
// ── why this is JavaScript, in a project whose rule is that it is not ────────
//
// master ships no hand-written JavaScript; its client is nimony compiled to JS
// and there is a gate that fails if a stray `.js` appears in `web/`. That rule
// is about MEANING: the UI is atoms, and a JS file that starts as "just the
// widgets" ends up owning the tree.
//
// This is the other side of the same contract. spec/viewtree.md's `widget`
// primitive is a mount point the reconciler never diffs into, because something
// imperative owns that subtree — Monaco is one. A monitor sampling the runtime
// sixty times a second is exactly that: it has its own loop, its own DOM, and
// nothing it draws is a fact about the store. Making it a view would mean a
// re-derivation per frame to display a number that changes per frame.
//
// It lives in aowlui rather than in master for the same reason the lab's dock
// did: it is a component with behaviour, so it ships with the components. The
// host mounts it by putting a `widget` node named `memory` in a view — which
// means it can be MOVED by editing that view, like anything else, while the
// thing inside stays imperative. Attached, and detached.
(function () {
  const NAME = 'memory';
  const MiB = 1048576;

  // ── where the numbers come from ────────────────────────────────────────────
  // `__lengMem` is exposed by the Leng JS runtime: two bump arenas in one
  // ArrayBuffer, so "how full" is a subtraction. If it is absent this is not a
  // nimony page and the widget says so rather than drawing zeros — a monitor
  // reading nothing must not look like a monitor reading idle.
  const sample = () => (typeof globalThis.__lengMem === 'function'
    ? globalThis.__lengMem() : null);

  const el = (cls, txt) => {
    const d = document.createElement('div');
    if (cls) d.className = cls;
    if (txt != null) d.textContent = txt;
    return d;
  };

  function build(host) {
    host.textContent = '';
    const root = el('mem');
    const head = el('mem-head');
    head.append(el('mem-title', 'memory'), el('mem-total', ''));
    // Two bars, because there are two arenas and they fail differently. The
    // value arena is reclaimed per callback frame and should sit flat; the heap
    // is the Nim allocator's pages and only ever grows. One combined number
    // would hide which of those is moving, which is the only question worth
    // asking of this.
    const rows = el('mem-rows');
    const mk = (label) => {
      const row = el('mem-row');
      const lab = el('mem-label', label);
      const track = el('mem-track');
      const fill = el('mem-fill');
      track.append(fill);
      const val = el('mem-val', '');
      row.append(lab, track, val);
      rows.append(row);
      return { fill, val };
    };
    const fixed = mk('values');
    const heap = mk('heap');
    const foot = el('mem-foot', '');
    root.append(head, rows, foot);
    host.append(root);
    return { root, total: head.lastChild, fixed, heap, foot };
  }

  const fmt = (b) => (b / MiB).toFixed(1) + ' MiB';

  function paint(ui, m) {
    if (!m) {
      ui.total.textContent = '';
      ui.foot.textContent = 'no leng runtime on this page';
      return;
    }
    ui.total.textContent = fmt(m.total);
    const set = (bar, used, cap) => {
      const pct = cap > 0 ? Math.min(100, (used / cap) * 100) : 0;
      bar.fill.style.width = pct.toFixed(2) + '%';
      // Three states, because the interesting one is "climbing towards a wall"
      // and a single colour cannot say it.
      bar.fill.classList.toggle('is-warn', pct >= 60 && pct < 85);
      bar.fill.classList.toggle('is-danger', pct >= 85);
      bar.val.textContent = fmt(used);
    };
    set(ui.fixed, m.fixedUsed, m.fixedCap);
    set(ui.heap, m.heapUsed, m.total - m.fixedCap);
    ui.foot.textContent = 'depth ' + m.frameDepth + '  ·  ' + m.handles + ' handles';
  }

  // ── staying mounted ────────────────────────────────────────────────────────
  // The host's reconciler may move this node, and a moved node keeps its
  // children — but a host that rebuilds instead would hand us a fresh, empty
  // element. Rather than depend on which, the loop checks each frame whether
  // the element it is drawing into is still the one in the document, and
  // rebuilds when it is not. Idempotent, and it costs one querySelector.
  let host = null, ui = null, raf = 0, last = 0;

  function tick(now) {
    raf = requestAnimationFrame(tick);
    const found = document.querySelector('[data-widget="' + NAME + '"]');
    if (!found) { host = null; ui = null; return; }
    if (found !== host || !found.firstChild) {
      host = found;
      ui = build(host);
    }
    // Ten samples a second. A monitor that repaints every frame costs more than
    // the thing it is monitoring, and nothing here changes faster than the eye.
    if (now - last < 100) return;
    last = now;
    paint(ui, sample());
  }

  function start() { if (!raf) raf = requestAnimationFrame(tick); }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
  // Named on globalThis so a host can stop it, and so a second copy of this
  // file cannot start a second loop.
  if (globalThis.__aowlMemory) cancelAnimationFrame(globalThis.__aowlMemory.raf);
  globalThis.__aowlMemory = { stop: () => { cancelAnimationFrame(raf); raf = 0; } };
})();

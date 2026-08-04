// aowlui/widgets/perf — a live performance panel, as a FOREIGN WIDGET.
//
// ── why this is JavaScript, in a project whose rule is that it is not ────────
//
// The host ships no hand-written JavaScript; its client is nimony compiled to
// JS and there is a gate that fails if a stray `.js` appears beside it. That
// rule is about MEANING: the UI is atoms, and a JS file that starts as "just
// the widgets" ends up owning the tree.
//
// This is the other side of the same contract. The `widget` primitive is a
// mount point the reconciler never diffs into, because something imperative
// owns that subtree — an editor is one. A panel sampling counters ten times a
// second is another: nothing it draws is a fact about the store, and making it
// a view would mean a re-derivation per frame to display a number that changes
// per frame.
//
// It lives in aowlui rather than in the host for the same reason the lab's dock
// did: a component with behaviour ships with the components. The host mounts it
// by putting a `widget` node named `perf` in a view — so it can be MOVED by
// editing that view, like anything else, while the thing inside stays
// imperative. Attached, and detached.
//
// ── why it is not called "memory" ───────────────────────────────────────────
//
// It began as two memory bars, and memory was the wrong headline: the numbers
// that predict whether an app FEELS bad are how long a round trip takes and
// whether a frame was dropped. Memory is one row among those, and it earns its
// place because a bump arena climbing without bound eventually stops the page —
// which it did, twice.
(function () {
  const NAME = 'perf';
  const MiB = 1048576;

  // ── sources ────────────────────────────────────────────────────────────────
  // `__lengMem` is exposed by the Leng JS runtime: two bump arenas in one
  // ArrayBuffer plus the value-table counts, so "how full" is a subtraction. If
  // it is absent this is not a nimony page; the memory rows say so rather than
  // drawing zeros, because a monitor reading nothing must not look like a
  // monitor reading idle.
  const mem = () => (typeof globalThis.__lengMem === 'function'
    ? globalThis.__lengMem() : null);

  // Requests are timed by wrapping `fetch` ONCE. Everything the host does that
  // a person waits on goes through it, so this is the latency that is actually
  // felt — as opposed to a number an app reports about itself, which is the
  // kind that is always fast.
  const R = { last: 0, n: 0, sum: 0, worst: 0, inflight: 0 };
  if (!globalThis.__perfFetchWrapped && typeof globalThis.fetch === 'function') {
    globalThis.__perfFetchWrapped = true;
    const inner = globalThis.fetch.bind(globalThis);
    globalThis.fetch = function (...args) {
      const t0 = performance.now();
      R.inflight++;
      const done = () => {
        const dt = performance.now() - t0;
        R.inflight--;
        R.last = dt; R.n++; R.sum += dt;
        if (dt > R.worst) R.worst = dt;
      };
      // Both arms, not `finally`: a failed request is still a request somebody
      // waited for, and dropping it would make the worst moments invisible.
      return inner(...args).then(
        (r) => { done(); return r; },
        (e) => { done(); throw e; });
    };
  }

  // Frame time, from the loop this widget is already running. Long frames are
  // what "the UI stuttered" actually is, and they are invisible in any
  // server-side timing.
  const F = { last: 16.7, worst: 0, jank: 0, n: 0, sum: 0 };

  const el = (cls, txt) => {
    const d = document.createElement('div');
    if (cls) d.className = cls;
    if (txt != null) d.textContent = txt;
    return d;
  };

  function build(host) {
    host.textContent = '';
    const root = el('perf');
    const head = el('perf-head');
    const note = el('perf-note', '');
    head.append(el('perf-title', 'performance'), note);
    const rows = el('perf-rows');

    // A BAR is for something with a ceiling, where the question is "how close".
    const bar = (label) => {
      const row = el('perf-row');
      const track = el('perf-track');
      const fill = el('perf-fill');
      track.append(fill);
      const val = el('perf-val', '');
      row.append(el('perf-label', label), track, val);
      rows.append(row);
      return { fill, val };
    };
    // A STAT is for something with no ceiling, where the number IS the answer.
    const stat = (label) => {
      const row = el('perf-row');
      const val = el('perf-val is-wide', '');
      row.append(el('perf-label', label), val);
      rows.append(row);
      return { val };
    };

    const ui = {
      values: bar('values'),
      heap: bar('heap'),
      request: stat('request'),
      frame: stat('frame'),
      handles: stat('handles'),
      note: note,
    };
    root.append(head, rows);
    host.append(root);
    return ui;
  }

  // Bytes at a readable scale. `(0.02).toFixed(1)` is "0.0", which reads as
  // nothing happening when the truth is 20 KiB — that exact display bug is why
  // the heap row looked empty.
  const bytes = (b) => (b >= MiB ? (b / MiB).toFixed(1) + ' MiB'
                      : b >= 1024 ? (b / 1024).toFixed(0) + ' KiB'
                      : b + ' B');
  const ms = (v) => (v >= 100 ? v.toFixed(0) : v.toFixed(1)) + ' ms';

  function setBar(b, used, cap) {
    const pct = cap > 0 ? Math.min(100, (used / cap) * 100) : 0;
    b.fill.style.width = pct.toFixed(2) + '%';
    // Three states, because the interesting one is "climbing towards a wall"
    // and one colour cannot say it.
    b.fill.classList.toggle('is-warn', pct >= 60 && pct < 85);
    b.fill.classList.toggle('is-danger', pct >= 85);
    b.val.textContent = bytes(used);
  }

  function paint(ui) {
    const m = mem();
    if (m) {
      setBar(ui.values, m.fixedUsed, m.fixedCap);
      setBar(ui.heap, m.heapUsed, m.total - m.fixedCap);
      ui.note.textContent = bytes(m.total);
      // LIVE handles, not the table size: the table never shrinks, so it shows
      // the largest number ever alive at once and climbs whether or not
      // anything is wrong. A rising `live` under a repeated action is a leak,
      // and one was found exactly this way — 463 per document opened.
      ui.handles.val.textContent = m.live + ' live';
      ui.handles.val.classList.toggle('is-danger', m.live > 50000);
    } else {
      ui.note.textContent = 'no leng runtime';
      ui.handles.val.textContent = '—';
    }
    const avg = R.n ? R.sum / R.n : 0;
    ui.request.val.textContent = R.n === 0 ? '—'
      : ms(R.last) + ' · avg ' + ms(avg) + ' · max ' + ms(R.worst);
    ui.request.val.classList.toggle('is-warn', R.last >= 150 && R.last < 400);
    ui.request.val.classList.toggle('is-danger', R.last >= 400);
    const favg = F.n ? F.sum / F.n : 0;
    ui.frame.val.textContent = ms(F.last) + ' · avg ' + ms(favg) +
                               ' · ' + F.jank + ' janky';
    ui.frame.val.classList.toggle('is-warn', F.last > 33 && F.last <= 100);
    ui.frame.val.classList.toggle('is-danger', F.last > 100);
  }

  // ── staying mounted ────────────────────────────────────────────────────────
  // The host's reconciler may MOVE this node, and a moved node keeps its
  // children — but a host that rebuilt instead would hand back a fresh, empty
  // element. Rather than depend on which, the loop checks each frame whether
  // the element it is drawing into is still the one in the document, and
  // rebuilds when it is not. Idempotent, and it costs one querySelector.
  let host = null, ui = null, raf = 0, lastPaint = 0, lastFrame = 0;

  function tick(now) {
    raf = requestAnimationFrame(tick);
    if (lastFrame) {
      const dt = now - lastFrame;
      F.last = dt; F.n++; F.sum += dt;
      if (dt > F.worst) F.worst = dt;
      // A frame over ~50ms is one a person notices. Counting them is more
      // useful than an average, which a single long pause barely moves.
      if (dt > 50) F.jank++;
    }
    lastFrame = now;

    const found = document.querySelector('[data-widget="' + NAME + '"]');
    if (!found) { host = null; ui = null; return; }
    if (found !== host || !found.firstChild) { host = found; ui = build(host); }
    // Ten repaints a second. A monitor that repaints every frame costs more
    // than the thing it is monitoring, and nothing here changes faster than the
    // eye — but the SAMPLING above still runs every frame, or the jank count
    // would miss the frames it exists to catch.
    if (now - lastPaint < 100) return;
    lastPaint = now;
    paint(ui);
  }

  function start() { if (!raf) raf = requestAnimationFrame(tick); }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
  // Named on globalThis so a host can stop it, and so a second copy of this
  // file cannot start a second loop.
  if (globalThis.__aowlPerf) globalThis.__aowlPerf.stop();
  globalThis.__aowlPerf = {
    stop: () => { cancelAnimationFrame(raf); raf = 0; },
    reset: () => { R.n = 0; R.sum = 0; R.worst = 0; F.n = 0; F.sum = 0; F.jank = 0; },
  };
})();

#!/bin/sh
# tests/run.sh — build and run every gate from the repo ROOT (the tools and
# tests read reference/styles.css by relative path).
set -u

here=$(cd "$(dirname "$0")" && pwd)
root=$(dirname "$here")
cd "$root" || exit 2
flags=$(tr '\n' ' ' < "$root/.aowlcode.flags")

# nimony shares ~/nimony/nimcache_static/static.o across every project and keys
# it only by mtime, so when it is missing the parallel workers of one build race
# to write it and the clobbered object fails to link. Build it once, serially.
static_o="$(dirname "$(dirname "$(command -v nimony)")")/nimcache_static/static.o"
if [ ! -f "$static_o" ]; then
  warm=$(mktemp -d)
  printf 'import std/syncio\necho "warm"\n' > "$warm/warm.nim"
  (cd "$warm" && nimony c warm.nim >/dev/null 2>&1)
  rm -rf "$warm"
fi

pass=0
fail=0

# Build a source file and echo the path of the binary it produced. A link may
# fail for the shared-object reason above, so retry — but delete the old binary
# first, or a stale one from a previous build is silently run instead.
build() {
  find "$root" -name "$2" -type f -perm -u+x -delete 2>/dev/null
  i=0
  while [ "$i" -lt 4 ]; do
    nimony $flags c "$1" >/dev/null 2>&1
    b=$(find "$root" -name "$2" -type f -perm -u+x 2>/dev/null | head -1)
    [ -n "$b" ] && { echo "$b"; return 0; }
    i=$((i + 1))
  done
  return 1
}

echo "== regenerating components from reference/styles.css =="
ing=$(build tools/ingest.nim ingest) || { echo "FAIL: ingest did not build"; exit 1; }
"$ing" || { echo "FAIL: ingest did not run"; exit 1; }

echo ""
echo "== gates =="
for src in "$here"/t*.nim; do
  name=$(basename "$src" .nim)
  bin=$(build "tests/$name.nim" "$name") || {
    echo "FAIL $name — did not build"; fail=$((fail + 1)); continue; }
  out=$("$bin" 2>&1)
  # A gate reports its own verdict; the runner only decides pass/fail from it.
  if printf '%s' "$out" | grep -q 'ROUND-TRIP OK\|^OK$'; then
    echo "ok   $name"
    pass=$((pass + 1))
  else
    echo "FAIL $name"
    printf '%s\n' "$out" | head -20 | sed 's/^/    /'
    fail=$((fail + 1))
  fi
done

echo ""
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

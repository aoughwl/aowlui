## tpage — print the ported lab page, so the markup is inspectable rather than
## only asserted. `tshell` is the gate; this is the artifact it guards.
import std/syncio
import ../aowlui/lab/shell

echo labPage()
echo ""
echo "OK"

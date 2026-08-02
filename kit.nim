## aowlui/kit — a technical UI kit driven by a handful of CSS variables.
##
##   import kit
##
##   useStylesheet kitSheet()
##   echo document("app", @[shell(top = @[toolbar()], body = @[...])],
##                 css = renderTheme() & renderReset())
##
## Theming is `--scale` and `--round` plus two colour ramps; see `kit/theme`.
## Every component is in `kit/components` and every rule in `kit/sheet`.
import kit/theme
import kit/sheet
import kit/components
export theme, sheet, components

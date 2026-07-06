# aoughwl/ui

Reusable UI tokens and components for the `aoughwl` lab build.

## Public surface

```nim
import aoughwl/ui

echo renderTheme()
echo render(button("Send"))
echo render(textInput(placeholder = "Search…", value = ""))
echo render(progressBar(68))
echo renderStylesheet()
```

Exports:

- `renderTheme()` for the token stylesheet
- `renderStylesheet()` for the scoped component styles
- `styleErrors()` for CSS validation feedback
- `button()`, `iconButton()`, `textInput()`, `badge()`, `pill()`, `avatar()`,
  `divider()`, `card()`, `surface()`, `stack()`, `cluster()`, `sidebar()`,
  `toolbar()`, `menuItem()`, `sectionHeader()`, `formField()`, `stat()`,
  `meter()`, `progressBar()`, `callout()`, `toast()`, `dialog()`,
  `emptyState()`, `codeBlock()`, `tab()`, `tabs()`, and `breadcrumb()` for the
  reusable UI surface

## Component syntax reference

The component form we are standardizing on is demonstrated in
[`scripts/component.aowl`](../../scripts/component.aowl):

```nim
component something:
  input name: string
  box:
    h1 "test"
    style:
      color: red
      [hover]:
        opacity: 0.5
```

That file is the place to look when adding new UI components or reshaping the
existing ones.

## Expansion Notes

- The public API stays plain-name, without the old `ui` prefix.
- Theme tokens are still centralized in `packs/aoughwl/ui/theme.aowl`.
- New components should reuse the existing `web:` DSL shape so styling and
  pseudo-state handling stay consistent across the pack.
- This public repo is a raw `.aowl` source mirror of the UI pack only.

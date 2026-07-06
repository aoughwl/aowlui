# ui

Raw `.aowl` source repo for the `aoughwl/ui` pack.

This repo publishes the UI package itself as the repo root.

Main entry points:

- `ui.aowl`
- `theme.aowl`
- `variants.aowl`
- `components/`

Public surface:

- `renderTheme()` for the token stylesheet
- `renderStylesheet()` for the scoped component styles
- `styleErrors()` for CSS validation feedback
- `button()`, `iconButton()`, `textInput()`, `badge()`, `pill()`, `avatar()`,
  `divider()`, `card()`, `surface()`, `stack()`, `cluster()`, `sidebar()`,
  `toolbar()`, `menuItem()`, `sectionHeader()`, `formField()`, `stat()`,
  `meter()`, `progressBar()`, `callout()`, `toast()`, `dialog()`,
  `emptyState()`, `codeBlock()`, `tab()`, `tabs()`, and `breadcrumb()`

Notes:

- The public API stays plain-name, without the old `ui` prefix.
- Theme tokens live in `theme.aowl`.
- New components should reuse the existing `web:` DSL shape so styling and
  pseudo-state handling stay consistent across the pack.

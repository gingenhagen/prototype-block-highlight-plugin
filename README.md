# prototype-block-highlight-plugin package

An atom plugin that highlights blocks of code instead of lines of code.

## Rationale

When working in lisp-based languages such as Clojure, code does not proceed line by line, but rather block by block, as indicated by its numerous nesting parentheses.  Therefore, the common editor convention of highlighting the current line is not useful.  Tools such as [paredit](https://www.emacswiki.org/emacs/ParEdit) work by forcing you to only manipulate code in terms of blocks, but when using tools such as [parinfer](https://shaunlebron.github.io/parinfer/) that allow for more traditional editor traversal, the ability to highlight your current wrapping block then becomes very useful.

## TODO

- [X] Highlight surrounding block based on cursor position, for `(`, `)`, `[`, `]`, `{`, `}`
- [X] Match atom's convention for highlighting the matching bracket
- [ ] Allow user to configure targeted file types
- [ ] Add support for wrapping `"`
- [ ] Add support for jumping between blocks, analogous to how `command-left` and `command-right` jump to the beginning and end of the line, respectively
- [ ] Add support for highlighting blocks, analogous to how adding `shift` to navigation shortcuts selects the underlying text

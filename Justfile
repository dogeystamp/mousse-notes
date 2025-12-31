root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
  @just --list --unsorted

# generate stuff for docs
doc:
  mkdir -p doc
  cat template/main.typ | sed 's/#import "@preview.mousse-notes:.*/#import "\/src\/lib.typ" as mousse-notes: */g' > doc/main.typ
  typst compile -f png --pages 1 --ppi 250 doc/main.typ thumbnail.png
  typst compile -f png --pages 2 --ppi 250 doc/main.typ thumbnail_pages.png
  optipng -o6 thumbnail.png
  optipng -o6 thumbnail_pages.png


# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# run ci suite
ci: doc

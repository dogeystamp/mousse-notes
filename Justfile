root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
  @just --list --unsorted

# generate images for docs
thumbnail:
  mkdir -p doc
  cat template/main.typ | sed 's/#import "@preview.mousse-notes:.*/#import "\/src\/lib.typ" as mousse-notes: */g' > doc/main.typ
  typst compile -f png --pages 1-3 --ppi 250 doc/main.typ doc/thumbnail{p}.png
  magick convert +append doc/thumbnail{2,3}.png thumbnail_pages.png
  cp doc/thumbnail1.png thumbnail.png
  optipng -o6 thumbnail*.png

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
ci:

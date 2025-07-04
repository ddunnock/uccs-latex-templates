# ────────────────────────────────────────────────────────────────
#  Makefile – UCCS LaTeX coursework toolchain
#  v2 • 2025-06-27 • ChatGPT-assisted refinement
# ────────────────────────────────────────────────────────────────
#
#  Requirements
#  ────────────
#    • tectonic  – preferred zero-config LaTeX engine
#         -or-
#    • latexmk   – fallback engine (watch mode, etc.)
#    • bash      – every recipe uses bash-isms
#
#  Key targets (also shown by `make help`)
#  ───────────────────────────────────────
#    pdf         make pdf FILE=<tex>      → compile one document
#    all         make all                 → compile every .tex in classes/
#    watch       make watch FILE=<tex>    → live-reload (latexmk only)
#    clean       make clean               → delete aux files
#    distclean   make distclean           → clean + delete PDFs
#    newdoc      make newdoc [...]        → scaffold homework/report
#    newhw       make newhw  [...]        → shorthand wrapper for homework
#    newreport   make newreport [...]     → shorthand wrapper for report
#
# ────────────────────────────────────────────────────────────────

SHELL := /usr/bin/env bash        # single point of truth for all recipes

# ──────────────────────────────
#  0.  Engine auto-detection
# ──────────────────────────────
ENGINE  	:= $(shell command -v tectonic 2>/dev/null || \
					 					 command -v xelatex 2>/dev/null || \
										 command -v latexmk 2>/dev/null)

ENGINEF := $(notdir $(ENGINE))

ifeq ($(ENGINEF),xelatex)
	COMPILE = xelatex -interaction=nonstopmode -synctex=1 -shell-escape $1
else ifeq ($(ENGINEF),tectonic)
	COMPILE = tectonic -X compile --synctec -Z shell-escape $1
else
	COMPILE = latexmk -xelatex -shell-escape -interaction=nonstopmode $1
endif

# ──────────────────────────────
#  1.  Compiler abstraction
#      $(call COMPILE,<file.tex>)
# ──────────────────────────────
ifeq ($(ENGINEF),tectonic)
  COMPILE = tectonic -X compile --synctex -Z shell-escape "$1"
else
  COMPILE = latexmk -pdf -shell-escape -interaction=nonstopmode "$1"
endif

# ──────────────────────────────
#  2.  Self-documenting help
# ──────────────────────────────
.PHONY: help
help: ## Print every documented target
	@grep -E '^[a-zA-Z_-]+:.*?##' $(firstword $(MAKEFILE_LIST)) | \
	  awk 'BEGIN {FS=":.*?##"} {printf "  \033[1m%-12s\033[0m %s\n", $$1, $$2}'

# ──────────────────────────────
#  3.  Single-file compile
# ──────────────────────────────
.PHONY: pdf
pdf: ## Compile one .tex file → PDF (usage: make pdf FILE=path/to/doc.tex)
ifndef FILE
	$(error Usage: make pdf FILE=classes/<course>/<term>/<name>.tex)
endif
	@$(call COMPILE,$(FILE))
	@# Optional – open the resulting PDF (macOS: `open`, Linux: `xdg-open`)
	@pdf="$${FILE%.tex}.pdf"; \
	if   command -v open      >/dev/null 2>&1; then open     "$$pdf"; \
	elif command -v xdg-open  >/dev/null 2>&1; then xdg-open "$$pdf"; fi

# ──────────────────────────────
#  4.  Compile everything
# ──────────────────────────────
.PHONY: all
all: ## Recursively compile every .tex under classes/
	@echo '🔄  Building ALL coursework PDFs…'
	@find classes -type f -name '*.tex' -print0 | \
	  while IFS= read -r -d '' f; do \
	    echo "—— $$f"; \
	    $(call COMPILE,$$f) || exit 1; \
	  done
	@echo '✅  All documents compiled.'

# ──────────────────────────────
#  5.  Continuous watch (latexmk only)
# ──────────────────────────────
.PHONY: watch
watch: ## Live-reload compilation (requires latexmk)
ifeq ($(ENGINEF),tectonic)
	$(error watch target requires latexmk in PATH)
endif
ifndef FILE
	$(error Usage: make watch FILE=path/to/doc.tex)
endif
	@latexmk -pdf -pvc -shell-escape -interaction=nonstopmode "$(FILE)"

# ──────────────────────────────
#  6.  Clean artefacts
# ──────────────────────────────
.PHONY: clean
clean: ## Delete auxiliary build artefacts (keeps PDFs)
	@echo '🧹  Cleaning auxiliary files…'
	@find . \( -name '*.aux'  -o -name '*.fdb_latexmk' -o -name '*.fls' \
	           -o -name '*.log' -o -name '*.synctex.gz' -o -name '*.out' \
	           -o -name '*.bbl' -o -name '*.blg' -o -name '*.bcf' \
	           -o -name '*.run.xml' \) -delete
	@echo '✅  Clean done.'

.PHONY: distclean
distclean: clean ## Clean + delete generated PDFs
	@echo '🧹  Removing PDFs…'
	@find classes -type f -name '*.pdf' -delete
	@echo '✅  distclean done.'

# ──────────────────────────────
#  7.  Template scaffolding
# ──────────────────────────────
.PHONY: newdoc
newdoc: ## Interactive homework/report scaffold (vars: TYPE CLASS ACAD_TERM MODULE_NUM ASSIGN_TITLE STUDENT INSTRUCTOR)
	@# Forward Make-vars into the environment; missing ones trigger prompts.
	@env TYPE="$(TYPE)" CLASS="$(CLASS)" ACAD_TERM="$(ACAD_TERM)" MODULE_NUM="$(MODULE_NUM)" ASSIGN_TITLE="$(ASSIGN_TITLE)" \
	     STUDENT="$(STUDENT)" INSTRUCTOR="$(INSTRUCTOR)" \
	     bash scripts/newdoc.sh

.PHONY: newhw
newhw: ## Wrapper – homework scaffold
	$(MAKE) newdoc TYPE=homework $(filter-out TYPE=%,$(MAKECMDGOALS))

.PHONY: newreport
newreport: ## Wrapper – report scaffold
	$(MAKE) newdoc TYPE=report   $(filter-out TYPE=%,$(MAKECMDGOALS))

# ──────────────────────────────
#  8.  Default target
# ──────────────────────────────
.DEFAULT_GOAL := help

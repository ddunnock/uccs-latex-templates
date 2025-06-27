#!/usr/bin/env bash
# -------------------------------------------------------------
#  newdoc.sh – Scaffold homework/report from LaTeX templates
# -------------------------------------------------------------
set -euo pipefail

# ─────────────── 1. Collect inputs ───────────────
TYPE=${TYPE:-${1:-}}
CLASS=${CLASS:-${2:-}}
ACAD_TERM=${ACAD_TERM:-${3:-}}           # 2025_summer, 2024_fall …
ASSIGN=${ASSIGN:-${4:-}}                 # HW-01, Module-1_Homework, MidtermReport, …
STUDENT=${STUDENT:-${USER}}
INSTRUCTOR=${INSTRUCTOR:-"TBD"}
COURSE_TITLE=${COURSE_TITLE:-""}
HWNUM=${HWNUM:-""}                       # optional override

prompt() { read -rp "  $1: " _tmp && printf '%s' "${_tmp:-}"; }

if [[ -z $TYPE || -z $CLASS || -z $ACAD_TERM || -z $ASSIGN ]]; then
  echo "Interactive mode – please provide the missing fields"
  [[ -z $TYPE       ]] && TYPE=$(prompt "Document type [homework/report]")
  [[ -z $CLASS      ]] && CLASS=$(prompt "Course ID (e.g. EMGT5510)")
  [[ -z $ACAD_TERM  ]] && ACAD_TERM=$(prompt "Academic term (e.g. 2025_summer)")
  [[ -z $ASSIGN     ]] && ASSIGN=$(prompt "Assignment label (e.g. HW-01)")
  STUDENT=$(prompt "Student name [$STUDENT]")     || true
  INSTRUCTOR=$(prompt "Instructor  [$INSTRUCTOR]")|| true
  COURSE_TITLE=$(prompt "Course title [optional]")|| true
fi

TYPE=$(printf '%s' "$TYPE" | tr '[:upper:]' '[:lower:]')
[[ $TYPE =~ ^(homework|report)$ ]] || { echo "TYPE must be homework or report"; exit 1; }

# ─────────────── 2. Homework number derivation (numeric only) ───────────────
if [[ $TYPE == homework && -z $HWNUM ]]; then
  HWNUM=$(printf '%s' "$ASSIGN" | grep -Eo '[0-9]+' | head -1 || true)
  [[ -n $HWNUM ]] && HWNUM=$(printf '%02d' "$HWNUM")
fi

# ─────────────── 3. Paths & filenames ───────────────
TEMPL_DIR="templates"
DEST_DIR="classes/$CLASS/$ACAD_TERM"
mkdir -p "$DEST_DIR"

TEMPLATE="$TEMPL_DIR/${TYPE}_template.tex"
OUTFILE="$DEST_DIR/${CLASS}_${ASSIGN}.tex"
[[ -e $OUTFILE ]] && { echo "❌ $OUTFILE exists. Aborting."; exit 1; }
cp "$TEMPLATE" "$OUTFILE"

# ─────────────── 4. Helper functions for in-file substitution ───────────────
# Escape / & \  for search   | escape / & \ for replacement
wrap_sed()   { printf '%s' "$1" | sed 's/[\\/&]/\\&/g'; }
wrap_perl_r() { printf '%s' "$1" | sed 's/[\\\\&]/\\\\&/g'; }

# s  <pattern>  <replacement>
s() {
  local p
  local r
  p=$(wrap_sed "$1")
  r=$(wrap_sed "$2")
  perl -pi -e "s/$p/$r/g" "$OUTFILE"
}

# ─────────────── 5. Perform substitutions ───────────────
# Convert underscores to spaces for display purposes
DISPLAY_TERM=$(printf '%s' "$ACAD_TERM" | sed 's/_/ /g')

s '<COURSE ID>'              "$CLASS"
[[ -n $COURSE_TITLE ]] && s '<Course Title>'       "$COURSE_TITLE"
s '<Professor / Instructor>' "$INSTRUCTOR"
s '<Student Name>'           "$STUDENT"
s '<Term / Year>'            "$DISPLAY_TERM"

if [[ $TYPE == homework ]]; then
  # 1. Replace the title-block placeholder
  s 'Homework~\\#\\homeworknum' "$ASSIGN"
  # 2. Safely rewrite the \homeworknum macro
  rep=$(wrap_perl_r "$ASSIGN")          # escape / and \
  perl -pi -e "s/\\newcommand\{\\homeworknum\}\{[^}]*\}/\\newcommand\{\\homeworknum\}\{$rep\}/" "$OUTFILE"
fi

printf '✅  Created %s\n' "$OUTFILE"

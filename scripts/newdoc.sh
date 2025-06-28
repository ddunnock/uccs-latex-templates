#!/usr/bin/env bash
# -------------------------------------------------------------
#  newdoc.sh – Scaffold homework/report from LaTeX templates
# -------------------------------------------------------------
set -euo pipefail

# ─────────────── 1. Load configuration file ───────────────
load_config() {
  local config_file=".newdoc.conf"
  
  # Check for config file in current directory or home directory
  if [[ -f "$config_file" ]]; then
    echo "📁 Loading config from ./$config_file"
    # shellcheck source=/dev/null
    source "$config_file"
  elif [[ -f "$HOME/$config_file" ]]; then
    echo "📁 Loading config from ~/$config_file"
    # shellcheck source=/dev/null
    source "$HOME/$config_file"
  fi
}

# Load config before setting variables
load_config

# ─────────────── 2. Collect inputs with config defaults ───────────────
TYPE=${TYPE:-${1:-}}
CLASS=${CLASS:-${2:-}}
ACAD_TERM=${ACAD_TERM:-${3:-}}           # 2025_summer, 2024_fall …
MODULE_NUM=${MODULE_NUM:-${4:-}}         # Module number (1, 2, 3, etc.)
ASSIGN_TITLE=${ASSIGN_TITLE:-${5:-}}     # Assignment title (free text)
STUDENT=${STUDENT:-${STUDENT_NAME:-${USER}}}
INSTRUCTOR=${INSTRUCTOR:-"TBD"}
COURSE_TITLE=${COURSE_TITLE:-""}

# Enhanced prompt function with defaults
prompt() {
  local prompt_text="$1"
  local default_val="${2:-}"
  local user_input
  
  if [[ -n "$default_val" ]]; then
    read -rp "  $prompt_text [$default_val]: " user_input
    printf '%s' "${user_input:-$default_val}"
  else
    read -rp "  $prompt_text: " user_input
    printf '%s' "${user_input:-}"
  fi
}

if [[ -z $TYPE || -z $CLASS || -z $ACAD_TERM || -z $MODULE_NUM || -z $ASSIGN_TITLE ]]; then
  echo "📝 Interactive mode – please provide the missing fields"
  echo "   (Press Enter to use default values shown in brackets)"
  echo
  
  [[ -z $TYPE        ]] && TYPE=$(prompt "Document type [homework/report]" "${TYPE:-homework}")
  [[ -z $CLASS       ]] && CLASS=$(prompt "Course ID (e.g. EMGT5510)" "$CLASS")
  [[ -z $ACAD_TERM   ]] && ACAD_TERM=$(prompt "Academic term (e.g. 2025_summer)" "$ACAD_TERM")
  [[ -z $MODULE_NUM  ]] && MODULE_NUM=$(prompt "Module number (e.g. 1, 2, 3)" "$MODULE_NUM")
  [[ -z $ASSIGN_TITLE ]] && ASSIGN_TITLE=$(prompt "Assignment title (e.g. Case Study Analysis)" "$ASSIGN_TITLE")
  
  # Always prompt for these, but show current values as defaults
  STUDENT=$(prompt "Student name" "$STUDENT")
  INSTRUCTOR=$(prompt "Instructor" "$INSTRUCTOR")
  
  # Course title is optional
  if [[ -n "$COURSE_TITLE" ]]; then
    COURSE_TITLE=$(prompt "Course title [optional]" "$COURSE_TITLE")
  else
    COURSE_TITLE=$(prompt "Course title [optional]")
  fi
  
  echo
fi

TYPE=$(printf '%s' "$TYPE" | tr '[:upper:]' '[:lower:]')
[[ $TYPE =~ ^(homework|report)$ ]] || { echo "TYPE must be homework or report"; exit 1; }

# ─────────────── 2. Filename generation ───────────────
# Function to sanitize text for cross-platform filenames
sanitize_filename() {
  local text="$1"
  # Convert to lowercase, replace spaces with hyphens, remove special chars
  printf '%s' "$text" | \
    tr '[:upper:]' '[:lower:]' | \
    sed 's/[[:space:]]\+/-/g' | \
    sed 's/[^a-z0-9._-]//g' | \
    sed 's/--\+/-/g' | \
    sed 's/^-\|-$//g'
}

# Generate standardized assignment filename
generate_assign_name() {
  local module="$1"
  local title="$2"
  local sanitized_title
  
  sanitized_title=$(sanitize_filename "$title")
  printf 'Module-%s_%s' "$module" "$sanitized_title"
}

# Create the assignment name for filename
ASSIGN=$(generate_assign_name "$MODULE_NUM" "$ASSIGN_TITLE")

# For homework, derive HWNUM from module number
if [[ $TYPE == homework ]]; then
  HWNUM=$(printf '%02d' "$MODULE_NUM")
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
s '<Module Number>'          "Module $MODULE_NUM"
s '<Assignment Title>'       "$ASSIGN_TITLE"

if [[ $TYPE == homework ]]; then
  # 1. Replace the title-block placeholder
  s 'Homework~\\#\\homeworknum' "$ASSIGN"
  # 2. Safely rewrite the \homeworknum macro
  rep=$(wrap_perl_r "$ASSIGN")          # escape / and \
  perl -pi -e "s/\\newcommand\{\\homeworknum\}\{[^}]*\}/\\newcommand\{\\homeworknum\}\{$rep\}/" "$OUTFILE"
fi

printf '✅  Created %s\n' "$OUTFILE"

#!/bin/zsh

if [ "$#" -eq 0 ]; then
  echo "Usage: mdf path/to/file.md [more.md ...]" >&2
  exit 2
fi

files=()

for f in "$@"; do
  if [[ "$f" != *.md ]]; then
    echo "Not a Markdown file: $f" >&2
    echo "Only .md files can be formatted." >&2
    exit 1
  fi

  if [ ! -f "$f" ]; then
    echo "File not found: $f" >&2
    exit 1
  fi

  files+=("$f")
done

root="$(npm prefix 2>/dev/null)"
repo_raw="https://raw.githubusercontent.com/Gwyntoria/my_cs_notes/main"

if [ -z "$root" ]; then
  echo "Cannot find npm project root." >&2
  echo "Please run mdf inside a Node/npm project directory." >&2
  exit 1
fi

missing_deps=0

if [ ! -x "$root/node_modules/.bin/markdownlint-cli2" ]; then
  echo "Missing dependency: markdownlint-cli2" >&2
  missing_deps=1
fi

if [ ! -x "$root/node_modules/.bin/textlint" ]; then
  echo "Missing dependency: textlint" >&2
  missing_deps=1
fi

if [ "$missing_deps" -eq 1 ]; then
  echo "" >&2
  echo "Run this in the project root:" >&2
  echo "cd \"$root\"" >&2
  echo "npm install -D markdownlint-cli2 textlint \\" >&2
  echo "  textlint-rule-ja-space-between-half-and-full-width \\" >&2
  echo "  textlint-rule-no-todo \\" >&2
  echo "  textlint-rule-prh \\" >&2
  echo "  textlint-rule-zh-half-and-full-width-bracket" >&2
  exit 1
fi

missing_configs=()

for config in ".markdownlint-cli2.jsonc" ".textlintrc.json" "tech-terms.yml"; do
  if [ ! -f "$root/$config" ]; then
    missing_configs+=("$config")
  fi
done

if [ "${#missing_configs[@]}" -gt 0 ]; then
  echo "Missing config file(s): ${missing_configs[*]}" >&2
  echo "" >&2
  echo "Download them from Gwyntoria/my_cs_notes:" >&2
  echo "cd \"$root\"" >&2
  echo "curl -fsSLO \"$repo_raw/.markdownlint-cli2.jsonc\"" >&2
  echo "curl -fsSLO \"$repo_raw/.textlintrc.json\"" >&2
  echo "curl -fsSLO \"$repo_raw/tech-terms.yml\"" >&2
  exit 1
fi

"$root/node_modules/.bin/markdownlint-cli2" --fix --no-globs "${files[@]}" &&
"$root/node_modules/.bin/textlint" --fix "${files[@]}"

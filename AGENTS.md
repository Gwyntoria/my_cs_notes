# Repository Guidelines

## Project Structure & Module Organization

This repository is a collection of computer science notes written primarily in Markdown. Topic directories such as `Algorithm/`, `Architecture/`, `C++/`, `Git/`, `Linux/`, `Network/`, `Operating System/`, and `Python/` contain standalone notes grouped by subject. `Summary/` holds broad concept summaries, `Manual/` contains repository process documentation, and `assets/` stores images referenced from notes. Root-level files such as `README.md`, `tech-terms.yml`, `.markdownlint-cli2.jsonc`, and `.textlintrc.json` define contributor-facing documentation and formatting rules.

## Coding Style & Naming Conventions

Write notes as Markdown with clear heading hierarchy and concise sections. Prefer topic-based filenames that match existing patterns, for example `Network/HTTP.md` or `Python/虚拟环境.md`. Store new images under `assets/`, or a note-specific subdirectory under `assets/` when several images belong together. Use standard Markdown image links with relative paths. Keep emphasis styles as asterisks, and avoid using emphasis as a heading.

## Commit & Pull Request Guidelines

Recent history uses short, direct commit messages, often in Chinese, such as `更新README.md` or `新增markdownlint和textlint配置文件`. Follow that style: summarize the changed note or configuration in one sentence. Pull requests should describe the affected topic areas, list formatting or lint commands run, and include screenshots only when image-heavy notes or rendered layout changes need visual review.

## Agent-Specific Instructions

Do not rewrite unrelated notes while making focused edits. Preserve existing bilingual terminology and filename conventions. If a lint fix changes many files, separate that formatting-only change from content edits when possible.

## Markdown File Format

After finishing edits to a Markdown file, format only the files that was changed with `markdownlint-cli2`, then run `textlint` to apply typography fixes and terminology replacements.

```bash
npx markdownlint-cli2 --fix --no-globs path/to/file.md
npx textlint --fix path/to/file.md
```

Avoid running broad auto-fix commands unless the task is specifically to clean up formatting across the repository.

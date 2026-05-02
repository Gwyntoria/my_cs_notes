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

## 代码设计原则

在需要添加代码进行进一步说明的情况下，代码应遵循以下原则：

- 示例代码优先服务于概念说明，保持短小、聚焦，不引入与当前主题无关的框架、工具或复杂抽象。
- 变量名、函数名、类名使用英文，并尽量通过名称表达清楚用途，避免使用 `data`、`temp`、`foo`、`bar` 这类无语义名称。
- 遵循对应语言的主流命名习惯，例如 Python 使用 `snake_case`，C++ 类型名可使用 `PascalCase`，常量名可使用 `UPPER_SNAKE_CASE`。
- 示例代码应尽量完整、可运行；如果为了突出重点省略了上下文，应在正文或注释中说明省略内容。
- 优先展示清晰直接的实现，再讨论优化、抽象或边界情况；不要为了展示技巧而牺牲可读性。
- 函数应尽量保持单一职责，输入、输出和副作用要清晰；涉及状态变化时，应让状态来源和修改位置容易追踪。
- 对可能出错的输入、资源访问、网络请求、文件操作等场景，应补充必要的错误处理或说明错误处理策略。
- 涉及资源管理时，应体现释放资源的正确方式，例如关闭文件、释放锁、回收内存或使用 RAII、`with` 等语言机制。
- 注释用于解释「为什么这样做」或说明不明显的约束，不重复描述代码已经直接表达的内容。
- 代码中的输出结果、复杂度、关键步骤或边界条件，应优先在正文中解释，避免把大段说明塞进注释里。
- 不在示例代码中写入真实密钥、Token、密码、私有地址或个人信息；需要占位时使用明显的示例值。
- 多段代码连续出现时，保持变量命名和示例背景一致，避免读者在无关命名变化中重新理解上下文。

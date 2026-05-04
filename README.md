# README

## Introduction

本仓库记录了我在遇到一些问题时，所查找到的可行的解决方案，但可能存在归因并不全面的情况，而导致解决方案在特定条件下并不能解决同样的问题。

同时也记录了一些我的学习笔记，比如一些对操作系统、数据库、网络协议的知识汇总和个人理解。

## More Info

1. *How_to_Ask_Questions.md* 是我从[华蟒用户组](https://groups.google.com/g/python-cn)的提问指南中找到的，英文原文为[How To Ask Questions the Smart Way](http://linuxmafia.com/faq/Essays/smart-questions.html)。

## Format

本仓库使用 `markdownlint-cli2` 和 `textlint` 统一 Markdown 结构、中文排版与技术术语。

### 基础环境

1. 安装 `Node.js`
2. 在仓库根目录执行

    ```bash
    npm install -D markdownlint-cli2 textlint \
    textlint-rule-ja-space-between-half-and-full-width \
    textlint-rule-no-todo \
    textlint-rule-prh \
    textlint-rule-zh-half-and-full-width-bracket
    ```

仓库内已提供以下配置文件：

1. `.markdownlint-cli2.jsonc`（会覆盖掉 VS Code 插件的 setting）
2. `.textlintrc.json`
3. `tech-terms.yml`

### 操作流程

完成对 Markdown 文件的编辑后，使用 `markdownlint-cli2` 对文件进行格式化，然后使用 `textlint` 完成排版修复和术语替换。

```bash
npx markdownlint-cli2 --fix --no-globs path/to/file.md
npx textlint --fix path/to/file.md
```

如果使用 VS Code，建议安装 `markdownlint` 和 `textlint` 插件，并在 `settings.json` 中启用保存时检查。更完整的规则说明见 [markdown格式化指南.md](Manual/markdown格式化指南.md)。

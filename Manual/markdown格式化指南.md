# Markdown 格式化指南

## 1. 目标

在 VS Code 中编辑 Markdown 时，实现以下效果：

1. 保存文件时使用 `markdownlint` 统一 Markdown 标记风格
2. 保存文件时使用 `textlint` 修复中文排版和术语问题
3. 自动在中文与英文、数字、半角字符之间补空格
4. 统一常见技术术语写法
5. 检查并禁止遗留的 `TODO`
6. 固定斜体和加粗使用 `*`，避免被改写成 `_`

## 2. 最终方案

1. `markdownlint-cli2`
   - 负责 Markdown 标题、列表、强调符号等结构和标记风格
   - 支持 `--fix` 自动修复可修复的问题
2. `textlint`
   - 负责中文技术笔记中的空格、括号、术语和 `TODO` 检查

## 3. 前提条件

需要提前安装以下 VS Code 插件：

1. [textlint](https://marketplace.visualstudio.com/items?itemName=3w36zj6.textlint)
2. [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)

此外，本地还需要可用的 `Node.js` 环境。

## 4. 初始化项目

在仓库根目录执行：

```bash
npm init -y
```

这一步会生成 `package.json`，用于记录依赖和脚本。

## 5. 安装依赖

### 本地安装

在仓库根目录执行：

```bash
npm install -D markdownlint-cli2
```

```bash
npm install -D textlint \
  textlint-rule-ja-space-between-half-and-full-width \
  textlint-rule-no-todo \
  textlint-rule-prh \
  textlint-rule-zh-half-and-full-width-bracket
```

安装完成后会生成

1. `node_modules/`
2. `package-lock.json`

### 全局安装（不推荐）

```bash
npm install -g textlint \
  textlint-rule-ja-space-between-half-and-full-width \
  textlint-rule-no-todo \
  textlint-rule-prh \
  textlint-rule-zh-half-and-full-width-bracket
```

textlint 插件需要在设置中配置 node path 才可以工作。

## 6. 配置 `markdownlint`

在仓库根目录创建 `.markdownlint-cli2.jsonc`：

```jsonc
{
  "globs": [
    "**/*.md",
    "#node_modules"
  ],
  "gitignore": ".gitignore",
  "config": {
    "line-length": false,
    "no-duplicate-heading": {
      "siblings_only": true
    },
    "no-inline-html": false,
    "no-emphasis-as-heading": true,
    "emphasis-style": {
      "style": "asterisk"
    },
    "strong-style": {
      "style": "asterisk"
    }
  }
}
```

这份配置的含义如下：

1. 默认检查仓库中的全部 Markdown 文件
2. 跟随根目录 `.gitignore` 忽略不需要的路径
3. 关闭 `MD013`，不强制限制行宽
4. 关闭 `MD033`，允许必要的内联 HTML
5. 关闭 `MD041`，不强制每个文件首行必须是一级标题
6. 使用 `MD049` 固定斜体风格为 `*`
7. 使用 `MD050` 固定加粗风格为 `*`

修改或新增配置可以参考[markdownlint 在 GitHub 中的 readme](https://github.com/DavidAnson/markdownlint)。

## 7. textlint 规则设计思路

本次选择的规则如下：

1. `ja-space-between-half-and-full-width`
   - 自动处理中文与英文、数字之间的空格
2. `zh-half-and-full-width-bracket`
   - 统一中文语境里的全角括号和英文语境里的半角括号
3. `no-todo`
   - 阻止把 `TODO` 残留到正式笔记里
4. `prh`
   - 通过自定义术语词典统一技术名词写法

## 8. 配置 textlint

在仓库根目录创建 `.textlintrc.json`：

```json
{
  "rules": {
    "ja-space-between-half-and-full-width": {
      "space": "always",
      "exceptPunctuation": true
    },
    "zh-half-and-full-width-bracket": {
      "bracket": "mixed"
    },
    "no-todo": true,
    "prh": {
      "rulePaths": ["./tech-terms.yml"],
      "checkHeader": true,
      "checkParagraph": true,
      "checkBlockQuote": true,
      "checkEmphasis": true,
      "checkLink": false
    }
  }
}
```

这份配置的含义如下：

1. 中文与英文之间强制保留空格
2. 中文内容优先使用中文全角括号，纯英文和数字内容优先使用英文半角括号
3. 遇到 `TODO` 时直接报错
4. 用独立的术语词典文件维护技术名词
5. 不检查链接内容，避免把 URL 或域名误改

## 9. 配置术语词典

在仓库根目录维护 `tech-terms.yml`，用于统一技术术语大小写和常见写法。

例如：

```md
Javascript
vscode
Github
nodejs
markdownlint
```

会被修正为：

```md
JavaScript
VS Code
GitHub
Node.js
markdownlint
```

后续如果有新的团队术语要求，只需要继续往这个 YAML 文件里追加规则即可。

## 10. package 脚本配置

可以在 `package.json` 中加入以下脚本：

```json
{
  "scripts": {
    "lint:md": "markdownlint-cli2 && textlint \"**/*.md\"",
    "lint:md:fix": "markdownlint-cli2 --fix && textlint --fix \"**/*.md\"",
    "format:md": "markdownlint-cli2 --fix"
  }
}
```

作用如下，作用域为仓库内所有 md 文件：

1. `npm run format:md`
   - 仅执行 `markdownlint-cli2 --fix`
2. `npm run lint:md`
   - 先检查 Markdown 结构和标记风格
   - 再检查中文排版和术语
3. `npm run lint:md:fix`
   - 先自动修复可修复的 Markdown 结构问题
   - 再自动修复可修复的文本问题

建议执行顺序：

```bash
npm run format:md
npm run lint:md
```

or

```bash
npm run lint:md:fix
```

## 11. VS Code 建议配置

如果希望保存时自动修复，可以在工作区或用户级 `settings.json` 中加入：

```json
{
  "[markdown]": {
    "editor.defaultFormatter": "DavidAnson.vscode-markdownlint",
  },

  // onType or onSave
  // 如果开启了自动保存，可以保持默认的 onSave
  "markdownlint.run": "onSave",
  "textlint.run": "onSave",

  // 保存时自动 fix
  "textlint.autoFixOnSave": true,

  // 限定 textlint 仅作用与 markdown
  "textlint.languages": [
      "markdown"
  ],

}
```

说明：

1. `markdownlint` 作为 Markdown 默认格式化器
2. 保存时由 `markdownlint` 处理结构类问题
3. `textlint` 继续负责中文排版和术语检查

不同版本的 VS Code 或插件对保存时自动修复的支持略有差异；如果 `textlint` 没有自动修复，可以继续使用：

```bash
npm run lint:md:fix
```

## 12. Git 管理建议

以下文件建议保留到 Git：

1. `package.json`
2. `.markdownlint-cli2.jsonc`
3. `.textlintrc.json`
4. `tech-terms.yml`

以下文件或目录不建议提交：

```gitignore
/node_modules
/package-lock.json
```

说明：

1. `node_modules/` 是安装依赖后的产物，可重复生成
2. `package-lock.json` 是安装依赖后自动生成的锁文件，用于指定依赖的版本；如果仓库不希望提交锁文件，可以继续加入 `.gitignore`

## 13. 验证方式

安装完成后，可以在仓库根目录执行：

```bash
npx markdownlint-cli2
npx textlint README.md
```

如果想验证自动修复效果，可以执行：

```bash
npx markdownlint-cli2 --fix
npx textlint --fix README.md
```

如果出现以下情况，说明配置是正常的：

1. `markdownlint-cli2` 能正常执行，没有报找不到配置文件
2. `markdownlint-cli2 --fix` 能把强调符号修正为 `*`
3. `textlint` 能正常执行，没有报找不到规则
4. `textlint --fix` 能对支持修复的规则自动改写

## 14. 常见问题

### 14.1 保存时没有生效

可以按以下顺序检查：

1. 确认打开的是项目根目录，而不是单个 Markdown 文件
2. 确认 `.markdownlint-cli2.jsonc` 已存在
3. 确认 `.textlintrc.json` 已存在
4. 确认 `tech-terms.yml` 已存在
5. 确认依赖已经安装完成
6. 在 VS Code 中执行一次 `Developer: Reload Window`

### 14.2 textlint 插件已安装，但仍然不工作

原因通常是：只安装了 VS Code 插件，但没有在当前项目里安装 `textlint` 及规则包。

需要重新执行：

```bash
npm install -D textlint \
  textlint-rule-ja-space-between-half-and-full-width \
  textlint-rule-no-todo \
  textlint-rule-prh \
  textlint-rule-zh-half-and-full-width-bracket
```

### 14.3 `markdownlint` 没有按照 `*` 风格修复

优先检查：

1. 当前使用的是不是 `markdownlint`，而不是 `Prettier`
2. `.markdownlint-cli2.jsonc` 中是否已经配置 `MD049.style = "asterisk"`
3. VS Code 的 Markdown 默认格式化器是否仍然指向 `Prettier`

### 14.4 为什么不用 `Prettier`

Prettier 不再支持盘古之白。

### 14.5 第一次执行 `lint:md` 为什么会报很多历史问题

这是正常现象。

`markdownlint` 接入后，会把仓库里原有 Markdown 文件中的重复标题、制表符、多余空行、裸链接等问题一起暴露出来。

这说明规则已经生效，不代表安装失败。通常有两种处理方式：

1. 先只把它用于新文档或正在维护的文档
2. 分目录逐步清理历史文件

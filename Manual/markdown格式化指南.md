# Markdown 格式化指南

## 1. 目标

在 VS Code 中编辑 Markdown 时，实现以下效果：

1. 保存文件时自动执行 `Prettier` 格式化
2. 保存文件时自动执行 `textlint` 修复
3. 自动在中文与英文、数字、半角字符之间补空格
4. 统一常见技术术语写法
5. 检查并禁止遗留的 `TODO`
6. 规范中文场景下的中英文括号使用

## 2. 前提条件

需要提前安装以下 VS Code 插件：

1. `Prettier - Code formatter`
2. `vscode-textlint`

此外，本地还需要可用的 `Node.js` 和 `npm` 环境。

## 3. 初始化项目

在仓库根目录执行：

```bash
npm init -y
```

这一步会生成 `package.json`，用于记录依赖和脚本。

## 4. 安装依赖

在仓库根目录执行：

```bash
npm install -D prettier textlint \
  textlint-rule-ja-space-between-half-and-full-width \
  textlint-rule-no-todo \
  textlint-rule-prh \
  textlint-rule-zh-half-and-full-width-bracket
```

安装完成后会生成：

1. `node_modules/`
2. `package-lock.json`

## 5. textlint 规则设计思路

这套规则专门面向中文技术笔记，目标是“高收益、低打扰”。

本次选择的规则如下：

1. `ja-space-between-half-and-full-width`
   - 自动处理中文与英文、数字之间的空格
2. `zh-half-and-full-width-bracket`
   - 统一中文语境里的全角括号和英文语境里的半角括号
3. `no-todo`
   - 阻止把 `TODO` 残留到正式笔记里
4. `prh`
   - 通过自定义术语词典统一技术名词写法

没有加入很多“写作风格类”规则，是为了避免在技术笔记场景下产生过多误报。

## 6. 配置 textlint

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

## 7. 配置术语词典

在仓库根目录创建 `tech-terms.yml`：

```yaml
version: 1
rules:
  - expected: JavaScript
    patterns:
      - Javascript
      - javascript

  - expected: TypeScript
    patterns:
      - Typescript
      - typescript

  - expected: Node.js
    patterns:
      - NodeJS
      - Nodejs
      - nodejs
      - node.js

  - expected: npm
    patterns:
      - NPM

  - expected: pnpm
    patterns:
      - PNPM
      - Pnpm

  - expected: VS Code
    patterns:
      - VSCode
      - vscode
      - VScode

  - expected: GitHub
    patterns:
      - Github
      - github

  - expected: Markdown
    patterns:
      - markdown

  - expected: textlint
    patterns:
      - Textlint

  - expected: Prettier
    patterns:
      - prettier

  - expected: macOS
    patterns:
      - MacOS
      - Macos

  - expected: Linux
    patterns:
      - linux

  - expected: API
    patterns:
      - api

  - expected: URL
    patterns:
      - url

  - expected: JSON
    patterns:
      - json

  - expected: YAML
    patterns:
      - yml
      - yaml
```

这份词典主要做两件事：

1. 统一技术术语大小写
2. 自动把常见错误写法替换为推荐写法

目前已经覆盖这类仓库里高频出现的术语：

1. 前端与通用开发：`JavaScript`、`TypeScript`、`Node.js`、`npm`、`pnpm`、`VS Code`、`GitHub`
2. 构建与编译：`CMake`、`GCC`、`GDB`、`GNU`
3. 系统与环境：`Linux`、`Windows`、`macOS`、`Ubuntu`、`Debian`、`CentOS`
4. 网络与服务：`HTTP`、`HTTPS`、`SSH`、`WebSocket`、`Nginx`
5. 嵌入式与音视频：`SDK`、`U-Boot`、`WebRTC`、`RTMP`、`FreeRTOS`、`FreeType`、`SDL`、`SDL_ttf`
6. 数据与 AI：`JSON`、`YAML`、`MySQL`、`Redis`、`OpenAI`、`ChatGPT`

例如：

```md
Javascript
vscode
Github
nodejs
markdown
```

会被修正为：

```md
JavaScript
VS Code
GitHub
Node.js
Markdown
```

后续如果有新的团队术语要求，只需要继续往这个 YAML 文件里追加规则即可。

## 8. 配置 Prettier

在仓库根目录创建 `.prettierrc.json`：

```json
{
  "proseWrap": "preserve",
  "singleQuote": false
}
```

这里的配置含义：

1. `proseWrap: "preserve"` 表示尽量保留现有 Markdown 段落换行
2. `singleQuote: false` 表示使用双引号

## 9. package 脚本配置

可以在 `package.json` 中加入以下脚本：

```json
{
  "scripts": {
    "lint:md": "textlint \"**/*.md\"",
    "lint:md:fix": "textlint --fix \"**/*.md\"",
    "format:md": "prettier --write \"**/*.md\""
  }
}
```

作用如下：

1. `npm run lint:md`：检查所有 Markdown 文件
2. `npm run lint:md:fix`：自动修复可修复的文本问题
3. `npm run format:md`：使用 `Prettier` 格式化所有 Markdown 文件

建议执行顺序：

```bash
npm run format:md
npm run lint:md:fix
```

## 10. Git 管理建议

以下文件建议保留到 Git：

1. `package.json`
2. `.textlintrc.json`
3. `tech-terms.yml`
4. `.prettierrc.json`

以下文件或目录不建议提交：

```gitignore
/node_modules
/package-lock.json
```

说明：

1. `node_modules/` 是安装依赖后的产物，可重复生成
2. `package-lock.json` 也是安装依赖后自动生成的锁文件，如果仓库不希望提交锁文件，可以加入 `.gitignore`

## 11. 验证方式

安装完成后，可以在仓库根目录执行：

```bash
npx textlint README.md
npx prettier --check README.md
```

如果想验证自动修复效果，可以执行：

```bash
npx textlint --fix README.md
```

如果出现以下情况，说明配置是正常的：

1. `textlint` 能正常执行，没有报找不到配置或规则
2. `Prettier --check` 能检查出文件是否需要格式化
3. `textlint --fix` 能对支持修复的规则自动改写

## 12. 常见问题

### 12.1 保存时没有生效

可以按以下顺序检查：

1. 确认打开的是项目根目录，而不是单个 Markdown 文件
2. 确认 `.textlintrc.json` 已存在
3. 确认 `tech-terms.yml` 已存在
4. 确认依赖已经安装完成
5. 在 VS Code 中执行一次 `Developer: Reload Window`

### 12.2 textlint 插件已安装，但仍然不工作

原因通常是：只安装了 VS Code 插件，但没有在当前项目里安装 `textlint` 及规则包。

需要重新执行：

```bash
npm install -D prettier textlint \
  textlint-rule-ja-space-between-half-and-full-width \
  textlint-rule-no-todo \
  textlint-rule-prh \
  textlint-rule-zh-half-and-full-width-bracket
```

### 12.3 想扩展更多术语

直接修改 `tech-terms.yml` 即可。

建议优先追加以下类型的术语：

1. 技术名词大小写
2. 品牌名和产品名
3. 团队内部约定写法
4. 常见拼写错误

### 12.4 为什么不用很多“语气类”或“文风类”规则

技术笔记和产品文案不同。

技术笔记通常包含：

1. 命令
2. 配置项
3. 版本号
4. 缩写
5. 大量专有名词

如果规则过多，误报会明显上升，反而影响写作效率。所以这套配置优先保留：

1. 排版一致性
2. 术语一致性
3. 明显问题拦截

## 13. 本仓库最终使用的文件

本次配置完成后，仓库中实际新增或修改了以下文件：

1. `package.json`
2. `.textlintrc.json`
3. `tech-terms.yml`
4. `.prettierrc.json`
5. `.gitignore`

其中依赖安装后自动生成但不需要保存在 Git 中的文件包括：

1. `node_modules/`
2. `package-lock.json`

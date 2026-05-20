# 回退 commit

在 Git 中，如果你想回退未 push 的本地 commit，有几种方法可以实现，具体取决于你希望如何处理这些更改。以下是几种常见的方法：

## 1. 使用 `git reset`

`git reset` 是一种常见的方法，用于回退到某个特定的 commit。它会移动当前分支指针，因此适合处理还没有 push 的本地 commit。

常用模式有三种：

- `--soft`：回退 commit，但保留暂存区和工作区的更改。
- `--mixed`：回退 commit，清空暂存区，但保留工作区的更改。它也是 `git reset` 的默认模式。
- `--hard`：回退 commit，清空暂存区，并丢弃工作区的更改。

三种模式的区别可以这样看：

| 命令 | commit | 暂存区 | 工作区 |
| --- | --- | --- | --- |
| `git reset --soft HEAD~1` | 回退 | 保留 | 保留 |
| `git reset --mixed HEAD~1` | 回退 | 清空 | 保留 |
| `git reset --hard HEAD~1` | 回退 | 清空 | 清空 |

比如你想回退到上一个 commit，但保留改动并继续放在暂存区：

```sh
git reset --soft HEAD~1  # 回退到上一个 commit，但保留更改
```

如果想回退到上一个 commit，并把改动放回工作区：

```sh
git reset HEAD~1
```

上面的命令等价于：

```sh
git reset --mixed HEAD~1
```

如果想彻底丢弃上一个 commit 里的改动：

```sh
git reset --hard HEAD~1  # 回退到上一个 commit，并丢弃更改
```

### 1.1 取消暂存文件

`git reset` 也可以只用来取消暂存，不回退 commit。比如已经执行了 `git add`，但想把某个文件从暂存区拿出来：

```sh
git reset HEAD <file>
```

这个命令不会删除工作区里的文件改动，只是撤销这次 `git add`。

### 1.2 找回误 reset 的 commit

如果误用了 `git reset --hard`，可以先看 `reflog`：

```sh
git reflog
```

`reflog` 会记录 HEAD 的移动历史。找到 reset 之前的 commit 后，可以再 reset 回去：

```sh
git reset --hard <commit-id>
```

这个方法只能找回 Git 仍然记录着的历史。发现误操作后，先不要继续做大量提交、清理或垃圾回收操作。

## 2. 使用 `git revert`

`git revert` 是另外一种回退方法，它会**生成一个新的 commit**，用于撤销指定的 commit。多用于已经与其他人共享的 commit。它不会重写历史，因此比 `reset` 更适合公共分支。

比如你想撤销上一个 commit：

```sh
git revert HEAD  # 生成一个新的 commit，撤销上一个 commit 的更改
```

也可以撤销指定 commit：

```sh
git revert <commit-id>
```

### 2.1 revert 多个 commit

如果想连续撤销多个 commit，可以使用范围：

```sh
git revert HEAD~3..HEAD
```

这个命令会撤销从 `HEAD~3` 之后到 `HEAD` 的提交，不包含 `HEAD~3` 本身。

也可以直接指定多个 commit：

```sh
git revert <commit-a> <commit-b>
```

### 2.2 只生成改动，不立刻提交

默认情况下，`git revert` 会自动生成新的 commit。如果想先把回退改动放到工作区，自己检查后再提交，可以加 `--no-commit`：

```sh
git revert --no-commit <commit-id>
```

也可以使用简写：

```sh
git revert -n <commit-id>
```

这个方式适合一次性撤销多个 commit，然后整理成一个新的 commit：

```sh
git revert -n <commit-a>
git revert -n <commit-b>
git commit -m "revert broken changes"
```

### 2.3 revert merge commit

如果要 revert 一个 merge commit，需要用 `-m` 指定主线父提交：

```sh
git revert -m 1 <merge-commit-id>
```

`-m 1` 表示保留第一个父提交所在的主线，撤销另一个分支合进来的改动。这个操作要谨慎，因为它会影响后续再次合并同一个分支时的结果。

执行前可以先查看 merge commit 的父提交：

```sh
git show --no-patch --pretty=%P <merge-commit-id>
```

输出里的父提交顺序决定了 `-m 1`、`-m 2` 分别指向哪条线。

### 2.4 撤销一次 revert

`revert` 本身也是一个普通 commit。如果回退错了，可以再 revert 这个 revert commit：

```sh
git revert <revert-commit-id>
```

这相当于把之前撤销掉的改动重新加回来。

## 3. 修改历史提交：使用 `git rebase -i`

如果你有多个未 push 的本地 commit，并且想要修改、合并、拆分或删除其中的一些，可以使用交互式 rebase。它会重写 commit 历史，因此更适合处理还没有共享给别人的本地提交。

常用命令如下：

```sh
git rebase -i HEAD~N  # 编辑最近 N 个 commit
```

也可以从指定 commit 之后开始整理：

```sh
git rebase -i <commit-id>
```

这里的 `<commit-id>` 不会被修改，Git 会打开它之后的提交列表。如果想整理从项目第一个 commit 开始的历史，可以用：

```sh
git rebase -i --root
```

执行后，Git 会打开一个编辑器，内容大致如下：

```text
pick a1b2c3d add login page
pick b2c3d4e fix login style
pick c3d4e5f update README
```

每一行代表一个 commit。你可以修改行首的命令，也可以调整行的顺序。常用命令有：

- `pick`：保留这个 commit。
- `reword`：保留这个 commit 的改动，但重新编辑 commit message。
- `edit`：暂停在这个 commit，方便继续修改、补文件或拆分 commit。
- `squash`：把这个 commit 合并到前一个 commit，并重新编辑 commit message。
- `fixup`：把这个 commit 合并到前一个 commit，并丢弃当前 commit message。
- `drop`：删除这个 commit。

修改完成后保存并退出编辑器，Git 会按新的顺序重新应用这些 commit。如果中间没有冲突，rebase 会直接完成。

### 3.1 修改 commit message

如果只想修改某个历史 commit 的 message，把对应行的 `pick` 改成 `reword`：

```text
reword a1b2c3d add login page
pick b2c3d4e fix login style
```

保存后，Git 会再次打开编辑器，让你输入新的 commit message。改完保存即可。

### 3.2 合并多个 commit

如果想把几个零散 commit 合并成一个，可以保留第一个 commit 的 `pick`，把后面的 commit 改成 `squash` 或 `fixup`：

```text
pick a1b2c3d add login page
fixup b2c3d4e fix login style
squash c3d4e5f adjust login copy
```

`squash` 会让你重新整理 commit message，`fixup` 会直接丢弃被合并 commit 的 message。日常整理本地提交时，如果后面的提交只是修 typo、补样式、修小错误，通常用 `fixup` 更省事。

### 3.3 删除某个 commit

如果想删除某个 commit，可以把它前面的 `pick` 改成 `drop`：

```text
pick a1b2c3d add login page
drop b2c3d4e debug login API
pick c3d4e5f update README
```

也可以直接删除这一整行。两种方式的效果相同，但 `drop` 更明确，回头看操作记录时也更容易判断意图。

### 3.4 拆分一个 commit

如果一个 commit 里混了几类改动，可以用 `edit` 暂停在这个 commit，再把它拆成多个新 commit。

先启动交互式 rebase：

```sh
git rebase -i HEAD~N
```

把要拆分的 commit 改成 `edit`：

```text
pick a1b2c3d add login page
edit b2c3d4e add login API and docs
pick c3d4e5f update README
```

保存后，Git 会停在这个 commit。此时执行：

```sh
git reset HEAD^
```

这个命令会撤销当前 commit，但保留文件改动。接着按你想要的粒度重新 `add` 和 `commit`：

```sh
git add path/to/api-file
git commit -m "add login API"

git add path/to/doc-file
git commit -m "add login docs"
```

拆分完成后继续 rebase：

```sh
git rebase --continue
```

### 3.5 处理 rebase 冲突

rebase 过程中如果遇到冲突，Git 会停下来。先查看冲突文件：

```sh
git status
```

解决冲突后，把文件重新加入暂存区：

```sh
git add <file>
```

然后继续：

```sh
git rebase --continue
```

如果发现这次 rebase 不应该继续，可以放弃整个 rebase，回到开始之前的状态：

```sh
git rebase --abort
```

如果当前这个 commit 可以跳过，可以使用：

```sh
git rebase --skip
```

`--skip` 会丢掉当前正在应用的 commit，使用前要确认这个 commit 的改动确实不需要了。

### 3.6 把当前分支变基到最新主分支

`git rebase` 也常用于把当前分支的提交挪到最新的主分支之后。比如当前在 feature 分支上，可以这样做：

```sh
git fetch origin
git rebase origin/main
```

这会先取回远端更新，再把当前分支上独有的 commit 重新应用到 `origin/main` 后面。相比 merge，它不会额外生成一个 merge commit，提交历史会更线性。

### 3.7 rebase 前后的安全习惯

rebase 会重写 commit hash。操作前可以先建一个备份分支：

```sh
git branch backup/before-rebase
```

如果 rebase 后已经 push 过的分支需要同步到远端，不要直接用 `git push --force`，优先用：

```sh
git push --force-with-lease
```

`--force-with-lease` 会先确认远端分支没有被别人更新，再执行强制推送，比 `--force` 更安全。

如果这些 commit 已经被别人基于它们继续开发，尽量不要 rebase。此时更适合用 `git revert` 生成新的回退 commit，避免影响其他人的历史。

## 总结

选择哪种方法取决于你对更改的处理方式：

- 如果你只是想回退到某个 commit，可以使用 `git reset`。
- 如果你要回退已经 push 或多人共享的 commit，可以使用 `git revert`。
- 如果你需要修改多个 commit 的历史记录，可以使用 `git rebase -i`。

请注意，`git reset --hard` 会丢失未提交的更改，`git rebase` 会重写 commit 历史。操作前先确认这些改动是否已经共享给别人。

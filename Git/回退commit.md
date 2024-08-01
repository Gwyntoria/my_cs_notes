# 回退 commit

在 Git 中，如果你想回退未 push 的本地 commit，有几种方法可以实现，具体取决于你希望如何处理这些更改。以下是几种常见的方法：

## 1. 使用 `git reset`

`git reset` 是一种常见的方法，用于回退到某个特定的 commit。它有两种常用模式：`--soft` 和 `--hard`。

- `--soft`：回退到指定的 commit，但保留工作区的更改。
- `--hard`：回退到指定的 commit，并丢弃工作区的所有更改。

例如，假设你想回退到上一个 commit：

```sh
git reset --soft HEAD~1  # 回退到上一个commit，但保留更改
```

```sh
git reset --hard HEAD~1  # 回退到上一个commit，并丢弃更改
```

## 2. 使用 `git revert`

`git revert` 是另外一种回退方法，它会**生成一个新的 commit**，用于撤销指定的 commit。多于已经与其他人共享的 commit。

例如，假设你想撤销上一个 commit：

```sh
git revert HEAD  # 生成一个新的commit，撤销上一个commit的更改
```

## 3. 修改历史提交：使用 `git rebase -i`

如果你有多个未 push 的本地 commit，并且想要修改、合并或删除其中的一些，可以使用交互式 rebase。

```sh
git rebase -i HEAD~N  # N 是要回退的commit数量
```

这会打开一个编辑器，显示最近的 N 个 commit。你可以通过修改这些 commit 前的命令来调整历史记录。

例如，如果你想删除最近的一个 commit，可以将其前面的`pick`改为`drop`。

## 总结

选择哪种方法取决于你对更改的处理方式：

- 如果你只是想回退到某个 commit，可以使用 `git reset`。
- 如果你希望生成一个新的 commit 来撤销更改，可以使用 `git revert`。
- 如果你需要修改多个 commit 的历史记录，可以使用 `git rebase -i`。

请注意，`git reset --hard` 会丢失未提交的更改，请谨慎使用。

# Linux 补丁—— `diff` 和 `patch`

## `diff`——生成补丁文件

```bash
diff original.txt updated.txt > update.patch
```

## `patch`——执行补丁文件

```bash
patch original.txt -i update.patch -o updated-1.txt
```

## Reversed Patch 相关

Reversed (or previously applied) patch detected! Assume -R? [n]

默认为 no

输入 yes 则将内容还原成打补丁之前

## Reference

1. [Linux中的Diff和Patch](https://juejin.cn/post/6963434347856658439)
2. [patch补丁文件格式](https://blog.csdn.net/sunxiaopengsun/article/details/114031738)

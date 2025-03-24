# Python 中 list 的使用方法详解与常用函数参数说明

Python 的 `list`（列表）是一种内置的可变序列类型，用于存储有序的数据集合。列表可以包含任意类型的元素，且支持嵌套结构。本文将系统地介绍列表的基本使用方法以及常用函数和方法的参数详解，帮助开发者更高效地操作列表。

## 一、列表的定义与基本操作

### 1. 创建列表

```python
# 创建空列表
empty_list = []

# 创建带有元素的列表
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True]
nested = [[1, 2], [3, 4]]
```

### 2. 访问元素

```python
# 通过索引访问（从 0 开始）
print(numbers[0])     # 输出 1
print(numbers[-1])    # 输出 5（负数表示从末尾开始计数）
```

### 3. 修改元素

```python
numbers[1] = 20
print(numbers)  # [1, 20, 3, 4, 5]
```

### 4. 删除元素

```python
del numbers[2]        # 删除索引为 2 的元素
numbers.remove(4)     # 删除值为 4 的第一个匹配项
value = numbers.pop() # 弹出最后一个元素
```

## 二、列表的常用方法及参数详解

### 1. `append(obj)`

在列表末尾追加元素。

```python
numbers.append(6)
```

- **参数说明**：`obj` 为要添加的单个对象，支持任意类型。
- **注意**：不会返回新列表，而是在原列表上修改。

### 2. `extend(iterable)`

将一个可迭代对象中的所有元素添加到列表末尾。

```python
numbers.extend([7, 8])
```

- **参数说明**：`iterable` 可以是列表、元组、字符串等。
- 与 `append([7, 8])` 的区别是：`extend` 会展开元素，而 `append` 是将整个对象作为一个元素加入。

### 3. `insert(index, obj)`

在指定位置插入元素。

```python
numbers.insert(2, 99)
```

- **index**：插入位置的索引。若超出范围，将在开头或末尾插入。
- **obj**：要插入的对象。

### 4. `remove(obj)`

移除列表中第一个匹配的指定元素。

```python
numbers.remove(99)
```

- **参数说明**：要删除的元素值。
- 若元素不存在，将抛出 `ValueError`。

### 5. `pop([index])`

移除并返回指定位置的元素，若未指定索引则默认最后一个。

```python
last_item = numbers.pop()
```

- **index**（可选）：要弹出的元素索引。
- 返回值：被移除的元素。

### 6. `clear()`

清空列表。

```python
numbers.clear()
```

- 无参数，作用等同于 `del numbers[:]`。

### 7. `index(obj[, start[, end]])`

返回列表中第一个匹配值的索引。

```python
idx = [1, 2, 3, 2].index(2)  # 1
```

- **obj**：查找的值。
- **start, end**（可选）：搜索的起止区间。

### 8. `count(obj)`

统计某个元素在列表中出现的次数。

```python
[1, 2, 2, 3].count(2)  # 输出 2
```

### 9. `sort(*, key=None, reverse=False)`

对列表进行原地排序。

```python
numbers.sort()
numbers.sort(reverse=True)
```

- **key**：函数，用于从元素中提取用于排序的关键字。
- **reverse**：是否反向排序，默认为 `False`。

示例：按字符串长度排序

```python
words = ["apple", "banana", "fig"]
words.sort(key=len)
```

### 10. `sorted(iterable, *, key=None, reverse=False)`

返回一个排序后的新列表，原对象不变。

```python
new_list = sorted(numbers)
```

与 `sort()` 区别：`sorted()` 是全局函数，适用于任何可迭代对象，且不改变原始数据。

### 11. `reverse()`

反转列表中的元素（原地修改）。

```python
numbers.reverse()
```

### 12. `copy()`

返回列表的浅拷贝。

```python
copy_list = numbers.copy()
```

等效于 `numbers[:]` 或使用 `list(numbers)`。

## 三、列表推导式（List Comprehension）

一种简洁表达式用于构造列表。

```python
# 创建平方列表
squares = [x**2 for x in range(5)]  # [0, 1, 4, 9, 16]

# 带条件过滤
even_squares = [x**2 for x in range(10) if x % 2 == 0]
```

## 四、列表与内置函数的结合使用

| 函数 | 作用 |
|-||
| `len()` | 返回列表长度 |
| `sum()` | 返回所有元素的总和 |
| `max()` | 返回最大元素 |
| `min()` | 返回最小元素 |
| `any()` | 至少有一个元素为真返回 True |
| `all()` | 所有元素为真返回 True |
| `zip()` | 将多个列表打包成元组序列 |
| `enumerate()` | 返回索引和值的迭代器 |

## 五、补充说明

在性能敏感或数据结构复杂的场景下，还可以结合生成器、`deque` 或 NumPy 数组等工具进一步优化。

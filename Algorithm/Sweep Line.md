# Sweep Line

以下是关于 Sweep Line（扫描线）算法的博客大纲与详细内容，包含原理、常见应用场景、Python 示例代码以及相关 LeetCode 题目推荐：

## 二、正文

### 引言

在处理与几何、区间、事件相关的问题时，常规的暴力或排序方式往往效率不足。此时，扫描线算法（Sweep Line Algorithm）提供了一种高效的处理方式。它通过一条“线”从一个方向（通常是从左到右或从上到下）扫描整个平面，在扫描过程中按顺序处理所有“事件点”，并动态维护当前活动的对象集合。

### 算法原理

#### 扫描线的核心思想

- 将二维或区间问题转化为一维问题：例如从左到右遍历所有重要“事件点”。
- 每一个事件点通常代表某个图形或区间的起点或终点。
- 事件按照某一主轴（如 x 轴）排序，从左至右逐一处理。
- 在每个事件点更新活动集合（active set），并通过合适的数据结构快速计算当前状态下的答案。

#### 事件驱动

每个事件通常包含以下内容：

```python
Event = (x, type, y1, y2)
# x: 扫描线的位置
# type: 1表示矩形开始，-1表示结束
# y1, y2: 表示活动区间
```

#### 数据结构支持

- **SortedList/TreeSet**：维护活动对象的有序集合，用于快速查找、插入、删除。
- **堆**：用于处理最早结束的对象。
- **线段树或树状数组**：高效维护区间信息，如总长度、数量等。

### 经典应用场景与 Python 示例

#### 场景 1：计算矩形并集的面积（线段树支持）

**问题描述**：给定若干个矩形，计算它们的并集面积。

```python
from collections import defaultdict
from bisect import bisect_left
from itertools import chain

class SegmentTree:
    def __init__(self, y_coords):
        self.n = len(y_coords) - 1
        self.y_coords = y_coords
        self.tree = [0] * (self.n * 4)
        self.count = [0] * (self.n * 4)

    def update(self, node, l, r, ul, ur, val):
        if ur <= l or r <= ul:
            return
        if ul <= l and r <= ur:
            self.count[node] += val
        else:
            mid = (l + r) // 2
            self.update(node * 2, l, mid, ul, ur, val)
            self.update(node * 2 + 1, mid, r, ul, ur, val)

        if self.count[node]:
            self.tree[node] = self.y_coords[r] - self.y_coords[l]
        else:
            self.tree[node] = self.tree[node * 2] + self.tree[node * 2 + 1]

    def query(self):
        return self.tree[1]

def rectangleArea(rectangles):
    MOD = 10 ** 9 + 7
    events = []
    y_coords = set()

    for x1, y1, x2, y2 in rectangles:
        events.append((x1, 1, y1, y2))  # entering
        events.append((x2, -1, y1, y2))  # leaving
        y_coords.add(y1)
        y_coords.add(y2)

    y_list = sorted(y_coords)
    y_i = {y: i for i, y in enumerate(y_list)}
    events.sort()

    tree = SegmentTree(y_list)
    cur_x = 0
    cur_y_sum = 0
    result = 0

    for x, typ, y1, y2 in events:
        result += (x - cur_x) * cur_y_sum
        result %= MOD
        tree.update(1, 0, tree.n, y_i[y1], y_i[y2], typ)
        cur_x = x
        cur_y_sum = tree.query()

    return result
```

#### 场景 2：合并区间并计算长度

```python
def get_total_covered_length(intervals):
    events = []
    for start, end in intervals:
        events.append((start, 1))
        events.append((end, -1))

    events.sort()
    count = 0
    prev = 0
    total = 0

    for x, typ in events:
        if count > 0:
            total += x - prev
        count += typ
        prev = x

    return total
```

#### 场景 3：检测线段是否相交（带 y 坐标排序）

使用 `SortedList` 动态维护活动线段。可用于判断是否存在交点。

## LeetCode 题目推荐（使用扫描线算法）

1. **[850. Rectangle Area II](https://leetcode.com/problems/rectangle-area-ii/)**

   - 典型矩形并集面积计算，结合线段树。

2. **[218. The Skyline Problem](https://leetcode.com/problems/the-skyline-problem/)**

   - 使用扫描线和堆，动态维护当前“最高楼”。

3. **[56. Merge Intervals](https://leetcode.com/problems/merge-intervals/)**

   - 可用扫描线变体实现区间合并。

4. **[391. Perfect Rectangle](https://leetcode.com/problems/perfect-rectangle/)**

   - 判断矩形是否完美覆盖，涉及事件排序与边界检测。

5. **[759. Employee Free Time](https://leetcode.com/problems/employee-free-time/)**
   - 多人时间区间合并，扫描线找空闲段。

## 与其他区间处理算法的对比分析

虽然扫描线是处理区间与二维事件问题的强大工具，但它并非唯一选择。在实际问题中，差分数组、滑动窗口、前缀和等技巧也能处理一类区间问题。以下是它们在关键维度上的对比：

| 特性/算法      | 扫描线（Sweep Line）              | 差分数组（Difference Array） | 滑动窗口（Sliding Window） | 线段树/树状数组            |
| -------------- | --------------------------------- | ---------------------------- | -------------------------- | -------------------------- |
| 适用问题类型   | 区间合并、二维/多维几何、事件排序 | 区间加、前缀和、计数型问题   | 窗口最值、连续子数组问题   | 区间查询、区间更新         |
| 数据结构依赖   | SortedList, Segment Tree, Heap    | 数组                         | 队列、双端队列             | 线段树/树状数组            |
| 是否离散化依赖 | 是（多数场景需要）                | 通常不需要（数组坐标下操作） | 否                         | 是（非整数坐标需离散化）   |
| 时间复杂度     | 通常为 O(N log N)                 | O(N)                         | O(N)                       | O(log N) 单次操作          |
| 空间复杂度     | 取决于事件数与辅助结构            | O(N)                         | O(K) （K 为窗口大小）      | O(N)                       |
| 多维支持       | 强（适用于二维、三维）            | 弱（主要是一维）             | 弱（主要是一维）           | 中等（扩展为二维树较复杂） |
| 常见用途       | 面积并、区间合并、矩形重叠        | 计数区间、区间频率           | 连续子序列、最大/最小窗口  | 多区间快速查询、计数统计   |

### 场景选择建议

- **当问题是事件驱动型、涉及排序处理区间开始/结束时，选择扫描线。**
- **当问题目标是对一段区间统一+1/-1 或累积统计时，优选差分数组。**
- **滑动窗口适用于连续子段、固定宽度窗口的问题。**
- **当需要动态更新/查询某一区间值或统计属性时，使用线段树或树状数组。**

## 总结与扩展

- **优点**：适合处理涉及区间、矩形、事件驱动的问题，效率高。
- **挑战**：需要对数据结构掌握扎实，边界处理细节复杂。
- **扩展方向**：
  - 多维扫描线（如三维空间）
  - 可持久化扫描线结构
  - 与差分数组、线段树的结合优化

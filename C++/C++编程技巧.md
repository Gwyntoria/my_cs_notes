# C++编程技巧

## Design Philosophy of C++

- Only add features if they solve an actual problem
- Programmers should be free to choose their own style
- Compartmentalization is key
- Allow the programmer full control if they want it
- Don’t sacrifice performance except as a last resort
- Enforce safety at compile time whenever possible

## 判断浮点数a、b是否相等

不应直接使用 a==b 来判断是否相等，应该判断两者之间**差的绝对值**是否小于一个足够小的阈值，如 1e-9：

```C++
if (fabs(a - b) < 1e-9){
    ......
}
```

## 判断一个数是否为奇数

```C++
if (a % 2 == 1){
    ......
}
```

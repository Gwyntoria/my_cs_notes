# lambda 表达式

C++11 引入了 lambda 表达式，它是一种方便的方式来创建匿名函数对象，通常用于简化代码和增加代码可读性。

lambda 表达式允许你在需要函数对象的地方内联定义函数，而不必显式地编写一个完整的函数。

## 基本语法

```c++
[capture list] (parameters) -> return_type { body }
```

- Capture List（捕获列表）: 指定 lambda 表达式访问的外部变量。可以通过值捕获或引用捕获。捕获列表是可选的，如果 lambda 函数体内没有使用任何外部变量，则可以省略。
- Parameters（参数）: 指定 lambda 函数的参数列表。与普通函数的参数列表一样，可以为空。
- Return Type（返回类型）: 指定 lambda 函数的返回类型。如果 lambda 函数体中只有一条 return 语句，并且可以推断出返回类型，则可以省略。
- Body（函数体）: 包含 lambda 函数执行的代码块。

## 示例

```c++
#include <iostream>

int main() {
    // Lambda function that takes two integers and returns their sum
    auto sum = [](int a, int b) -> int {
        return a + b;
    };

    // Call the lambda function and print the result
    std::cout << "Sum: " << sum(3, 5) << std::endl;

    return 0;
}
```

在这个例子中，

- []是捕获列表，表示未捕获任何外部变量
- (int a, int b)是参数列表
- -> int 指定了返回类型为 int
- { return a + b; }是 lambda 函数体，计算两个参数的和

## lambda 表达式的特点

- 方便性：允许在需要函数对象的地方内联定义函数，避免了显式地定义命名函数或函数对象的麻烦。
- 简洁性：可以大大减少代码量，特别是在使用标准算法和 STL 时，lambda 表达式能够让代码更加简洁。
- 灵活性：可以方便地捕获外部变量，并根据需要进行值捕获或引用捕获。
- 可读性：能够使代码更加易读，尤其是在函数对象的逻辑相对简单的情况下，将函数逻辑直接写在调用处更易理解。

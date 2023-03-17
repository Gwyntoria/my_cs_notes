# Types and Structs

## C++

### Basic syntax

- Semicolons at EOL
- Primitive types (int,  double, char etc)
- Basic grammar rules

### the STL

- Tons of general  functionality
- Built in classes like maps, sets, vectors
- Accessed through the namespace std::
- Extremely powerful and well-maintained

## Namespaces

- MANY things are in the  `std::` namespace
  - **std::cout**, **std::cin**, **std::lower_bound**
- DON’T always use the `using namespace std;` declaration

## C++ is a statically typed language

- **statically typed:** everything  with a name (variables,  functions, etc) is given a  type **before runtime**
- **static typing** helps us to  prevent errors **before our  code runs**

## Struct

**Definition:** a group of named  variables each with their  own type. **A way to bundle  different types together**.

```C++
// struct definition
struct Student {
    string name; // these are called fields
    string state; // separate these by semicolons
    int age;
};
```

```C++
// struct declaration and initialization
Student s;
s.name = "Frankie"; 
s.state = "MN";
s.age = 21; // use . to access fields

// is the same as
Student s = {"Frankie", "MN", 21};
```

```C++
// 操作struct类型变量的方法
void printStudentInfo(Student student) {
    cout << student.name << " from " << student.state;
    cout << " (" << student.age << ")" << endl;
}
```

## std::pair

**Definition:** An STL built-in struct with two fields of any type.

- `std::pair` is a **template**: You specify the types of the fields  inside <> for each pair object you make
- The fields in `std::pair` are named **first** and **second**

```C++
std::pair<int, string> numSuffix = {1,"st"};
std::cout << numSuffix.first << numSuffix.second;
```

To avoid specifying the types of pair, use `std::make_pair(field1, field2)`

```C++
int n = 1;
int a[5] = {1, 2, 3, 4, 5};

// build a pair from two ints
auto p1 = std::make_pair(n, a[1]);
std::cout << "The value of p1 is "
          << "(" << p1.first << ", " << p1.second << ")\n";

// build a pair from a reference to int and an array (decayed to pointer)
auto p2 = std::make_pair(std::ref(n), a);
n = 7;
std::cout << "The value of p2 is "
          << "(" << p2.first << ", " << *(p2.second + 2) << ")\n";
```

## Type Deduction with `auto`

**Definition:** `auto` is a KEYWORD used in lieu of type when declaring a variable, tells the compilers to deduce the type.

```C++
auto a = 3;
auto a = 3.14;
auto str = "Karl Meng";
auto com_pair = std::make_pair(true, "Hangzhou"); 
```

:star: ==auto== **does not mean that the variable doesn’t have a type**. It means that the type is **deduced** by the **compiler**.

## Recapitulation

- Everything with a name in program has a **type**
- **Strong type systems** prevent errors before your code runs!
- **Structs** are a way to bundle a bunch of variables of many types
- `std::pair` is a type of struct that had been defined for you and is in the STL
- So you access it through the `std::` namespace (std::pair)
- `auto` is a keyword that tells the compiler to deduce the type of a variable, it should be used when the type is obvious or very  cumbersome to write out

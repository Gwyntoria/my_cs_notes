# Initialization & References

 Two ways to initialize a struct：

```C++
Student s;
s.name = "Frankie"; 
s.state = "MN";
s.age = 21; 

//is the same as ...
Student s = {"Frankie", "MN", 21};
```

Multiple ways to initialize a pair:

```C++
std::pair<int, string> numSuffix1 = {1,"st"};

std::pair<int, string> numSuffix2;
numSuffix2.first = 2;
numSuffix2.second = "nd";

std::pair<int, string> numSuffix2 = std::make_pair(3, "rd");
```

Initialization of vectors:

```C++
std::vector<int> vec1(3,5); 
// makes {5, 5, 5}, not {3, 5}!

std::vector<int> vec2;
vec2 = {3,5};
// initialize vec2 to {3, 5} after its declared
```

## Uniform Initialization

**Definition:** curly bracket initialization. Available for all types, immediate initialization on declaration! 

```C++
std::vector<int> vec{1,3,5};
std::pair<int, std::string> numSuffix1{1,"st"};
```

TLDR: use uniform initialization to initialize every field of non-primitive typed variables, but be careful not to use `vec(n, k)`!

## When should we use auto?

当变量的声明和初始化同时进行时，为避免输入过长的**变量类型名称**，可以使用`auto`来减少需要输入的字符

但不要过度使用`auto`！

尽量不要使用`auto`的情况：

- 只进行变量声明，如：`auto a, b, c;`
- 需要明确表示变量类型，如：`auto result = stu.first; // stu.first is bool type`

## Structed Binding

Structured binding lets you initialize **directly** from the contents of a struct

```C++
// Before
auto p = std::make_pair("s", 5);
string a = s.first;
int b = s.second;

// After
auto p = std::make_pair("s", 5); // p is std::pair<string, int>
auto [a, b] = p; // use structed binding
// a is string, b is int
// auto [a, b] = std::make_pair(...);
```

Example:

```C++
#include <string>
#include <iostream>
#include <cmath> // gives us pow and sqrt!

using std::string; using std::cout;
using std::cin; using std::pow;
using std::sqrt; using std::endl;

std::pair<bool, std::pair<double, double>> quadratic(double a, double b, double c){
	// get radical, test if negative, return false if so
	double radical = pow(b, 2) - (4*a*c);

	if(radical < 0){
		// First way: return std::make_pair(false, std::make_pair(-1, -1));
		// Uniform initialization
		return {false, {-1, -1}};
	} else {
		double root1 = ( -1*b + sqrt(radical) ) / (2*a);
		double root2 = ( -1*b - sqrt(radical) ) / (2*a);
		// First way: return std::make_pair(true, std::make_pair(root1, root2));
		// Uniform initialization
		return {true, {root1, root2}};
	}
}

int main(){
	// get 3 doubles (ax^2 + bx + c)
	double a, b, c;
	cout << "Input coefficients" << endl;
	cin >> a >> b >> c;
	// get roots if they exist
	// First way: std::pair<bool, std::pair<double, double>> res = quadratic(a, b, c);
	// Using structured binding:
	auto [exists, results] = quadratic(a, b, c);
	// print accordingly
	// if(res.first) {
	if (exists) {
		auto [root1, root2] = results;
		// cout << "Solutions are: " << res.second.first << " " << res.second.second << endl;
		cout << "Solutions are: " << root1 << " " << root2 << endl;
	} else {
		cout << "No solutions exist!" << endl;
	}
	return 0;
}
```

This is better is because it’s semantically clearer: **variables have clear names**:

- `auto [exists, results] = quadratic(a, b, c);`
- `auto [root1, root2] = results;`

## References

**Definition:** An alias (another name) for a named variable

```C++
void changeX(int &x){ //changes to x will persist
	x = 0;
}
void keepX(int x){
	x = 0;
}

int a = 100;
int b = 100;
changeX(a); //a becomes a reference to x
keepX(b); //b becomes a copy of x
cout << a << endl; //0
cout << b << endl; //100
```

```C++
vector<int> original{1, 2};
vector<int> copy = original;
vector<int> &ref = original;
// "=" automatically make a copy! Must use "&" to avoid this

original.push_back(3);
copy.push_back(4);
ref.push_back(5);

cout << original << endl; // {1, 2, 3, 5}
cout << copy << endl; // {1, 2, 4}
cout << ref << endl; // {1, 2, 3, 5}
```

## L-Value and R-Value

```C++
int x = 3;
int y = 4;
int k = x;
```

**left-value:**

- l-values can appear on the left or right of an `=`
- `x` is an **l-value**
- l-values have names
- l-values are **not temporary**

**right-value:**

- r-values can ONLY appear on the right of an `=`
- `3` is a **r-value**
- r-values don’t have names
- r-values are **temporary**

:star: **r-value can NOT be referenced**

```C++
void shift(vector<std::pair<int, int>> &nums) {
    for (auto& [num1, num2]: nums) {
        num1++;
        num2++;
	}
}
// shift({{1, 1}}); 
// {{1, 1}} is an r-value, it can’t be referenced

// fixed
vector<std::pair<int, int>> num_pair = {{1, 1}};
shift(num_pair);
```

## Const and Const References

Const indicates a variable can’t be modified!

```C++
std::vector<int> vec{1, 2, 3};
const std::vector<int> c_vec{7, 8}; // a const variable
std::vector<int> &ref = vec; // a regular reference
const std::vector<int> &c_ref = vec; // a const reference
vec.push_back(3); // OKAY
c_vec.push_back(3); // BAD - const
ref.push_back(3); // OKAY
c_ref.push_back(3); // BAD - const
```

Can’t declare non-const reference to const variable!

```C++
const std::vector<int> c_vec{7, 8}; // a const variable

// BAD - can't declare non-const reference to const vector
// std::vector<int> &bad_ref = c_vec;

// fixed
const std::vector<int> &bad_ref = c_vec;

// BAD - Can't declare a non-const reference as equal to a const reference!
// std::vector<int> &ref = bad_ref;

// fixed
const std::vector<int> &ref = bad_ref;
```

## `const &` subtleties

```C++
std::vector<int> vec{1, 2, 3};
const std::vector<int> c_vec{7, 8};

std::vector<int>& ref = vec;
const std::vector<int>& c_ref = vec;

auto copy = c_ref; // a non-const copy
const auto copy = c_ref; // a const copy
auto& a_ref = ref; // a non-const reference
const auto& c_aref = ref; // a const reference
```

C++, by default, makes copies when we do variable assignment! We need to use `&` if we need references instead

## Recapitulation

- Use input streams to get information 
- Use structs to bundle information 
- Use uniform initialization wherever possible 
- Use references to have multiple aliases to the same thing 
- Use const references to avoid making copies whenever possible

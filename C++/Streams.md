# Streams

**Definition:** an abstraction for input/output. Streams convert between **data** and **the string representation of data** 

## Output Steams

- `std::cout` is an output stream. It has type  `std::ostream` 
- `std::cout` can only send data using the `<<` operator 
  - Converts any type into **string** and sends it to the **stream** 
- `std::cout` is the output stream that goes to the console 

```C++
std::cout << 5 <<std::endl;
// converts int value 5 to string “5”
// sends “5” to the console output stream
```

- `std::cout` is a **global constant object** that you get from `#include <iostream>` 

## Input Steams

- Have type `std::istream` 
- Can only receive **strings** using the `>>` operator 
  - Receives a string from the stream and **converts it to data** 
- `std::cin` is the input stream that gets input from **console** 

```C++
int x;
std::string str;
std::cin >> x >> str;
// reads exactly one int then 1 string from console
```

- `std::cin` is a **global constant object** that you get from `#include <iostream>` 

### Details: 

- First call to `std::cin >>` creates a command line prompt that allows the user to type until they hit enter 
- Each `>>` ONLY reads until the next **whitespace** 
  - Whitespace = tab, space, newline 
- Everything after the first whitespace gets saved and used the next time `std::cin >>` is called 
  - The place its saved is called a **buffer**! 
- If there is nothing waiting in the buffer, `std::cin >>` creates a new command line prompt
- Whitespace is eaten: it won’t show up in output
- :star: `std::cin` is dangerous to use in its own!

Reading using `>>` extracts a single “word” or type including for strings. 
To **read a whole line**, use `std::getline(istream &stream, string &line);`

### How to use `getline`

- Notice `getline(istream &stream, string &line)` takes in both parameters by reference! 

```C++
std::string line;
std::getline(std::cin, line); //now line has changed!
//say the user entered “Hello World 42!” 
std::cout << line << std::endl; 
//should print out“Hello World 42!”
```

### Don’t mix `>>` with `getline`!

- `>>` reads up to the next **whitespace character** and **does not** go past that whitespace character
- `getline` reads up to the next **delimiter** (by default, ‘\n’), and **does** go past that delimiter

## File Streams 

### Output File Streams

- Have type `std::ofstream` 
- Only send data using the `<<` operator 
  - Converts data of any type into a **string** and sends it to the  **file stream** 
- Must initialize your own `std::ofstream` object linked to your file 

```C++
std::ofstream out(“out.txt”);
// out is now an ofstream that outputs to out.txt
out << 5 << std::endl; // out.txt contains 5
```

`std::cout` is global constant object. To use any other output stream, you must first initialize it!

```C++
void writeToStream(std::ostream& anyOutputStream, int num) {
    anyOutputStream << "Writing to stream: "
        << num << endl;
}
```

```C++
std::ofstream fileOut("out.txt");
writeToStream(std::cout, 5); // to console
writeToStream(fileOut, 15); // to file
```

#### Write a struct to a file：

```C++
// struct type definition
struct Teacher {
    int ID;
    std::string name;
    std::string state;
    int age;
};
```

```C++
// << operator override
std::ostream &operator<<(std::ostream &os, const Teacher &teacher) {
    os << teacher.name << " from " << teacher.state;
    os << " (" << teacher.age << ")";
    os << " ID: " << teacher.ID;
    return os;
}
```

```C++
// 构造文件输出对象，并指定文件地址
std::ofstream out(R"(C:\Users\Karl\Desktop\test.txt)");
// 使用 << 操作符进行内容输出到文件
out << t1 << std::endl;
```

### Input File Streams

- Have type `std::ifstream` 
- Only receives **strings** using the `>>` operator
  - Receives strings from a **file** and converts it to data of any type
- Must initialize your own `std::ifstream` object linked to your file

```C++
std::ifstream in(“out.txt”);
// in is now an ifstream that reads from out.txt
std::string str;
in >> str; // first word in out.txt goes into str
```

```C++
// 读取文件中的第一行
std::getline(fileIn,line); // 返回值为bool，判断是否读取到了一行
std::cout << "line: " << line << std::endl; // 输出第一行
```

```C++
// 读取文件中的每一行
while (std::getline(fileIn, line)) {
    std::cout << line << std::endl;
}
```

```C++
//read numbers from a file
void readNumbers() {
    // Create our ifstream and make it open the file
    std::ifstream input("res/numbers.txt");

    // This will store the values as we get them form the stream
    int value;
    while(true) {
        // Extract next number from input
        input >> value;

        // If input is in a fail state, either a value couldn't
        // be converted, or we are at the end of the file.

        if(input.fail())
            break;
        cout << "Value read: " << value << endl;
    }
}
```

```C++
//read a single word at a time from a file
void readHaikuWord() {
    // Create our ifstream and make it open the file
    std::ifstream input("res/haiku.txt");

    // This will store the values as we get them form the stream
    string word;
    while(true) {
        // Extract next word from input
        input >> word;

        // If input is in a fail state, either a value couldn't
        // be converted, or we are at the end of the file.

        if(input.fail())
            break;

        cout << "Word read: " << word << endl;
    }
}
```

```C++
// read a line at a time from a file
void readHaikuLine() {
    // Create our ifstream and make it open the file
    std::ifstream input("res/haiku.txt");

    // This will store the lines as we get them form the stream
    string line;
    while(true) {
        std::getline(input, line);

        // If input is in a fail state, either a value couldn't
        // be converted, or we are at the end of the file.
        if(input.fail())
            break;
        cout << line << endl;
    }
}
```

## String  Streams

- Output stream: `std::ostringstream`
  - Give any data type to the `ostringstream`, it’ll store it as a string!
- Input stream: `std::istringstream`
  - Make an `istringstream` out of a string, read from it  word/type by word/type!
- The same as the other `i/ostreams` you’ve seen!

```C++
string judgementCall(int age, string name, bool lovesCpp) {
	std::ostringstream formatter;
	formatter << name <<", age " << age;
	if(lovesCpp) 
        formatter << ", rocks.";
	else 
        formatter << " could be better";
	return formatter.str();
}
```

```C++
Student reverseJudgementCall(string judgement) { 
    // input: “Frankie age 22, rocks”
    std::istringstream converter(judgement);
    
    string fluff;
    int age;
    bool lovesCpp;
    string name;
    
    converter >> name;
    converter >> fluff;
    converter >> age;
    converter >> fluff;
    string cool;
    converter >> cool;
    if(cool == "rocks") return Student{name, age, "bliss"};
    else return Student{name, age, "misery"};
}	// returns: {“Frankie”, 22, “bliss”}
```

```C++
int StringToInteger(const string& str) {
    /*
     * We'll specifically use an istringstream, which is just a
     * stringstream that you can only get things from.
     *
     * You can set its internal string when creating it or by doing
     * converter.str("string_to_set");
     */
    std::istringstream converter(str);
    /*
     * Try getting an int from the stream. If this is not succesful
     * then user input was not a valid input.
     */
    int value;
    if(converter >> value) {
        /*
         * See if we can extract a char from the stream.
         * If so, the user had junk after a valid int in their input.
         */
        char rem;
        if(converter >> rem) {
            /*
             * Throwing an error is a way of propogating up the funcion
             * callstack that something went wrong. Previous functions can
             * anticipate such an error and catch it. In this case, we will
             * just let the thrown domain_error propogate up until it terminates
             * the program.
             *
             * A domain_error is defined in the standard namespace as an error
             * to signal that the input arguments to the function were not valid.
             */
            throw std::domain_error(string("Unexpected character in input: ") + rem);
        }
        return value;
    }
    /* throw a domain error with a helpful error message. */
    throw std::domain_error(string("Failed to convert input: ") + str);
}
```

```C++
int getInteger() {
    // 接收到正确的输入才会结束循环
    while(true) {
        std::string line;
        std::getline(std::cin, line);
        std::istringstream converter(line);
        int result;
        
        // 判断是否输入了整数
        if(converter >> result) {
            char remaining;
			/*
              * 判断整数后是否还有其他字符
              * 如果有，则抛出异常
              * 如果没有，则返回整数
              */
            if(converter >> remaining) {
                std::cout << "Unexpected character. Try again." << std::endl;
            } else {
                return result;
            }
        } else {
            std::cout << "Not a valid integer. Try again." << std::endl;
        }
    }
}
```

## Recapitulation

- Streams convert between **data of any type** and **the string representation of that data**
- Streams have an endpoint: **console** for `cin/cout`, **files** for `i/o fstreams`,  **string variables** for `i/o sstreams` *where they read in a string from or output a string to*. 
- To **send data** (in string form) to a stream, use `stream_name << data`
- To **extract data** from a stream, use `stream_name >> data`, and the stream will try to *convert* a string to whatever type data is 
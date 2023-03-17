# CMake

## 1 `CMakeLists.txt`基本结构

```cmake
# 设置CMake的最低版本要求
cmake_minimum_required(VERSION <version>)

# 定义项目名称和版本号
project(<project_name> VERSION <version>)

# 添加可选的配置选项
option(<option_name> "option description" <default_value>)

# 设置编译器选项
set(CMAKE_C_FLAGS "<compiler_flags>")
set(CMAKE_CXX_FLAGS "<compiler_flags>")

# 添加子目录，指定源代码的位置
add_subdirectory(<subdir>)

# 指定依赖库的位置
find_package(<package_name> REQUIRED)

# 指定生成目标
add_executable(<target_name> <source_files>)

# 添加编译选项
target_compile_options(<target_name> PRIVATE <option>)

# 添加链接库
target_link_libraries(<target_name> <library_name>)

# 指定安装目录
install(TARGETS <target_name> DESTINATION <install_directory>)

```



## 2 `CMake`增加`CFLAG`内容

`CMAKE_C_FLAGS`变量用于设置C编译器的编译选项，例如优化选项、调试选项、警告选项等。同样，`CMAKE_CXX_FLAGS`变量用于设置C++编译器的编译选项。

```cmake
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
```

**注意：**这些变量中包含的选项将适用于整个项目，因此需要谨慎添加选项以避免对整个项目造成意外的影响。如果你只想对特定的源文件或目标加入选项，可以使用`target_compile_options`命令，例如：

```cmake
target_compile_options(my_target PRIVATE -Wall)
```

这样，只有名为`my_target`的目标会添加`-Wall`选项。

## 3 `CMake`配置`PREFIX`目录

在`CMake`中，可以通过设置`CMAKE_INSTALL_PREFIX`变量来指定安装目录的前缀。这个变量用于**指定安装时的根目录**，即安装目录的父级目录，而不是安装目录本身。

在`CMake`中，安装目录一般包括`bin`目录、`lib`目录、`include`目录等。设置`CMAKE_INSTALL_PREFIX`变量将决定这些目录的安装路径，例如：

```cmake
set(CMAKE_INSTALL_PREFIX /usr/local)
```

这里将安装目录的前缀设置为`/usr/local`，也就是说，`bin`目录将安装到`/usr/local/bin`，`lib`目录将安装到`/usr/local/lib`，`include`目录将安装到`/usr/local/include`等。

一旦设置了`CMAKE_INSTALL_PREFIX`变量，就可以使用`install`命令将文件或目标安装到指定的安装目录中。例如，以下代码将可执行文件`my_app`安装到指定的安装目录中：

```cmake
install(TARGETS my_app DESTINATION bin)
```

这将把`my_app`安装到`/usr/local/bin`目录下。在安装过程中，`CMake`会根据`CMAKE_INSTALL_PREFIX`变量的值，将`bin`目录添加到安装路径的尾部，从而得到实际的安装目录。

### 3.1 `install`命令基本语法

**用于安装编译生成的文件到指定的目录。**使用`install`命令可以将可执行文件、库文件、头文件等安装到指定的安装目录，以便在其他机器上使用。

```cmake
install(TARGETS targets...
        [[ARCHIVE|LIBRARY|RUNTIME|FRAMEWORK|BUNDLE|PRIVATE_HEADER|PUBLIC_HEADER|RESOURCE]
         [DESTINATION <dir>]
         [PERMISSIONS permissions...]
         [CONFIGURATIONS [Debug|Release|...]]
         [COMPONENT <component>]
         [OPTIONAL]
         [NAMELINK_COMPONENT <component>]
         [NAMELINK_SKIP]
         [EXCLUDE_FROM_ALL]
         [INCLUDES DESTINATION <dir>]
         [NO_POLICY_SCOPE])
install(FILES files... [DESTINATION <dir>]
        [PERMISSIONS permissions...]
        [CONFIGURATIONS [Debug|Release|...]]
        [COMPONENT <component>]
        [RENAME <name>]
        [OPTIONAL]
        [NO_SOURCE_PERMISSIONS]
        [NO_POLICY_SCOPE])
install(DIRECTORY dirs... [DESTINATION <dir>]
        [FILE_PERMISSIONS permissions...]
        [DIRECTORY_PERMISSIONS permissions...]
        [USE_SOURCE_PERMISSIONS]
        [CONFIGURATIONS [Debug|Release|...]]
        [COMPONENT <component>]
        [OPTIONAL]
        [PATTERN <pattern> [EXCLUDE | INCLUDE] [PATTERN <pattern> [EXCLUDE | INCLUDE] ...]]
        [NO_POLICY_SCOPE])
install(PROGRAMS files... [DESTINATION <dir>]
        [PERMISSIONS permissions...]
        [CONFIGURATIONS [Debug|Release|...]]
        [COMPONENT <component>]
        [RENAME <name>]
        [OPTIONAL]
        [NO_SOURCE_PERMISSIONS]
        [NO_POLICY_SCOPE])
install(CODE "code..."
        [TO <location>]
        [COMPONENT <component>]
        [SCRIPT <file>])

```

- `TARGETS`：安装可执行文件、库文件等。使用`add_executable`、`add_library`等命令定义的目标，可以使用`TARGETS`参数进行安装。例如，以下命令将可执行文件`myapp`安装到`/usr/local/bin`目录中：

  ```cmake
  install(TARGETS myapp DESTINATION bin)
  ```

- `FILES`：安装单个文件。使用`FILES`参数可以安装指定的文件。例如，以下命令将`README.md`文件安装到`/usr/local/share/myapp`目录中：

  ```cmake
  install(FILES README.md DESTINATION share/myapp)
  ```

- `DIRECTORY`：安装目录。使用`DIRECTORY`参数可以安装整个目录及其下的文件。例如，以下命令将`doc`目录及其下所有文件安装到`/usr/local/share/myapp/doc`目录中：

  ```cmake
  install(DIRECTORY doc DESTINATION share/myapp)
  ```

- `PROGRAMS`：安装可执行文件。和`FILES`类似，但是会为文件添加可执行权限。




### macro variable `CMAKE_INSTALL_PREFIX` and command`install`

```cmake
set(CMAKE_INSTALL_PREFIX /home/karl/Development/PortLib)

install(DIRECTORY include DESTINATION $(CMAKE_INSTALL_PREFIX)/)
```



## 4 常见预定义变量及其含义

### 4.1 `CMAKE_TOOLCHAIN_FILE`

`CMAKE_TOOLCHAIN_FILE`用于**指定交叉编译时使用的工具链文件**。

通常，交叉编译需要使用不同于本地平台的编译器、链接器和头文件库。**为了使用这些工具，需要提供一个交叉编译工具链文件。**该文件描述了编译器、链接器、头文件和库文件的位置，以及如何使用这些工具来生成可执行文件或库。

在`CMake`中，可以使用`CMAKE_TOOLCHAIN_FILE`变量来指定交叉编译工具链文件的位置。例如，以下命令将使用`/path/to/my_toolchain_file.cmake`文件提供交叉编译工具链的相关路径：

```bash
cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/my_toolchain_file.cmake /path/to/source
```

在工具链文件中，可以通过定义一些变量来指定交叉编译需要使用的工具，例如：

- `CMAKE_SYSTEM_NAME`：**指定目标平台的名称**，例如Linux、Android、iOS等。
- `CMAKE_C_COMPILER`和`CMAKE_CXX_COMPILER`：**指定C和C++编译器的位置**。
- `CMAKE_FIND_ROOT_PATH`：**指定头文件和库文件的搜索路径**。
- `CMAKE_SYSROOT`：**指定交叉编译工具链的根目录**。

根据交叉编译工具链文件中的定义，CMake将自动使用正确的编译器和库文件，生成适用于目标平台的可执行文件或库。

### 4.2 `CMAKE_SYSTEM_PROCESSOR`

`CMAKE_SYSTEM_PROCESSOR`表示当前主机的**处理器架构**。该变量的值通常由`CMake`自动检测得出，但是你也可以手动设置它。

在跨平台开发中，你可能需要使用`CMAKE_SYSTEM_PROCESSOR`来**区分主机和目标平台的处理器架构**。例如，如果你的主机使用`x86`架构，但你要编译一个适用于`ARM`架构的程序，你可以在`CMakeLists.txt`文件中设置`CMAKE_SYSTEM_PROCESSOR`为`arm`，以确保`CMake`在交叉编译时使用正确的编译器和库文件。

需要注意的是，`CMAKE_SYSTEM_PROCESSOR`并不是一个精确的处理器型号或者`CPUID`。它只是用来指示处理器架构的名称。在Linux上，`CMAKE_SYSTEM_PROCESSOR`的值通常是类似于`armv7l`或`x86_64`这样的字符串。具体的取值范围取决于`CMake`的实现和主机操作系统。

### 4.3 `CMAKE_FIND_ROOT_PATH` 

`CMAKE_FIND_ROOT_PATH`指示`CMake`**查找头文件、库文件和可执行文件时应该搜索的目录**。该变量通常在交叉编译时使用，因为在交叉编译过程中，你需要告诉`CMake`查找适用于目标平台的头文件和库文件，而不是在本地主机上查找。

默认情况下，`CMake`会在主机上的标准目录中搜索头文件和库文件。但是在交叉编译时，这些**标准目录通常不包含目标平台的头文件和库文件**。因此，你需要告诉`CMake`在哪里搜索这些文件。

`CMAKE_FIND_ROOT_PATH`变量的值应该是一个包含了目标平台头文件和库文件的目录列表。例如，在交叉编译ARM平台的程序时，你可能需要将`CMAKE_FIND_ROOT_PATH`设置为包含`ARM`平台交叉编译工具链的目录，以便CMake可以在这个目录中查找适用于ARM平台的头文件和库文件。具体来说，以下三个子变量用来设置查找路径：

- `CMAKE_FIND_ROOT_PATH_MODE_PROGRAM`：指示`CMake`在哪些目录中搜索**可执行文件**，例如编译器和链接器。
- `CMAKE_FIND_ROOT_PATH_MODE_LIBRARY`：指示`CMake`在哪些目录中搜索**库文件**。
- `CMAKE_FIND_ROOT_PATH_MODE_INCLUDE`：指示`CMake`在哪些目录中搜索**头文件**。

对于每个子变量，可能的值为：

- `NEVER`：表示**不在**这些目录中搜索，**忽略**`CMAKE_FIND_ROOT_PATH`。
- `ONLY`：表示**仅在**这些目录中搜索。
- `BOTH`：表示**先在**这些目录中搜索，**如果没有找到则在默认目录中搜索**。

**NOTE: **通过设置`CMAKE_FIND_ROOT_PATH`和`CMAKE_FIND_ROOT_PATH_MODE_*`变量，可以确保`CMake`*在交叉编译时使用适当的头文件和库文件*。


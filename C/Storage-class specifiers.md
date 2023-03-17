# Storage-class specifiers

Specify storage duration and linkage of objects and functions:

- **auto** - automatic duration and no linkage
- **register** - automatic duration and no linkage; address of this variable cannot be taken
- **static** - static duration and internal linkage (unless at block scope)
- **extern** - static duration and external linkage (unless already declared internal)
- **_Thread_local** - thread storage duration (since C11)

## storage duration

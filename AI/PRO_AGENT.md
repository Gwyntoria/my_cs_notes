# Repository Guidelines

## Coding Style & Naming Conventions

### Formatting

C/C++ formatting follows `.clang-format`:

- 4-space indentation, NO tabs.
- NO column limit.
- When a function declaration or call is too long, place each argument on a separate line and align the arguments after the opening parenthesis:

  ```c
  rtos_create_thread(NULL,
                     BEKEN_DEFAULT_WORKER_PRIORITY,
                     "memchk",
                     (beken_thread_function_t)_check_memory_usage,
                     1024,
                     (beken_thread_arg_t)0);
  ```

- Keep at most one consecutive empty line.
- Left-align pointer declarators.
- Use one space before trailing comments.

Do NOT run `clang-format` to format any changed C/C++ files.

### Naming

- Use lower_snake_case for C files, headers, functions, and local variables.
- Public functions should use names such as `calculate_len()`.
- Static private functions should use a leading underscore, such as `_calculate_len()`.
- Use all-uppercase names for macros, such as `BEKEN_DEFAULT_WORKER_PRIORITY`.
- Format enum types and enumerators as follows:

  ```c
  typedef enum StatusCode {
      kStatusCodeOk = 0,
      kStatusCodeFail,
      kStatusCodeRuning,
      kStatusCodeStop,
      kStatusCodeInvalid,
  } StatusCode;
  ```

- Format structures as follows:

  ```c
  typedef struct ObjClass {
      void* context;
      int status;
  } ObjClass;
  ```

### Comment

- Add function comments with `@brief`, `@param`, and `@return` for new or changed functions.
- Public declarations in headers need matching comments.
- Add concise logic comments where control flow is not obvious.
- Document structs with a struct-level description and field descriptions.

## Branching & Merging

- Development branches must be merged into `dev` first. Merging a development branch directly into `main` is not allowed; `main` only accepts merges from `dev`.
- Both merging into `dev` and merging from `dev` into `main` require explicit confirmation from the maintainer before the merge is performed.
- Do NOT run `git push` or `git pull`.

## 日志等级约束

在判断改用哪个日志等级时，唯一判断锚点: "这个固件正常运行 / 这次流程正常推进时, 我每次都想看到这条吗?"

- LOGE (E) -- 已经错了、失败了, 需要立即注意。出错时一定想看。
  - 例: 内存分配失败、解析失败、数据非法、回调指针为 NULL。
- LOGW (W) -- 不太对但能继续 / 需要等待 / 降级处理。一定想看。
  - 例: 功能未启用而跳过、网络未就绪而等待、被中断但可恢复、重复操作被忽略。
- LOGI (I) -- 正常流程的里程碑、状态跃迁、操作结果。一定想看。
  - 例: 模块初始化成功、第 N 步开始、设备激活、序列完成。
- LOGD (D) -- 排查问题时才想看的细粒度信息, 平时是噪音。默认不想看。
  - 例: 高频轮询、循环体内逐项、中间变量、底层返回码、定时器调度细节。
- LOGV (V) -- 比 DEBUG 更细的逐字节 / 逐帧追踪, 仅深挖单点问题时开启。

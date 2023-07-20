# Thread Pool

## Introduction

线程池是一种常见的并发编程技术，用于管理和复用线程，从而提高程序的性能和效率。线程池可以避免频繁地创建和销毁线程，减少线程切换开销，特别是当需要处理大量短时间任务时，线程池能够显著提升性能。

## Simple Implement in C

### 定义线程池的数据结构

```c
typedef struct {
    pthread_t *threads;     // 线程数组
    int thread_count;       // 线程数量
    int task_count;         // 任务队列中任务数量
    int head;               // 任务队列头指针
    int tail;               // 任务队列尾指针
    int count;              // 任务队列容量
    pthread_mutex_t lock;   // 互斥锁
    pthread_cond_t notify;  // 条件变量，用于通知线程有新任务到来
    int shutdown;           // 是否销毁线程池的标志位
} ThreadPool;
```

### 初始化线程池

```c
ThreadPool* createThreadPool(int thread_count, int task_queue_size) {
    ThreadPool *pool = (ThreadPool*)malloc(sizeof(ThreadPool));
    pool->threads = (pthread_t*)malloc(sizeof(pthread_t) * thread_count);
    pool->thread_count = thread_count;
    pool->task_count = 0;
    pool->head = 0;
    pool->tail = 0;
    pool->count = task_queue_size;
    pool->shutdown = 0;
    pthread_mutex_init(&(pool->lock), NULL);
    pthread_cond_init(&(pool->notify), NULL);

    for (int i = 0; i < thread_count; i++) {
        pthread_create(&(pool->threads[i]), NULL, worker, (void*)pool);
    }

    return pool;
}
```

### 定义线程执行的工作函数（worker函数）

```c
void* worker(void *arg) {
    ThreadPool *pool = (ThreadPool*)arg;
    while (1) {
        pthread_mutex_lock(&(pool->lock));
        while (pool->task_count == 0 && !(pool->shutdown)) {
            pthread_cond_wait(&(pool->notify), &(pool->lock));
        }

        if (pool->shutdown) {
            pthread_mutex_unlock(&(pool->lock));
            pthread_exit(NULL);
        }

        // 从任务队列中取出任务并执行
        Task *task = pool->tasks[pool->head];
        pool->head = (pool->head + 1) % pool->count;
        pool->task_count--;

        pthread_mutex_unlock(&(pool->lock));

        // 执行任务函数
        task->function(task->arg);
        free(task);
    }
    return NULL;
}
```

### 定义任务的数据结构

```c
typedef struct {
    void (*function)(void* arg);
    void *arg;
} Task;
```

### 添加任务到线程池

```c
int addTask(ThreadPool *pool, void (*function)(void*), void *arg) {
    pthread_mutex_lock(&(pool->lock));

    if (pool->task_count == pool->count) {
        pthread_mutex_unlock(&(pool->lock));
        return -1; // 任务队列已满
    }

    Task *task = (Task*)malloc(sizeof(Task));
    task->function = function;
    task->arg = arg;

    pool->tasks[pool->tail] = task;
    pool->tail = (pool->tail + 1) % pool->count;
    pool->task_count++;

    pthread_cond_signal(&(pool->notify));
    pthread_mutex_unlock(&(pool->lock));

    return 0;
}
```

### 销毁线程池

```c
void destroyThreadPool(ThreadPool *pool) {
    if (pool == NULL) return;

    pthread_mutex_lock(&(pool->lock));
    pool->shutdown = 1;
    pthread_mutex_unlock(&(pool->lock));

    pthread_cond_broadcast(&(pool->notify));

    for (int i = 0; i < pool->thread_count; i++) {
        pthread_join(pool->threads[i], NULL);
    }

    free(pool->threads);
    free(pool);
}
```

**NOTE:** 这只是一个简单的线程池实现，并未考虑线程安全性、任务优先级等高级特性。在实际使用中，可能需要根据具体需求进行进一步的优化和扩展。

## Optimization

1. 线程安全性优化：

    - 使用读写锁：可以考虑将任务队列拆分成两部分，一部分用于任务的添加，另一部分用于任务的执行。这样可以使用读写锁（读者写者锁）来保护两个部分，从而提高并发性能。
    - 原子操作：使用原子操作来更新任务队列的头尾指针，以避免竞态条件。

2. 任务优先级优化：

    - 支持任务优先级：在任务结构中添加任务优先级字段，同时在添加任务到队列时根据优先级进行排序或插入。执行任务时，从队列中选择优先级最高的任务执行。
    - 多个任务队列：可以根据任务的优先级创建多个任务队列，不同优先级的任务放入不同的队列中，线程可以根据优先级选择执行任务队列。

```c
#include <pthread.h>
#include <stdlib.h>

typedef struct {
    void (*function)(void* arg);
    void *arg;
    int priority; // 任务优先级
} Task;

typedef struct {
    // 线程池数据结构
    // ...

    Task** tasks; // 任务队列改为任务指针数组
    int* priorities; // 任务优先级数组
} ThreadPool;

// 添加任务到线程池，并根据任务优先级排序
int addTask(ThreadPool *pool, void (*function)(void*), void *arg, int priority) {
    pthread_mutex_lock(&(pool->lock));

    if (pool->task_count == pool->count) {
        pthread_mutex_unlock(&(pool->lock));
        return -1; // 任务队列已满
    }

    Task *task = (Task*)malloc(sizeof(Task));
    task->function = function;
    task->arg = arg;
    task->priority = priority;

    // 找到合适的位置插入任务，并根据优先级进行排序
    int insert_pos = pool->task_count;
    for (int i = pool->task_count - 1; i >= 0; i--) {
        if (priority > pool->priorities[i]) {
            pool->tasks[i + 1] = pool->tasks[i];
            pool->priorities[i + 1] = pool->priorities[i];
            insert_pos = i;
        }
        else {
            break;
        }
    }

    pool->tasks[insert_pos] = task;
    pool->priorities[insert_pos] = priority;

    pool->task_count++;

    pthread_cond_signal(&(pool->notify));
    pthread_mutex_unlock(&(pool->lock));

    return 0;
}

// 线程执行函数，根据任务优先级选择执行任务
void* worker(void *arg) {
    ThreadPool *pool = (ThreadPool*)arg;
    while (1) {
        pthread_mutex_lock(&(pool->lock));
        while (pool->task_count == 0 && !(pool->shutdown)) {
            pthread_cond_wait(&(pool->notify), &(pool->lock));
        }

        if (pool->shutdown) {
            pthread_mutex_unlock(&(pool->lock));
            pthread_exit(NULL);
        }

        // 从任务队列中取出优先级最高的任务并执行
        Task *task = pool->tasks[0];
        int priority = pool->priorities[0];

        // 将后续任务往前移动一个位置
        for (int i = 1; i < pool->task_count; i++) {
            pool->tasks[i - 1] = pool->tasks[i];
            pool->priorities[i - 1] = pool->priorities[i];
        }

        pool->task_count--;

        pthread_mutex_unlock(&(pool->lock));

        // 执行任务函数
        task->function(task->arg);
        free(task);
    }
    return NULL;
}
```

## Multiplexing

1. 在线程池数据结构中添加一个标志数组，用于标记线程是否空闲:

    ```c
    typedef struct {
    // 其他成员...
    int* is_idle;   // 线程是否空闲的标志数组

    } ThreadPool;
    ```

2. 修改线程执行函数（worker函数），使线程在任务执行完毕后继续等待任务:

    ```c
    void* worker(void *arg) {
        ThreadPool *pool = (ThreadPool*)arg;
        while (1) {
            pthread_mutex_lock(&(pool->lock));
            while (pool->task_count == 0 && !(pool->shutdown)) {
                // 线程没有任务可执行，将标志位置为1，表示线程空闲
                pool->is_idle[pthread_self()] = 1;
                pthread_cond_wait(&(pool->notify), &(pool->lock));
                // 线程有新任务，将标志位置为0，表示线程不再空闲
                pool->is_idle[pthread_self()] = 0;
            }

            if (pool->shutdown) {
                pthread_mutex_unlock(&(pool->lock));
                pthread_exit(NULL);
            }

            // 从任务队列中取出优先级最高的任务并执行
            Task *task = pool->tasks[0];
            int priority = pool->priorities[0];

            // 将后续任务往前移动一个位置
            for (int i = 1; i < pool->task_count; i++) {
                pool->tasks[i - 1] = pool->tasks[i];
                pool->priorities[i - 1] = pool->priorities[i];
            }

            pool->task_count--;

            pthread_mutex_unlock(&(pool->lock));

            // 执行任务函数
            task->function(task->arg);
            free(task);
        }
        return NULL;
    }
    ```

3. 修改任务添加函数（addTask函数），在任务添加后通知空闲线程:

    ```c
    int addTask(ThreadPool *pool, void (*function)(void*), void *arg, int priority) {
        pthread_mutex_lock(&(pool->lock));

        if (pool->task_count == pool->count) {
            pthread_mutex_unlock(&(pool->lock));
            return -1; // 任务队列已满
        }

        Task *task = (Task*)malloc(sizeof(Task));
        task->function = function;
        task->arg = arg;
        task->priority = priority;

        // 找到合适的位置插入任务，并根据优先级进行排序
        int insert_pos = pool->task_count;
        for (int i = pool->task_count - 1; i >= 0; i--) {
            if (priority > pool->priorities[i]) {
                pool->tasks[i + 1] = pool->tasks[i];
                pool->priorities[i + 1] = pool->priorities[i];
                insert_pos = i;
            }
            else {
                break;
            }
        }

        pool->tasks[insert_pos] = task;
        pool->priorities[insert_pos] = priority;

        pool->task_count++;

        // 查找空闲线程并通知
        for (int i = 0; i < pool->thread_count; i++) {
            if (pool->is_idle[pool->threads[i]]) {
                pthread_cond_signal(&(pool->notify));
                break;
            }
        }

        pthread_mutex_unlock(&(pool->lock));

        return 0;
    }
    ```

线程池中的线程在执行完任务后会继续等待下一个任务，从而实现了线程的复用。请注意，为了记录线程是否空闲，我们添加了一个标志数组（is_idle），并在添加任务时检查空闲线程并通知它们。在任务执行完毕后，线程将再次等待通知，并在有新任务到来时继续执行。

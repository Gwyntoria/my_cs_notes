#ifndef ASYNC_MODULE_DESIGN_EVENT_LOOP_H
#define ASYNC_MODULE_DESIGN_EVENT_LOOP_H

#include <stdint.h>

#include "message.h"

#define EVENT_LOOP_QUEUE_CAPACITY 16U

typedef struct Player Player;

typedef struct EventLoop {
    Message queue[EVENT_LOOP_QUEUE_CAPACITY];
    uint32_t head;
    uint32_t tail;
    uint32_t count;
    Player *player;
} EventLoop;

int event_loop_post(EventLoop *loop, const Message *message);
void event_loop_publish(EventLoop *loop, MessageType type,
                        uint32_t request_id, int error_code);
void event_loop_run(EventLoop *loop);

#endif

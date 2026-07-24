#include <stdio.h>

#include "event_loop.h"
#include "player.h"

int event_loop_post(EventLoop *loop, const Message *message)
{
    if (loop->count == EVENT_LOOP_QUEUE_CAPACITY) {
        return -1;
    }

    loop->queue[loop->tail] = *message;
    loop->tail = (loop->tail + 1U) % EVENT_LOOP_QUEUE_CAPACITY;
    loop->count++;
    return 0;
}

void event_loop_publish(EventLoop *loop, MessageType type,
                        uint32_t request_id, int error_code)
{
    Message event = {0};

    event.kind = KIND_DOMAIN_EVENT;
    event.target = TARGET_NONE;
    event.type = type;
    event.request_id = request_id;
    event.error_code = error_code;

    (void)event_loop_post(loop, &event);
}

static int event_loop_pop(EventLoop *loop, Message *message)
{
    if (loop->count == 0U) {
        return -1;
    }

    *message = loop->queue[loop->head];
    loop->head = (loop->head + 1U) % EVENT_LOOP_QUEUE_CAPACITY;
    loop->count--;
    return 0;
}

static void event_bus_publish(const Message *event)
{
    if (event->type == MSG_PLAYER_STARTED) {
        printf("PlayerStarted, request=%u\n", event->request_id);
    } else if (event->type == MSG_PLAYER_STOPPED) {
        printf("PlayerStopped, request=%u\n", event->request_id);
    } else if (event->type == MSG_PLAYER_FAILED) {
        printf("PlayerFailed, request=%u, error=%d\n",
               event->request_id, event->error_code);
    }
}

void event_loop_run(EventLoop *loop)
{
    Message message;

    while (event_loop_pop(loop, &message) == 0) {
        if (message.kind == KIND_DOMAIN_EVENT) {
            event_bus_publish(&message);
        } else if (message.target == TARGET_PLAYER) {
            player_handle(loop->player, loop, &message);
        }
    }
}

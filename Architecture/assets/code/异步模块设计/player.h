#ifndef ASYNC_MODULE_DESIGN_PLAYER_H
#define ASYNC_MODULE_DESIGN_PLAYER_H

#include <stdint.h>

#include "audio_port.h"
#include "message.h"

typedef struct EventLoop EventLoop;

typedef enum {
    PLAYER_IDLE,
    PLAYER_PREPARING,
    PLAYER_PLAYING,
    PLAYER_STOPPING,
    PLAYER_FAILED,
} PlayerState;

typedef struct Player {
    PlayerState state;
    uint32_t active_request_id;
    AudioPort audio;
} Player;

void player_handle(Player *player, EventLoop *loop, const Message *message);

#endif

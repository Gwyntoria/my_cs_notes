#ifndef ASYNC_MODULE_DESIGN_MESSAGE_H
#define ASYNC_MODULE_DESIGN_MESSAGE_H

#include <stdint.h>

#define MESSAGE_URL_SIZE 128U

typedef enum {
    KIND_COMMAND,
    KIND_INTERNAL_EVENT,
    KIND_DOMAIN_EVENT,
} MessageKind;

typedef enum {
    TARGET_PLAYER,
    TARGET_NONE,
} Target;

typedef enum {
    MSG_PLAY,
    MSG_STOP,
    MSG_AUDIO_STARTED,
    MSG_AUDIO_STOPPED,
    MSG_AUDIO_FAILED,
    MSG_PLAYER_STARTED,
    MSG_PLAYER_STOPPED,
    MSG_PLAYER_FAILED,
} MessageType;

typedef struct {
    MessageKind kind;
    Target target;
    MessageType type;
    uint32_t request_id;
    int error_code;
    char url[MESSAGE_URL_SIZE];
} Message;

#endif

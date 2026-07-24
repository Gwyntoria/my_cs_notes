#ifndef ASYNC_MODULE_DESIGN_AUDIO_PORT_H
#define ASYNC_MODULE_DESIGN_AUDIO_PORT_H

#include <stdint.h>

typedef struct {
    void *ctx;
    void (*start)(void *ctx, const char *url, uint32_t request_id);
    void (*stop)(void *ctx, uint32_t request_id);
} AudioPort;

#endif

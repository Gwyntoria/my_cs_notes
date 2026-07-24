#ifndef ASYNC_MODULE_DESIGN_AUDIO_SIM_H
#define ASYNC_MODULE_DESIGN_AUDIO_SIM_H

#include <stdint.h>

#include "audio_port.h"

typedef struct EventLoop EventLoop;

typedef struct {
    EventLoop *loop;
} AudioSim;

void audio_sim_init(AudioSim *sim, EventLoop *loop);
AudioPort audio_sim_port(AudioSim *sim);
void audio_sim_notify_started(AudioSim *sim, uint32_t request_id);
void audio_sim_notify_stopped(AudioSim *sim, uint32_t request_id);

#endif

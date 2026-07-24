#include <stdio.h>

#include "audio_sim.h"
#include "event_loop.h"

static void audio_start(void *ctx, const char *url, uint32_t request_id)
{
    (void)ctx;
    printf("audio start: %s, request=%u\n", url, request_id);
}

static void audio_stop(void *ctx, uint32_t request_id)
{
    (void)ctx;
    printf("audio stop, request=%u\n", request_id);
}

void audio_sim_init(AudioSim *sim, EventLoop *loop)
{
    sim->loop = loop;
}

AudioPort audio_sim_port(AudioSim *sim)
{
    AudioPort port = {
        .ctx = sim,
        .start = audio_start,
        .stop = audio_stop,
    };

    return port;
}

void audio_sim_notify_started(AudioSim *sim, uint32_t request_id)
{
    Message event = {0};

    event.kind = KIND_INTERNAL_EVENT;
    event.target = TARGET_PLAYER;
    event.type = MSG_AUDIO_STARTED;
    event.request_id = request_id;
    (void)event_loop_post(sim->loop, &event);
}

void audio_sim_notify_stopped(AudioSim *sim, uint32_t request_id)
{
    Message event = {0};

    event.kind = KIND_INTERNAL_EVENT;
    event.target = TARGET_PLAYER;
    event.type = MSG_AUDIO_STOPPED;
    event.request_id = request_id;
    (void)event_loop_post(sim->loop, &event);
}

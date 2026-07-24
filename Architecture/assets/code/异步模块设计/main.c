#include "audio_sim.h"
#include "event_loop.h"
#include "network.h"
#include "player.h"

int main(void)
{
    Player player = {
        .state = PLAYER_IDLE,
    };
    EventLoop loop = {
        .player = &player,
    };
    AudioSim audio;

    audio_sim_init(&audio, &loop);
    player.audio = audio_sim_port(&audio);

    network_receive(&loop, "PLAY 42 https://example.com/welcome.mp3");
    event_loop_run(&loop);

    audio_sim_notify_started(&audio, 42);
    event_loop_run(&loop);

    network_receive(&loop, "STOP");
    event_loop_run(&loop);

    audio_sim_notify_stopped(&audio, 42);
    event_loop_run(&loop);
    return 0;
}

#include "event_loop.h"
#include "player.h"

void player_handle(Player *player, EventLoop *loop, const Message *message)
{
    switch (player->state) {
    case PLAYER_IDLE:
        if (message->type == MSG_PLAY) {
            player->state = PLAYER_PREPARING;
            player->active_request_id = message->request_id;
            player->audio.start(player->audio.ctx,
                                message->url,
                                message->request_id);
        }
        break;

    case PLAYER_PREPARING:
        if (message->type == MSG_AUDIO_STARTED &&
            message->request_id == player->active_request_id) {
            player->state = PLAYER_PLAYING;
            event_loop_publish(loop, MSG_PLAYER_STARTED,
                               player->active_request_id, 0);
        } else if (message->type == MSG_AUDIO_FAILED &&
                   message->request_id == player->active_request_id) {
            player->state = PLAYER_FAILED;
            event_loop_publish(loop, MSG_PLAYER_FAILED,
                               player->active_request_id,
                               message->error_code);
        } else if (message->type == MSG_STOP) {
            player->state = PLAYER_STOPPING;
            player->audio.stop(player->audio.ctx,
                               player->active_request_id);
        }
        break;

    case PLAYER_PLAYING:
        if (message->type == MSG_STOP) {
            player->state = PLAYER_STOPPING;
            player->audio.stop(player->audio.ctx,
                               player->active_request_id);
        }
        break;

    case PLAYER_STOPPING:
        if (message->type == MSG_AUDIO_STOPPED &&
            message->request_id == player->active_request_id) {
            uint32_t completed_id = player->active_request_id;

            player->state = PLAYER_IDLE;
            player->active_request_id = 0;
            event_loop_publish(loop, MSG_PLAYER_STOPPED, completed_id, 0);
        }
        break;

    case PLAYER_FAILED:
        if (message->type == MSG_PLAY) {
            player->state = PLAYER_PREPARING;
            player->active_request_id = message->request_id;
            player->audio.start(player->audio.ctx,
                                message->url,
                                message->request_id);
        }
        break;
    }
}

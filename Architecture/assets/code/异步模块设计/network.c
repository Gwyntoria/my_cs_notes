#include <stdio.h>
#include <string.h>

#include "event_loop.h"
#include "network.h"

void network_receive(EventLoop *loop, const char *packet)
{
    Message command = {0};
    unsigned int request_id;
    char url[MESSAGE_URL_SIZE] = {0};

    if (sscanf(packet, "PLAY %u %127s", &request_id, url) == 2) {
        command.kind = KIND_COMMAND;
        command.target = TARGET_PLAYER;
        command.type = MSG_PLAY;
        command.request_id = request_id;
        strncpy(command.url, url, sizeof(command.url) - 1U);
        (void)event_loop_post(loop, &command);
    } else if (strcmp(packet, "STOP") == 0) {
        command.kind = KIND_COMMAND;
        command.target = TARGET_PLAYER;
        command.type = MSG_STOP;
        (void)event_loop_post(loop, &command);
    }
}

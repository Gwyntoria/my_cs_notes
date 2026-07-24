#ifndef ASYNC_MODULE_DESIGN_NETWORK_H
#define ASYNC_MODULE_DESIGN_NETWORK_H

typedef struct EventLoop EventLoop;

void network_receive(EventLoop *loop, const char *packet);

#endif

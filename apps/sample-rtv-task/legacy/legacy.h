#include <stdint.h>
// XXX
#include <tower.h>
#include <runtime-checker.h>

void update_time_init(void (*recordEmit)(const struct assignment* n_var0));

void read_clock_block(void (*send)(const int32_t *));

void update_time_block(int32_t new_time);



#include <smavlink/pack.h>
#include "smavlink_message_local_position_ned.h"
void smavlink_send_local_position_ned(struct local_position_ned_msg* var0,
                                      struct smavlink_out_channel* var1,
                                      struct smavlink_system* var2)
{
    uint8_t local0[28U] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    uint8_t(* ref1)[28U] = &local0;
    uint32_t deref2 = *&var0->time_boot_ms;
    
    smavlink_pack_uint32_t(ref1, 0, deref2);
    
    float deref3 = *&var0->x;
    
    smavlink_pack_float(ref1, 4, deref3);
    
    float deref4 = *&var0->y;
    
    smavlink_pack_float(ref1, 8, deref4);
    
    float deref5 = *&var0->z;
    
    smavlink_pack_float(ref1, 12, deref5);
    
    float deref6 = *&var0->vx;
    
    smavlink_pack_float(ref1, 16, deref6);
    
    float deref7 = *&var0->vy;
    
    smavlink_pack_float(ref1, 20, deref7);
    
    float deref8 = *&var0->vz;
    
    smavlink_pack_float(ref1, 24, deref8);
    smavlink_send_ivory(var1, var2, 32, ref1, 28, 185);
    return;
}
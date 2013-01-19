#include <smavlink/pack.h>
#include "smavlink_message_highres_imu.h"
void smavlink_send_highres_imu(struct highres_imu_msg* var0,
                               struct smavlink_out_channel* var1,
                               struct smavlink_system* var2)
{
    uint8_t local0[62U] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0};
    uint8_t(* ref1)[62U] = &local0;
    uint64_t deref2 = *&var0->time_usec;
    
    smavlink_pack_uint64_t(ref1, 0U, deref2);
    
    float deref3 = *&var0->xacc;
    
    smavlink_pack_float(ref1, 8U, deref3);
    
    float deref4 = *&var0->yacc;
    
    smavlink_pack_float(ref1, 12U, deref4);
    
    float deref5 = *&var0->zacc;
    
    smavlink_pack_float(ref1, 16U, deref5);
    
    float deref6 = *&var0->xgyro;
    
    smavlink_pack_float(ref1, 20U, deref6);
    
    float deref7 = *&var0->ygyro;
    
    smavlink_pack_float(ref1, 24U, deref7);
    
    float deref8 = *&var0->zgyro;
    
    smavlink_pack_float(ref1, 28U, deref8);
    
    float deref9 = *&var0->xmag;
    
    smavlink_pack_float(ref1, 32U, deref9);
    
    float deref10 = *&var0->ymag;
    
    smavlink_pack_float(ref1, 36U, deref10);
    
    float deref11 = *&var0->zmag;
    
    smavlink_pack_float(ref1, 40U, deref11);
    
    float deref12 = *&var0->abs_pressure;
    
    smavlink_pack_float(ref1, 44U, deref12);
    
    float deref13 = *&var0->diff_pressure;
    
    smavlink_pack_float(ref1, 48U, deref13);
    
    float deref14 = *&var0->pressure_alt;
    
    smavlink_pack_float(ref1, 52U, deref14);
    
    float deref15 = *&var0->temperature;
    
    smavlink_pack_float(ref1, 56U, deref15);
    
    uint16_t deref16 = *&var0->fields_updated;
    
    smavlink_pack_uint16_t(ref1, 60U, deref16);
    smavlink_send_ivory(var1, var2, 105U, ref1, 62U, 93U);
    return;
}

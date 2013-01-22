/* This file has been autogenerated by Ivory
 * Compiler version  5326f414a5a63af59269d31f823a2e142af0b2c9
 */
#include <out.h>
#include "gcs_transmit_driver.h"
void gcs_transmit_send_heartbeat(struct motorsoutput_result* n_var0,
                                 struct smavlink_out_channel* n_var1,
                                 struct smavlink_system* n_var2)
{
    struct heartbeat_msg n_local0 = {.custom_mode =0, .mavtype =0, .autopilot =
                                     0, .base_mode =0, .system_status =0,
                                     .mavlink_version =0};
    struct heartbeat_msg* n_ref1 = &n_local0;
    
    smavlink_send_heartbeat(n_ref1, n_var1, n_var2);
    return;
}
void gcs_transmit_send_attitude(struct sensors_result* n_var0,
                                struct smavlink_out_channel* n_var1,
                                struct smavlink_system* n_var2)
{
    struct attitude_msg n_local0 = {.time_boot_ms =0, .roll =0, .pitch =0,
                                    .yaw =0, .rollspeed =0, .pitchspeed =0,
                                    .yawspeed =0};
    struct attitude_msg* n_ref1 = &n_local0;
    float n_deref2 = *&n_var0->roll;
    
    *&n_ref1->roll = n_deref2;
    smavlink_send_attitude(n_ref1, n_var1, n_var2);
    return;
}
void gcs_transmit_send_vfrhud(struct sensors_result* n_var0,
                              struct smavlink_out_channel* n_var1,
                              struct smavlink_system* n_var2)
{
    struct vfr_hud_msg n_local0 = {.airspeed =0, .groundspeed =0, .alt =0,
                                   .climb =0, .heading =0, .throttle =0};
    struct vfr_hud_msg* n_ref1 = &n_local0;
    
    smavlink_send_vfr_hud(n_ref1, n_var1, n_var2);
    return;
}
void gcs_transmit_send_servo_output(struct servo_result* n_var0,
                                    struct smavlink_out_channel* n_var1,
                                    struct smavlink_system* n_var2)
{
    struct servo_output_raw_msg n_local0 = {.time_boot_ms =0, .servo1_raw =0,
                                            .servo2_raw =0, .servo3_raw =0,
                                            .servo4_raw =0, .servo5_raw =0,
                                            .servo6_raw =0, .servo7_raw =0,
                                            .servo8_raw =0, .port =0};
    struct servo_output_raw_msg* n_ref1 = &n_local0;
    
    smavlink_send_servo_output_raw(n_ref1, n_var1, n_var2);
    return;
}
void gcs_transmit_send_gps(struct position_result* n_var0,
                           struct smavlink_out_channel* n_var1,
                           struct smavlink_system* n_var2)
{
    struct global_position_int_msg n_local0 = {.time_boot_ms =0, .lat =0, .lon =
                                               0, .alt =0, .relative_alt =0,
                                               .vx =0, .vy =0, .vz =0, .hdg =0};
    struct global_position_int_msg* n_ref1 = &n_local0;
    
    smavlink_send_global_position_int(n_ref1, n_var1, n_var2);
    return;
}
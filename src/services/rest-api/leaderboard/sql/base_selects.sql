     , sum(base.num_pitches) as num_pitches
     , round(sum(total_velo) / nullif(sum(num_velo), 0), 1) as avg_velocity
     , round(100 * (sum(num_barrel) / nullif(sum(num_batted_ball_event), 0)), 1) as barrel_pct
     , round(100 * (sum(num_foul) / nullif(sum(base.num_pitches), 0)), 1) as foul_pct
     , round(100 * (sum(num_plus_pitch) / nullif(sum(base.num_pitches), 0)), 1) as plus_pct
     , round(100 * (sum(num_first_pitch_swing) / nullif(sum(num_ab), 0)), 1) as first_pitch_swing_pct
     , round(100 * (sum(num_early_o_contact) / nullif(sum(num_o_contact), 0)), 1) as early_o_contact_pct
     , round(100 * (sum(num_late_o_contact) / nullif(sum(num_o_contact), 0)), 1) as late_o_contact_pct
     , round((sum(total_launch_speed) / nullif(sum(num_launch_speed), 0))::decimal, 1) as avg_launch_speed
     , round((sum(total_launch_angle) / nullif(sum(num_launch_angle), 0))::decimal, 1) as avg_launch_angle
     , round((sum(total_release_extension) / nullif(sum(num_release_extension), 0))::decimal, 1) as avg_release_extension
     , round((sum(total_spin_rate) / nullif(sum(num_spin_rate), 0))::decimal, 1) as avg_spin_rate
     , round((sum(total_x_movement) / nullif(sum(num_x_movement), 0))::decimal, 1) as avg_x_movement
     , round((sum(total_z_movement) / nullif(sum(num_z_movement), 0))::decimal, 1) as avg_z_movement
     , round(100 * (sum(num_armside) / nullif(sum(base.num_pitches), 0)), 1) as armside_pct
     , round(100 * (sum(num_gloveside) / nullif(sum(base.num_pitches), 0)), 1) as gloveside_pct
     , round(100 * (sum(num_inside) / nullif(sum(base.num_pitches), 0)), 1) as inside_pct
     , round(100 * (sum(num_outside) / nullif(sum(base.num_pitches), 0)), 1) as outside_pct
     , round(100 * (sum(num_high) / nullif(sum(base.num_pitches), 0)), 1) as high_pct
     , round(100 * (sum(num_horizontal_middle) / nullif(sum(base.num_pitches), 0)), 1) as horizonal_middle_location_pct
     , round(100 * (sum(num_middle) / nullif(sum(base.num_pitches), 0)), 1) as vertical_middle_location_pct
     , round(100 * (sum(num_low) / nullif(sum(base.num_pitches), 0)), 1) low_pct
     , round(100 * (sum(num_heart) / nullif(sum(base.num_pitches), 0)), 1) as heart_pct
     , round(100 * (sum(num_early) / nullif(sum(base.num_pitches), 0)), 1) as early_pct
     , round(100 * (sum(num_behind) / nullif(sum(base.num_pitches), 0)), 1) as behind_pct
     , round(100 * (sum(num_late) / nullif(sum(base.num_pitches), 0)), 1) as late_pct
     , round(100 * (sum(num_zone) / nullif(sum(base.num_pitches), 0)), 1) as zone_pct
     , round(100 * (sum(num_non_bip_strike) / nullif(sum(base.num_pitches), 0)), 1) as non_bip_strike_pct
     , round(100 * (sum(num_early_bip) / nullif(sum(base.num_early), 0)), 1) as early_bip_pct
     , round(100 * (sum(num_ground_ball) / nullif(sum(num_batted_ball_event), 0)), 1) as groundball_pct
     , round(100 * (sum(num_line_drive) / nullif(sum(num_batted_ball_event), 0)), 1) as linedrive_pct
     , round(100 * (sum(num_fly_ball) / nullif(sum(num_batted_ball_event), 0)), 1) as flyball_pct
     , round(100 * (sum(num_if_fly_ball) / nullif(sum(num_batted_ball_event), 0)), 1) as infield_flyball_pct
     , round(100 * (sum(num_weak_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as weak_pct
     , round(100 * (sum(num_medium_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as medium_pct
     , round(100 * (sum(num_hard_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as hard_pct
     , round(100 * (sum(num_pulled_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as pull_pct
     , round(100 * (sum(num_opposite_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as opposite_field_pct
     , round(100 * (sum(num_swing) / nullif(sum(base.num_pitches), 0)), 1) as swing_pct
     , round(100 * (sum(num_o_swing) / nullif(sum(num_swing), 0)), 1) as o_swing_pct
     , round(100 * (sum(num_z_swing) / nullif(sum(num_swing), 0)), 1) as z_swing_pct
     , round(100 * (sum(num_contact) / nullif(sum(num_swing), 0)), 1) as contact_pct
     , round(100 * (sum(num_o_contact) / nullif(sum(num_o_swing), 0)), 1) as o_contact_pct
     , round(100 * (sum(num_z_contact) / nullif(sum(num_z_swing), 0)), 1) as z_contact_pct
     , round(100 * (sum(num_whiff) / nullif(sum(num_swing), 0)), 1) as swinging_strike_pct
     , round(100 * (sum(num_called_strike) / nullif(sum(base.num_pitches), 0)), 1) as called_strike_pct
     , round(100 * (sum(num_called_strike_plus_whiff) / nullif(sum(base.num_pitches), 0)), 1) as csw_pct
     , round(100 * (sum(num_early_called_strike) / nullif(sum(num_early), 0)), 1) as early_called_strike_pct
     , round(100 * (sum(num_late_o_swing) / nullif(sum(num_late), 0)), 1) as late_o_swing_pct
     , round(100 * (sum(num_first_pitch_strike) / nullif(sum(num_pa), 0)), 1) as f_strike_pct
     , round(100 * (sum(num_true_first_pitch_strike) / nullif(sum(num_pa), 0)), 1) as true_f_strike_pct
     , round(100 * (sum(num_put_away) / nullif(sum(num_late), 0)), 1) as put_away_pct
     , round(sum(num_hit) / nullif(sum(num_ab), 0), 3) as batting_average
     , round(100 * (sum(num_k) / nullif(sum(num_pa), 0)), 1) as strikeout_pct
     , round(100 * (sum(num_bb) / nullif(sum(num_pa), 0)), 1) as walk_pct
     , round(100 * (sum(num_hr) / nullif(sum(num_fly_ball), 0)), 1) as hr_flyball_pct
     , round(((sum(num_hit) - sum(num_hr)) / nullif((sum(num_ab) - sum(num_hr) - sum(num_k) + sum(num_sacrifice)), 0)), 3) as babip_pct
     , round(sum(num_hit) / nullif((sum(num_ab) - sum(num_k) + sum(num_sacrifice)), 0), 3) as bacon_pct
     , round((sum(num_hit) + sum(num_bb) + sum(num_hbp)) / nullif((sum(num_ab) + sum(num_bb) + sum(num_sacrifice) + sum(num_hbp)), 0), 3) as on_base_pct
     , round((sum(num_hit) + sum(num_bb)) / nullif(sum(num_outs) / 3, 0), 2) as whip
     , round(nullif(sum(num_outs) / 3, 0), 1) as num_ip
     , sum(num_zone)                                             as num_zone
     , sum(total_velo)                                           as total_velo
     , sum(num_velo)                                             as num_velo
     , sum(num_armside)                                          as num_armside
     , sum(num_gloveside)                                        as num_gloveside
     , sum(num_inside)                                           as num_inside
     , sum(num_outside)                                          as num_outside
     , sum(num_horizontal_middle)                                as num_horizontal_middle
     , sum(num_high)                                             as num_high
     , sum(num_middle)                                           as num_middle
     , sum(num_low)                                              as num_low
     , sum(num_heart)                                            as num_heart
     , sum(num_early)                                            as num_early
     , sum(num_late)                                             as num_late
     , sum(num_behind)                                           as num_behind
     , sum(num_non_bip_strike)                                   as num_non_bip_strike
     , sum(num_batted_ball_event)                                as num_batted_ball_event
     , sum(num_early_bip)                                        as num_early_bip
     , sum(num_fastball)                                         as num_fastball
     , sum(num_secondary)                                        as num_secondary
     , sum(num_early_secondary)                                  as num_early_secondary
     , sum(num_late_secondary)                                   as num_late_secondary
     , sum(num_called_strike)                                    as num_called_strike
     , sum(num_early_called_strike)                              as num_early_called_strike
     , sum(num_called_strike_plus_whiff)                         as num_called_strike_plus_whiff
     , sum(num_put_away)                                         as num_put_away
     , sum(num_swing)                                            as num_swing
     , sum(num_whiff)                                            as num_whiff
     , sum(num_contact)                                          as num_contact
     , sum(num_foul)                                             as num_foul
     , sum(num_first_pitch_swing)                                as num_first_pitch_swing
     , sum(num_first_pitch_strike)                               as num_first_pitch_strike
     , sum(num_true_first_pitch_strike)                          as num_true_first_pitch_strike
     , sum(num_plus_pitch)                                       as num_plus_pitch
     , sum(num_z_swing)                                          as num_z_swing
     , sum(num_z_contact)                                        as num_z_contact
     , sum(num_o_swing)                                          as num_o_swing
     , sum(num_o_contact)                                        as num_o_contact
     , sum(num_early_o_swing)                                    as num_early_o_swing
     , sum(num_early_o_contact)                                  as num_early_o_contact
     , sum(num_late_o_swing)                                     as num_late_o_swing
     , sum(num_late_o_contact)                                   as num_late_o_contact
     , sum(num_pulled_bip)                                       as num_pulled_bip
     , sum(num_opposite_bip)                                     as num_opposite_bip
     , sum(num_line_drive)                                       as num_line_drive
     , sum(num_fly_ball)                                         as num_fly_ball
     , sum(num_if_fly_ball)                                      as num_if_fly_ball
     , sum(num_ground_ball)                                      as num_ground_ball
     , sum(num_weak_bip)                                         as num_weak_bip
     , sum(num_medium_bip)                                       as num_medium_bip
     , sum(num_hard_bip)                                         as num_hard_bip
     , sum(num_outs)                                             as num_outs
     , sum(num_pa)                                               as num_pa
     , sum(num_ab)                                               as num_ab
     , sum(num_1b)                                               as num_1b
     , sum(num_2b)                                               as num_2b
     , sum(num_3b)                                               as num_3b
     , sum(num_hr)                                               as num_hr
     , sum(num_bb)                                               as num_bb
     , sum(num_ibb)                                              as num_ibb
     , sum(num_hbp)                                              as num_hbp
     , sum(num_sacrifice)                                        as num_sacrifice
     , sum(num_k)                                                as num_k
     , sum(num_hit)                                              as num_hit
     , sum(num_runs)                                             as num_runs
     , sum(num_barrel)                                           as num_barrel
     , sum(total_launch_speed)                                   as total_launch_speed
     , sum(num_launch_speed)                                     as num_launch_speed
     , sum(total_launch_angle)                                   as total_launch_angle
     , sum(num_launch_angle)                                     as num_launch_angle
     , sum(total_release_extension)                              as total_release_extension
     , sum(num_release_extension)                                as num_release_extension
     , sum(total_spin_rate)                                      as total_spin_rate
     , sum(num_spin_rate)                                        as num_spin_rate
     , sum(total_x_movement)                                     as total_x_movement
     , sum(num_x_movement)                                       as num_x_movement
     , sum(total_z_movement)                                     as total_z_movement
     , sum(num_z_movement)                                       as num_z_movement

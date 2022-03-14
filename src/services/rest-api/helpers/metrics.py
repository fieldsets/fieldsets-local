import pandas as pd
import numpy as np
import math


# Advanced Tab
def velocity(num_velocity, total_velocity):

    if num_velocity == 0 or math.isnan(num_velocity):
        return float('NaN')
    elif math.isnan(total_velocity):
        return float('NaN')
    else:
        return total_velocity / num_velocity


def barrelpercentage(num_barrel, num_bbe):

    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    elif math.isnan(num_barrel):
        return float('NaN')
    else:
        return 100 * (num_barrel / num_bbe)


def foulpercentage(num_foul, num_pitches):

    if num_pitches == 0:
        return float('NaN')
    else:
        return 100 * (num_foul / num_pitches)


def pluspercentage(num_plus, num_pitches):

    if num_pitches == 0:
        return float('NaN')
    else:
        return 100 * (num_plus / num_pitches)


def firstpitchswingpercentage(num_first_pitch_swing, num_ab):

    if num_ab == 0 or math.isnan(num_ab):
        return float('NaN')
    else:
        return 100 * (num_first_pitch_swing / num_ab)


def earlyocontactpercentage(num_early_o_contact, num_o_contact):

    if num_o_contact == 0 or math.isnan(num_o_contact):
        return float('NaN')
    else:
        return 100 * (num_early_o_contact / num_o_contact)


def lateocontactpercentage(num_late_o_contact, num_o_contact):

    if num_o_contact == 0 or math.isnan(num_o_contact):
        return float('NaN')
    else:
        return 100 * (num_late_o_contact / num_o_contact)


def launchspeed(num_launch_speed, total_launch_speed):

    if num_launch_speed == 0 or math.isnan(num_launch_speed):
        return float('NaN')
    elif math.isnan(total_launch_speed):
        return float('NaN')
    else:
        return total_launch_speed / float(num_launch_speed)


def launchangle(num_launch_angle, total_launch_angle):

    if num_launch_angle == 0 or math.isnan(num_launch_angle):
        return float('NaN')
    elif math.isnan(total_launch_angle):
        return float('NaN')
    else:
        return total_launch_angle / float(num_launch_angle)


def releaseextension(num_release_extension, total_release_extension):

    if num_release_extension == 0 or math.isnan(num_release_extension):
        return float('NaN')
    elif math.isnan(total_release_extension):
        return float('NaN')
    else:
        return total_release_extension / float(num_release_extension)


def spinrate(num_spin_rate, total_spin_rate):

    if num_spin_rate == 0 or math.isnan(num_spin_rate):
        return float('NaN')
    elif math.isnan(total_spin_rate):
        return float('NaN')
    else:
        return total_spin_rate / float(num_spin_rate)


def xmovement(num_x_movement, total_x_movement):

    if num_x_movement == 0 or math.isnan(num_x_movement):
        return float('NaN')
    elif math.isnan(total_x_movement):
        return float('NaN')
    else:
        return total_x_movement / float(num_x_movement)


def zmovement(num_z_movement, total_z_movement):

    if num_z_movement == 0 or math.isnan(num_z_movement):
        return float('NaN')
    elif math.isnan(total_z_movement):
        return float('NaN')
    else:
        return total_z_movement / float(num_z_movement)



# Approach Tab
def armsidepercentage(num_armside, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_armside / num_pitches)


def glovesidepercentage(num_gloveside, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_gloveside / num_pitches)


def insidepercentage(num_inside, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_inside / num_pitches)


def outsidepercentage(num_outside, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
         return float('NaN')
    else:
        return 100 * (num_outside / num_pitches)


def highlocpercentage(num_highloc, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
         return float('NaN')
    else:
        return 100 * (num_highloc / num_pitches)

def hmidlocpercentage(num_hmiddle, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_hmiddle / num_pitches)


def vmidlocpercentage(num_vmidloc, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_vmidloc / num_pitches)


def lowlocpercentage(num_lowloc, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
         return float('NaN')
    else:
        return 100 * (num_lowloc / num_pitches)


def heartpercentage(num_heart, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
         return float('NaN')
    else:
        return 100 * (num_heart / num_pitches)


def earlypercentage(num_early, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
         return float('NaN')
    else:
        return 100 * (num_early / num_pitches)


def behindpercentage(num_behind, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
         return float('NaN')
    else:
        return 100 * (num_behind / num_pitches)


def latepercentage(num_late, num_pitches):

    if num_pitches == 0 or math.isnan(num_pitches):
         return float('NaN')
    else:
        return 100 * (num_late / num_pitches)


def zonepercentage(num_zone, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_zone / num_pitches)


def nonbipstrikepercentage(num_nonbipstrike, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_nonbipstrike / num_pitches)


def earlybippercentage(num_earlybip, num_early):
    if num_early == 0 or math.isnan(num_early):
        return float('NaN')
    else:
        return 100 * (num_earlybip / num_early)


def fastballpercentage(num_fastball, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_fastball / num_pitches)


def earlysecondarypercentage(num_earlysecondary, num_early):
    if num_early == 0 or math.isnan(num_early):
        return float('NaN')
    else:
        return 100 * (num_earlysecondary / num_early)


def latesecondarypercentage(num_latesecondary, num_late):
    if num_late == 0 or math.isnan(num_late):
        return float('NaN')
    else:
        return 100 * (num_latesecondary / num_late)


# Batted Ball Tab
def groundballpercentage(num_groundball, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_groundball / num_bbe)


def linedrivepercentage(num_linedrive, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_linedrive / num_bbe)


def flyballpercentage(num_flyball, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_flyball / num_bbe)


def infieldflyballpercentage(num_infieldflyball, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_infieldflyball / num_bbe)


def weakpercentage(num_weak, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_weak / num_bbe)


def mediumpercentage(num_medium, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_medium / num_bbe)


def hardpercentage(num_hard, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_hard / num_bbe)


def pullpercentage(num_pull, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_pull / num_bbe)


def oppositefieldpercentage(num_oppositefield, num_bbe):
    if num_bbe == 0 or math.isnan(num_bbe):
        return float('NaN')
    else:
        return 100 * (num_oppositefield / num_bbe)


def babip(num_hits, num_homerun, num_at_bat, num_strikeout, num_sacrifice):
    numerator = num_hits - num_homerun
    denominator = num_at_bat - num_homerun - num_strikeout + num_sacrifice
    if denominator == 0:
        return float('NaN')
    else:
        return numerator / denominator


def bacon(num_hits, num_at_bat, num_strikeout, num_sacrifice):
    numerator = num_hits
    denominator = num_at_bat - num_strikeout + num_sacrifice
    if denominator == 0:
        return float('NaN')
    else:
        return numerator / denominator


# Plate Discipline Tab
# Calculations Needed: OSwing%, Zone%, SwStrk%, CS%, CSW%, Contact%, ZContact%, OContact%, Swing%, EarlyCalledStrike%
# 2StrkOSwing%, FStrike%, TrueFStrike%
def swingpercentage(num_swing, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_swing / num_pitches)


def oswingpercentage(num_oswing, num_swing):
    if num_swing == 0 or math.isnan(num_swing):
        return float('NaN')
    else:
        return 100 * (num_oswing / num_swing)


def zswingpercentage(num_zswing, num_swing):
    if num_swing == 0 or math.isnan(num_swing):
        return float('NaN')
    else:
        return 100 * (num_zswing / num_swing)


def contactpercentage(num_contact, num_swing):
    if num_swing == 0 or math.isnan(num_swing):
        return float('NaN')
    else:
        return 100 * (num_contact / num_swing)


def ocontactpercentage(num_ocontact, num_oswing):
    if num_oswing == 0 or math.isnan(num_oswing):
        return float('NaN')
    else:
        return 100 * (num_ocontact / num_oswing)


def zcontactpercentage(num_zcontact, num_zswing):
    if num_zswing == 0 or math.isnan(num_zswing):
        return float('NaN')
    else:
        return 100 * (num_zcontact / num_zswing)


def swingingstrikepercentage(num_whiff, num_swing):
    if num_swing == 0 or math.isnan(num_swing):
        return float('NaN')
    else:
        return 100 * (num_whiff / num_swing)


def calledstrikepercentage(num_calledstrike, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_calledstrike / num_pitches)


def calledstrikespluswhiffspercentage(num_csw, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_csw / num_pitches)


def earlycalledstrikepercentage(num_earlycs, num_early):
    if num_early == 0 or math.isnan(num_early):
        return float('NaN')
    else:
        return 100 * (num_earlycs / num_early)


def lateoswingpercentage(num_lateoswing, num_late):
    if num_late == 0 or math.isnan(num_late):
        return float('NaN')
    else:
        return 100 * (num_lateoswing / num_late)


def fstrikepercentage(num_fstrike, num_pa):
    if num_pa == 0 or math.isnan(num_pa):
        return float('NaN')
    else:
        return 100 * (num_fstrike / num_pa)


def truefstrikepercentage(num_truefstrike, num_pa):
    if num_pa == 0 or math.isnan(num_pa):
        return float('NaN')
    else:
        return 100 * (num_truefstrike / num_pa)


# Overview Tab
def usagepercentage(num_pitch, num_pitches):
    if num_pitches == 0 or math.isnan(num_pitches):
        return float('NaN')
    else:
        return 100 * (num_pitch / num_pitches)


def putawaypercentage(num_putaway, num_late):
    if num_late == 0 or math.isnan(num_late):
        return float('NaN')
    else:
        return 100 * (num_putaway / num_late)


def battingaverage(num_hits, num_at_bat):
    if num_at_bat == 0 or math.isnan(num_at_bat):
        return float('NaN')
    else:
        return num_hits / num_at_bat


def onbasepercentage(num_hit, num_bb, num_hbp, num_at_bat, num_sac_fly):
    numerator = num_hit + num_bb + num_hbp
    denominator = num_at_bat + num_bb + num_sac_fly + num_hbp
    if denominator == 0:
        return float('NaN')
    else:
        return numerator / denominator


def weightedonbasepercentage(year, num_ab, num_bb, num_ibb, num_hbp, num_sf, num_1b, num_2b, num_3b, num_hr):
    year = str(year)
    const = {
        "2020": {
            "wBB": 0.692,
            "wHBP": 0.723,
            "w1B": 0.882,
            "w2B": 1.250,
            "w3B": 1.582,
            "wHR": 2.030},
        "2019": {
            "wBB": 0.690,
            "wHBP": 0.719,
            "w1B": 0.870,
            "w2B": 1.217,
            "w3B": 1.529,
            "wHR": 1.940},
        "2018": {
            "wBB": 0.690,
            "wHBP": 0.720,
            "w1B": 0.880,
            "w2B": 1.247,
            "w3B": 1.578,
            "wHR": 2.031},
        "2017": {
            "wBB": 0.693,
            "wHBP": 0.723,
            "w1B": 0.877,
            "w2B": 1.232,
            "w3B": 1.552,
            "wHR": 1.980},
        "2016": {
            "wBB": 0.691,
            "wHBP": 0.721,
            "w1B": 0.878,
            "w2B": 1.242,
            "w3B": 1.569,
            "wHR": 2.015},
        "2015": {
            "wBB": 0.687,
            "wHBP": 0.718,
            "w1B": 0.881,
            "w2B": 1.256,
            "w3B": 1.594,
            "wHR": 2.065}
    }

    if num_ab == 0 or math.isnan(num_ab):
        return float('NaN')
    else:
        numerator = (const[year]['wBB'] * float(num_bb - num_ibb)) + (const[year]['wHBP'] * float(num_hbp)) + (
                const[year]['w1B'] * float(num_1b)) + (const[year]['w2B'] * float(num_2b)) + (
                const[year]['w3B'] * float(num_3b)) + (const[year]['wHR'] * float(num_hr))
        denominator = float(num_ab + num_bb - num_ibb + num_sf + num_hbp)
        if denominator == 0 or math.isnan(denominator):
            return float('NaN')
        return numerator / denominator


def strikeoutpercentage(num_strikeout, num_pa):
    if num_pa == 0 or math.isnan(num_pa):
        return float('NaN')
    else:
        return 100 * (num_strikeout / num_pa)


def walkpercentage(num_bb, num_pa):
    if num_pa == 0 or math.isnan(num_pa):
        return float('NaN')
    else:
        return 100 * (num_bb / num_pa)


def homerunflyballratio(num_hr, num_flyball):
    if num_flyball == 0 or math.isnan(num_flyball):
        return float('NaN')
    return num_hr / num_flyball


def whip(num_hits, num_bb, num_outs):
    if num_outs == 0 or math.isnan(num_outs):
        return float('NaN')
    else:
        return (num_hits + num_bb) / (num_outs / 3)


def ip(num_outs):
    if math.isnan(num_outs):
        return float('NaN')
    else:
        return num_outs / 3

# Standard Tab
# Calculations Needed:
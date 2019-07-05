#####################################################################
#
# First Encounter setup file
# Created by Encounter(R) RTL Compiler on 07/03/2019 13:58:49
#
#
#####################################################################


# Design Import
###########################################################
source rc_enc_des/rc.globals
init_design


# Mode Setup
###########################################################
source rc_enc_des/rc.mode


# The following is partial list of suggested prototyping commands.
# These commands are provided for reference only.
# Please consult the First Encounter documentation for more information.
#   Placement...
#     ecoPlace                     ;# legalizes placement including placing any cells that may not be placed
#     - or -
#     placeDesign -incremental     ;# adjusts existing placement
#     - or -
#     placeDesign                  ;# performs detailed placement discarding any existing placement
#   Optimization & Timing...
#     optDesign -preCTS            ;# performs trial route and optimization
#     timeDesign -preCTS           ;# performs timing analysis


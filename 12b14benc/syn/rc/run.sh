#!/usr/bin/env tcsh
#
# Script to synthesize ssp 12b14b encoder using Cadence RC
# Faisal T. Abu-Nimeh 20171005

# load rc env variables
module load tools/rc/14.28.000
setenv TSMC130_DIR /home/slac_tech/tsmc130pdk/TSMCHOME/digital

# rc flow is in rtl.tcl
rc -f rtl.tcl

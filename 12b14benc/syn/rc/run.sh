#!/usr/bin/env tcsh
#
# Script to synthesize ssp 12b14b encoder using Cadence RC
# Faisal T. Abu-Nimeh 20171005

# load rc env variables
#module load tools/rc/14.28.000
module load tools/rc/latest
setenv TSMC130_DIR /home/slac_designs/PPA/cryo_v2.0/tsmc130mm/TSMCHOME/digital

# rc flow is in rtl.tcl
#rc -f rtl.tcl
rc -f syn.tcl

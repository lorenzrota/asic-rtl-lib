#!/usr/bin/env tcsh
#
# Script to synthesize ssp 12b14b encoder using Synopsys DC
# Faisal T. Abu-Nimeh 20171005

# load vcs env variables
source /afs/slac/g/reseng/synopsys/syn/M-2016.12-SP5-1/settings.csh
setenv TSMC130_DIR /u1/abunimeh/pdk/TSMCHOME/digital

# dc flow is in rtl.tcl
dc_shell-xg-t -f rtl.tcl

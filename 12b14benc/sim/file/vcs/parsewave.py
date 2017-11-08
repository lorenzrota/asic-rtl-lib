#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Parse waveform output from hspice and prepare it to stimulate vhdl

:Author: Faisal Abu-Nimeh (abunimeh@slac.stanford.edu)
:Licesnse: https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
:Date: 20171107
:Style: OpenStack Style Guidelines https://docs.openstack.org/developer/hacking/
:vcs_id: $Id$
"""

import logging
import numpy as np
import sys

sfile = 'test.txt'  # input file from hspice
ofile = 'in.txt'  # output file for stimulating vhdl testbench
# myloglevel = logging.DEBUG
myloglevel = logging.INFO

# set logging based on args
logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s', level=myloglevel)

# openfiles
try:
    val, clk = np.loadtxt(sfile, dtype=np.bool, skiprows=3, delimiter=' ', usecols=(2, 3), unpack=True)
except IOError as e:
    logging.error("[%s] cannot be opened!", sfile)
    logging.error(e)
    sys.exit(1)
logging.debug("[%s] opened for reading", sfile)

# add dummy clk switches at start and end
clk_se = np.insert(clk, 0, np.invert(clk[0]))
clk_se = np.insert(clk_se, clk_se.size, np.invert(clk[-1]))

clk_diff = np.ediff1d(clk_se)  # diff bitween consecutive rows
clk_nzero = np.nonzero(clk_diff)[0]  # indecies of nonzero elements
clk_offset = np.ediff1d(clk_nzero)//2  # stable value offset
clk_stable_idx = np.ediff1d(clk_nzero)//2 + clk_nzero[:-1]  # stable index
val_stable = val[clk_stable_idx]  # stable values
clk_stable = clk[clk_stable_idx]  # stable values

# check if stream is correct
clk_check = clk_stable[1:] + clk_stable[:-1]
if not np.all(clk_check):
    logging.error("clk is not toggling correctly")
    sys.exit(1)
else:
    logging.debug("clk is OK")

# save stable values to empty array then save it
out = np.zeros((val_stable.size, 2), dtype=np.int)
out[:, 0] = val_stable
out[:, 1] = clk_stable

try:
    np.savetxt('in.txt', out, delimiter=' ', fmt='%u')
except IOError as e:
    logging.error("[%s] cannot be opened!", sfile+'.new')
    logging.error(e)
    sys.exit(1)
logging.debug("[%s] written", sfile+'.new')
logging.info("Done")

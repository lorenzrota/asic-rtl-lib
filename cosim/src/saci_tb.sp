* Full-Chip Co-Simulation
* SACI Slave Test bench
* Faisal Abu-Nimeh 20180619

.global G_DG
.global G_DS

*** -- DUNE libs
.lib rf013_dune.l TT_25
.lib rf013_dune.l TT_lvt25
.lib rf013_dune.l TT_MIM
.lib rf013_dune.l TT
.lib rf013_dune.l TT_RES
.lib rf013_dune.l TT_DIO

*** -- SACI SLAVE SPICE netlist
.include SaciSlave2.sp

*** -- params
.temp -186 $ C

*** global supplies
* G_DG = 0
V_G_DG G_DG 0  DC 0
V_G_DS G_DS 0  DC 1.0

$ .option finesim_vector=saci.vec
.option finesim_mode=spicemd

*** -- sim options
.option post probe
.probe v(*)
*** -- finesim options
* .include fs.opt
.end

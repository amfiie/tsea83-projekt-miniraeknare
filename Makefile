# Makefile for hardware implementation on Xilinx FPGAs and ASICs
# Author: Andreas Ehliar <ehliar@isy.liu.se>
# 
# T is the testbench file for this project
# S is the synthesizable sources for this project
# U is the UCF file
# PART is the part

# Important makefile targets:
# make lab.sim		GUI simulation
# make lab.simc		batch simulation
# make lab.synth	Synthesize
# make lab.route	Route the design
# make lab.bitgen	Generate bit file
# make lab.timing	Generate timing report
# make lab.clean	Use whenever you change settings in the Makefile!
# make lab.prog		Downloads the bitfile to the FPGA. NOTE: Does not
#                       rebuild bitfile if source files have changed!
# make clean            Removes all generated files for all projects. Also
#                       backup files (*~) are removed.
# 
# VIKTIG NOTERING: 	Om du ändrar vilka filer som finns med i projektet så måste du köra
#                  	make lab.clean
#
# Syntesrapporten ligger i lab-synthdir/xst/synth/design.syr
# Maprapporten (bra att kolla i för arearapportens skull) ligger i lab-synthdir/layoutdefault/design_map.mrp
# Timingrapporten (skapas av make lab.timing) ligger i lab-synthdir/layoutdefault/design.trw

# (Or proj2.simc, proj2.sim, etc, depending on the name of the
# project)

#XILINX_INIT = source /sw/xilinx/ise_12.4i/ISE_DS/settings64.sh;
XILINX_INIT = source /opt/xilinx_ise/14.7/settings64.sh;
PART=xc6slx16-3-csg324


pipeline.%: S=src/pipeline.vhd src/pm.vhd src/alu.vhd src/register_file.vhd src/kbd_enc.vhd src/bootloader.vhd
pipeline.%: T=src/testbenches/pipeline_tb.vhd
pipeline.%: U=Nexys3_Master.ucf

pipeline_bl.%: S=src/pipeline.vhd src/pm.vhd src/alu.vhd src/register_file.vhd src/kbd_enc.vhd src/bootloader.vhd
pipeline_bl.%: T=src/testbenches/pipeline_bl_tb.vhd
pipeline_bl.%: U=Nexys3_Master.ucf

alu.%: S=src/alu.vhd
alu.%: T=src/testbenches/alu_tb.vhd
alu.%: U=Nexys3_Master.ucf

kbd_enc.%: S=src/kbd_enc.vhd
kbd_enc.%: T=src/testbenches/kbd_enc_tb.vhd
kbd_enc.%: U=Nexys3_Master.ucf

bootloader.%: S=src/bootloader.vhd src/bootloader_uart.vhd
bootloader.%: T=src/testbenches/bootloader_tb.vhd
bootloader.%: U=Nexys3_Master.ucf

computer.%: S=src/computer.vhd src/pipeline.vhd src/pm.vhd src/alu.vhd src/dm.vhd src/addr_dec.vhd src/register_file.vhd src/kbd_enc.vhd src/VGA_motor.vhd src/pict_mem.vhd src/tile_mem.vhd src/bootloader.vhd src/bootloader_uart.vhd
computer.%: T=src/testbenches/computer_tb.vhd
computer.%: U=Nexys3_Master.ucf

computer_bl.%: S=src/computer.vhd src/pipeline.vhd src/pm.vhd src/alu.vhd src/dm.vhd src/addr_dec.vhd src/register_file.vhd src/kbd_enc.vhd src/VGA_motor.vhd src/pict_mem.vhd src/tile_mem.vhd src/bootloader.vhd src/bootloader_uart.vhd
computer_bl.%: T=src/testbenches/computer_bl_tb.vhd
computer_bl.%: U=Nexys3_Master.ucf

# Det här är ett exempel på hur man kan skriva en testbänk som är
# relevant, även om man kör en simulering i batchläge (make batchlab.simc)
#batchlab.%: S=cpu_embryo.vhd
#batchlab.%: T=cpu_embryo_tb.vhd
#batchlab.%: U=Nexys3_Master.ucf


# Misc functions that are good to have
include build/util.mk
# Setup simulation environment
include build/vsim.mk
# Setup synthesis environment
include build/xst.mk
# Setup backend flow environment
include build/xilinx-par.mk
# Setup tools for programming the FPGA
include build/digilentprog.mk



# Alternative synthesis methods
# The following is for ASIC synthesis
#include design_compiler.mk
# The following is for synthesis to a Xilinx target using Precision.
#include precision-xilinx.mk




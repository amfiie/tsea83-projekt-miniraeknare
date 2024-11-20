vcom "+acc" ../src/computer.vhd ../src/pipeline.vhd ../src/pm.vhd ../src/alu.vhd ../src/dm.vhd ../src/addr_dec.vhd ../src/register_file.vhd ../src/kbd_enc.vhd ../src/VGA_motor.vhd ../src/pict_mem.vhd ../src/tile_mem.vhd ../src/bootloader.vhd ../src/bootloader_uart.vhd
vcom "+acc" ../src/testbenches/computer_tb.vhd
vsim computer_tb


add wave -position insertpoint sim:/computer_tb/comput/clk
add wave -position insertpoint sim:/computer_tb/comput/PICT_MEM_map/addr_pipe
#add wave -position insertpoint sim:/computer_tb/comput/Hsync
#add wave -position insertpoint sim:/computer_tb/comput/Vsync
#add wave -position insertpoint sim:/computer_tb/comput/vgaRed
#add wave -position insertpoint sim:/computer_tb/comput/vgaGreen
#add wave -position insertpoint sim:/computer_tb/comput/vgaBlue
#add wave -position insertpoint sim:/computer_tb/comput/IOR
add wave -position insertpoint sim:/computer_tb/comput/we_vector
add wave -position insertpoint sim:/computer_tb/comput/mem_addr
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/PC
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/PC0
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/PC1
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/PC2
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/IR0
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/IR1
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/IR2
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/IR3
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/IR4
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/K_flag
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/halted
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/N_flag
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/alu_result
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/stall1
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/stall2
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/X_REG
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Y_REG
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/data_forward_x
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/data_forward_y
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/D3
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/D4
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Level_4_data
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/stack_ptr
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R0
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R1
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R2
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R3
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R4
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R5
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R6
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R7
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R8
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R9
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R10
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R11
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R12
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R13
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R14
add wave -position insertpoint sim:/computer_tb/comput/CPU_map/Register_map/R15

add wave -position insertpoint sim:/computer_tb/comput/CPU_map/ALU_map/Nc

add wave -position insertpoint sim:/computer_tb/comput/DM_map/dm
#add wave -position insertpoint sim:/computer_tb/comput/PICT_MEM_map/*
#add wave -position insertpoint sim:/computer_tb/comput/TILE_MEM_map/*
#add wave -position insertpoint sim:/computer_tb/comput/VGAM_map/*


restart -f
run 50000ns

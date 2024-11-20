all:
	python3 assembly.py boot main.hex
reset:
	cd .. && make computer.prog
	python3 assembly.py boot main.hex
clear:
	cd .. && make computer.prog
compile:
	cd .. && make computer.prog
	python3 assembly.py parse main.asm -c --boot -o main.hex
vhdl:
	python3 write_pm.py
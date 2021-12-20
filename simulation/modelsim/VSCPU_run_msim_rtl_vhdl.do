transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Data/QuartusPrimeWorkingDirectory/VSCPU/VSCPU.vhd}

vcom -93 -work work {C:/Data/QuartusPrimeWorkingDirectory/VSCPU/tb_VSCPU.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  tb_vscpu

add wave *
view structure
view signals
run -all

-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

-- DATE "08/31/2021 17:25:19"

-- 
-- Device: Altera 5CGXFC7C7F23C8 Package FBGA484
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY ALTERA_LNSIM;
LIBRARY CYCLONEV;
LIBRARY IEEE;
USE ALTERA_LNSIM.ALTERA_LNSIM_COMPONENTS.ALL;
USE CYCLONEV.CYCLONEV_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	MajorityLogic IS
    PORT (
	A : IN std_logic;
	B : IN std_logic;
	C : IN std_logic;
	D : IN std_logic;
	E : IN std_logic;
	Y : OUT std_logic
	);
END MajorityLogic;

-- Design Ports Information
-- Y	=>  Location: PIN_P19,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- B	=>  Location: PIN_R16,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- C	=>  Location: PIN_P22,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- A	=>  Location: PIN_R21,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- D	=>  Location: PIN_R17,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- E	=>  Location: PIN_R15,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF MajorityLogic IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_A : std_logic;
SIGNAL ww_B : std_logic;
SIGNAL ww_C : std_logic;
SIGNAL ww_D : std_logic;
SIGNAL ww_E : std_logic;
SIGNAL ww_Y : std_logic;
SIGNAL \~QUARTUS_CREATED_GND~I_combout\ : std_logic;
SIGNAL \B~input_o\ : std_logic;
SIGNAL \A~input_o\ : std_logic;
SIGNAL \E~input_o\ : std_logic;
SIGNAL \C~input_o\ : std_logic;
SIGNAL \D~input_o\ : std_logic;
SIGNAL \Y~0_combout\ : std_logic;
SIGNAL \ALT_INV_C~input_o\ : std_logic;
SIGNAL \ALT_INV_B~input_o\ : std_logic;
SIGNAL \ALT_INV_A~input_o\ : std_logic;
SIGNAL \ALT_INV_D~input_o\ : std_logic;
SIGNAL \ALT_INV_E~input_o\ : std_logic;

BEGIN

ww_A <= A;
ww_B <= B;
ww_C <= C;
ww_D <= D;
ww_E <= E;
Y <= ww_Y;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
\ALT_INV_C~input_o\ <= NOT \C~input_o\;
\ALT_INV_B~input_o\ <= NOT \B~input_o\;
\ALT_INV_A~input_o\ <= NOT \A~input_o\;
\ALT_INV_D~input_o\ <= NOT \D~input_o\;
\ALT_INV_E~input_o\ <= NOT \E~input_o\;

-- Location: IOOBUF_X89_Y9_N39
\Y~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \Y~0_combout\,
	devoe => ww_devoe,
	o => ww_Y);

-- Location: IOIBUF_X89_Y8_N4
\B~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_B,
	o => \B~input_o\);

-- Location: IOIBUF_X89_Y8_N38
\A~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_A,
	o => \A~input_o\);

-- Location: IOIBUF_X89_Y6_N21
\E~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_E,
	o => \E~input_o\);

-- Location: IOIBUF_X89_Y8_N55
\C~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_C,
	o => \C~input_o\);

-- Location: IOIBUF_X89_Y8_N21
\D~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_D,
	o => \D~input_o\);

-- Location: LABCELL_X88_Y8_N30
\Y~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \Y~0_combout\ = ( \C~input_o\ & ( \D~input_o\ & ( ((\E~input_o\) # (\A~input_o\)) # (\B~input_o\) ) ) ) # ( !\C~input_o\ & ( \D~input_o\ & ( (!\B~input_o\ & (\A~input_o\ & \E~input_o\)) # (\B~input_o\ & ((\E~input_o\) # (\A~input_o\))) ) ) ) # ( 
-- \C~input_o\ & ( !\D~input_o\ & ( (!\B~input_o\ & (\A~input_o\ & \E~input_o\)) # (\B~input_o\ & ((\E~input_o\) # (\A~input_o\))) ) ) ) # ( !\C~input_o\ & ( !\D~input_o\ & ( (\B~input_o\ & (\A~input_o\ & \E~input_o\)) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000100000001000101110001011100010111000101110111111101111111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_B~input_o\,
	datab => \ALT_INV_A~input_o\,
	datac => \ALT_INV_E~input_o\,
	datae => \ALT_INV_C~input_o\,
	dataf => \ALT_INV_D~input_o\,
	combout => \Y~0_combout\);

-- Location: LABCELL_X60_Y14_N0
\~QUARTUS_CREATED_GND~I\ : cyclonev_lcell_comb
-- Equation(s):

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000000000000000000000000000000000000000000000000000000000000",
	shared_arith => "off")
-- pragma translate_on
;
END structure;



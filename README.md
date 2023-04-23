# Shake Game for FPGA

This repository contains modules for realisation famous shake game on FPGA.

For those who want repite this project you need choose game.v as top module.

## Module documentation

### button.v
This module processes the signal from the button and converts it into a 1-clock signal when the button is released.

input <br/>
	- rst : reset signal <br/>
	- clk : clock signal <br/>
	- in_key : button signal <br/>
output <br/>
	- out_key : single-clock signal <br/>



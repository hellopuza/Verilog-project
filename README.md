# Shake Game for FPGA

This repository contains modules for realisation famous shake game on FPGA.

For those who want repite this project you need choose game.v as top module.

## Module documentation

### button.v
This module processes the signal from the button and converts it into a 1-clock signal when the button is released.  

**input**  
\- rst : reset signal  
\- clk : clock signal  
\- in_key : button signal  
**output**  
\- out_key : single-clock signal  

### field_calculate.v
The module calculates the field values after the next step

**input**  
\- clk : clock signal 
\- rst : reset signal  
\- step : signal about next step of movement  
\- lengh : register indicating snake's length  
\- snake_xy : snake's coordinates  
**output**  
\- empty_cells : number of empty cells on the field  
\- field : field filled with values  

### snake_calculate.v
Еhe module calculates changes in the coordinates and length of the snake  

**input**  
\- clk : clock signal 
\- rst : reset signal  
\- step : signal about next step of movement  
\- start : signal about start new game  
\- grow : signal about shake's growth  
\- key : pushed direction button  
**output**  
\- lengh : current snake's lengh 
\- snake_xy : snake's coordinates  

### XXXXXX.v
(Description ATTANTION 2 space at end)  

**input**  
\- xxxxxx : xxxxxxxxxxx(2 space at end)  
**output**  
\- xxxxxx : xxxxxxxxxxx(2 space at end)  

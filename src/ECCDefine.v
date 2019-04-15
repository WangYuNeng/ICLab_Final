`ifndef _ECC_DEFINE_
`define _ECC_DEFINE_

parameter MAX_BITS = 256;
parameter MAX_REG = 7;  // lg(MAX_BITS) - 1

// operating mode
parameter 256BITS = 2'b11;
parameter 128BITS = 2'b10;
parameter 64BITS  = 2'b01;
parameter 32BITS  = 2'b00;
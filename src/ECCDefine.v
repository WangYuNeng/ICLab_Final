`ifndef _ECC_DEFINE_
`define _ECC_DEFINE_

parameter MAX_BITS = 256;
parameter MAX_REG = 7;  // lg(MAX_BITS) - 1

// operating mode
parameter BITS256 = 2'b11;
parameter BITS128 = 2'b10;
parameter BITS64  = 2'b01;
parameter BITS32  = 2'b00;
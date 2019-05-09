`ifndef _ECCDefine_VH_
`define _ECCDefine_VH_

`define MAX_BITS 258
`define MAX_BITS_1 256
`define MAX_REG  7  // lg(MAX_BITS) - 1

// operating mode
`define BITS256 2'b11
`define BITS128 2'b10
`define BITS64  2'b01
`define BITS32  2'b00

//window algorithm
`define WINDOW_WIDTH 4
`define PRECAL_NUM 16
`define WIDTH 258

`endif

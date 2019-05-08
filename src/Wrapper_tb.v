`timescale 1ns/10ps
`define CYCLE 20
`define TIME_LIMIT 5000000
`include "ECCDefine.vh"

// `define sdf_file "./ECC_syn.sdf"

module Wrapper_tb;
    // clock reset signal
    reg clk;
    reg rst;

    // reg control signal
    reg i_m_P_valid, i_nP_valid, i_mode;
    
    // reg data
    reg i_a, i_b, i_prime, i_Px, i_Py, i_m, i_nPx, i_nPy;

    //output control signal
    wire o_mP_valid, o_mnP_valid;

    // output data
    wire o_mPx, o_mPy, o_mnPx, o_mnPy;

    // tb
    integer err1, err2, err3, err4, err5, err6, err7, err8;
    reg [`MAX_BITS-1:0] out_mPx, out_mPy;
    reg [`MAX_BITS-1:0] out_mnPx, out_mnPy;
    reg [`MAX_BITS-1:0] data_input  [0:7];
    reg [`MAX_BITS-1:0] data_golden [0:3];
    
    Wrapper top(clk, rst, i_m_P_valid, i_nP_valid, i_mode, i_a, i_b, i_prime, i_Px, i_Py, i_m, i_nPx, i_nPy, o_mP_valid, o_mnP_valid, 
    o_mPx, o_mPy, o_mnPx, o_mnPy);

    `ifdef SDF
	    initial $sdf_annotate(`sdf_file, top);
    `endif

    initial begin
	    clk = 1'b1;
        rst = 1'b1;
	    err1 = 0;
	    err2 = 0;
	    err3 = 0;
	    err4 = 0;
	    err5 = 0;
	    err6 = 0;
	    err7 = 0;
	    err8 = 0;
        i_m_P_valid = 0;
        i_nP_valid = 0;
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
// -----------------------------------------------------------------------------------------------
        $display(" ----------------------------------------------------------------------");
        $display("TEST START !!!");
        $display(" ----------------------------------------------------------------------");
        $display("Pattern 1. 32 bits");
        $readmemh("in32_0.pattern", data_input);
        $readmemh("out32_0.pattern", data_golden);
        fork
            compute_mP(2'b00, 32);
            #(`CYCLE*10) compute_mnP(32);
        join
        check_result(1, err1);
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern 2. 32 bits");
        $readmemh("in32_1.pattern", data_input);
        $readmemh("out32_1.pattern", data_golden);
        fork
            compute_mP(2'b00, 32);
            #(`CYCLE*10) compute_mnP(32);
        join
        check_result(2, err2);
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern 3. 64 bits");
        $readmemh("in64_0.pattern", data_input);
        $readmemh("out64_0.pattern", data_golden);
        fork
            compute_mP(2'b01, 64);
            #(`CYCLE*10) compute_mnP(64);
        join
        check_result(3, err3);
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern 4. 64 bits");
        $readmemh("in64_1.pattern", data_input);
        $readmemh("out64_1.pattern", data_golden);
        fork
            compute_mP(2'b01, 64);
            #(`CYCLE*10) compute_mnP(64);
        join
        check_result(4, err4);
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern 5. 128 bits");
        $readmemh("in128_0.pattern", data_input);
        $readmemh("out128_0.pattern", data_golden);
        fork
            compute_mP(2'b10, 128);
            #(`CYCLE*10) compute_mnP(128);
        join
        check_result(5, err5);
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern 6. 128 bits");
        $readmemh("in128_1.pattern", data_input);
        $readmemh("out128_1.pattern", data_golden);
        fork
            compute_mP(2'b10, 128);
            #(`CYCLE*10) compute_mnP(128);
        join
        check_result(6, err6);
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern 7. 256 bits");
        $readmemh("in256_0.pattern", data_input);
        $readmemh("out256_0.pattern", data_golden);
        fork
            compute_mP(2'b11, 256);
            #(`CYCLE*10) compute_mnP(256);
        join
        check_result(7, err7);
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern 8. 256 bits");
        $readmemh("in256_1.pattern", data_input);
        $readmemh("out256_1.pattern", data_golden);
        fork
            compute_mP(2'b11, 256);
            #(`CYCLE*10) compute_mnP(256);
        join
        check_result(8, err8);
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*10);
        if((err1==0) && (err2==0) && (err3 == 0) && (err4 == 0) && (err5 == 0) && (err6 == 0) && (err7 == 0) && (err8 == 0)) begin
	    	$display("==========================================");
	    	$display("======  Congratulation! You Pass All 8 Tests!  =======");
	    	$display("==========================================");
	    end
	    else begin
	    	$display("===============================");
	    	$display("There are %d errors.", err1+err2+err3+err4+err5+err6+err7+err8);
	    	$display("===============================");
	    end
	    $finish;
    end

    always #(`CYCLE*0.5) clk = ~clk;

    initial begin
        $fsdbDumpfile("ecc.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA;
    end

    initial begin
        #(`TIME_LIMIT*`CYCLE) 
        $display("out of time");
        $finish;
    end

task compute_mP;
    input [1:0] mode;
    input integer bit_num;
    integer i;

    begin
        @(negedge clk); 
            i_m_P_valid = 1'b1;
        @(negedge clk); 
            i_mode = mode[1];
            i_m_P_valid = 1'b0;
        @(negedge clk); 
            i_mode = mode[0];
    for (i=bit_num-1; i>=0; i=i-1) begin
        @(negedge clk);
            i_mode = 1'bx;
            i_a = data_input[0][i]; 
            i_b = data_input[1][i]; 
            i_prime = data_input[2][i];
            i_Px = data_input[3][i];
            i_Py = data_input[4][i];
            i_m = data_input[5][i];
            // i_m_P_valid = 1'b1;
	end

    wait(o_mP_valid === 1'b1);
    for(i=bit_num-1; i>=0; i=i-1) begin
		@(negedge clk);
		out_mPx[i] = o_mPx;
		out_mPy[i] = o_mPy;
	end
    end
endtask

    task compute_mnP;
    input integer bit_num;
    integer i;

    begin
        @(negedge clk); 
            i_nP_valid = 1'b1;           
    for (i=bit_num-1; i>=0; i=i-1) begin
        @(negedge clk);
            i_nP_valid = 1'b0;
            i_nPx = data_input[6][i];
            i_nPy = data_input[7][i];
	end

    wait(o_mnP_valid === 1'b1);
    for(i=bit_num-1; i>=0; i=i-1) begin
		@(negedge clk);
		out_mnPx[i] = o_mnPx;
		out_mnPy[i] = o_mnPy;
	end
    end
    endtask

    task check_result;
    input integer test_id;
    output integer err;
    begin
    err = 0;
    if (out_mPx != data_golden[0]) begin
        $display("mPx Wrong!, expected result is %h, but the responsed result is %h", data_golden[0], out_mPx);
        err = err + 1;
    end
    if (out_mPy != data_golden[1]) begin
        $display("mPy Wrong!, expected result is %h, but the responsed result is %h", data_golden[1], out_mPy);
        err = err + 1;
    end
    if (out_mnPx != data_golden[2]) begin
        $display("mnPx Wrong!, expected result is %h, but the responsed result is %h", data_golden[2], out_mnPx);
        err = err + 1;
    end
    if (out_mnPy != data_golden[3]) begin
        $display("mnPy Wrong!, expected result is %h, but the responsed result is %h", data_golden[3], out_mnPy);
        err = err + 1;
    end
    if (err == 0) begin
        $display("Test Pattern %d pass!", test_id);
    end
    end
    endtask
endmodule
`timescale 1ns/100ps
`define CYCLE 20
`define TIME_LIMIT 5000000
`define SDFFILE    "./ECC_syn.sdf"	          // Modify your sdf file name
`include "ECCDefine.vh"

module Wrapper_tb;
    // clock reset signal
    reg clk;
    reg rst;

    // reg control signal
    reg i_data_valid, i_mode;
    
    // reg data
    reg i_a, i_b, i_prime, i_Px, i_Py, i_m;

    //output control signal
    wire o_data_valid;

    // output data
    wire o_Px, o_Py;

    // tb
    integer err1, err2, err3, err4, err5, err6, err7, err8, testID;
    reg [`MAX_BITS-1:0] out_mPx, out_mPy;
    reg [`MAX_BITS-1:0] out_mnPx, out_mnPy;
    reg [`MAX_BITS-1:0] data_input  [0:7];
    reg [`MAX_BITS-1:0] data_golden [0:3];
    
    Wrapper top(clk, rst, i_data_valid, i_mode, i_a, i_prime, i_Px, i_Py, i_m, o_data_valid, o_Px, o_Py);

    `ifdef SDF
	    initial $sdf_annotate(`SDFFILE, top);
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
        testID = 1;
// -----------------------------------------------------------------------------------------------
        $display(" ----------------------------------------------------------------------");
        $display("TEST START !!!");
        $display(" ----------------------------------------------------------------------");
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern %d. 16 bits", testID);
        $readmemh("in16_0.pattern", data_input);
        $readmemh("out16_0.pattern", data_golden);
        begin
            compute_mP(`BITS16, 16);
            #(`CYCLE*5) compute_mnP(16);
        end
        check_result(testID, err1);
        testID = testID + 1;
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern %d. 16 bits", testID);
        $readmemh("in16_1.pattern", data_input);
        $readmemh("out16_1.pattern", data_golden);
        begin
            compute_mP(`BITS16, 16);
            #(`CYCLE*5) compute_mnP(16);
        end
        check_result(testID, err2);
        testID = testID + 1;
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern %d. 32 bits", testID);
        $readmemh("in32_0.pattern", data_input);
        $readmemh("out32_0.pattern", data_golden);
        begin
            compute_mP(`BITS32, 32);
            #(`CYCLE*5) compute_mnP(32);
        end
        check_result(testID, err3);
        testID = testID + 1;
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern %d. 32 bits", testID);
        $readmemh("in32_1.pattern", data_input);
        $readmemh("out32_1.pattern", data_golden);
        begin
            compute_mP(`BITS32, 32);
            #(`CYCLE*5) compute_mnP(32);
        end
        check_result(testID, err4);
        testID = testID + 1;
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern %d. 64 bits", testID);
        $readmemh("in64_0.pattern", data_input);
        $readmemh("out64_0.pattern", data_golden);
        begin
            compute_mP(`BITS64, 64);
            #(`CYCLE*5) compute_mnP(64);
        end
        check_result(testID, err5);
        testID = testID + 1;
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern %d. 64 bits", testID);
        $readmemh("in64_1.pattern", data_input);
        $readmemh("out64_1.pattern", data_golden);
        begin
            compute_mP(`BITS64, 64);
            #(`CYCLE*5) compute_mnP(64);
        end
        check_result(testID, err6);
        testID = testID + 1;
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern %d. 128 bits", testID);
        $readmemh("in128_0.pattern", data_input);
        $readmemh("out128_0.pattern", data_golden);
        begin
            compute_mP(`BITS128, 128);
            #(`CYCLE*5) compute_mnP(128);
        end
        check_result(testID, err7);
        testID = testID + 1;
        $display(" ----------------------------------------------------------------------");
// -----------------------------------------------------------------------------------------------
        #(`CYCLE*3); 
        @(negedge clk); rst = 1'b0;
        #(`CYCLE*3);
        @(negedge clk); rst = 1'b1;
        #(`CYCLE*3);
        $display("Pattern %d. 128 bits", testID);
        $readmemh("in128_1.pattern", data_input);
        $readmemh("out128_1.pattern", data_golden);
        begin
            compute_mP(`BITS128, 128);
            #(`CYCLE*5) compute_mnP(128);
        end
        check_result(testID, err8);
        testID = testID + 1;
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
            i_data_valid = 1'b1; 
        @(negedge clk); 
            i_mode = mode[1];
            i_data_valid = 1'b0;
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
	    end

        wait(o_data_valid === 1'b1);
        for(i=bit_num-1; i>=0; i=i-1) begin
	    	@(negedge clk);
	    	out_mPx[i] = o_Px;
	    	out_mPy[i] = o_Py;
	    end

        for(i=bit_num; i<`MAX_BITS; i=i+1) begin
            out_mPx[i] = 1'b0;
            out_mPy[i] = 1'b0;
        end
    end
endtask

task compute_mnP;
    input integer bit_num;
    integer i;

    begin
        @(negedge clk); 
            i_data_valid = 1'b1;
                       
        for (i=bit_num-1; i>=0; i=i-1) begin
            @(negedge clk);
                i_data_valid = 1'b0;
                i_Px = data_input[6][i];
                i_Py = data_input[7][i];
	    end

        wait(o_data_valid === 1'b1);
        for(i=bit_num-1; i>=0; i=i-1) begin
	    	@(negedge clk);
	    	out_mnPx[i] = o_Px;
	    	out_mnPy[i] = o_Py;
	    end

        for(i=bit_num; i<`MAX_BITS; i=i+1) begin
            out_mnPx[i] = 1'b0;
            out_mnPy[i] = 1'b0;
        end
    end
endtask

task check_result;
    input integer test_id;
    output integer err;
    begin
    err = 0;
    if (out_mPx !== data_golden[0]) begin
        $display("mPx Wrong!, expected result is %h, but the responsed result is %h", data_golden[0], out_mPx);
        err = err + 1;
    end
    if (out_mPy !== data_golden[1]) begin
        $display("mPy Wrong!, expected result is %h, but the responsed result is %h", data_golden[1], out_mPy);
        err = err + 1;
    end
    if (out_mnPx !== data_golden[2]) begin
        $display("mnPx Wrong!, expected result is %h, but the responsed result is %h", data_golden[2], out_mnPx);
        err = err + 1;
    end
    if (out_mnPy !== data_golden[3]) begin
        $display("mnPy Wrong!, expected result is %h, but the responsed result is %h", data_golden[3], out_mnPy);
        err = err + 1;
    end
    if (err == 0) begin
        $display("Test Pattern %d pass!", test_id);
    end
    end
endtask

endmodule
`timescale 1ns/10ps
`define CYCLE 20
`define INFILE "in.pattern"
`define OUTFILE "out_golden.pattern" 

module Wrapper_tb;
    // clock reset signal
    reg clk;
    reg rst;

    // reg control signal
    reg i_p_a_valid;
    reg i_pb_valid;
    reg i_mode;
    
    // reg data
    reg i_p;
    reg i_x;
    reg i_y;
    reg i_a;
    reg i_Pb;

    //output control signal
    wire o_Pa_valid;
    wire o_Pab_valid;

    // output data
    wire o_x;
    wire o_y;
    wire o_Pab;

    // tb
    integer i, num, error;
    parameter bit_num = 32;
    reg stop;

    reg [bit_num-1:0] data_input  [0:3];
    reg [bit_num-1:0] data_golden [0:1];

    Wrapper wrapper(clk, rst, i_p_a_valid, i_pb_valid, i_mode, i_p, i_x, i_y, i_a, i_Pb, o_Pa_valid, o_Pab_valid, o_x, o_y, o_Pab);

    initial begin
        $readmemh(`INFILE, data_input);
        $readmemh(`OUTFILE, data_golden);
	    clk = 1'b1;
        rst = 1'b1;
	    error = 0;
	    stop = 0;
	    i=bit_num-1;
    end

    always #(`CYCLE*0.5) clk = ~clk;

    initial begin
        #(`CYCLE*0.5) rst = 1'b0;
        #(`CYCLE) rst = 1'b1;
        i_p_a_valid = 1'b1;
        i_mode = 2'b00;
        
        #(`CYCLE*0.5)   
	    for(num = bit_num; num >= 0; num = num - 1) begin
	    	#(`CYCLE) begin
                i_p = data_input[0][num];
                i_x = data_input[1][num];
                i_y = data_input[2][num];
                i_a = data_input[3][num];
	    	end
	    end
        #(`CYCLE)
        i_p_a_valid = 1'b0;
    end

    always@(posedge clk) begin
	    if (i == 0)
		    stop <= 1;
    end

    always@(posedge clk ) begin
        if (o_Pa_valid) begin
            if(o_x !== data_golden[0][i]) begin
                error <= error + 1;
            end
            if(o_y !== data_golden[1][i]) begin
                error <= error + 1;
            end
            i <= i - 1;
        end
    end

    initial begin
	    @(posedge stop) begin
	    	if(error == 0) begin
	    		$display("==========================================\n");
	    		$display("======  Congratulation! You Pass!  =======\n");
	    		$display("==========================================\n");
	    	end
	    	else begin
	    		$display("===============================\n");
	    		$display("There are %d errors.", error);
	    		$display("===============================\n");
	    	end
	    	$finish;
	    end
    end


    initial begin
        //$dumpfile("ecc.vcd");
        //$dumpvars;
        $fsdbDumpfile("ecc.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA;
    end

    initial begin
        #(10000*`CYCLE) 
        $display("out of time");
        $finish;
    end
endmodule
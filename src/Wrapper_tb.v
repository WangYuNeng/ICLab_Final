`timescale 1ns/10ps
`define CYCLE 20
// modify these for different test
`define INFILE "in32_0.pattern"
`define OUTFILE "out32_0.pattern"

module Wrapper_tb;
    // modify these for different test
    parameter BIT = 32;
    parameter MODE = 2'b00;

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
    wire o_mPx, o_mPy, o_mnPx, o_mnpy;

    // tb
    integer i, j, k, num, error;
    reg stop;

    reg [BIT-1:0] data_input  [0:7];
    reg [BIT-1:0] data_golden [0:3];
    
    Wrapper wrapper(clk, rst, i_m_P_valid, i_nP_valid, i_mode, i_a, i_b, i_prime, i_Px, i_Py, i_m, i_nPx, i_nPy, o_mP_valid, o_mnP_valid, 
    o_mPx, o_mPy, o_mnPx, o_mnpy);

    initial begin
        $readmemh(`INFILE, data_input);
        $readmemh(`OUTFILE, data_golden);
	    clk = 1'b1;
        rst = 1'b1;
	    error = 0;
	    stop = 0;
        i_m_P_valid = 0;
        i_nP_valid = 0;
	    i = BIT-1;
        j = BIT-1;
        k = BIT-1;
    end

    always #(`CYCLE*0.5) clk = ~clk;

    initial begin
        #(`CYCLE*0.5) rst = 1'b0;
        #(`CYCLE) rst = 1'b1;
        #(`CYCLE)
        #(`CYCLE)
        i_m_P_valid = 1'b1;
        #(`CYCLE)
        i_mode = MODE[1];
        #(`CYCLE)
        i_mode = MODE[0];
        #(`CYCLE*0.5)
	    for(num = BIT-1; num >= 0; num = num - 1) begin
	    	#(`CYCLE*0.5) begin
                i_mode = 1'bx;
                i_a = data_input[0][k]; 
                i_b = data_input[1][k]; 
                i_prime = data_input[2][k];
                i_Px = data_input[3][k];
                i_Py = data_input[4][k];
                i_m = data_input[5][k];
                i_m_P_valid = 1'b1;
	    	end
            #(`CYCLE*0.5) k = k-1;
	    end
        #(`CYCLE*0.5)
        i_m_P_valid = 1'b0;
        k = BIT-1;
        #(`CYCLE*5) // nP start to transmit
        i_nP_valid = 1'b1;
        #(`CYCLE*0.5)
        for(num = BIT-1; num >= 0; num = num - 1) begin
	    	#(`CYCLE*0.5) begin
                i_nPx = data_input[6][k];
                i_nPy = data_input[7][k];
	    	end
            #(`CYCLE*0.5) k = k-1;
	    end
        #(`CYCLE*0.5)
        i_nP_valid = 1'b0;
    end

    always@(posedge clk) begin
        if (o_mP_valid) begin
            if (i > 0) i <= i - 1;
        end
        if (o_mnP_valid) begin
            if (j > 0) j <= j - 1;
        end
	    if (i == 0 && j == 0) stop <= 1;
    end

    always@(negedge clk ) begin
        if (o_mP_valid) begin
            if(o_mPx !== data_golden[0][i]) begin
                error <= error + 1;
            end
            if(o_mPy !== data_golden[1][i]) begin
                error <= error + 1;
            end
        end
        if (o_mnP_valid) begin
            if(o_mnPx !== data_golden[2][j]) begin
                error <= error + 1;
            end
            if(o_mnpy !== data_golden[3][j]) begin
                error <= error + 1;
            end
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
	    		$display("There are %d bit errors.", error);
	    		$display("===============================\n");
	    	end
	    	$finish;
	    end
    end


    initial begin
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
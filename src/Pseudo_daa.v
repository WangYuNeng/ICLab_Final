
module point_always(
    input clk,
    input rst,
    input [1:0] daa_mode,
    input daa_valid,
    input [255:0] i_daa_pointx,
    input [255:0] i_daa_pointy,
    input [255:0] i_daa_prime,
    input [255:0] i_daa_a,
    input [255:0] i_daa_b,
    input [255:0] i_daa_mul,
    output reg o_daa_finished,
    output reg [255:0] o_daa_outputx,
    output reg [255:0] o_daa_outputy
);
    parameter [31:0] ans_mPx = 32'hDFA978E7;
    parameter [31:0] ans_mPy = 32'hF6A1A9BB;
    parameter [31:0] ans_mnPx = 32'h888F3531;
    parameter [31:0] ans_mnPy = 32'h71917832;

    reg [6:0] counter, n_counter;
    reg cheat_counter, n_cheat_counter; // to remember its mP or mnP
    
    assign o_mPx = ans_mPx;
    assign o_mPy = ans_mPy;
    assign o_mnPx = ans_mnPx;
    assign o_mnPy = ans_mnPy;
    
    always@( posedge clk or negedge rst ) begin
        if ( !rst ) begin
            counter <= 32;
            cheat_counter <= 0;
        end else begin
            counter <= n_counter;
            cheat_counter <= n_cheat_counter;
        end
    end

    always@(*) begin
        n_counter = counter;
        o_daa_finished = 0;
        o_daa_outputx = 0;
        o_daa_outputy = 0;
        n_cheat_counter = cheat_counter;

        if(daa_valid) begin
            n_counter = counter - 1;
        end
        
        if(daa_valid && counter == 0 && cheat_counter == 0) begin
            o_daa_finished = 1;
            o_daa_outputx = ans_mPx;
            o_daa_outputy = ans_mPy;
            n_cheat_counter = 1;
            n_counter = 64;
        end
        if(daa_valid && counter == 0 && cheat_counter == 1) begin
            o_daa_finished = 1;
            o_daa_outputx = ans_mnPx;
            o_daa_outputy = ans_mnPy;
        end
    end
    
endmodule
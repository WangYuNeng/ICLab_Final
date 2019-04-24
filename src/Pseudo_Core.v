
module Core(
    input clk,
    input rst,
    input [255:0] i_Px,
    input [255:0] i_Py,
    input [255:0] i_prime,
    input [255:0] i_a,
    input [255:0] i_b,
    input [255:0] i_m,
    input [255:0] i_nPx,
    input [255:0] i_nPy,
    input i_m_P_valid,
    input i_nP_valid,
    output [255:0] o_mPx,
    output [255:0] o_mPy,
    output [255:0] o_mnPx,
    output [255:0] o_mnPy,
    output reg o_mP_valid,
    output reg o_mnP_valid
);
    parameter [31:0] ans_mPx = 32'hDFA978E7;
    parameter [31:0] ans_mPy = 32'hF6A1A9BB;
    parameter [31:0] ans_mnPx = 32'h888F3531;
    parameter [31:0] ans_mnPy = 32'h71917832;

    reg [6:0] counter, n_counter;
    
    assign o_mPx = ans_mPx;
    assign o_mPy = ans_mPy;
    assign o_mnPx = ans_mnPx;
    assign o_mnPy = ans_mnPy;
    
    always@( posedge clk or negedge rst ) begin
        if ( !rst ) begin
            counter <= 127;
        end else begin
            counter <= n_counter;
        end
    end

    always@(*) begin
        n_counter = counter;
        if (i_m_P_valid & counter != 0) 
            n_counter = counter - 1;
        
        if(counter == 64) begin
            o_mP_valid = 1;
        end
        if(counter == 32) begin
            o_mnP_valid = 1;
            o_mP_valid = 0;
        end
        if (counter == 0) begin
            o_mnP_valid = 0;
        end
    end
    
endmodule
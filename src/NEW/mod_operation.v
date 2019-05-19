`include "ECCDefine.vh"
// compute o_result = i_a / (1 / i_b) if i_mul_start = 1
// compute o_result = i_a / i_b  if i_div_start = 1

module mod_operation(
	input  clk,
    input  rst,
    input  i_mul_start,
    input  i_div_start,
    input  [`MAX_BITS-1:0] i_p,
    input  [`MAX_BITS-1:0] i_a,
    input  [`MAX_BITS-1:0] i_b,  
    output [`MAX_BITS-1:0] o_result,
    output reg o_finished
);

parameter IDLE = 2'b00;
parameter MUL1 = 2'b01;
parameter WAIT = 2'b10;
parameter DONE  = 2'b11;

reg [1:0] state_r, state_w;
reg sub_start;
reg [`MAX_BITS-1:0] i_a_or_1;
reg [`MAX_BITS-1:0] i_b_or_i_b_inv;

uni_inversion u_inv (
	.i_clk(clk),
    .i_rst(rst),
    .i_start(sub_start),
    .i_n(i_p),
    .i_a(i_a_or_1),
    .i_b(i_b_or_i_b_inv),  
    .o_result(o_result),
    .o_finished(sub_finish)
);

always@(*) begin
	sub_start = 0;
	state_w = state_r;
	i_a_or_1 = i_a;
	i_b_or_i_b_inv = i_b;
	o_finished = 0;
	case(state_r)
		IDLE: begin
			if(i_div_start) begin
                state_w = WAIT;
                sub_start = 1;
				i_a_or_1 = i_a;
				i_b_or_i_b_inv = i_b;
			end
			if(i_mul_start) begin
				state_w = MUL1;
				sub_start = 1;
				i_a_or_1 = 1;
				i_b_or_i_b_inv = i_b;
			end
		end
		MUL1: begin
			if (sub_finish) begin
				state_w = WAIT;
				sub_start = 1;
				i_a_or_1 = i_a;
				i_b_or_i_b_inv = o_result;
			end
		end
		WAIT: begin
			if (sub_finish) begin
				state_w = DONE;
			end
		end
		DONE: begin
			o_finished = 1;
			state_w = IDLE;
		end
	endcase
end

always@(posedge clk or negedge rst) begin
	if(!rst) begin
		state_r <= IDLE;
	end else begin
		state_r <= state_w;
	end
end
endmodule

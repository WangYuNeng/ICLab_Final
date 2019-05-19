// calculate p1+p2, if i_add_start = 1
// calculate 2p1=2p2, if i_double_start = 1
`include "ECCDefine.vh"

module point_operation(
	input clk,
	input rst,
	input i_add_start,
	input i_double_start,
	input [`MAX_BITS-1:0] i_a,
	//input [`MAX_BITS-1:0] i_b,
	input [`MAX_BITS-1:0] i_p,
	input [`MAX_BITS-1:0] i_x1,
	input [`MAX_BITS-1:0] i_y1,
	input [`MAX_BITS-1:0] i_x2,
	input [`MAX_BITS-1:0] i_y2,
	output o_finish,
	output [`MAX_BITS-1:0] o_result_x,
	output [`MAX_BITS-1:0] o_result_y
);

    reg  start_div_r, start_div_w;
	reg  start_mul_r, start_mul_w;
	wire mod_finish;
   	
	reg  [`MAX_BITS-1:0] mod_a_r, mod_a_w; 
	reg  [`MAX_BITS-1:0] mod_b_r, mod_b_w;
    wire [`MAX_BITS-1:0] mod_result;
    
	reg  [`MAX_BITS-1:0] lambda_r, lambda_w;
	reg  [`MAX_BITS-1:0]   temp_r, temp_w;

	parameter IDLE           = 0;
	parameter LAMBDA_DOUBLE  = 1;
	parameter RUNX1          = 2;
	parameter RUNX2          = 3;
	parameter RUNY1          = 4;
	parameter RUNY2          = 5;

	reg [2:0] state_r, state_w;
	reg [`MAX_BITS-1:0] result_x_r, result_x_w;
	reg [`MAX_BITS-1:0] result_y_r, result_y_w;
	reg finish_r, finish_w;

	mod_operation mod_op(
		.clk(clk),
        .rst(rst),
        .i_mul_start(start_mul_r),
        .i_div_start(start_div_r),
        .i_p(i_p),
        .i_a(mod_a_r), 
        .i_b(mod_b_r), 
        .o_result(mod_result),
        .o_finished(mod_finish)
	);

assign o_finish = finish_r;
assign o_result_x = result_x_r;
assign o_result_y = result_y_r;

always@(*) begin
	state_w = state_r;
	start_div_w = start_div_r;
	start_mul_w = start_mul_r;
	mod_a_w = mod_a_r;
	mod_b_w = mod_b_r;
	lambda_w = lambda_r;
	temp_w = temp_r;
	result_x_w = result_x_r;
	result_y_w = result_y_r;
	finish_w = finish_r;
	case(state_r)
		IDLE: begin
			finish_w = 0;
			start_mul_w = 0;
			start_div_w = 0;
			if (i_add_start) begin // compute lambda = (y2 - y1) / (x2 - x1)
				start_div_w = 1;
				// mod_a_w = y2 - y1
				if (i_y2 >= i_y1)
					mod_a_w = i_y2 - i_y1;
				else
					mod_a_w = i_y2 - i_y1 + i_p;
				// mod_b_w = x2 - x1
				if (i_x2 >= i_x1)
					mod_b_w = i_x2 - i_x1;
				else 
					mod_b_w = i_x2 - i_x1 + i_p;
				
				state_w = RUNX1;
			end
			if (i_double_start) begin // compute lambda = (3x^2 + a) / 2y
				// first compute 3x^2, mod_a_w = 3x, mod_b_w = x
				start_mul_w = 1;
				if (3*i_x1 >= 2*i_p)
					mod_a_w = 3*i_x1 - 2*i_p;
				else if (3*i_x1 >= i_p)
					mod_a_w = 3*i_x1 - i_p;
				else
					mod_a_w = 3*i_x1;
				
				mod_b_w = i_x1;
				state_w = LAMBDA_DOUBLE;
			end
		end
		LAMBDA_DOUBLE: begin // continue compute lambda = (3x^2 + a) / 2y
			start_mul_w = 0;
			start_div_w = 0;
			if (mod_finish) begin
				start_div_w = 1;	
				// mod_a_w = 3x^2 + a
				if (mod_result + i_a >= i_p)
					mod_a_w = mod_result + i_a - i_p;
				else
					mod_a_w = mod_result + i_a;
				// mod_b_w = 2y
				if( (2*i_y1) >= i_p)
					mod_b_w = (2*i_y1) - i_p;
				else
					mod_b_w = (2*i_y1);
				state_w = RUNX1;
			end
		end
		RUNX1: begin // compute result_x =  lambda^2 - x1 - x2
			start_mul_w = 0;
			start_div_w = 0;
			// first compute lambda^2 and temp_w = (x1 + x2)
			if (mod_finish) begin
				start_mul_w = 1; 
				lambda_w = mod_result;
				mod_a_w = mod_result;
				mod_b_w = mod_result;
				state_w = RUNX2;
				if (i_x1 + i_x2 >= i_p)
					temp_w = i_x1 + i_x2 - i_p;
				else
					temp_w = i_x1 + i_x2;
				state_w = RUNX2;
			end
		end
		RUNX2: begin // compute result_x =  lambda^2 - x1 - x2
			start_mul_w = 0;
			start_div_w = 0;
			// next compute lambda^2 - temp
			if (mod_finish) begin
				if (mod_result >= temp_r)
					result_x_w = mod_result - temp_r;
				else
					result_x_w = mod_result - temp_r + i_p;
				state_w = RUNY1;
			end
		end
		RUNY1: begin // compute result_y = lambda*(x1 - result_x) - y1
			start_mul_w = 1;
			start_div_w = 0;
			// first compute lambda*(x1 - result_x)
			mod_a_w = lambda_r;
			if (i_x1 >= result_x_r)
				mod_b_w = i_x1 - result_x_r;
			else
				mod_b_w = i_x1 - result_x_r + i_p;
			state_w = RUNY2;
		end
		RUNY2: begin // compute result_y = lambda*(x1 - result_x) - y1
			start_mul_w = 0;
			start_div_w = 0;
			if (mod_finish) begin
				if (mod_result >= i_y1)
					result_y_w = mod_result - i_y1;
				else
					result_y_w = mod_result - i_y1 + i_p; 
				
				finish_w = 1;
				state_w = IDLE;
			end
		end
	endcase
end

always@(posedge clk or negedge rst) begin
	if(!rst) begin
		state_r <= IDLE;
		start_div_r <= 0;
		start_mul_r <= 0;
		mod_a_r <= 0;
		mod_b_r <= 0;
		lambda_r <= 0;
		temp_r <= 0;
		result_x_r <= 0;
		result_y_r <= 0;
		finish_r <= 0;
	end else begin
		state_r <= state_w;
		start_div_r <= start_div_w;
		start_mul_r <= start_mul_w;
		mod_a_r <= mod_a_w;
		mod_b_r <= mod_b_w;
		lambda_r <= lambda_w;
		temp_r <= temp_w;
		result_x_r <= result_x_w;
		result_y_r <= result_y_w;
		finish_r <= finish_w;
	end
end
endmodule


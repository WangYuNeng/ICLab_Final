//calculate 2p
//as general point_double
`include "ECCDefine.vh"
module point_double_always(
	input i_clk,
	input i_rst,
	input i_start,
	input [1:0] i_mode,
	input [`MAX_BITS-1:0] i_a,
	input [`MAX_BITS-1:0] i_b,
	input [`MAX_BITS-1:0] i_p,
	input [`MAX_BITS-1:0] i_x1,
	input [`MAX_BITS-1:0] i_y1,
	input add, //for whether add or not

	output o_finish_mul,
	output [`MAX_BITS-1:0] o_result_x,
	output [`MAX_BITS-1:0] o_result_y
);

    reg  start_div_r, start_div_w;
   	wire finish_div;
	reg [`MAX_BITS:0] div_a_r,div_a_w; 
	reg [`MAX_BITS:0] div_b_r, div_b_w;
    wire [`MAX_BITS-1:0] result_div;

    reg  start_mul_r, start_mul_w;
    wire finish_mul;  
    reg [`MAX_BITS:0] mul_a_r, mul_a_w;
    reg [`MAX_BITS:0] mul_b_r, mul_b_w;
	wire [`MAX_BITS-1:0] result_mul;
	
	reg [`MAX_BITS - 1:0] lambda_r, lambda_w;

	parameter IDLE = 3'b000;
	parameter RUN1 = 3'b001;
	parameter RUN2 = 3'b010;
	parameter RUNX = 3'b011;
	parameter RUNX2 = 3'b100;
	parameter RUNY = 3'b101;
	parameter DONE = 3'b110;

	reg [3:0] state_r, state_w;
	reg [`MAX_BITS - 1:0] result_x_r, result_x_w;
	reg [`MAX_BITS - 1:0] result_y_r, result_y_w;
	reg finished_w, finished_r;

	ModuloProduct modulo_product_double_0(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(start_mul_r),
		.i_mode(i_mode),
        .i_n(i_p),
        .i_a(mul_a_r), 
        .i_b(mul_b_r), 
        .o_result(result_mul),
        .o_finished(finish_mul)
    );

	uni_inversion inversion_double(
		.i_clk(i_clk),
	    .i_rst(i_rst),
	    .i_start(start_div_r),
	    .i_n(i_p),
	    .i_a(div_a_r), 
        .i_b(div_b_r),
	    .o_result(result_div), // 256 bits only
	    .o_finished(finish_div)
	);

assign o_finish_mul = finished_r;
assign o_result_x = result_x_r;
assign o_result_y = result_y_r;

always@(*) begin
	state_w = state_r;
	mul_a_w = mul_a_r;
	mul_b_w = mul_b_r;
	div_a_w = div_a_r;
	div_b_w = div_b_r;
	lambda_w = lambda_r;
	result_x_w = result_x_r;
	result_y_w = result_y_r;
	finished_w = finished_r;
	start_div_w = start_div_r;
	start_mul_w = start_mul_r;
	case(state_r)
		IDLE: begin
			finished_w = 0;
			if (i_start) begin
				if(i_x1 != {`MAX_BITS{1'b1}}) begin
					// (2y)
					if( (2*i_y1) >= i_p)
						div_b_w = (2*i_y1) - i_p;
					else
						div_b_w = (2*i_y1);
					// 3x	
					if(3*i_x1 >= 2*i_p)
						mul_a_w = 3*i_x1 - 2*i_p;
					else if(3*i_x1 >= i_p)
						mul_a_w = 3*i_x1 - i_p;
					else
						mul_a_w = 3*i_x1;
					
					mul_b_w = i_x1;
					start_mul_w = 1; //3x^2
					state_w = RUN1;
				end else begin
					result_x_w = i_x1;
					result_y_w = i_y1;
					finished_w = 1;
				end
			end
		end
		RUN1:begin
			start_mul_w = 0;
			// 3x^2+a
			if (finish_mul) begin	
				if (result_mul + i_a >= i_p)
					div_a_w = result_mul + i_a - i_p;
				else
					div_a_w = result_mul + i_a;
				
				start_div_w = 1; // (3x^2+a)/2y
				state_w = RUN2;
			end
		end
		RUN2: begin
			start_div_w = 0;
			if (finish_div) begin // lambda = (3x^2+a)/2y
				lambda_w = result_div;
				mul_a_w = result_div;
				mul_b_w = result_div;
				start_mul_w = 1; // lambda^2
				state_w = RUNX;
			end
		end
		RUNX: begin
			start_mul_w = 0;
			if (finish_mul) begin // lambda^2
				if (add) begin // 2x1
					if(2*i_x1 > result_mul + i_p)
						result_x_w = result_mul + 2*i_p - 2*i_x1;
					else if(2*i_x1 > result_mul)
						result_x_w = result_mul + i_p - 2*i_x1;
					else
						result_x_w = result_mul - 2*i_x1;
				end else begin
					result_x_w = i_x1;
				end
				state_w = RUNX2;			
			end
		end
		RUNX2: begin
			mul_a_w = lambda_r;
			if(result_x_r > i_x1)
				mul_b_w = i_x1 - result_x_r + i_p;
			else
				mul_b_w = i_x1 - result_x_r;
			start_mul_w = 1; // lambda*(x1-x3)
			state_w = RUNY;
		end
		RUNY:begin
			start_mul_w = 0;
			if(finish_mul) begin // lambda*(x1 - x3)
				if(add)begin
					if(i_y1 > result_mul)
						result_y_w = result_mul - i_y1 + i_p;
					else
						result_y_w = result_mul - i_y1;
					end else begin
						result_y_w = i_y1;
					end
				state_w = DONE;
			end
		end
		DONE: begin
			finished_w = 1;
			state_w = IDLE;
		end
	endcase
end

always@(posedge i_clk or negedge i_rst) begin
	if(!i_rst) begin
		state_r <= IDLE;
		mul_a_r <= 0;
		mul_b_r <= 0;
		start_div_r <= 0;
		start_mul_r <= 0;
		lambda_r <= 0;
		div_a_r <= 0;
		div_b_r <= 0;
		result_x_r <= 0;
		result_y_r <= 0;
		finished_r <= 0;
	end else begin
		state_r <= state_w;
		div_a_r <= div_a_w;
		div_b_r <= div_b_w;
		mul_a_r <= mul_a_w;
		mul_b_r <= mul_b_w;
		start_div_r <= start_div_w;
		start_mul_r <= start_mul_w;
		lambda_r <= lambda_w;
		result_x_r <= result_x_w;
		result_y_r <= result_y_w;
		finished_r <= finished_w;
	end
end

endmodule
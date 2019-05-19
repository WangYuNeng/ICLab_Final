//for add and double always method
`include "ECCDefine.vh"

module core(
	input clk,
	input rst,
	input i_start,
	input [`MAX_BITS-1:0] i_a,
	//input [`MAX_BITS-1:0] i_b,
	input [`MAX_BITS-1:0] i_p,
	input [`MAX_BITS-1:0] i_x,
	input [`MAX_BITS-1:0] i_y,
	input [`MAX_BITS-1:0] i_n, //nP
	input [1:0]i_mode,

	output [`MAX_BITS-1:0] o_result_x,
	output [`MAX_BITS-1:0] o_result_y,
	output o_finish
);

parameter IDLE       = 0;
parameter PRECALC    = 1;
parameter DOUBLE     = 2;
parameter ADD        = 3;
parameter WAITADD    = 4;
parameter WAITDOUBLE = 5;
parameter DONE       = 6;

reg [2:0] state_r, state_w;
reg add_start_r, add_start_w, double_start_r, double_start_w;
reg [`MAX_BITS-1:0] x1_r, y1_r, x2_r, y2_r, x1_w, y1_w, x2_w, y2_w;
wire point_finish;
wire [`MAX_BITS-1:0] point_x, point_y;

point_operation point_op(
	.clk(clk),
	.rst(rst),
	.i_add_start(add_start_r),
	.i_double_start(double_start_r),
	.i_a(i_a),
	//.i_b(i_b),
	.i_p(i_p),
	.i_x1(x1_r),
	.i_y1(y1_r),
	.i_x2(x2_r),
	.i_y2(y2_r),
	.o_finish(point_finish),
	.o_result_x(point_x),
	.o_result_y(point_y)
);

reg finish_r, finish_w;
reg [`MAX_BITS-1:0] p1x_r, p1y_r, p1x_w, p1y_w;
reg [`MAX_BITS-1:0] p2x_r, p2y_r, p2x_w, p2y_w;
reg [`MAX_REG:0] counter_r, counter_w;

assign o_finish   = finish_r;
assign o_result_x = p1x_r;
assign o_result_y = p1y_r;

always@(*) begin
	state_w        = state_r;
	add_start_w    = add_start_r;
	double_start_w = double_start_r;
	x1_w           = x1_r; 
	y1_w           = y1_r; 
	x2_w           = x2_r; 
	y2_w           = y2_r;
	finish_w       = finish_r;
	p1x_w          = p1x_r;
	p1y_w          = p1y_r;
	p2x_w          = p2x_r;
	p2y_w          = p2y_r;
	counter_w      = counter_r;
	case (state_r)
		IDLE: begin
			finish_w = 0;
			double_start_w = 0;
			add_start_w = 0;
			if (i_start) begin
				case(i_mode)
					`BITS16: counter_w = 14;
					`BITS32: counter_w = 30;
					`BITS64: counter_w = 62;
					`BITS128: counter_w = 126;
				endcase
				double_start_w = 1;
				x1_w = i_x;
				y1_w = i_y;
				x2_w = i_x;
				y2_w = i_y;
				state_w = PRECALC;
			end
		end
		PRECALC: begin
			double_start_w = 0;
			add_start_w = 0;
			if (point_finish) begin
				p1x_w = i_x;
				p1y_w = i_y;
				p2x_w = point_x;
				p2y_w = point_y;
				state_w = ADD;
			end
		end
		ADD: begin
			add_start_w = 1;
			x1_w = p1x_r;
			y1_w = p1y_r;
			x2_w = p2x_r;
			y2_w = p2y_r;
			state_w = WAITADD;
		end
		WAITADD: begin
			double_start_w = 0;
			add_start_w = 0;
			if (point_finish) begin
				if (i_n[counter_r]) begin
					p1x_w = point_x;
					p1y_w = point_y;
				end
				else begin
					p2x_w = point_x;
					p2y_w = point_y;
				end
				state_w = DOUBLE;
			end
		end
		DOUBLE: begin
			double_start_w = 1;
			if (i_n[counter_r]) begin
				x1_w = p2x_r;
				y1_w = p2y_r;
				x2_w = p2x_r;
				y2_w = p2y_r;
			end
			else begin
				x1_w = p1x_r;
				y1_w = p1y_r;
				x2_w = p1x_r;
				y2_w = p1y_r;
			end
			state_w = WAITDOUBLE;
		end
		WAITDOUBLE: begin
			double_start_w = 0;
			add_start_w = 0;
			if (point_finish) begin
				if (i_n[counter_r]) begin
					p2x_w = point_x;
					p2y_w = point_y;
				end
				else begin
					p1x_w = point_x;
					p1y_w = point_y;
				end
				counter_w =counter_r - 1;
				if (counter_r == 0) begin
					state_w = DONE;
				end
				else begin
					state_w = ADD;
				end
			end
		end
		DONE: begin
			finish_w = 1;
			state_w = IDLE;
		end
	endcase
end

always@(posedge clk or negedge rst) begin
	if(!rst) begin
		state_r        <= IDLE;
		add_start_r    <= 0;
		double_start_r <= 0;
		x1_r           <= 0; 
		y1_r           <= 0; 
		x2_r           <= 0; 
		y2_r           <= 0;
		finish_r       <= 0;
		p1x_r          <= 0;
		p1y_r          <= 0;
		p2x_r          <= 0;
		p2y_r          <= 0;
		counter_r      <= 0;
	end else begin
		state_r        <= state_w;
		add_start_r    <= add_start_w;
		double_start_r <= double_start_w;
		x1_r           <= x1_w; 
		y1_r           <= y1_w; 
		x2_r           <= x2_w; 
		y2_r           <= y2_w;
		finish_r       <= finish_w;
		p1x_r          <= p1x_w;
		p1y_r          <= p1y_w;
		p2x_r          <= p2x_w;
		p2y_r          <= p2y_w;
		counter_r      <= counter_w;
	end
end
endmodule

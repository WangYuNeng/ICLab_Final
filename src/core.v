//for add and double always method
//`include "./point_double.sv"
//`include "./point_add.sv"
//20190425 change sv into v

//`define WIDTH 192
`include "ECCDefine.vh"

module point_always(
	input i_clk,
	input i_rst,
	input i_start,
	input [`MAX_BITS - 1:0]i_a,
	input [`MAX_BITS - 1:0]i_b,
	input [`MAX_BITS - 1:0]i_p,//mod p
	input [`MAX_BITS - 1:0]i_x1,
	input [`MAX_BITS - 1:0]i_y1,
	input [`MAX_BITS - 1:0]i_n,//nP
	input [1:0]i_mode,

	output [`MAX_BITS - 1:0]o_result_x,
	output [`MAX_BITS - 1:0]o_result_y,
	output o_finished
);

parameter IDLE = 3'b000;
parameter ADD1 = 3'b001;
parameter MUL = 3'b010;
parameter ADD = 3'b011;
parameter DONE = 3'b100;

reg [3:0] state_r, state_w;
reg start_mul_r, start_add_r,start_mul_w, start_add_w;
reg [`MAX_BITS - 1:0]add_x1_r, add_x1_w;
reg [`MAX_BITS - 1:0]add_y1_r, add_y1_w;
reg [`MAX_BITS - 1:0]add_x2_r, add_x2_w;
reg [`MAX_BITS - 1:0]add_y2_r, add_y2_w;
reg [`MAX_BITS - 1:0]mul_x_r,mul_x_w;
reg [`MAX_BITS - 1:0]mul_y_r,mul_y_w;

reg [`MAX_REG:0]k_counter_r, k_counter_w;
reg [`MAX_BITS - 1:0] result_x_r,result_x_w;
reg [`MAX_BITS - 1:0] result_y_r,result_y_w;
wire [`MAX_BITS - 1:0] result_add_x,result_add_y;
wire [`MAX_BITS - 1:0] result_mul_x,result_mul_y;
reg finished_w, finished_r;
reg finished_init_w, finished_init_r;
reg add_r,add_w;


	point_add_always add(
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_start(start_add_r),
		.i_a(i_a),
		.i_b(i_b),
		.i_p(i_p),
		.i_x1(add_x1_r),
		.i_y1(add_y1_r),
		//.i_x2(add_x2_r),
		//.i_y2(add_y2_r),		
		.i_x2(i_x1),//add and double -> add 1
		.i_y2(i_y1),
		.i_num({`MAX_BITS{1'b0}}),//nP

		.o_result_x(result_add_x),
		.o_result_y(result_add_y),
		.o_finish_mul(finish_add),
		.add(add_r)
	);

	point_double_always mul(
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_start(start_mul_r),
		.i_a(i_a),
		.i_b(i_b),
		.i_p(i_p),
		.i_x1(mul_x_r),
		.i_y1(mul_y_r),
		.i_num({`MAX_BITS{1'b0}}),//nP

		.o_result_x(result_mul_x),
		.o_result_y(result_mul_y),
		.o_finish_mul(finish_mul),
		.add(add_r)
	);

assign o_result_x = result_x_r;
assign o_result_y = result_y_r;
assign o_finished = finished_r;

always @(*) begin
		start_mul_w = start_mul_r;
		start_add_w = start_add_r;
        k_counter_w = k_counter_r;
        add_x1_w = add_x1_r;
        add_x2_w = add_x2_r;
        add_y1_w = add_y1_r;
        add_y2_w = add_y2_r;
        mul_x_w = mul_x_r;
        mul_y_w = mul_y_r;
        state_w = state_r;
        result_x_w = result_x_r;
        result_y_w = result_y_r;
        finished_w = finished_r;
        finished_init_w = finished_init_r;
        add_w = add_r;
	case(state_r)
		IDLE:begin
            finished_w = 0;
			if(i_start) begin
				case (i_mode)
					`BITS256: k_counter_w = 255;
					`BITS128: k_counter_w = 127;
					`BITS64 : k_counter_w = 63;
					`BITS32 : k_counter_w = 31;
				endcase
				state_w = ADD1;
			end
		end
		/*
		ADD1:begin
			if(i_n[k_counter_r]) begin
					add_x1_w = -1;
					add_y1_w = -1;
					add_x2_w = i_x1;
					add_y2_w = i_y1;
					start_add_w = 1;
					state_w = ADD;
				end else begin
					k_counter_w = k_counter_r - 1;
				end
		end
		*/
		ADD1:begin		
			if(i_n[k_counter_r]) begin
				if(k_counter_r == 0)begin
					result_x_w = i_x1;
					result_y_w = i_y1;
					state_w = DONE;
				end else begin
					mul_x_w = i_x1;
					mul_y_w = i_y1;
					start_mul_w = 1;
					add_w = 1;
					state_w = MUL;
				end
			end
			k_counter_w = k_counter_r - 1;		
		end

		ADD:begin
			start_add_w = 0;
			start_mul_w = 0;
			//if(k_counter_r != 4'hffff) begin
				if(finish_add) begin
					mul_x_w = result_add_x;
					mul_y_w = result_add_y;
					start_mul_w = 1;
					add_w = 1;
					state_w = MUL;
					k_counter_w = k_counter_r - 1;
					if(k_counter_r == 0)begin
						start_mul_w = 0;
						result_x_w = result_add_x;
						result_y_w = result_add_y;
						state_w = DONE;
					end					
				end
				if(finish_mul)begin
					mul_x_w = result_mul_x;
					mul_y_w = result_mul_y;
					start_mul_w = 1;
					add_w = 1;
					state_w = MUL;
					k_counter_w = k_counter_r - 1;
					if(k_counter_r == 0)begin
						start_mul_w = 0;
						result_x_w = result_mul_x;
						result_y_w = result_mul_y;
						state_w = DONE;
					end					
				end
			//end else 

		end

		MUL:begin
			start_mul_w = 0;
			
			if(finish_mul) begin
				add_w = 0;
				if(i_n[k_counter_r]) begin
					//add_x2_w = i_x1;
					//add_y2_w = i_y1;
					add_w = 1;
				end else begin
					//add_x2_w = -1;
					//add_y2_w = -1;
					add_w =0;
				end			
				if(result_mul_x==i_x1 && result_mul_y== i_y1)begin
					mul_x_w = result_mul_x;
					mul_y_w = result_mul_y;
					start_mul_w = 1;
					state_w = ADD;		
				end else begin
					add_x1_w = result_mul_x;
					add_y1_w = result_mul_y;	

					start_add_w = 1;
					state_w = ADD;				
			
				end
			end
		end
		
		DONE:begin
			finished_w = 1;
			state_w = IDLE;
		end
	endcase
	
end

always@(posedge i_clk or negedge i_rst) begin
	if(!i_rst) begin
		start_mul_r <= 0;
		start_add_r <= 0;
        add_x1_r <= 0;
        add_x2_r <= 0;
        add_y1_r <= 0;
        add_y2_r <= 0;
        mul_x_r <= 0;
        mul_y_r <= 0;
		k_counter_r <= 31;
        state_r <= IDLE;
        finished_r <= 0;
        finished_init_r <= 0;
        result_x_r <= {`MAX_BITS{1'b1}};
        result_y_r <= {`MAX_BITS{1'b1}};
        add_r <= 0;
	end else begin
		start_mul_r <= start_mul_w;
		start_add_r <= start_add_w;
        add_x1_r <= add_x1_w;
        add_x2_r <= add_x2_w;
        add_y1_r <= add_y1_w;
        add_y2_r <= add_y2_w;
        mul_x_r <= mul_x_w;
        mul_y_r <= mul_y_w;
        result_x_r <= result_x_w;
        result_y_r <= result_y_w;
		k_counter_r <= k_counter_w;
        state_r <= state_w;
        finished_r <= finished_w;
        finished_init_r <= finished_init_w;
        add_r <= add_w;

	end
end
endmodule

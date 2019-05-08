//calculate (a+1)p
//for add and double always method
//do (a+1)p anyway and decide output at the end of calculation
//a>=2 && a != (-1,-1)

//`define WIDTH 192
`include "ECCDefine.vh"

module point_add_always(
input i_clk,
input i_rst,
input i_start,
input [`MAX_BITS - 1:0]i_a,
input [`MAX_BITS - 1:0]i_b,
input [`MAX_BITS - 1:0]i_p,
input [`MAX_BITS - 1:0]i_x1,
input [`MAX_BITS - 1:0]i_y1,
input [`MAX_BITS - 1:0]i_x2,
input [`MAX_BITS - 1:0]i_y2,
input [`MAX_BITS - 1:0]i_num,//add for division
input add,//for whether add or not

output o_finish_mul,
output [`MAX_BITS - 1:0]o_result_x,
output [`MAX_BITS - 1:0]o_result_y
);
	//reg add;
    wire [`MAX_BITS - 1:0] result_in;
    reg         start_in_r, start_in_w;
    wire         finish_in; 
    reg [`MAX_BITS - 1:0]in_a_r, in_a_w; 
    reg [`MAX_BITS - 1:0]in_b_r, in_b_w; 

    wire [`MAX_BITS - 1:0] result_mod_prod3;
    reg         start_mod_prod3_r, start_mod_prod3_w;
    wire         finish_mod_prod3;  
 
    wire [`MAX_BITS - 1:0] result_mod_prod4;
    reg         start_mod_prod4_r, start_mod_prod4_w;
    wire         finish_mod_prod4;  
    reg [`MAX_BITS - 1:0]a_mod4_r, a_mod4_w;

//enum  {IDLE, MUL, RUN1, RUN2, RUNX, RUNX2, RUNY, DONE} state_r, state_w;
parameter IDLE = 3'b000;
parameter RUN1 = 3'b001;
parameter RUN2 = 3'b010;
parameter RUNX = 3'b011;
parameter RUNX2 = 3'b100;
parameter RUNY = 3'b101;
parameter DONE = 3'b110;
parameter MUL = 3'b111;
reg [3:0] state_r, state_w;
reg [`MAX_BITS - 1:0]temp_r, temp_w;
reg [`MAX_BITS - 1:0]temp1_r,temp1_w;
reg [`MAX_BITS - 1:0]temp2_r,temp2_w;
reg [`MAX_BITS - 1:0]temp3_r,temp3_w;
reg [1:0]mc_r, mc_w;
reg [`MAX_BITS - 1:0]result_x_r, result_x_w;
reg [`MAX_BITS - 1:0]result_y_r, result_y_w;
reg finished_w, finished_r;
/*
reg start_mul_r, start_mul_w;
reg [`MAX_BITS - 1:0]mul_x_r,mul_x_w;
reg [`MAX_BITS - 1:0]mul_y_r,mul_y_w;
reg [`MAX_BITS - 1:0] result_mul_x,result_mul_y;

	point_mul_1 mul(
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_start(start_mul_r),
		.i_a(i_a),
		.i_b(i_b),
		.i_p(i_p),
		.i_x1(i_x1),
		.i_y1(i_y1),

		.o_result_x(result_mul_x),
		.o_result_y(result_mul_y),
		.o_finish_mul(finish_mul)
	);
*/
	uni_inversion inversion(
		.i_clk(i_clk),
	    .i_rst(i_rst),
	    .i_start(start_in_r),
	    .i_n(i_p),
        .i_num(i_num), 
	    .i_a(in_a_r), 
        .i_b(in_b_r),
	    .o_result(result_in), // 256 bits only
	    .o_finished(finish_in)

	);

    ModuloProduct modulo_product3(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(start_mod_prod3_r),
        .i_n(i_p), // concat 1 bit to MSB since i_n [256:0]
        .i_a(temp_r), // temp
        .i_b(temp_r), // temp
        .o_result(result_mod_prod3),
        .o_finished(finish_mod_prod3)
    );
    ModuloProduct modulo_product4(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(start_mod_prod4_r),
        .i_n(i_p), // concat 1 bit to MSB since i_n [256:0]
        .i_a(temp_r), // temp
        .i_b(temp3_r), // x1 - x3
        .o_result(result_mod_prod4),
        .o_finished(finish_mod_prod4)
    );
assign o_finish_mul = finished_r;
assign o_result_x = result_x_r;
assign o_result_y = result_y_r;

always @(*) begin
	in_a_w = in_a_r;
	in_b_w = in_b_r;
	state_w = state_r;
	temp_w = temp_r;
	temp1_w = temp1_r;
	temp2_w = temp2_r;
	temp3_w = temp3_r;
	a_mod4_w = a_mod4_r;
	result_x_w = result_x_r;
	result_y_w = result_y_r;
	finished_w = finished_r;
	start_in_w = start_in_w;
	start_mod_prod3_w = start_mod_prod3_r;
	start_mod_prod4_w = start_mod_prod4_r;
	//start_mul_w = start_mul_r;
	case(state_r)
		IDLE: begin
		state_w = IDLE;

		finished_w = 0;
			if(i_start) begin
			//(2*y)^-1
				if(i_y2 > i_y1)
					in_a_w = i_y2 - i_y1;
				else
					in_a_w = i_y2 - i_y1 + i_p;

				
				//won't be happened
/*				
				if(i_x2 == -1) begin
					result_x_w = i_x1;
					result_y_w = i_y1;
					finished_w = 1;
					//state_w = DONE;
				end else 

				if(i_x1 == -1) begin
					result_x_w = i_x2;
					result_y_w = i_y2;
					finished_w = 1;
					//state_w = DONE;
				end else 
				
*/
				if(i_x2 != i_x1) begin
					if(i_x2 > i_x1)
						in_b_w = i_x2 - i_x1;
					else
						in_b_w = i_x2 - i_x1 + i_p;
					start_in_w = 1;
					//start_mod_prod_w = 1;
					//mc_w = 0;
					//state_w = RUN1;
					state_w = RUN2;
				//end
				/*
				 
				else if(i_x2 == i_x1 && i_y1 == i_y2)begin
					start_mul_w = 1;
					state_w = MUL;
				*/
				end else begin
				if(add == 0)begin
					result_x_w = i_x1;
					result_y_w = i_y1;
					state_w = DONE;
				end else begin
					result_x_w = {`MAX_BITS{1'b1}};
					result_y_w = {`MAX_BITS{1'b1}};
					state_w = DONE;
				end

				end
				
			end


			
		end
/*
		MUL: begin
				start_mul_w = 0;
				if(finish_mul) begin
					result_x_w = result_mul_x;
					result_y_w = result_mul_y;
					finished_w = 1;
					state_w = DONE;
				end
		end
*/
/*
		RUN1: begin
				start_in_w = 0;
				if(finish_in) begin
				if(i_y2 > i_y1)
					temp1_w = i_y2 - i_y1;
				else
					temp1_w = i_y2 - i_y1 + i_p;
				temp2_w = result_in;
				start_mod_prod1_w = 1;
				state_w = RUN2;
				end
		end
		RUN2: begin

			start_mod_prod1_w = 0;
			if(finish_mod_prod1)begin //3x^2/2y
				temp_w = result_mod_prod1;
				start_mod_prod3_w = 1;
				state_w = RUNX;
				mc_w = 0;
			end

		end


*/
		RUN2: begin

			start_in_w = 0;
			if(finish_in)begin //3x^2/2y
				temp_w = result_in;
				start_mod_prod3_w = 1;
				state_w = RUNX;
				mc_w = 0;
			end

		end
		RUNX: begin
			start_mod_prod3_w = 0;
			if(finish_mod_prod3) begin //temp^2
				if(add == 1)begin
				if(i_x1 + i_x2 > result_mod_prod3 + i_p)
					result_x_w = result_mod_prod3 + 2*i_p - i_x1 - i_x2;
				else if(i_x1 + i_x2 > result_mod_prod3)
					result_x_w = result_mod_prod3 + i_p - i_x1 - i_x2;
				else
					result_x_w = result_mod_prod3 - i_x1 - i_x2;
				end else begin
					result_x_w = i_x1;
				end
			state_w = RUNX2;			
			end


		end
		RUNX2:begin
				if(add == 1)begin
				if(result_x_r > i_x1)
					temp3_w = i_x1 - result_x_r + i_p;
				else
					temp3_w = i_x1 - result_x_r;
				end else begin
				if(i_x2 > i_x1)
					temp3_w = i_x1 - i_x2 + i_p;
				else
					temp3_w = i_x1 - i_x2;
				end				
				start_mod_prod4_w = 1;
				state_w = RUNY;

		end
		RUNY:begin
			start_mod_prod4_w = 0;
			if(finish_mod_prod4) begin //temp*(x1 - x3)
				if(add == 1)begin
				if(i_x1 == {`MAX_BITS{1'b1}}) begin
					result_x_w = i_x2;
					result_y_w = i_y2;
					//finished_w = 1;
					state_w = DONE;
				end else begin
					if(i_y1 > result_mod_prod4)
						result_y_w = result_mod_prod4 - i_y1 + i_p;
					else
						result_y_w = result_mod_prod4 - i_y1;
				end
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

always @(posedge i_clk or negedge i_rst) begin
	if(!i_rst) begin
	state_r <= IDLE;
	in_a_r <= 0;
	in_b_r <= 0;
	start_in_r <= 0;
	start_mod_prod3_r <= 0;
	start_mod_prod4_r <= 0;
	temp_r <= 0;
	temp1_r <= 0;
	temp2_r <= 0;
	temp3_r <= 0;
	a_mod4_r <= 0;
	result_x_r <= 0;
	result_y_r <= 0;
	finished_r <= 0;
	mc_r <= 0;
	//start_mul_r <= 0;
	end else begin
	state_r <= state_w;
	in_a_r <= in_a_w;
	in_b_r <= in_b_w;
	start_in_r <= start_in_w;
	start_mod_prod3_r <= start_mod_prod3_w;
	start_mod_prod4_r <= start_mod_prod4_w;
	temp_r <= temp_w;
	temp1_r <= temp1_w;
	temp2_r <= temp2_w;
	temp3_r <= temp3_w;
	a_mod4_r <= a_mod4_w;
	result_x_r <= result_x_w;
	result_y_r <= result_y_w;
	finished_r <= finished_w;
	mc_r <= mc_w;
	//start_mul_r <= start_mul_w;
	end

end

endmodule

//`include "../../../syn/modulo_product_syn.v"
//`include "../../../syn/unique_inversion_syn.v"

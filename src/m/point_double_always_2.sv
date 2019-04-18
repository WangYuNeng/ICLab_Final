//calculate 2p
//as general point_double

module point_double_always(
input i_clk,
input i_rst,
input i_start,
input [255:0]i_a,
input [255:0]i_b,
input [255:0]i_p,
input [255:0]i_x1,
input [255:0]i_y1,
input [255:0]i_num,
input add,//for whether add or not

output o_finish_mul,
output [255:0]o_result_x,
output [255:0]o_result_y
);


    logic [255:0] result_in1;
    logic         start_in1_r, start_in1_w;
    logic         finish_in1; 
    logic [255:0]in_a_r, in_a_w;
/*
    logic [255:0] result_in2;
    logic         start_in2_r, start_in2_w;
    logic         finish_in2;  
*/
    logic [255:0] result_mod_prod;
    logic         start_mod_prod_r, start_mod_prod_w;
    logic         finish_mod_prod;  
    logic [255:0]mod_prod_x_r, mod_prod_x_w;

    logic [255:0] result_mod_prod3;
    logic         start_mod_prod3_r, start_mod_prod3_w;
    logic         finish_mod_prod3;  
 
    logic [255:0] result_mod_prod4;
    logic         start_mod_prod4_r, start_mod_prod4_w;
    logic         finish_mod_prod4;  
    logic [255:0]a_mod4_r, a_mod4_w;

enum  {IDLE, RUN1, RUN2, RUNX, RUNX2, RUNY, DONE} state_r, state_w;
logic [255:0]temp_r, temp_w;
logic [255:0]temp1_r,temp1_w;
logic [255:0]temp2_r,temp2_w;
logic [255:0]temp3_r,temp3_w;
//logic [1:0]mc_r, mc_w;
logic [255:0]result_x_r, result_x_w;
logic [255:0]result_y_r, result_y_w;
logic finished_w, finished_r;



	ModuloProduct modulo_product(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(start_mod_prod_r),
        .i_n(i_p), // concat 1 bit to MSB since i_n [256:0]
        .i_a(mod_prod_x_r), // 3x
        .i_b(i_x1),//x
        .o_result(result_mod_prod),
        .o_finished(finish_mod_prod)
    );





	uni_inversion inversion1(
		.i_clk(i_clk),
	    .i_rst(i_rst),
	    .i_start(start_in1_r),
	    .i_n(i_p),
        .i_num(i_num), 
	    .i_a(temp1_r), 
        .i_b(in_a_r),
	    .o_result(result_in1), // 256 bits only
	    .o_finished(finish_in1)

	);
	/*
	uni_inversion inversion2(
		.i_clk(i_clk),
	    .i_rst(i_rst),
	    .i_start(start_in2_r),
	    .i_n(i_p),
        .i_num(i_num), 
	    .i_a(i_a), 
        .i_b(in_a_r),
	    .o_result(result_in2), // 256 bits only
	    .o_finished(finish_in2)

	);
*/


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

always_comb begin
	in_a_w = in_a_r;
	//mc_w = mc_r;
	state_w = state_r;
	mod_prod_x_w = mod_prod_x_r;
	temp_w = temp_r;
	temp1_w = temp1_r;
	temp2_w = temp2_r;
	temp3_w = temp3_r;
	a_mod4_w = a_mod4_r;
	result_x_w = result_x_r;
	result_y_w = result_y_r;
	finished_w = finished_r;
	start_in1_w = start_in1_r;
	//start_in2_w = start_in2_r;
	start_mod_prod_w = start_mod_prod_r;
	start_mod_prod3_w = start_mod_prod3_r;
	start_mod_prod4_w = start_mod_prod4_r;
	case(state_r)
		IDLE: begin
		finished_w = 0;
			if(i_start) begin
			//(2*y)^-1
				if(i_x1 != {256{1'b1}}) begin
					if(2*i_y1 >= i_p)
						in_a_w = 2*i_y1 - i_p;
					else
						in_a_w = 2*i_y1;
				//x^2	
					if(3*i_x1 >= 2*i_p)
						mod_prod_x_w = 3*i_x1 - 2*i_p;
					else if(3*i_x1 >= i_p)
						mod_prod_x_w = 3*i_x1 - i_p;
					else
						mod_prod_x_w = 3*i_x1;

					//start_in_w = 1;
					start_mod_prod_w = 1;
					//mc_w = 0;
					state_w = RUN1;
				end else begin
					result_x_w = i_x1;
					result_y_w = i_y1;
					finished_w = 1;
				end
			end
		end
		/*
		RUN1: begin
				start_in_w = 0;
				start_mod_prod_w = 0;
				if(finish_in)
				mc_w[1] = 1;

				if(finish_mod_prod)
				mc_w[0] = 1;

				if(mc_r == 3)begin
					temp1_w = result_mod_prod;
					temp2_w = result_in;
					start_mod_prod1_w = 1;
					start_mod_prod2_w = 1;
					mc_w = 0;
					state_w = RUN2;
				end
		*/
		/*
		RUN1: begin
				start_mod_prod_w = 0;
				if(finish_mod_prod) begin//3x^2
					temp1_w = result_mod_prod;
					start_in1_w = 1;
					start_in2_w = 1;
					mc_w = 0;
					state_w = RUN2;
				end
		end
		*/
		RUN1:begin
				start_mod_prod_w = 0;
				if(finish_mod_prod) begin//3x^2
					temp1_w = result_mod_prod;
				if(result_mod_prod + i_a >= i_p)
					temp1_w = result_mod_prod + i_a - i_p;
				else
					temp1_w = result_mod_prod + i_a;
					start_in1_w = 1;
					//start_in2_w = 1;
					//mc_w = 0;
					state_w = RUN2;
				end

		end
		RUN2: begin

			start_in1_w = 0;
			//start_in2_w = 0;
			//if(finish_in1)//3x^2/2y
			//	mc_w[1] = 1;
			//if(finish_in2)//a/2y
			//	mc_w[0] = 1;

			/*if(mc_r == 3)begin
				if(finish_in1) begin//3x^2
				if(result_in1 + result_in2 >= i_p)
					temp_w = result_in1 + result_in2 - i_p;
				else
					temp_w = result_in1 + result_in2;
				start_mod_prod3_w = 1;
				state_w = RUNX;
				mc_w = 0;
			*/
				if(finish_in1) begin//3x^2
				if(result_in1 >= i_p)
					temp_w = result_in1 - i_p;
				else
					temp_w = result_in1;
				start_mod_prod3_w = 1;
				state_w = RUNX;
				//mc_w = 0;


				end

		end
		RUNX: begin
			start_mod_prod3_w = 0;
			if(finish_mod_prod3) begin //temp^2
				if(add)begin
				if(2*i_x1 > result_mod_prod3 + i_p)
					result_x_w = result_mod_prod3 + 2*i_p - 2*i_x1;
				else if(2*i_x1 > result_mod_prod3)
					result_x_w = result_mod_prod3 + i_p - 2*i_x1;
				else
					result_x_w = result_mod_prod3 - 2*i_x1;
				end else begin
					result_x_w = i_x1;
				end

			state_w = RUNX2;			
			end


		end
		RUNX2:begin
				if(result_x_r > i_x1)
					temp3_w = i_x1 - result_x_r + i_p;
				else
					temp3_w = i_x1 - result_x_r;
				start_mod_prod4_w = 1;
				state_w = RUNY;

		end
		RUNY:begin
			start_mod_prod4_w = 0;
			if(finish_mod_prod4) begin //temp*(x1 - x3)
				if(add)begin
				if(i_y1 > result_mod_prod4)
					result_y_w = result_mod_prod4 - i_y1 + i_p;
				else
					result_y_w = result_mod_prod4 - i_y1;
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

always_ff@(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
	state_r <= IDLE;
	in_a_r <= 0;
	mod_prod_x_r <= 0;
	start_in1_r <= 0;
	//start_in2_r <= 0;
	start_mod_prod_r <= 0;
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
	//mc_r <= 0;
	end else begin
	state_r <= state_w;
	in_a_r <= in_a_w;
	mod_prod_x_r <= mod_prod_x_w;
	start_in1_r <= start_in1_w;
	//start_in2_r <= start_in2_w;
	start_mod_prod_r <= start_mod_prod_w;
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
	//mc_r <= mc_w;
	end

end

endmodule

//`include "../../../syn/modulo_product_syn.v"
//`include "../../../syn/unique_inversion_syn.v"

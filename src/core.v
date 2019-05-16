//for add and double always method
//`include "./point_double.sv"
//`include "./point_add.sv"
//20190425 change sv into v
//add and doube always
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

parameter RUN1 = 3'b001;
parameter RUN2 = 3'b010;
parameter RUNX = 3'b011;
parameter RUNX2 = 3'b110;
parameter RUNY = 3'b101;

reg [3:0] state_r, state_w;
reg [2:0]add_state_r, add_state_w;
reg [2:0]mul_state_r, mul_state_w;

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
reg [`MAX_BITS-1:0] result_add_x_r,result_add_y_r;//add result
reg [`MAX_BITS-1:0] result_add_x_w,result_add_y_w;
reg [`MAX_BITS-1:0] result_mul_x_r,result_mul_y_r;//double result
reg [`MAX_BITS-1:0] result_mul_x_w,result_mul_y_w;
reg finished_w, finished_r;
reg finished_init_w, finished_init_r;
reg add_r,add_w;

    wire [`MAX_BITS-1:0] result_in;
    reg         start_in_r, start_in_w;
    wire         finish_in; 
    reg [`MAX_BITS-1:0]in_a_r, in_a_w; 
    reg [`MAX_BITS-1:0]in_b_r, in_b_w; 

    wire [`MAX_BITS-1:0] result_mod_prod;
    reg         start_mod_prod_r, start_mod_prod_w;
    reg [`MAX_BITS-1:0]        mod_prod_a_r, mod_prod_a_w;
    reg [`MAX_BITS-1:0]        mod_prod_b_r, mod_prod_b_w;
    wire         finish_mod_prod;  
reg finished_add_w, finished_add_r;
reg finished_mul_w, finished_mul_r;
reg [`MAX_BITS:0]temp257_1,temp257_2;

/*
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
*/

	uni_inversion inversion(
		.i_clk(i_clk),
	    .i_rst(i_rst),
	    .i_start(start_in_r),
	    .i_n(i_p),
        //.i_num({`MAX_BITS{1'b0}}), 
	    .i_a(in_a_r), 
        .i_b(in_b_r),
	    .o_result(result_in), // 256 bits only
	    .o_finished(finish_in)

	);

    ModuloProduct modulo_product(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(start_mod_prod_r),
        .i_n(i_p), // concat 1 bit to MSB since i_n [256:0]
        .i_a(mod_prod_a_r), // temp
        .i_b(mod_prod_b_r), // temp
        .o_result(result_mod_prod),
        .o_finished(finish_mod_prod),
	    .i_mode(i_mode)
    );

assign o_result_x = result_x_r;
assign o_result_y = result_y_r;
assign o_finished = finished_r;

always @(*) begin
		start_mul_w = start_mul_r;
		start_add_w = start_add_r;
			start_in_w = start_in_r;
		start_mod_prod_w = start_mod_prod_r;
        k_counter_w = k_counter_r;
        add_x1_w = add_x1_r;
        add_x2_w = add_x2_r;
        add_y1_w = add_y1_r;
        add_y2_w = add_y2_r;
        mul_x_w = mul_x_r;
        mul_y_w = mul_y_r;
	    mod_prod_a_w = mod_prod_a_r;
	    mod_prod_b_w = mod_prod_b_r;
	    in_a_w = in_a_r;
	    in_b_w = in_b_r;        
        state_w = state_r;
        add_state_w = add_state_r;
    	mul_state_w = mul_state_r;
        result_x_w = result_x_r;
        result_y_w = result_y_r;
    result_mul_x_w = result_mul_x_r;
    result_mul_y_w = result_mul_y_r;
    result_add_x_w = result_add_x_r;
    result_add_y_w = result_add_y_r;
    finished_w = finished_r;
    finished_add_w = finished_add_r;
    finished_mul_w = finished_mul_r;
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
					add_x2_w = i_x1;
					add_y2_w = i_y1;
					start_mul_w = 1;
					add_w = 1;
					state_w = MUL;
				end
			end
			k_counter_w = k_counter_r - 1;		
		end

		ADD:begin
		add(start_add_r,finished_add_r,finish_in,finish_mod_prod);
		mul(start_mul_r,finished_mul_r,finish_in,finish_mod_prod);			
			start_add_w = 0;
			start_mul_w = 0;
			//if(k_counter_r != 4'hffff) begin
				if(finished_add_r) begin
					mul_x_w = result_add_x_r;
					mul_y_w = result_add_y_r;
					start_mul_w = 1;
					add_w = 1;
					state_w = MUL;
					k_counter_w = k_counter_r - 1;
					if(k_counter_r == 0)begin
						start_mul_w = 0;
						result_x_w = result_add_x_r;
						result_y_w = result_add_y_r;
						state_w = DONE;
					end					
				end
				if(finished_mul_r)begin
					mul_x_w = result_mul_x_r;
					mul_y_w = result_mul_y_r;
					start_mul_w = 1;
					add_w = 1;
					state_w = MUL;
					k_counter_w = k_counter_r - 1;
					if(k_counter_r == 0)begin
						start_mul_w = 0;
						result_x_w = result_mul_x_r;
						result_y_w = result_mul_y_r;
						state_w = DONE;
					end					
				end
	
			//end else 

		end

		MUL:begin
			mul(start_mul_r,finished_mul_r,finish_in,finish_mod_prod);
			start_mul_w = 0;
			
			if(finished_mul_r) begin
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
				if(result_mul_x_r==i_x1 && result_mul_y_r== i_y1)begin
					mul_x_w = result_mul_x_r;
					mul_y_w = result_mul_y_r;
					start_mul_w = 1;
					state_w = ADD;		
				end else begin
					add_x1_w = result_mul_x_r;
					add_y1_w = result_mul_y_r;	

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
		start_in_r <= 0;
		start_mod_prod_r <= 0;
        add_x1_r <= 0;
        add_x2_r <= i_x1;
        add_y1_r <= 0;
        add_y2_r <= i_y1;
        mul_x_r <= 0;
        mul_y_r <= 0;
		k_counter_r <= 31;
        mod_prod_a_r <= 0;
    	mod_prod_b_r <= 0;
    	in_a_r <= 0;
    	in_b_r <= 0;
           result_add_x_r <= 0;
        result_add_y_r <= 0;        
        result_mul_x_r <= 0;
        result_mul_y_r <= 0;
        state_r <= IDLE;
        add_state_r <= IDLE;
        mul_state_r <= IDLE;
        finished_r <= 0;
        finished_init_r <= 0;
        finished_add_r <= 0;
        finished_mul_r <= 0;
        result_x_r <= {`MAX_BITS{1'b1}};
        result_y_r <= {`MAX_BITS{1'b1}};
        add_r <= 0;
	end else begin
		start_mul_r <= start_mul_w;
		start_add_r <= start_add_w;
		start_in_r <= start_in_w;
		start_mod_prod_r <= start_mod_prod_w;
        add_x1_r <= add_x1_w;
        add_x2_r <= add_x2_w;
        add_y1_r <= add_y1_w;
        add_y2_r <= add_y2_w;
        mul_x_r <= mul_x_w;
        mul_y_r <= mul_y_w;
        mod_prod_a_r <= mod_prod_a_w;
    	mod_prod_b_r <= mod_prod_b_w;
    	in_a_r <= in_a_w;
    	in_b_r <= in_b_w;
        result_x_r <= result_x_w;
        result_y_r <= result_y_w;
        result_add_x_r <= result_add_x_w;
        result_add_y_r <= result_add_y_w;        
        result_mul_x_r <= result_mul_x_w;
        result_mul_y_r <= result_mul_y_w;
		k_counter_r <= k_counter_w;
        state_r <= state_w;
        add_state_r <= add_state_w;
        mul_state_r <= mul_state_w;
        finished_add_r <= finished_add_w;
        finished_mul_r <= finished_mul_w;
        finished_r <= finished_w;
        finished_init_r <= finished_init_w;
        add_r <= add_w;

	end
end

task add(input start_add_r,finished_add_r,finish_in,finish_mod_prod);
	case(add_state_r)
		IDLE: begin
		finished_add_w = 0;
			if(start_add_r) begin
			//(2*y)^-1
				if(add_y2_r > add_y1_r)
					in_a_w = add_y2_r - add_y1_r;
				else
					in_a_w = add_y2_r - add_y1_r + i_p;

				
				//won't happened
				/*
				if(add_x2_r == -1) begin
					result_x_w = add_x1_r;
					result_y_w = add_y1_r;
					finished_w = 1;
					state_w = DONE;
				end else if(add_x1_r == -1) begin
						result_x_w = add_x2_r;
						result_y_w = add_y2_r;
						finished_w = 1;
						state_w = DONE;
				end else 
				*/

				if(add_x2_r != add_x1_r) begin
					if(add_x2_r > add_x1_r)
						in_b_w = add_x2_r - add_x1_r;
					else
						in_b_w = add_x2_r - add_x1_r + i_p;
					start_in_w = 1;
					//start_mod_prod_w = 1;
					//mc_w = 0;
					//state_w = RUN1;
					add_state_w = RUN2;
				//end
				/*
				 
				else if(add_x1_r == add_x2_r && add_y1_r == add_y2_r)begin
					start_mul_w = 1;
					add_state_w = MUL;
				*/
				end else begin
			
					if(add_r == 0)begin
						result_add_x_w = add_x1_r;
						result_add_y_w = add_y1_r;
						add_state_w = DONE;
					end else begin
						result_add_x_w = {`MAX_BITS{1'b1}};
						result_add_y_w = {`MAX_BITS{1'b1}};
						add_state_w = DONE;
					end

				end
				
			end


			
		end

		RUN2: begin
			start_in_w = 0;
			if(finish_in)begin //3x^2/2y
				mod_prod_a_w = result_in;
				mod_prod_b_w = result_in;
				start_mod_prod_w = 1;
				add_state_w = RUNX;			
			end
		end
		RUNX: begin
			start_mod_prod_w = 0;

			if(finish_mod_prod) begin //temp^2
				if(add_r == 1)begin
					temp257_1 = {1'b0,add_x1_r} + add_x2_r;
					temp257_2 = {1'b0,result_mod_prod} + i_p;
					if(temp257_1 > temp257_2)
						result_add_x_w = temp257_2 + i_p - temp257_1;
					else if(temp257_1 > result_mod_prod)
						result_add_x_w = temp257_2 - temp257_1;
					else
						result_add_x_w = result_mod_prod - temp257_1;
				end else begin
					result_add_x_w = add_x1_r;
				end
			add_state_w = RUNX2;			
			end


		end
		RUNX2:begin
				if(add_r == 1)begin
					temp257_1 = {1'b0,add_x1_r} - result_add_x_r;
					temp257_2 = {1'b0,add_x1_r} - add_x2_r;
				if(result_add_x_r > add_x1_r)
					mod_prod_b_w = temp257_1 + i_p;
				else
					mod_prod_b_w = temp257_1;
				end else begin
				if(add_x2_r > add_x1_r)
					mod_prod_b_w = temp257_2 + i_p;
				else
					mod_prod_b_w = temp257_2;
				end				
				start_mod_prod_w = 1;
				add_state_w = RUNY;

		end
		RUNY:begin
			start_mod_prod_w = 0;
			if(finish_mod_prod) begin //temp*(x1 - x3)
				if(add_r == 1)begin
					if(add_x2_r == {`MAX_BITS{1'b1}}) begin
						result_x_w = add_x1_r;
						result_y_w = add_y1_r;
						//finished_w = 1;
						//add_state_w = DONE;
					end else if(add_x1_r == {`MAX_BITS{1'b1}}) begin
						result_x_w = add_x2_r;
						result_y_w = add_y2_r;
						//finished_w = 1;
						//add_state_w = DONE;
					end else begin
						temp257_1 = result_mod_prod - add_y1_r;
						if(add_y1_r > result_mod_prod)
							result_add_y_w = temp257_1 + i_p;
						else
							result_add_y_w = temp257_1;
					end
				end else begin
					result_add_y_w = add_y1_r;
				
				end
				add_state_w = DONE;

			end
		end
		DONE: begin
			finished_add_w = 1;
			add_state_w = IDLE;
		end
	endcase

endtask


task mul(input start_mul_r,finished_mul_r,finish_in,finish_mod_prod);
	case(mul_state_r)
		IDLE: begin
		finished_mul_w = 0;
			if(start_mul_r) begin
			//(2*y)^-1
				if(mul_x_r != {`MAX_BITS{1'b1}}) begin
					if(2*{1'b0,mul_y_r} >= i_p)
						in_b_w = 2*{1'b0,mul_y_r} - {1'b0,i_p};
					else
						in_b_w = 2*{1'b0,mul_y_r};
				//x^2
					mod_prod_b_w = mul_x_r;
					if(3*{2'b00,mul_x_r} >= 2*{2'b00,i_p})begin
						mod_prod_a_w = 3*{2'b00,mul_x_r} - 2*{2'b00,i_p};
					end else if(3*{2'b00,mul_x_r} >= {2'b00,i_p})begin
						mod_prod_a_w = 3*{2'b00,mul_x_r} - {2'b00,i_p};
					end else begin
						mod_prod_a_w = 3*{2'b00,mul_x_r};					
					end


					//start_in_w = 1;
					start_mod_prod_w = 1;
					//mc_w = 0;
					mul_state_w = RUN1;
				end else begin
					result_mul_x_w = mul_x_r;
					result_mul_y_w = mul_y_r;
					finished_w = 1;
				end
			end
		end
		RUN1:begin
				start_mod_prod_w = 0;
				if(finish_mod_prod) begin//3x^2
					temp257_1 = {1'b0,result_mod_prod} + i_a;
					if(temp257_1 >= i_p)
						in_a_w = temp257_1 - i_p;
					else
						in_a_w = temp257_1;
					start_in_w = 1;
					//start_in2_w = 1;
					//mc_w = 0;
					mul_state_w = RUN2;
				end

			end
		RUN2: begin

			start_in_w = 0;
			//start_in2_w = 0;
			//if(finish_in1)//3x^2/2y
			//	mc_w[1] = 1;
			//if(finish_in2)//a/2y
			//	mc_w[0] = 1;

				if(finish_in) begin//3x^2
				if(result_in >= i_p) begin
					mod_prod_a_w = result_in - i_p;
					mod_prod_b_w = result_in - i_p;
				end else begin
					mod_prod_a_w = result_in;
					mod_prod_b_w = result_in;
				end
				start_mod_prod_w = 1;
				mul_state_w = RUNX;
				//mc_w = 0;


				end

		end
		RUNX: begin
			start_mod_prod_w = 0;
			
			if(finish_mod_prod) begin //temp^2
				if(add_r)begin
				temp257_1 = result_mod_prod - 2*{1'b0,mul_x_r};	
				if(2*{1'b0,mul_x_r} > {1'b0,result_mod_prod} + i_p)
					result_mul_x_w = temp257_1 + 2*{1'b0,i_p};
				else if(2*{1'b0,mul_x_r} > result_mod_prod)
					result_mul_x_w = temp257_1 + i_p;
				else
					result_mul_x_w = temp257_1;
				end else begin
					result_mul_x_w = mul_x_r;
				end

			mul_state_w = RUNX2;			
			end


		end
		RUNX2:begin
				temp257_2 = {1'b0,mul_x_r} - result_mul_x_r;				
				if(result_mul_x_r > mul_x_r)

					mod_prod_b_w = temp257_2 + i_p;
				else
					mod_prod_b_w = temp257_2;
				start_mod_prod_w = 1;
				mul_state_w = RUNY;

		end
		RUNY:begin


			start_mod_prod_w = 0;
			if(finish_mod_prod) begin //temp*(x1 - x3)			
				if(add_r)begin
					temp257_2 = result_mod_prod - mul_y_r;
					if(mul_y_r > result_mod_prod)
						result_mul_y_w = temp257_2 + i_p;
					else
						result_mul_y_w = temp257_2;
				end else begin
					result_mul_y_w = mul_y_r;
				end

				mul_state_w = DONE;

			end
		end
		DONE: begin
			finished_mul_w = 1;
			mul_state_w = IDLE;
		end
	endcase
endtask

endmodule


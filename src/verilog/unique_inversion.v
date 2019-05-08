`define WIDTH 192
module uni_inversion(
	input  i_clk,
    input  i_rst,
    input  i_start,
    input  [`MAX_BITS-1:0] i_n,
    input  [`MAX_BITS-1:0] i_num,
    input  [`MAX_BITS-1:0] i_a,
    input  [`MAX_BITS-1:0] i_b,  
    output [`MAX_BITS-1:0] o_result, // 256 bits only
    output         o_finished

);
    wire [`MAX_BITS-1:0] result_mont;
    reg         start_mont_r, start_mont_w;
    wire         finish_mont;
    reg [`MAX_BITS-1:0] a_mont_w, a_mont_r;
    reg [`MAX_BITS-1:0] b_mont_w, b_mont_r;

parameter IDLE = 3'b000;
parameter RUN1 = 3'b001;
parameter RUN2 = 3'b010;
parameter MONT_MUL = 3'b011;
parameter DONE = 3'b100;


reg [2:0]state_r, state_w;
reg [`MAX_BITS-1:0] u_r, u_w, v_r, v_w, r_r, r_w, s_r, s_w;
reg [`MAX_BITS-1:0]i_count_r, i_count_w;
reg [`MAX_BITS-1:0]l_count_r, l_count_w;
//logic r2_r, r2_w;
reg finished_w, finished_r;
reg [`MAX_BITS-1:0] k_r,k_w;
assign o_finished = finished_r;
assign o_result = r_r;

always@(*) begin
        u_w = u_r;
		v_w = v_r;
		r_w = r_r;
		s_w = s_r;
		k_w = k_r;
        state_w = state_r;
        i_count_w = i_count_r;
        l_count_w = l_count_r;
        //start_mont_w = start_mont_r;
        a_mont_w = a_mont_r;
        b_mont_w = b_mont_r;
        finished_w = finished_r;
	case(state_r)
		IDLE: begin
            finished_w = 0;
			if(i_start) begin
                state_w = RUN1;
                u_w = i_n;
				v_w = i_b;
				r_w = 0;
				s_w = i_a;
				i_count_w = 0;
			end
		end


		RUN1: begin
			if(v_r > 0)begin
				if(u_r%2 == 0) begin
					u_w = u_r >> 1;
					if((s_r << 1) >= i_n)
						s_w = (s_r << 1) - i_n;
					else
						s_w = (s_r << 1);
				end
				else if(v_r%2 == 0) begin
					v_w = v_r >> 1;
					if((r_r << 1) >= i_n)
						r_w = (r_r << 1) - i_n;
					else
						r_w = (r_r << 1);				
				end
				else if(u_r > v_r) begin
					u_w = (u_r - v_r) >> 1;
					if(r_r + s_r >= i_n)
						r_w = r_r + s_r - i_n;
					else
						r_w = r_r + s_r;
					if((s_r << 1) >= i_n)
						s_w = (s_r << 1) - i_n;
					else
						s_w = (s_r << 1);
				end
				else begin
					v_w = (v_r - u_r) >> 1;
					if(r_r + s_r >= i_n)
						s_w = r_r + s_r - i_n;
					else
						s_w = r_r + s_r;
					if((r_r << 1) >= i_n)
						r_w = (r_r << 1) - i_n;
					else
						r_w = (r_r << 1);	
				end
			i_count_w = i_count_r + 1;
			end else begin
				if(r_r > i_n)
					r_w = r_r - i_n;
					k_w = i_count_r - i_num;
				state_w = RUN2;
			end
			
		end

		RUN2: begin
			if(l_count_r < k_r) begin
				if(r_r%2)begin
					r_w = (r_r + i_n) >> 1;
				end else begin
					r_w = r_r >> 1;
				end
			end else begin
				//start_mont_w = 1;
				//a_mont_w = i_n - r_r;
				//b_mont_w = i_r2;
				//state_w = MONT_MUL;
				r_w = i_n - r_r;
				state_w = DONE;

			end
			l_count_w = l_count_r + 1;
		end
		/*
		MONT_MUL:begin
			start_mont_w = 0;
			if(finish_mont) begin
				r_w = result_mont;
				state_w = DONE;
			end
		end
		*/
		DONE:begin
			l_count_w = 0;
			finished_w = 1;
			state_w = IDLE;
		end
	endcase
end

always@(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
		u_r <= 0;
		v_r <= 0;
		r_r <= 0;
		s_r <= 0;
		state_r <= IDLE;
        finished_r <= 0;
        i_count_r <= 0;
        l_count_r <= 0;
        //start_mont_r <= 0;
        a_mont_r <= 0;
        b_mont_r <= 0;
        finished_r <= 0;
        k_r <=0;
	end else begin
		u_r <= u_w;
		v_r <= v_w;
		r_r <= r_w;
		s_r <= s_w;
		i_count_r <= i_count_w;
		l_count_r <= l_count_w;
		state_r <= state_w;
        finished_r <= finished_w;
        //start_mont_r <= start_mont_w;
        a_mont_r <= a_mont_w;
        b_mont_r <= b_mont_w;
        finished_r <= finished_w;
        k_r<=k_w;
	end
end
endmodule

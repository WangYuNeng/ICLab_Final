`include "ECCDefine.vh"
// compute o_result = i_a / i_b  

module uni_inversion(
	input  i_clk,
    input  i_rst,
    input  i_start,
    input  [`MAX_BITS-1:0] i_n,
    input  [`MAX_BITS-1:0] i_a,
    input  [`MAX_BITS-1:0] i_b,  
    output [`MAX_BITS-1:0] o_result, // 256 bits only
    output  o_finished

);
parameter IDLE = 2'b00;
parameter RUN1 = 2'b01;
parameter RUN2 = 2'b10;

reg [1:0] state_r, state_w;
reg [`MAX_BITS-1:0] u_r, u_w, v_r, v_w, r_r, r_w, s_r, s_w;
reg [`MAX_REG+1:0] i_count_r, i_count_w;
reg finished_w, finished_r;
assign o_finished = finished_r;
assign o_result = r_r;

always@(*) begin
        u_w = u_r;
		v_w = v_r;
		r_w = r_r;
		s_w = s_r;
        state_w = state_r;
        i_count_w = i_count_r;
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
				if(!u_r[0]) begin
					u_w = u_r >> 1;
					s_w = s_r << 1;
					if((s_r << 1) >= i_n)
						s_w = (s_r << 1) - i_n;
					else
						s_w = (s_r << 1);
				end
				else if(!v_r[0]) begin
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
				state_w = RUN2;
			end
		end
		RUN2: begin
			if(i_count_r == 0) begin
				r_w = i_n - r_r;
				finished_w = 1;
				state_w = IDLE;
			end 
			else begin
				if(r_r[0])begin
					r_w = (r_r + i_n) >> 1;
				end else begin
					r_w = r_r >> 1;
				end
			end
			i_count_w = i_count_r - 1;
		end
	endcase
end

always@(posedge i_clk or negedge i_rst) begin
	if(!i_rst) begin
		u_r <= 0;
		v_r <= 0;
		r_r <= 0;
		s_r <= 0;
        i_count_r <= 0;
		state_r <= IDLE;
        finished_r <= 0;
	end else begin
		u_r <= u_w;
		v_r <= v_w;
		r_r <= r_w;
		s_r <= s_w;
		i_count_r <= i_count_w;
		state_r <= state_w;
        finished_r <= finished_w;
	end
end
endmodule

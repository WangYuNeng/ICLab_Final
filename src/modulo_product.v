//a*r
`include "ECCDefine.vh" 

module ModuloProduct(
    input  i_clk,
    input  i_rst,
    input  i_start,
	input  [1:0] i_mode,
    input  [`MAX_BITS-1:0] i_n,
    input  [`MAX_BITS-1:0] i_a, 
    input  [`MAX_BITS-1:0] i_b,
    output [`MAX_BITS-1:0] o_result, // 256 bits only
    output         o_finished
);

parameter IDLE = 1'b0;
parameter RUN  = 1'b1;

reg state_r, state_w;
reg [`MAX_BITS:0] t_r, t_w;
reg [`MAX_BITS:0] m_r, m_w;
reg [`MAX_REG+1:0] k_counter_r, k_counter_w;
reg finished_w, finished_r;
assign o_finished = finished_r;
assign o_result = m_r;
/*
reg [`MAX_REG:0] bit_num;
always@(*) begin
	case (i_mode)
		`BITS32: bit_num = 31;
		`BITS64: bit_num = 63;
		`BITS128: bit_num = 127;
		`BITS256: bit_num = 255;
	endcase
end
*/
always@(*) begin
        t_w = t_r;
        m_w = m_r;
        k_counter_w = k_counter_r;
        state_w = state_r;
        finished_w = finished_r;
	case (state_r)
		IDLE: begin
            finished_w = 0;
			if (i_start) begin
				m_w = 0;
				t_w = i_b;
				k_counter_w = 0;
				state_w = RUN;
			end
		end
		RUN: begin
			finished_w = 0;
			if(k_counter_r < `MAX_BITS) begin
				if(i_a[k_counter_r])begin
					if((m_r + t_r) >= i_n)begin
						m_w = m_r + t_r - i_n;
					end else begin
						m_w = m_r + t_r;
					end
                
				end
                k_counter_w = k_counter_r + 1;
			end 
			else begin
				finished_w = 1;
				state_w = IDLE;
			end

			if( (t_r << 1) >= i_n) begin
                t_w = (t_r << 1) - i_n;
            end 
			else begin
                t_w = t_r << 1;
            end 
		end
	endcase
end

always@(posedge i_clk or negedge i_rst) begin
	if(!i_rst) begin
		t_r <= i_b;
		m_r <= 1;
		k_counter_r <= 0;
		state_r <= IDLE;
        finished_r <= 0;
	end else begin
		t_r <= t_w;
		m_r <= m_w;
		k_counter_r <= k_counter_w;
		state_r <= state_w;
        finished_r <= finished_w;
	end
end
endmodule
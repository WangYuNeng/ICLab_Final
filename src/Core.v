module Core(
    input clk,
    input rst,
    input [MAX_BITS-1:0] i_P [1:0],
    input [MAX_BITS-1:0] i_a,
    input [MAX_BITS-1:0] i_prime,
    input [MAX_BITS-1:0] i_Pb [1:0],
    input i_p_a_valid,
    input i_pb_valid,
    output [MAX_BITS-1:0] o_Pa [1:0],
    output [MAX_BITS-1:0] o_Pab [1:0],
    output o_pa_valid,
    output o_pab_valid
);

    assign o_Pa[0] = Pa[0];
    assign o_Pa[1] = Pa[1];
    assign o_Pab[0] = Pab[0];
    assign o_Pab[1] = Pab[1];
    assign o_pa_valid = pa_valid;
    assign o_pab_valid = pab_valid;
    

    // i_P, i_a, i_prime, i_Pb can use directly, i_valids will keep their value, too

    // state control signal
    reg [1:0] state, n_state;
    localparam IDLE = 2'b00;
    localparam AP = 2'b01;
    localparam ABP = 2'b10;

    // output signal
    reg [MAX_BITS-1:0] Pa [1:0], Pab [1:0];
    reg [MAX_BITS-1:0] n_Pa [1:0], n_Pab [1:0];
    reg pa_valid, pab_valid;
    reg n_pa_valid, n_pab_valid;

    // signal for submodule
    reg [MAX_BITS-1:0] daa_point [1:0], daa_prime, daa_mul, daa_output [1:0];
    reg daa_valid, daa_finished;

    integer i;

    always@(posedge clk or negedge rst) begin
        if ( !rst ) begin
            state <= IDLE;
            for (i = 0; i < 2; i = i + 1) begin
                Pa[i] <= 0;
                Pab[i] <= 0;
            end
            pa_valid <= 0;
            pab_valid <= 0;
        end else begin
            state <= n_state;
            for (i = 0; i < 2; i = i + 1) begin
                Pa[i] <= n_Pa[i];
                Pab[i] <= n_Pab[i];
            end
            pa_valid <= n_pa_valid;
            pab_valid <= n_pab_valid;
        end
    end

    always@(*) begin
        
        n_state = state;

        for (i = 0; i < 2; i = i + 1) begin
            n_Pa[i] = Pa[i];
            n_Pab[i] = Pab[i];
            daa_point[i] = 0;
        end

        data_valid = 0;
        data_prime = 0;
        data_mul = 0;

        n_pa_valid = pa_valid;
        n_pab_valid = pab_valid;

        case ( state )
            IDLE: begin
                if ( i_p_a_valid ) begin
                    n_state = AP
                end
                if ( i_pb_valid ) begin
                    n_state = ABP
                end
            end 
            AP: begin
                daa_valid = 1;
                daa_point[0] = i_P[0];
                daa_point[1] = i_P[1];
                daa_prime = i_prime;
                daa_mul = i_a;
                if ( daa_finished ) begin
                    n_state = IDLE;
                    n_Pa[0] = daa_output[0];
                    n_Pa[0] = daa_output[1];
                    n_pa_valid = 1;
                end
            end
            ABP: begin
                daa_valid = 1;
                daa_point[0] = i_Pb[0];
                daa_point[1] = i_Pb[1];
                daa_prime = i_prime;
                daa_mul = i_a;
                if ( daa_finished ) begin
                    n_state = IDLE;
                    n_Pab[0] = daa_output[0];
                    n_Pab[0] = daa_output[1];
                    n_pab_valid = 1;
                end
            end
            default: n_state = state;
        endcase

    end

    double_and_add_always daa(
        daa_valid,
        daa_point,
        daa_prime,
        daa_mul,
        daa_finished,
        daa_output
    );

endmodule
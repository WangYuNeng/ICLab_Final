/* 
Warning: should modify the following before testing
V (1) variables can't be named started by a number, so 32BITS, 64BITS, ... these parameters are illegal
V (2) can't write MAX_REG'd1, just simply write 1 should work
V (3) missing input prime
V (4) points should contain x-cordinate and y-cordinate
V (5) i/o ports list should not ended with ";" but ","
v (6) declared as "io_state" and "n_io_state", but using "state" and "n_state" in the code
*/

/*
Something needs further discussion:
(1) o_Pa = Pa[counter] can be modify to o_Pa = Pa[0] and using shift to reduce the unnecessary mux area
Yes. However we need another 256bit to save the correct Pa, because when shifting, the Pa cannot be used by the submodule directly
I don't know which area is smaller. 
may be Pa use counter, Pab use shift reg
*/

`include "ECCDefine.v"
module Wrapper(
    // clock reset signal
    input clk,
    input rst,

    // input control signal
    input i_p_a_valid,
    input i_pb_valid,
    input i_mode,
    
    // input data
    input i_P,
    input i_ax,
    input i_ay,
    input i_prime,
    input i_Pbx,
    input i_Pby,

    //output control signal
    output reg o_Pa_valid,
    output reg o_Pab_valid,

    // output data
    output o_Pax,
    output o_Pay,
    output o_Pabx,
    output o_Paby
);

/* In/Out process
1. #0 -> i_p_a_valid 
2. #1 -> i_mode (MSB first)
3. #3 -> i_P and i_a; (MSB first)
4. #3+mode+x, x >= 1 -> i_Pb
5. o_Pa_valid( or o_Pab_valid) and their MSB transmit at the same cycle, which is different from input signal
*/


    // output signal and data
    assign o_Pax = Pa[0][counter];
    assign o_Pay = Pa[1][counter];
    assign o_Pabx = Pab[0][counter];
    assign o_Paby = Pab[1][counter];

    // input data
    reg [1:0] mode;
    reg [1:0] n_mode;
    // 0 -> x, 1 -> y
    reg [MAX_BITS - 1:0] P, a [1:0], Pb [1:0], prime;
    reg [MAX_BITS - 1:0] n_P, n_a [1:0], n_Pb [1:0], n_prime;
    reg p_a_valid, n_p_a_valid;
    reg pb_valid, n_pb_valid;

    // output data 
    reg [MAX_BITS - 1:0] Pa [1:0], Pab [1:0];
    reg [MAX_BITS - 1:0] n_Pa [1:0], n_Pab [1:0];
    reg pa_valid, n_pa_valid;
    reg pab_valid, n_pab_valid;

    // io control signal
    reg [2:0] io_state, n_io_state;
    localparam IDLE    = 3'b000;
    localparam MODE_IN = 3'b001
    localparam P_A_IN  = 3'b010;
    localparam PB_IN   = 3'b011;
    localparam PA_OUT  = 3'b100;
    localparam PAB_OUT = 3'b101;

    reg [MAX_REG:0] counter, n_counter;
    integer ite;


    always@( posedge clk or negedge rst ) begin
        if ( !rst ) begin
            io_state <= IDLE;
            mode  <= BITS32;
            P   <= 0;
            for (ite = 0; ite < 2; i = i + 1) begin
                a[i]   <= 0;
                Pb[i]  <= 0;
                Pa[i]  <= 0;
                Pab[i] <= 0;
            end
            prime <= 0;
            p_a_valid <= 0;
            pb_valid <= 0;
            pa_valid <= 0;
            pab_valid <= 0;
            counter <= 0;
        end else begin
            io_state <= n_io_state;
            mode <= n_mode;
            for (ite = 0; ite < 2; i = i + 1) begin
                a[i]   <= n_a[i];
                Pb[i]  <= n_Pb[i];
                Pa[i]  <= n_Pa[i];
                Pab[i] <= n_Pab[i];
            end
            prime <= n_prime;
            p_a_valid <= n_p_a_valid;
            pb_valid <= n_pb_valid;
            pa_valid <= n_pa_valid;
            pab_valid <= n_pab_valid;
            counter <= n_counter;
        end
    end

    always@(*) begin

        n_io_state = io_state;

        n_mode = mode;
        for (ite = 0; ite < 2; i = i + 1) begin
            n_a[i]   = a[i];
            n_Pb[i]  = Pb[i];
            n_Pa[i]  = Pa[i];
            n_Pab[i] = Pab[i];
        end
        n_prime = prime;

        n_p_a_valid = p_a_valid;
        n_pb_valid = pb_valid;
        n_pa_valid = pa_valid;
        n_pab_valid = pab_valid;

        o_Pa_valid = 0;
        o_Pab_valid = 0;

        n_counter = counter;

        case ( io_state )
            IDLE: begin

                if ( pa_valid ) begin
                    n_io_state = PA_OUT;
                end
                if ( pab_valid ) begin
                    n_io_state = PAB_OUT;
                end

                case ( mode )
                    BITS32: n_counter =  31;
                    BITS64: n_counter =  63;
                    BITS128: n_counter =  128;
                    BITS256: n_counter =  255;
                endcase

                if ( i_pb_valid ) begin
                    n_io_state = PB_IN;
                end
                if ( i_p_a_valid ) begin
                    n_io_state = MODE_IN;
                    n_counter = 1; // not sure if this is ok
                end

            end 
            MODE_IN: begin
                n_counter = counter - 1;
                n_mode = {mode[0], i_mode};

                if ( counter == 0 ) begin
                    n_io_state = P_A_IN;
                    case ( mode )
                        BITS32: n_counter =  31;
                        BITS64: n_counter =  63;
                        BITS128: n_counter =  128;
                        BITS256: n_counter =  255;
                    endcase
                end
            end
            P_A_IN: begin
                n_counter = counter - 1;
                n_P = { P[MAX_BITS - 1:1], i_P };
                n_a[0] = { a[0][MAX_BITS - 1:1], i_ax };
                n_a[1] = { a[1][MAX_BITS - 1:1], i_ay };
                n_prime = { prime[MAX_BITS - 1:1], i_prime }

                if ( counter == 0 ) begin
                    n_p_a_valid = 1;
                    n_io_state = IDLE;
                end
            end 
            PB_IN: begin
                n_counter = counter - 1;
                n_Pb[0] = { Pb[0][MAX_BITS - 1:1], i_Pbx };
                n_Pb[1] = { Pb[1][MAX_BITS - 1:1], i_Pby };

                if ( counter == 0 ) begin
                    n_pb_valid = 1;
                    n_io_state = IDLE;
                end
            end
            PA_OUT: begin
                n_counter = counter - 1;

                o_Pa_valid = 1;

                if ( counter == 0 ) begin
                    n_io_state = IDLE;
                end
            end
            PAB_OUT: begin
                n_counter = counter - 1;

                o_Pab_valid = 1;

                if ( counter == 0 ) begin
                    n_io_state = IDLE;
                end
            end
            default: begin
                n_io_state = state;
            end
        endcase
    end

    Core core(
        clk,
        rst,
        P,
        a,
        prime,
        Pb,
        n_Pa,
        n_Pab,
        p_a_valid,
        pb_valid,
        n_pa_valid,
        n_pab_valid
    );

endmodule // Wrapper

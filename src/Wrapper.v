/* 
Warning: should modify the following before testing
(1) variables can't be named started by a number, so 32BITS, 64BITS, ... these parameters are illegal
(2) can't write MAX_REG'd1, just simply write 1 should work
(3) missing input prime
(4) points should contain x-cordinate and y-cordinate
(5) i/o ports list should not ended with ";" but ","
(6) declared as "io_state" and "n_io_state", but using "state" and "n_state" in the code
*/

/*
Something needs further discussion:
(1) o_Pa = Pa[counter] can be modify to o_Pa = Pa[0] and using shift to reduce the unnecessary mux area
*/

`include "ECCDefine.v"
module Wrapper(
    // clock reset signal
    input clk;
    input rst;

    // input control signal
    input i_p_a_valid;
    input i_pb_valid;
    input i_mode;
    
    // input data
    input i_P;
    input i_a;
    input i_Pb;

    //output control signal
    output reg o_Pa_valid;
    output reg o_Pab_valid;

    // output data
    output o_Pa;
    output o_Pab;
);

/* In/Out process
1. #0 -> i_p_a_valid 
2. #1 -> i_mode (MSB first)
3. #3 -> i_P and i_a; (MSB first)
4. #3+mode+x, x >= 1 -> i_Pb
5. o_Pa_valid( or o_Pab_valid) and their MSB transmit at the same cycle, which is different from input signal
*/


    // output signal and data
    assign o_Pa = Pa[counter];
    assign o_Pab = Pab[counter];

    // input data
    reg [1:0] mode;
    reg [1:0] n_mode;
    reg [MAX_BITS - 1:0] P, a, Pb;
    reg [MAX_BITS - 1:0] n_P, n_a, n_Pb;
    reg p_a_valid, n_p_a_valid;
    reg pb_valid, n_pb_valid;

    // output data 
    reg [MAX_BITS - 1:0] Pa, Pab;
    reg [MAX_BITS - 1:0] n_Pa, n_Pab;
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

    always@( posedge clk or negedge rst ) begin
        if ( !rst ) begin
            io_state <= IDLE;
            mode  <= 32BITS;
            P   <= 0;
            a   <= 0;
            Pb  <= 0;
            Pa  <= 0;
            Pab <= 0;
            p_a_valid <= 0;
            pb_valid <= 0;
            pa_valid <= 0;
            pab_valid <= 0;
            counter <= 0;
        end else begin
            io_state <= n_io_state;
            mode <= n_mode;
            P <= n_P;
            a <= n_a;
            Pb <= n_Pb;
            Pa <= n_Pa;
            Pab <= n_Pab;
            p_a_valid <= n_p_a_valid;
            pb_valid <= n_pb_valid;
            pa_valid <= n_pa_valid;
            pab_valid <= n_pab_valid;
            counter <= n_counter;
        end
    end

    always@(*) begin

        n_state = state;

        n_mode = mode;
        n_P = P;
        n_a = a;
        n_Pb = Pb;
        n_Pa = Pa;
        n_Pab = Pab;

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
                    n_state = PA_OUT;
                end
                if ( pab_valid ) begin
                    n_state = PAB_OUT;
                end

                case ( mode )
                    32BITS: n_counter =  MAX_REG'd31;
                    64BITS: n_counter =  MAX_REG'd63;
                    128BITS: n_counter =  MAX_REG'd128;
                    256BITS: n_counter =  MAX_REG'd255;
                endcase

                if ( i_pb_valid ) begin
                    n_state = PB_IN;
                end
                if ( i_p_a_valid ) begin
                    n_state = MODE_IN;
                    n_counter = MAX_REG'd1; // not sure if this is ok
                end

            end 
            MODE_IN: begin
                n_counter = counter - 1;
                n_mode = {mode[0], i_mode};

                if ( counter == 0 ) begin
                    n_state = P_A_IN;
                    case ( mode )
                        32BITS: n_counter =  MAX_REG'd31;
                        64BITS: n_counter =  MAX_REG'd63;
                        128BITS: n_counter =  MAX_REG'd128;
                        256BITS: n_counter =  MAX_REG'd255;
                    endcase
                end
            end
            P_A_IN: begin
                n_counter = counter - 1;
                n_P = { P[MAX_BITS - 1:1], i_P };
                n_a = { a[MAX_BITS - 1:1], i_a };

                if ( counter == 0 ) begin
                    n_p_a_valid = 1;
                    n_state = IDLE;
                end
            end 
            PB_IN: begin
                n_counter = counter - 1;
                n_Pb = { Pb[MAX_BITS - 1:1], i_Pb};

                if ( counter == 0 ) begin
                    n_pb_valid = 1;
                    n_state = IDLE;
                end
            end
            PA_OUT: begin
                n_counter = counter - 1;

                o_Pa_valid = 1;
                o_Pa = Pa[counter];

                if ( counter == 0 ) begin
                    n_state = IDLE;
                end
            end
            PAB_OUT: begin
                n_counter = counter - 1;

                o_Pab_valid = 1;
                o_Pab = Pab[counter];

                if ( counter == 0 ) begin
                    n_state = IDLE;
                end
            end
            default: begin
                n_state = state;
            end
        endcase
    end

    Core core(
        clk,
        rst,
        P,
        a,
        Pb,
        n_Pa,
        n_Pab,
        p_a_valid,
        pb_valid,
        n_pa_valid,
        n_pab_valid
    );

endmodule // Wrapper

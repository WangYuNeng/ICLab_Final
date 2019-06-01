/*
a, b = coefficiont of EC
Prime
m, n = multiplier
Pointx, Pointy = coordinate of point
*/

`include "ECCDefine.vh"
module Wrapper(
    // clock reset signal
    input clk,
    input rst,

    // input control signal
    input i_data_valid,
    input i_mode,
    
    // input data
    input i_a,
    input i_prime,
    
    input i_Pointx,
    input i_Pointy,
    input i_mul,

    //output control signal
    output reg o_data_valid,

    // output data
    output reg o_Pointx,
    output reg o_Pointy
);

/* In/Out process
1. #0 -> i_data_valid 
2. #1 -> i_mode (MSB first)
3. #3 -> i_Pointx, i_Pointy, i_a, i_mul; (MSB first)
4. o_data_valid and their MSB transmit at the same cycle, which is different from input signal
5. #0 -> i_data_valid 
6. #3 -> i_Pointx, i_Pointy, i_mul; (MSB first)
4. o_data_valid and their MSB transmit at the same cycle, which is different from input signal

*/

    // input data
    reg [1:0] mode;
    reg [1:0] n_mode;
    // 0 -> x, 1 -> y
    reg [`MAX_BITS - 1:0] Px, Py, m, prime, a;
    reg [`MAX_BITS - 1:0] n_Px, n_Py, n_m, n_prime, n_a;

    // output data 
    reg [`MAX_BITS - 1:0] outPx, outPy;
    reg [`MAX_BITS - 1:0] n_outPx, n_outPy;

    reg [`MAX_REG:0] point_counter, n_point_counter;

    // output signal and data
    always@(*) begin
        case (mode)
            `BITS16: begin
                o_Pointx = outPx[15];
                o_Pointy = outPy[15];
            end
            `BITS32: begin
                o_Pointx = outPx[31];
                o_Pointy = outPy[31];
            end
            `BITS64: begin
                o_Pointx = outPx[63];
                o_Pointy = outPy[63];
            end
            `BITS128: begin
                o_Pointx = outPx[127];
                o_Pointy = outPy[127];
            end
        endcase
    end
    
    // io control signal
    reg [2:0] state, n_state;
    reg stage, n_stage;
    localparam IDLE    = 3'd0;
    localparam MODE_IN = 3'd1;
    localparam MP_IN   = 3'd2;
    localparam CAL  = 3'd3;
    localparam OUT  = 3'd4;
    localparam NP_IN   = 3'd5;


    // signal for submodule
    wire [`MAX_BITS-1:0] daa_a, daa_prime, daa_mul, daa_outputx, daa_outputy; // daa_b
    wire [1:0] daa_mode;
    wire [`MAX_BITS-1:0] daa_pointx, daa_pointy;
    reg daa_valid;
    wire daa_finished;

    assign daa_a = a;
    assign daa_prime = prime;
    assign daa_mul = m;
    assign daa_mode = mode;
    assign daa_pointx = Px;
    assign daa_pointy = Py;


    always@( posedge clk or negedge rst ) begin
        if ( !rst ) begin
            state <= IDLE;
            stage <= 0;
            mode  <= `BITS32;
            m <= 0;
            a <= 0;
            Px <= 0;
            Py <= 0;
            outPx <= 0;
            outPy <= 0;
            prime <= 0;
            point_counter <= 0;
        end else begin
            state <= n_state;
            stage <= n_stage;
            mode <= n_mode;
            m <= n_m;
            a <= n_a;
            Px <= n_Px;
            Py <= n_Py;
            outPx <= n_outPx;
            outPy <= n_outPy;
            prime <= n_prime;
            point_counter <= n_point_counter;
        end
    end

    always@(*) begin

        n_state = state;
        n_stage = stage;
        n_mode = mode;
        n_m = m;
        n_a = a;
        n_Px = Px;
        n_Py = Py;
        n_outPx = outPx;
        n_outPy = outPy;
        n_prime = prime;
        n_point_counter = point_counter;

        o_data_valid = 0;

        daa_valid = 0;

        case ( state )
            IDLE: begin

                if ( i_data_valid ) begin
                    if ( stage == 0 ) begin
                        n_state = MODE_IN;
                        n_point_counter = 1;
                    end
                    else begin
                        n_state = NP_IN;
                        case ( mode )
                            `BITS16: n_point_counter =  15;
                            `BITS32: n_point_counter =  31;
                            `BITS64: n_point_counter =  63;
                            `BITS128: n_point_counter =  127;
                        endcase
                    end
                    n_stage = ~stage;
                end
                n_Px = 0;
                n_Py = 0;
            end 
            MODE_IN: begin
                n_point_counter = point_counter - 1;
                n_mode = {mode[0], i_mode};

                if ( point_counter == 0 ) begin
                    n_state = MP_IN;
                    case ( {mode[0], i_mode} )
                        `BITS16: n_point_counter =  15;
                        `BITS32: n_point_counter =  31;
                        `BITS64: n_point_counter =  63;
                        `BITS128: n_point_counter =  127;
                    endcase
                end
            end
            MP_IN: begin
                n_point_counter = point_counter - 1;
                n_Px = { Px[`MAX_BITS - 2:0], i_Pointx };
                n_Py = { Py[`MAX_BITS - 2:0], i_Pointy };
                n_m = { m[`MAX_BITS - 2:0], i_mul };
                n_a = { a[`MAX_BITS - 2:0], i_a };
                n_prime = { prime[`MAX_BITS - 2:0], i_prime };

                if ( point_counter == 0 ) begin
                    n_state = CAL;
                end
            end 
            CAL: begin
                daa_valid = 1;
                if ( daa_finished ) begin
                    daa_valid = 0;
                    n_state = OUT;
                    n_outPx = daa_outputx;
                    n_outPy = daa_outputy;
                end
                case ( mode )
                    `BITS16: n_point_counter =  15;
                    `BITS32: n_point_counter =  31;
                    `BITS64: n_point_counter =  63;
                    `BITS128: n_point_counter =  127;
                endcase
            end
            OUT: begin
                n_point_counter = point_counter - 1;

                n_outPx = { outPx[`MAX_BITS - 2:0], outPx[`MAX_BITS - 1] };
                n_outPy = { outPy[`MAX_BITS - 2:0], outPy[`MAX_BITS - 1] };
                o_data_valid = 1;

                if ( point_counter == 0 ) begin
                    n_state = IDLE;
                end
            end
            NP_IN: begin
                n_point_counter = point_counter - 1;
                n_Px = { Px[`MAX_BITS - 2:0], i_Pointx };
                n_Py = { Py[`MAX_BITS - 2:0], i_Pointy };

                if ( point_counter == 0 ) begin
                    n_state = CAL;
                end
            end
            default: n_state = state;
        endcase
    end

    core core(
        clk,
        rst,
        daa_valid,
        daa_a,
        daa_prime,
        daa_pointx,
        daa_pointy,
        daa_mul,
        daa_mode,
        daa_outputx,
        daa_outputy,
        daa_finished
    );

endmodule // Wrapper

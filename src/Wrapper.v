/*
a, b = coefficiont of EC
Prime
m, n = multiplier
Px, Py = coordinate of point

*/

`include "ECCDefine.v"
module Wrapper(
    // clock reset signal
    input clk,
    input rst,

    // input control signal
    input i_m_P_valid,
    input i_nP_valid,
    input i_mode,
    
    // input data
    input i_a,
    input i_b,
    input i_prime,
    input i_Px,
    input i_Py,
    input i_m,
    input i_nPx,
    input i_nPy,

    //output control signal
    output reg o_mP_valid,
    output reg o_mnP_valid,

    // output data
    output o_mPx,
    output o_mPy,
    output o_mnPx,
    output o_mnpy
);

/* In/Out process
1. #0 -> i_m_P_valid 
2. #1 -> i_mode (MSB first)
3. #3 -> i_P, i_a, i_b, i_m; (MSB first)
4. #3+mode+x, x >= 1 -> i_nP
5. o_mP_valid( or o_mnP_valid) and their MSB transmit at the same cycle, which is different from input signal
*/


    // input data
    reg [1:0] mode;
    reg [1:0] n_mode;
    // 0 -> x, 1 -> y
    reg [MAX_BITS - 1:0] Px, Py, m, nPx, nPy, prime, a, b;
    reg [MAX_BITS - 1:0] n_Px, n_Py, n_m, n_nPx, n_nPy, n_prime, n_a, n_b;
    reg m_P_valid, n_m_P_valid;
    reg nP_valid, n_nP_valid;

    // output data 
    reg [MAX_BITS - 1:0] mPx, mPy, mnPx, mnPy;
    reg [MAX_BITS - 1:0] n_mPx, n_mPy, n_mnPx, n_mnPy;
    reg mP_valid, n_mP_valid;
    reg mnP_valid, n_mnP_valid;

    // output signal and data
    assign o_mPx = mPx[counter];
    assign o_mPy = mPy[counter];
    assign o_mnPx = mnPx[counter];
    assign o_mnPy = mnPy[counter];

    // io control signal
    reg [2:0] io_state, n_io_state;
    localparam IDLE    = 3'b000;
    localparam MODE_IN = 3'b001
    localparam MP_IN  = 3'b010;
    localparam NP_IN   = 3'b011;
    localparam MP_OUT  = 3'b100;
    localparam MNP_OUT = 3'b101;

    reg [MAX_REG:0] counter, n_counter;


    always@( posedge clk or negedge rst ) begin
        if ( !rst ) begin
            io_state <= IDLE;
            mode  <= BITS32;
            m <= 0;
            a <= 0;
            b <= 0;
            Px   <= 0;
            Py   <= 0;
            nPx  <= 0;
            nPy  <= 0;
            mPx  <= 0;
            mPy  <= 0;
            mnPx <= 0;
            mnPy <= 0;
            prime <= 0;
            m_P_valid <= 0;
            nP_valid <= 0;
            mP_valid <= 0;
            mnP_valid <= 0;
            counter <= 0;
        end else begin
            io_state <= n_io_state;
            mode <= n_mode;
            m <= n_m;
            a <= n_a;
            b <= n_b;
            Px   <= n_Px;
            Py   <= n_Py;
            nPx  <= n_nPx;
            nPy  <= n_nPy;
            mPx  <= n_mPx;
            mPy  <= n_mPy;
            mnPx <= n_mnPx;
            mnPy <= n_mnPy;
            prime <= n_prime;
            m_P_valid <= n_m_P_valid;
            nP_valid <= n_nP_valid;
            mP_valid <= n_mP_valid;
            mnP_valid <= n_mnP_valid;
            counter <= n_counter;
        end
    end

    always@(*) begin

        n_io_state = io_state;

        n_mode = mode;
        n_m = m;
        n_a = a;
        n_b = b;
        n_Px   = Px;
        n_Py   = Py;
        n_nPx  = nPx;
        n_nPy  = nPy;
        n_mPx  = mPx;
        n_mPy  = mPy;
        n_mnPx = mnPx;
        n_mnPy = mnPy;
        n_prime = prime;

        n_m_P_valid = m_P_valid;
        n_nP_valid = nP_valid;
        n_mP_valid = mP_valid;
        n_mnP_valid = mnP_valid;

        o_mP_valid = 0;
        o_mnP_valid = 0;

        n_counter = counter;

        case ( io_state )
            IDLE: begin

                if ( mP_valid ) begin
                    n_io_state = MP_OUT;
                end
                if ( mnP_valid ) begin
                    n_io_state = MNP_OUT;
                end

                case ( mode )
                    BITS32: n_counter =  31;
                    BITS64: n_counter =  63;
                    BITS128: n_counter =  128;
                    BITS256: n_counter =  255;
                endcase

                if ( i_nP_valid ) begin
                    n_io_state = NP_IN;
                end
                if ( i_m_P_valid ) begin
                    n_io_state = MODE_IN;
                    n_counter = 1; // not sure if this is ok
                end

            end 
            MODE_IN: begin
                n_counter = counter - 1;
                n_mode = {mode[0], i_mode};

                if ( counter == 0 ) begin
                    n_io_state = MP_IN;
                    case ( mode )
                        BITS32: n_counter =  31;
                        BITS64: n_counter =  63;
                        BITS128: n_counter =  128;
                        BITS256: n_counter =  255;
                    endcase
                end
            end
            MP_IN: begin
                n_counter = counter - 1;
                n_Px = { Px[MAX_BITS - 1:1], i_Px };
                n_Py = { Py[MAX_BITS - 1:1], i_Py };
                n_m = { m[MAX_BITS - 1:1], i_m };
                n_a = { a[MAX_BITS - 1:1], i_a };
                n_b = { a[MAX_BITS - 1:1], i_b };
                n_prime = { prime[MAX_BITS - 1:1], i_prime }

                if ( counter == 0 ) begin
                    n_m_P_valid = 1;
                    n_io_state = IDLE;
                end
            end 
            NP_IN: begin
                n_counter = counter - 1;
                n_nPx = { nPx[MAX_BITS - 1:1], i_nPx };
                n_nPy = { nPy[MAX_BITS - 1:1], i_nPy };

                if ( counter == 0 ) begin
                    n_nP_valid = 1;
                    n_io_state = IDLE;
                end
            end
            MP_OUT: begin
                n_counter = counter - 1;

                o_mP_valid = 1;

                if ( counter == 0 ) begin
                    n_io_state = IDLE;
                end
            end
            MNP_OUT: begin
                n_counter = counter - 1;

                o_mnP_valid = 1;

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
        .clk(clk),
        .rst(rst),
        .i_Px(Px),
        .i_Py(Py),
        .i_prime(prime),
        .i_a(a),
        .i_b(b),
        .i_m(m),
        .i_nPx(nPx),
        .i_nPy(nPy),
        .i_m_P_valid(m_P_valid),
        .i_nP_valid(nP_valid),
        .o_mPx(n_mPx),
        .o_mPy(n_mPy),
        .o_mnPx(n_mnPx),
        .o_mnPy(n_mnPy),
        .o_mP_valid(mP_valid),
        .o_mnP_valid(mnP_valid)
    );

endmodule // Wrapper

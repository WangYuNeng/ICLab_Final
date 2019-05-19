/*
a, b = coefficiont of EC
Prime
m, n = multiplier
Px, Py = coordinate of point
*/

`include "ECCDefine.vh"
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
    //input i_b,
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
    output reg o_mPx,
    output reg o_mPy,
    output reg o_mnPx,
    output reg o_mnPy
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
    reg [`MAX_BITS - 1:0] Px, Py, m, nPx, nPy, prime, a;//, b;
    reg [`MAX_BITS - 1:0] n_Px, n_Py, n_m, n_nPx, n_nPy, n_prime, n_a;//, n_b;
    reg m_P_valid, n_m_P_valid;
    reg nP_valid, n_nP_valid;

    // output data 
    reg [`MAX_BITS - 1:0] mPx, mPy, mnPx, mnPy;
    reg [`MAX_BITS - 1:0] n_shift_mPx, n_shift_mPy, n_shift_mnPx, n_shift_mnPy;
    reg [`MAX_BITS - 1:0] n_load_mPx, n_load_mPy, n_load_mnPx, n_load_mnPy;
    reg mP_valid, n_mP_valid;
    reg mnP_valid, n_mnP_valid;

    reg [`MAX_REG:0] mp_counter, n_mp_counter;
    reg [`MAX_REG:0] mnp_counter, n_mnp_counter;

    // output signal and data
    always@(*) begin
        case (mode)
            `BITS16: begin
                o_mPx = mPx[15];
                o_mPy = mPy[15];
                o_mnPx = mnPx[15];
                o_mnPy = mnPy[15];
            end
            `BITS32: begin
                o_mPx = mPx[31];
                o_mPy = mPy[31];
                o_mnPx = mnPx[31];
                o_mnPy = mnPy[31];
            end
            `BITS64: begin
                o_mPx = mPx[63];
                o_mPy = mPy[63];
                o_mnPx = mnPx[63];
                o_mnPy = mnPy[63];
            end
            `BITS128: begin
                o_mPx = mPx[127];
                o_mPy = mPy[127];
                o_mnPx = mnPx[127];
                o_mnPy = mnPy[127];
            end
        endcase
    end
    
    // io control signal
    reg [1:0] mp_state, n_mp_state;
    reg [1:0] mnp_state, n_mnp_state;
    reg [1:0] cal_state, n_cal_state;
    reg mp_flag, n_mp_flag, cal_flag, n_cal_flag; // 0->mp, mnp both undo, 1->finish mp
    localparam IDLE    = 2'b00;
    localparam MODE_IN = 2'b01;
    localparam MP_IN  = 2'b10;
    localparam MP_OUT  = 2'b11;

    localparam NP_IN   = 2'b10;
    localparam MNP_OUT = 2'b11;
    localparam MNP_FINISH = 2'b01;

    localparam MP_CAL = 2'b01;
    localparam MNP_CAL = 2'b10;
    localparam DONT_CAL = 2'b11;

    // signal for submodule
    wire [`MAX_BITS-1:0] daa_a,  daa_prime, daa_mul, daa_outputx, daa_outputy; // daa_b
    wire [1:0] daa_mode;
    reg [`MAX_BITS-1:0] daa_pointx, daa_pointy;
    reg daa_valid;
    wire daa_finished;

    assign daa_a = a;
    //assign daa_b = b;
    assign daa_prime = prime;
    assign daa_mul = m;
    assign daa_mode = mode;


    always@( posedge clk or negedge rst ) begin
        if ( !rst ) begin
            mp_state <= IDLE;
            mnp_state <= IDLE;
            cal_state <= IDLE;
            mp_flag <= 0;
            cal_flag <= 0;
            mode  <= `BITS32;
            m <= 0;
            a <= 0;
            //b <= 0;
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
            mp_counter <= 0;
            mnp_counter <= 0;
        end else begin
            mp_state <= n_mp_state;
            mnp_state <= n_mnp_state;
            cal_state <= n_cal_state;
            mp_flag <= n_mp_flag;
            cal_flag <= n_cal_flag;
            mode <= n_mode;
            m <= n_m;
            a <= n_a;
            //b <= n_b;
            Px   <= n_Px;
            Py   <= n_Py;
            nPx  <= n_nPx;
            nPy  <= n_nPy;

            // Assume daa cycle is longer than output so mP and mnP wouldn't interfere each other
            if ( daa_finished ) begin
                mPx  <= n_load_mPx;
                mPy  <= n_load_mPy;
                mnPx <= n_load_mnPx;
                mnPy <= n_load_mnPy;
            end else begin
                mPx  <= n_shift_mPx;
                mPy  <= n_shift_mPy;
                mnPx <= n_shift_mnPx;
                mnPy <= n_shift_mnPy;
            end

            prime <= n_prime;
            m_P_valid <= n_m_P_valid;
            nP_valid <= n_nP_valid;
            mP_valid <= n_mP_valid;
            mnP_valid <= n_mnP_valid;
            mp_counter <= n_mp_counter;
            mnp_counter <= n_mnp_counter;
        end
    end

    always@(*) begin

        n_mp_state = mp_state;
        n_mp_flag = mp_flag;

        n_mode = mode;
        n_m = m;
        n_a = a;
        //n_b = b;
        n_Px   = Px;
        n_Py   = Py;
        n_prime = prime;

        n_m_P_valid = m_P_valid;

        o_mP_valid = 0;

        n_shift_mPx = mPx;
        n_shift_mPy = mPy;
        n_mp_counter = mp_counter;

        case ( mp_state )
            IDLE: begin

                if ( mP_valid && !mp_flag ) begin
                    n_mp_state = MP_OUT;
                end

                if ( i_m_P_valid ) begin
                    n_mp_state = MODE_IN;
                    n_mp_counter = 1; // not sure if this is ok
                end

            end 
            MODE_IN: begin
                n_mp_counter = mp_counter - 1;
                n_mode = {mode[0], i_mode};

                if ( mp_counter == 0 ) begin
                    n_mp_state = MP_IN;
                    case ( {mode[0], i_mode} )
                        `BITS16: n_mp_counter =  15;
                        `BITS32: n_mp_counter =  31;
                        `BITS64: n_mp_counter =  63;
                        `BITS128: n_mp_counter =  127;
                    endcase
                end
            end
            MP_IN: begin
                n_mp_counter = mp_counter - 1;
                n_Px = { Px[`MAX_BITS - 2:0], i_Px };
                n_Py = { Py[`MAX_BITS - 2:0], i_Py };
                n_m = { m[`MAX_BITS - 2:0], i_m };
                n_a = { a[`MAX_BITS - 2:0], i_a };
                //n_b = { b[`MAX_BITS - 2:0], i_b };
                n_prime = { prime[`MAX_BITS - 2:0], i_prime };

                if ( mp_counter == 0 ) begin
                    n_m_P_valid = 1;
                    n_mp_state = IDLE;
                end
            end 
            MP_OUT: begin
                n_mp_counter = mp_counter - 1;

                n_shift_mPx = { mPx[`MAX_BITS - 2:0], mPx[`MAX_BITS - 1] };
                n_shift_mPy = { mPy[`MAX_BITS - 2:0], mPy[`MAX_BITS - 1] };
                o_mP_valid = 1;

                if ( mp_counter == 0 ) begin
                    n_mp_state = IDLE;
                    n_mp_flag = 1;
                end
            end
            default: begin
                n_mp_state = mp_state;
            end
        endcase
    end

    always@(*) begin
        
        n_mnp_state = mnp_state;

        n_nPx  = nPx;
        n_nPy  = nPy;

        n_nP_valid = nP_valid;

        n_shift_mnPx = mnPx;
        n_shift_mnPy = mnPy;
        o_mnP_valid = 0;

        n_mnp_counter = mnp_counter;

        case ( mnp_state )
            IDLE: begin

                if ( mnP_valid ) begin
                    n_mnp_state = MNP_OUT;
                end

                case ( mode )
                    `BITS16: n_mnp_counter =  15;
                    `BITS32: n_mnp_counter =  31;
                    `BITS64: n_mnp_counter =  63;
                    `BITS128: n_mnp_counter =  127;
                endcase

                if ( i_nP_valid ) begin
                    n_mnp_state = NP_IN;
                end

            end 
            NP_IN: begin
                n_mnp_counter = mnp_counter - 1;
                n_nPx = { nPx[`MAX_BITS - 2:0], i_nPx };
                n_nPy = { nPy[`MAX_BITS - 2:0], i_nPy };

                if ( mnp_counter == 0 ) begin
                    n_nP_valid = 1;
                    n_mnp_state = IDLE;
                end
            end
            MNP_OUT: begin
                n_mnp_counter = mnp_counter - 1;

                n_shift_mnPx = { mnPx[`MAX_BITS - 2:0], mnPx[`MAX_BITS - 1] };
                n_shift_mnPy = { mnPy[`MAX_BITS - 2:0], mnPy[`MAX_BITS - 1] };

                o_mnP_valid = 1;

                if ( mnp_counter == 0 ) begin
                    n_mnp_state = MNP_FINISH;
                end
            end
            MNP_FINISH: begin
                n_mnp_state = mnp_state;
            end
        endcase
    end

    always@(*) begin
        
        n_cal_state = cal_state;
        n_cal_flag = cal_flag;

        n_load_mPx = mPx;
        n_load_mPy = mPy;
        n_load_mnPx = mnPx;
        n_load_mnPy = mnPy;
        daa_pointx = 0;
        daa_pointy = 0;

        daa_valid = 0;

        n_mP_valid = mP_valid;
        n_mnP_valid = mnP_valid;

        case ( cal_state )
            IDLE: begin
                if ( m_P_valid && !cal_flag ) begin
                    n_cal_state = MP_CAL;
                end
                if ( nP_valid ) begin
                    n_cal_state = MNP_CAL;
                end
            end 
            MP_CAL: begin
                daa_valid = 1;
                daa_pointx = Px;
                daa_pointy = Py;
                if ( daa_finished ) begin
                    daa_valid = 0;
                    n_cal_state = IDLE;
                    n_load_mPx = daa_outputx;
                    n_load_mPy = daa_outputy;
                    n_mP_valid = 1;
                    n_cal_flag = 1;
                end
            end
            MNP_CAL: begin
                daa_valid = 1;
                daa_pointx = nPx;
                daa_pointy = nPy;
                if ( daa_finished ) begin
                    daa_valid = 0;
                    n_cal_state = DONT_CAL;
                    n_load_mnPx = daa_outputx;
                    n_load_mnPy = daa_outputy;
                    n_mnP_valid = 1;
                end
            end
            DONT_CAL: n_cal_state = cal_state;
        endcase

    end


    core core(
        clk,
        rst,
        daa_valid,
        daa_a,
        //daa_b,
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

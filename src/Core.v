module Core(
    input clk,
    input rst,
    input [MAX_BITS-1:0] i_Px,
    input [MAX_BITS-1:0] i_Py,
    input [MAX_BITS-1:0] i_prime,
    input [MAX_BITS-1:0] i_a,
    input [MAX_BITS-1:0] i_b,
    input [MAX_BITS-1:0] i_m,
    input [MAX_BITS-1:0] i_nPx,
    input [MAX_BITS-1:0] i_nPy,
    input i_m_P_valid,
    input i_nP_valid,
    output [MAX_BITS-1:0] o_mPx,
    output [MAX_BITS-1:0] o_mPy,
    output [MAX_BITS-1:0] o_mnPx,
    output [MAX_BITS-1:0] o_mnPy,
    output o_mP_valid,
    output o_mnP_valid
);
    

    // i_P, i_a, i_prime, i_Pb can use directly, i_valids will keep their value, too

    // state control signal
    reg [1:0] state, n_state;
    localparam IDLE = 2'b00;
    localparam MP = 2'b01;
    localparam MNP = 2'b10;

    // output signal
    reg [MAX_BITS-1:0] mPx, mPy, mnPx, mnPy;
    reg [MAX_BITS-1:0] n_mPx, n_mPy, n_mnPx, n_mnPy;
    reg mP_valid, mnP_valid;
    reg n_mP_valid, n_mnP_valid;

    assign o_nPx = nPx;
    assign o_nPy = nPy;
    assign o_mnPx = mnPx;
    assign o_mnPy = mnPy;
    assign o_mP_valid = mP_valid;
    assign o_mnP_valid = mnP_valid;

    // signal for submodule
    wire [MAX_BITS-1:0] daa_a, daa_b;
    reg [MAX_BITS-1:0] daa_pointx, daa_pointy, daa_prime, daa_mul, daa_outputx, daa_outputy;
    reg daa_valid, daa_finished;

    assign daa_a = i_a;
    assign daa_b = i_b;

    integer i;

    always@(posedge clk or negedge rst) begin
        if ( !rst ) begin
            state <= IDLE;
            mPx <= 0;
            mPy <= 0;
            mnPx <= 0;
            mnPy <= 0;
            mP_valid <= 0;
            mnP_valid <= 0;
        end else begin
            state <= n_state;
            mPx <= n_mPx;
            mPy <= n_mPy;
            mnPx <= n_mnPx;
            mnPy <= n_mnPy;
            mP_valid <= n_mP_valid;
            mnP_valid <= n_mnP_valid;
        end
    end

    always@(*) begin
        
        n_state = state;

        n_mPx = mPx;
        n_mPy = mPy;
        n_mnPx = mnPx;
        n_mnPy = mnPy;
        daa_pointx = 0;
        daa_pointy = 0;

        data_valid = 0;
        data_prime = 0;
        data_mul = 0;

        n_mP_valid = mP_valid;
        n_mnP_valid = mnP_valid;

        case ( state )
            IDLE: begin
                if ( i_m_P_valid ) begin
                    n_state = MP
                end
                if ( i_nP_valid ) begin
                    n_state = MNP
                end
            end 
            MP: begin
                daa_valid = 1;
                daa_pointx = i_Px;
                daa_pointy = i_Py;
                daa_prime = i_prime;
                daa_mul = i_m;
                if ( daa_finished ) begin
                    n_state = IDLE;
                    n_mPx = daa_outputx;
                    n_mPy = daa_outputy;
                    n_mP_valid = 1;
                end
            end
            MNP: begin
                daa_valid = 1;
                daa_pointx = i_nPx;
                daa_pointy = i_nPy;
                daa_prime = i_prime;
                daa_mul = i_m;
                if ( daa_finished ) begin
                    n_state = IDLE;
                    n_mnPx = daa_outputx;
                    n_mnPy = daa_outputy;
                    n_mnP_valid = 1;
                end
            end
            default: n_state = state;
        endcase

    end

    double_and_add_always daa(
        clk,
        rst,
        daa_valid,
        daa_pointx,
        daa_pointy,
        daa_prime,
        daa_a,
        daa_b,
        daa_mul,
        daa_finished,
        daa_outputx,
        daa_outputy
    );

endmodule
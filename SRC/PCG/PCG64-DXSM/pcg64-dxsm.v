module pcg_dxsm (
    input          clk,
    input          rst,
    input          en,
    input  [127:0] data_in,
    output reg [63:0] out
);

    reg [127:0] state;

    localparam [127:0] MULT =
        128'h2360ED051FC65DA44385DF649FCCF645;

    localparam [127:0] INC  =
        128'h5851F42D4C957F2D14057B7EF767814F;

    wire [127:0] next_state;

    assign next_state = state * MULT + INC;

    wire [63:0] hi;

    assign hi = next_state[127:64];

    wire [63:0] dx1;
    wire [63:0] dx2;
    wire [63:0] dx3;

    assign dx1 = (hi ^ (hi >> 32))
               * 64'h9E3779B97F4A7C15;

    assign dx2 = (dx1 ^ (dx1 >> 29))
               * 64'hBF58476D1CE4E5B9;

    assign dx3 = dx2 ^ (dx2 >> 32);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= data_in;
            out   <= 64'd0;
        end
        else if (en) begin
            state <= next_state;
            out   <= dx3;
        end
    end

endmodule

module philox4x32_10 (
    input         clk,
    input         rst,
    input         en,

    input  [127:0] counter,
    input  [63:0]  key,

    output reg [127:0] out,
    output reg         valid
);

    localparam [31:0] M0 = 32'hD2511F53;
    localparam [31:0] M1 = 32'hCD9E8D57;

    localparam [31:0] W0 = 32'h9E3779B9;
    localparam [31:0] W1 = 32'hBB67AE85;

    reg [31:0] c0, c1, c2, c3;
    reg [31:0] k0, k1;

    reg [3:0] round;
    reg busy;

    wire [63:0] prod0;
    wire [63:0] prod1;

    assign prod0 = c0 * M0;
    assign prod1 = c2 * M1;

    wire [31:0] hi0 = prod0[63:32];
    wire [31:0] lo0 = prod0[31:0];

    wire [31:0] hi1 = prod1[63:32];
    wire [31:0] lo1 = prod1[31:0];

    wire [31:0] next_c0;
    wire [31:0] next_c1;
    wire [31:0] next_c2;
    wire [31:0] next_c3;

    assign next_c0 = hi1 ^ c1 ^ k0;
    assign next_c1 = lo1;
    assign next_c2 = hi0 ^ c3 ^ k1;
    assign next_c3 = lo0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c0    <= 32'd0;
            c1    <= 32'd0;
            c2    <= 32'd0;
            c3    <= 32'd0;

            k0    <= 32'd0;
            k1    <= 32'd0;

            round <= 4'd0;
            busy  <= 1'b0;

            out   <= 128'd0;
            valid <= 1'b0;
        end
        else begin
            valid <= 1'b0;

            if (en && !busy) begin
                c0 <= counter[31:0];
                c1 <= counter[63:32];
                c2 <= counter[95:64];
                c3 <= counter[127:96];

                k0 <= key[31:0];
                k1 <= key[63:32];

                round <= 4'd0;
                busy  <= 1'b1;
            end
            else if (busy) begin
                c0 <= next_c0;
                c1 <= next_c1;
                c2 <= next_c2;
                c3 <= next_c3;

                k0 <= k0 + W0;
                k1 <= k1 + W1;

                if (round == 4'd9) begin
                    out   <= {next_c3, next_c2, next_c1, next_c0};
                    valid <= 1'b1;
                    busy  <= 1'b0;
                end

                round <= round + 1'b1;
            end
        end
    end

endmodule

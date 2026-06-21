module xorshift256_plus (
    input          clk,
    input          rst,
    input          en,
    input  [255:0] seed,
    output reg [63:0] out
);

    reg [63:0] s0, s1, s2, s3;

    function [63:0] rotl64;
        input [63:0] x;
        input [5:0] k;
        begin
            rotl64 = (x << k) | (x >> (64-k));
        end
    endfunction

    // Intermediate values
    wire [63:0] result;
    wire [63:0] t;

    wire [63:0] ns0;
    wire [63:0] ns1;
    wire [63:0] ns2;
    wire [63:0] ns3;

    assign result = s0 + s3;
    assign t      = s1 << 17;

    // First stage
    wire [63:0] v2;
    wire [63:0] v3;

    assign v2 = s2 ^ s0;
    assign v3 = s3 ^ s1;

    // Final next-state values
    assign ns1 = s1 ^ v2;
    assign ns0 = s0 ^ v3;
    assign ns2 = v2 ^ t;
    assign ns3 = rotl64(v3, 45);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s0 <= (seed[63:0]      == 64'd0 &&
                   seed[127:64]    == 64'd0 &&
                   seed[191:128]   == 64'd0 &&
                   seed[255:192]   == 64'd0)
                  ? 64'h1
                  : seed[63:0];

            s1 <= seed[127:64];
            s2 <= seed[191:128];
            s3 <= seed[255:192];

            out <= 64'd0;
        end
        else if (en) begin
            out <= result;

            s0 <= ns0;
            s1 <= ns1;
            s2 <= ns2;
            s3 <= ns3;
        end
    end

endmodule

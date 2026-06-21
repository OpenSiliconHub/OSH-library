// -----------------------------------------------------------------------------
// Module: xorshift32 (Xorshift Pseudo-Random Number Generator)
// Author: MrAbhi19
// Description:
//   This module implements the Xorshift32 algorithm, a fast and lightweight
//   pseudo-random number generator based on XOR and bit-shift operations.
//
//   The generator evolves its internal 32-bit state on each clock cycle
//   (when enabled), producing a new pseudo-random number.
//
// Algorithm:
//   The recurrence relation is defined as:
//       X ^= (X << 13);
//       X ^= (X >> 17);
//       X ^= (X << 5);
//   where X is the internal state.
//
// Parameters:
//   None (constants are fixed for Xorshift32)
//
// Ports:
//   clk   - Input clock signal. Advances the generator on each rising edge.
//   rst   - Asynchronous reset. Resets the generator state to the seed.
//   en    - Enable signal. When high, the generator updates its state.
//   seed  - 32-bit input seed value used to initialize the generator.
//           Valid range: 1 to (2^32 - 1).
//   out   - 32-bit output representing the current pseudo-random number.
//
// Notes:
//   - Xorshift generators are known for speed and simplicity, but not for
//     cryptographic security. They are suitable for simulations, games,
//     and non-secure randomization tasks.
//   - The output sequence is deterministic given the same seed.
//   - Ensure the seed is non-zero to avoid a stuck state (all zeros).
// -----------------------------------------------------------------------------

module xorshift32 (
  input        clk,        // Clock input
  input        rst,        // Asynchronous reset input
  input        en,         // Enable input
  input  [31:0] seed,      // Seed value (1 to 2^32 - 1)
  output reg [31:0] out    // Current pseudo-random output
);

  reg [31:0] state;        // Internal state register
  wire [31:0] x1, x2, x3;

  assign x1 = state ^ (state << 13); // Step 1: XOR with left shift by 13
  assign x2 = x1 ^ (x1 >> 17); // Step 2: XOR with right shift by 17
  assign x3 = x2 ^ (x2 << 5); // Step 3: XOR with left shift by 5

  // Sequential logic: update state and output on clock or reset
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= seed;        // Initialize state with seed
      out   <= 0;           // Clear output on reset
    end else if (en) begin
      // Xorshift32 algorithm steps:
      state <= x3;
      out   <= x3;       // Update output with new state
    end
  end

endmodule

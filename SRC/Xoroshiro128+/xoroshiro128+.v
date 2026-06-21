// ============================================================================
// Xoroshiro128+ Pseudo-Random Number Generator (PRNG)
// Author: MrAbhi19
// ----------------------------------------------------------------------------
// This module implements the xoroshiro128+ algorithm in hardware (Verilog).
// Designed by David Blackman and Sebastiano Vigna, xoroshiro128+ is a fast,
// statistically strong PRNG widely used in simulations, randomized algorithms,
// and seeding other generators.
//
// Methodology:
// 1. State Representation:
//    - The generator maintains two 64-bit registers (s0, s1), forming a 128-bit state.
//    - This state evolves deterministically with each clock cycle when enabled.
//
// 2. Output Function:
//    - Each cycle produces the sum of the two state registers: out = s0 + s1.
//    - This addition is where the name "xoroshiro128+" comes from.
//
// 3. State Transition:
//    - After producing the output, the state is updated using XOR, rotate-left,
//      and shift operations:
//        s1 ^= s0;
//        s0 = rotl(s0, 55) ^ s1 ^ (s1 << 14);
//        s1 = rotl(s1, 36);
//
//    - rotl(x, k) rotates the 64-bit word x left by k bits, wrapping around
//      the shifted-out bits.
//
// 4. Constants:
//    - Rotation by 55 and 36 bits, and shift by 14 bits, were chosen empirically
//      to maximize randomness quality and avoid linear correlations.
//    - These constants were tested extensively against statistical randomness
//      suites (like TestU01).
//
// 5. Characteristics:
//    - State size: 128 bits.
//    - Period: 2^128 - 1 (very long before repeating).
//    - Speed: Extremely fast due to simple bitwise operations.
//    - Quality: Passes most randomness tests, but not cryptographically secure.
// ----------------------------------------------------------------------------
// Limitations:
// - Not suitable for cryptographic use (predictable if state is known).
// - Lowest output bits have weaker statistical quality; higher bits are preferred.
// ============================================================================

module xoroshiro128plus (
  input clk,              // Clock signal
  input rst,              // Reset signal (synchronous to clk)
  input en,               // Enable signal (generate new random number)
  input [127:0] data_in,  // Seed input (initial state: lower 64 bits -> s0, upper 64 bits -> s1)
  output reg [63:0] out   // Random number output
);

  reg [63:0] s0, s1;   
  wire [63:0] int1;

  // Rotate left function
  // Rotates a 64-bit word x left by k bits.
  // This ensures bits wrap around instead of being discarded.
  function [63:0] rotl;
    input [63:0] x;
    input [5:0] k;
    begin
      rotl = (x << k) | (x >> (64 - k));
    end
  endfunction

  assign int1 = s1 ^ s0;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Initialize state from seed when reset is asserted
      s0 <= data_in[63:0];
      s1 <= data_in[127:64];
      out <= 64'd0;
    end else if (en) begin
      // Step 1: Output random number
      out <= s0 + s1;

      // Step 2: Update state                       // XOR step
      s0 <= rotl(s0, 55) ^ int1 ^ (int1 << 14);   // Rotate left, XOR, and shift
      s1 <= rotl(int1, 36);                     // Rotate left
    end
  end
endmodule

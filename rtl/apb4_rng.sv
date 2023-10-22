// Copyright (c) 2023 Beijing Institute of Open Source Chip
// timer is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// verilog_format: off
`define RNG_CTRL 4'b0000 //BASEADDR+0x00
`define RNG_SEED 4'b0001 //BASEADDR+0x04
`define RNG_VAL  4'b0010 //BASEADDR+0x08
// verilog_format: on

/* register mapping
 * RNG_CTRL:
 * BITS:   | 31:0 |
 * FIELDS: | RES  |
 * PERMS:  | RW   |
 * ------------------------------------
 * RNG_SEED:
 * BITS:   | 31:0 |
 * FIELDS: | SEED |
 * PERMS:  | W    |
 * ------------------------------------
 * RNG_VAL:
 * BITS:   | 31:0 |
 * FIELDS: | VAL  |
 * PERMS:  | R    |
*/

module apb4_rng #(
    parameter int DATA_WIDTH = 32
) (
    // verilog_format: off
    apb4_if.slave apb4
    // verilog_format: on
);

  logic [3:0] s_apb_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [DATA_WIDTH-1:0] s_rng_ctrl_d, s_rng_ctrl_q;
  logic [DATA_WIDTH-1:0] s_rng_val;

  assign s_apb_addr = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);

  assign s_rng_ctrl_d = (s_apb4_wr_hdshk && s_apb_addr == `RNG_CTRL) ? apb4.pwdata : s_rng_ctrl_q;
  dffr u_rng_ctrl_dffr (
      apb4.hclk,
      apb4.hresetn,
      s_rng_ctrl_d,
      s_rng_ctrl_q
  );

  lfsr_galois #(32, 32'h04C1_1DB7) u_lfsr_galois (
      .clk_i  (apb4.hclk),
      .rst_n_i(apb4.hresetn),
      .wr_i   (s_apb4_wr_hdshk && s_apb_addr == `RNG_SEED),
      .dat_i  (s_rng_seed),
      .dat_o  (s_rng_val)
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb_addr)
        `RNG_CTRL: apb4.prdata[DATA_WIDTH-1:0] = s_rng_ctrl_q;
        `RNG_VAL:  apb4.prdata[DATA_WIDTH-1:0] = s_rng_seed;
      endcase
    end
  end

  assign apb4.pready = 1'b1;
  assign apb4.pslerr = 1'b0;

endmodule

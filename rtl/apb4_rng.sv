// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rng is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "register.sv"
`include "lfsr.sv"
`include "rng_define.sv"

module apb4_rng (
    apb4_if.slave apb4
);

  logic [3:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [`RNG_VAL_WIDTH-1:0] s_rng_val;
  logic [`RNG_CTRL_WIDTH-1:0] s_rng_ctrl_d, s_rng_ctrl_q;
  logic s_rng_ctrl_en;

  assign s_apb4_addr     = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready     = 1'b1;
  assign apb4.pslverr    = 1'b0;

  assign s_rng_ctrl_en   = s_apb4_wr_hdshk && s_apb4_addr == `RNG_CTRL;
  assign s_rng_ctrl_d    = apb4.pwdata[`RNG_CTRL_WIDTH-1:0];
  dffer #(`RNG_CTRL_WIDTH) u_rng_ctrl_dffer (
      apb4.pclk,
      apb4.presetn,
      s_rng_ctrl_en,
      s_rng_ctrl_d,
      s_rng_ctrl_q
  );

  // 32bits m-sequence
  lfsr_galois #(`RNG_VAL_WIDTH, 32'hE000_0200) u_lfsr_galois (
      .clk_i  (apb4.pclk),
      .rst_n_i(apb4.presetn),
      .wr_i   (s_apb4_wr_hdshk && s_apb4_addr == `RNG_SEED && s_rng_ctrl_q[0]),
      .dat_i  (apb4.pwdata[`RNG_VAL_WIDTH-1:0]),
      .dat_o  (s_rng_val)
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `RNG_CTRL: apb4.prdata[`RNG_CTRL_WIDTH-1:0] = s_rng_ctrl_q;
        `RNG_VAL:  apb4.prdata[`RNG_VAL_WIDTH-1:0] = s_rng_val;
        default:   apb4.prdata = '0;
      endcase
    end
  end

endmodule

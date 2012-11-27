// ***************************************************************************
// ***************************************************************************
// Copyright 2011(c) Analog Devices, Inc.
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//     - Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     - Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     - Neither the name of Analog Devices, Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//     - The use of this software may or may not infringe the patent rights
//       of one or more patent holders.  This license does not release you
//       from the requirement that you obtain separate licenses from these
//       patent holders to use this software.
//     - Use of the software either in source or binary form, must be run
//       on or directly connected to an Analog Devices Inc. component.
//    
// THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED.
//
// IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
// RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module cf_adc_2c (

  pid,

  adc_clk_in_p,
  adc_clk_in_n,
  adc_data_in_p,
  adc_data_in_n,
  adc_data_or_p,
  adc_data_or_n,

  dma_clk,
  dma_valid,
  dma_data,
  dma_be,
  dma_last,
  dma_ready,

  up_rstn,
  up_clk,
  up_sel,
  up_rwn,
  up_addr,
  up_wdata,
  up_rdata,
  up_ack,
  up_status,

  up_adc_capture_int,
  up_adc_capture_ext,

  delay_rst,
  delay_clk,

  dma_dbg_data,
  dma_dbg_trigger,

  adc_clk,
  adc_dbg_data,
  adc_dbg_trigger,

  adc_mon_valid,  
  adc_mon_data);

  parameter C_CF_BUFTYPE = 0;

  input   [ 7:0]  pid;

  input           adc_clk_in_p;
  input           adc_clk_in_n;
  input   [13:0]  adc_data_in_p;
  input   [13:0]  adc_data_in_n;
  input           adc_data_or_p;
  input           adc_data_or_n;

  input           dma_clk;
  output          dma_valid;
  output  [63:0]  dma_data;
  output  [ 7:0]  dma_be;
  output          dma_last;
  input           dma_ready;

  input           up_rstn;
  input           up_clk;
  input           up_sel;
  input           up_rwn;
  input   [ 4:0]  up_addr;
  input   [31:0]  up_wdata;
  output  [31:0]  up_rdata;
  output          up_ack;
  output  [ 7:0]  up_status;

  output          up_adc_capture_int;
  input           up_adc_capture_ext;

  input           delay_rst;
  input           delay_clk;

  output  [63:0]  dma_dbg_data;
  output  [ 7:0]  dma_dbg_trigger;

  output          adc_clk;
  output  [63:0]  adc_dbg_data;
  output  [ 7:0]  adc_dbg_trigger;

  output          adc_mon_valid;
  output  [31:0]  adc_mon_data;

  reg     [ 1:0]  up_ch_sel = 'd0;
  reg             up_adc_capture_int = 'd0;
  reg     [15:0]  up_capture_count = 'd0;
  reg             up_dma_unf_hold = 'd0;
  reg             up_dma_ovf_hold = 'd0;
  reg             up_dma_status = 'd0;
  reg     [ 1:0]  up_adc_or_hold = 'd0;
  reg     [ 1:0]  up_adc_pn_oos_hold = 'd0;
  reg     [ 1:0]  up_adc_pn_err_hold = 'd0;
  reg     [ 1:0]  up_dmode = 'd0;
  reg             up_delay_sel = 'd0;
  reg             up_delay_rwn = 'd0;
  reg     [ 3:0]  up_delay_addr = 'd0;
  reg     [ 4:0]  up_delay_wdata = 'd0;
  reg     [ 1:0]  up_pn_type = 'd0;
  reg             up_muladd_offbin = 'd0;
  reg             up_muladd_enable = 'd0;
  reg             up_signext_enable = 'd0;
  reg             up_status_enable = 'd0;
  reg     [14:0]  up_muladd_offset_a = 'd0;
  reg     [15:0]  up_muladd_scale_a = 'd0;
  reg     [14:0]  up_muladd_offset_b = 'd0;
  reg     [15:0]  up_muladd_scale_b = 'd0;
  reg     [ 7:0]  up_status = 'd0;
  reg             up_adc_master_capture_n = 'd0;
  reg     [31:0]  up_rdata = 'd0;
  reg             up_sel_d = 'd0;
  reg             up_sel_2d = 'd0;
  reg             up_ack = 'd0;
  reg             up_dma_ovf_m1 = 'd0;
  reg             up_dma_ovf_m2 = 'd0;
  reg             up_dma_ovf = 'd0;
  reg             up_dma_unf_m1 = 'd0;
  reg             up_dma_unf_m2 = 'd0;
  reg             up_dma_unf = 'd0;
  reg             up_dma_complete_m1 = 'd0;
  reg             up_dma_complete_m2 = 'd0;
  reg             up_dma_complete_m3 = 'd0;
  reg             up_dma_complete = 'd0;
  reg     [ 1:0]  up_adc_or_m1 = 'd0;
  reg     [ 1:0]  up_adc_or_m2 = 'd0;
  reg     [ 1:0]  up_adc_or = 'd0;
  reg     [ 1:0]  up_adc_pn_oos_m1 = 'd0;
  reg     [ 1:0]  up_adc_pn_oos_m2 = 'd0;
  reg     [ 1:0]  up_adc_pn_oos = 'd0;
  reg     [ 1:0]  up_adc_pn_err_m1 = 'd0;
  reg     [ 1:0]  up_adc_pn_err_m2 = 'd0;
  reg     [ 1:0]  up_adc_pn_err = 'd0;
  reg             up_delay_ack_m1 = 'd0;
  reg             up_delay_ack_m2 = 'd0;
  reg             up_delay_ack_m3 = 'd0;
  reg             up_delay_ack = 'd0;
  reg     [ 4:0]  up_delay_rdata = 'd0;
  reg             up_delay_locked = 'd0;

  wire            up_wr_s;
  wire            up_ack_s;
  wire            adc_master_capture_s;
  wire            dma_ovf_s;
  wire            dma_unf_s;
  wire            dma_complete_s;
  wire            adc_valid_s;
  wire    [63:0]  adc_data_s;
  wire    [ 1:0]  adc_or_s;
  wire    [ 1:0]  adc_pn_oos_s;
  wire    [ 1:0]  adc_pn_err_s;
  wire            delay_ack_s;
  wire    [ 4:0]  delay_rdata_s;
  wire            delay_locked_s;

  assign up_wr_s = up_sel & ~up_rwn;
  assign up_ack_s = up_sel_d & ~up_sel_2d;

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_ch_sel <= 'd3;
      up_adc_capture_int <= 'd0;
      up_capture_count <= 'd0;
      up_dma_unf_hold <= 'd0;
      up_dma_ovf_hold <= 'd0;
      up_dma_status <= 'd0;
      up_adc_or_hold <= 'd0;
      up_adc_pn_oos_hold <= 'd0;
      up_adc_pn_err_hold <= 'd0;
      up_dmode <= 'd0;
      up_delay_sel <= 'd0;
      up_delay_rwn <= 'd0;
      up_delay_addr <= 'd0;
      up_delay_wdata <= 'd0;
      up_pn_type <= 'd0;
      up_muladd_offbin <= 'd0;
      up_muladd_enable <= 'd0;
      up_signext_enable <= 'd0;
      up_status_enable <= 'd0;
      up_muladd_offset_a <= 'd0;
      up_muladd_scale_a <= 'd0;
      up_muladd_offset_b <= 'd0;
      up_muladd_scale_b <= 'd0;
      up_status <= 'd0;
      up_adc_master_capture_n <= 'd1;
    end else begin
      if ((up_addr == 5'h02) && (up_wr_s == 1'b1)) begin
        up_ch_sel <= up_wdata[1:0];
      end
      if ((up_addr == 5'h03) && (up_wr_s == 1'b1)) begin
        up_adc_capture_int <= up_wdata[16];
        up_capture_count <= up_wdata[15:0];
      end
      if (up_dma_unf == 1'b1) begin
        up_dma_unf_hold <= 1'b1;
      end else if ((up_addr == 5'h04) && (up_wr_s == 1'b1)) begin
        up_dma_unf_hold <= up_dma_unf_hold & ~up_wdata[2];
      end
      if (up_dma_ovf == 1'b1) begin
        up_dma_ovf_hold <= 1'b1;
      end else if ((up_addr == 5'h04) && (up_wr_s == 1'b1)) begin
        up_dma_ovf_hold <= up_dma_ovf_hold & ~up_wdata[2];
      end
      if (up_dma_complete == 1'b1) begin
        up_dma_status <= 1'b0;
      end else if ((up_addr == 5'h03) && (up_wr_s == 1'b1) && (up_dma_status == 1'b0)) begin
        up_dma_status <= up_wdata[16];
      end
      if (up_adc_or[0] == 1'b1) begin
        up_adc_or_hold[0] <= 1'b1;
      end else if ((up_addr == 5'h05) && (up_wr_s == 1'b1)) begin
        up_adc_or_hold[0] <= up_adc_or_hold[0] & ~up_wdata[0];
      end
      if (up_adc_or[1] == 1'b1) begin
        up_adc_or_hold[1] <= 1'b1;
      end else if ((up_addr == 5'h05) && (up_wr_s == 1'b1)) begin
        up_adc_or_hold[1] <= up_adc_or_hold[1] & ~up_wdata[1];
      end
      if (up_adc_pn_oos[0] == 1'b1) begin
        up_adc_pn_oos_hold[0] <= 1'b1;
      end else if ((up_addr == 5'h05) && (up_wr_s == 1'b1)) begin
        up_adc_pn_oos_hold[0] <= up_adc_pn_oos_hold[0] & ~up_wdata[2];
      end
      if (up_adc_pn_oos[1] == 1'b1) begin
        up_adc_pn_oos_hold[1] <= 1'b1;
      end else if ((up_addr == 5'h05) && (up_wr_s == 1'b1)) begin
        up_adc_pn_oos_hold[1] <= up_adc_pn_oos_hold[1] & ~up_wdata[3];
      end
      if (up_adc_pn_err[0] == 1'b1) begin
        up_adc_pn_err_hold[0] <= 1'b1;
      end else if ((up_addr == 5'h05) && (up_wr_s == 1'b1)) begin
        up_adc_pn_err_hold[0] <= up_adc_pn_err_hold[0] & ~up_wdata[4];
      end
      if (up_adc_pn_err[1] == 1'b1) begin
        up_adc_pn_err_hold[1] <= 1'b1;
      end else if ((up_addr == 5'h05) && (up_wr_s == 1'b1)) begin
        up_adc_pn_err_hold[1] <= up_adc_pn_err_hold[1] & ~up_wdata[5];
      end
      if ((up_addr == 5'h06) && (up_wr_s == 1'b1)) begin
        up_dmode <= up_wdata[1:0];
      end
      if ((up_addr == 5'h07) && (up_wr_s == 1'b1)) begin
        up_delay_sel <= up_wdata[17];
        up_delay_rwn <= up_wdata[16];
        up_delay_addr <= up_wdata[11:8];
        up_delay_wdata <= up_wdata[4:0];
      end
      if ((up_addr == 5'h09) && (up_wr_s == 1'b1)) begin
        up_pn_type <= up_wdata[1:0];
      end
      if ((up_addr == 5'h0b) && (up_wr_s == 1'b1)) begin
        up_muladd_offbin <= up_wdata[3];
        up_muladd_enable <= up_wdata[2];
        up_signext_enable <= up_wdata[1];
        up_status_enable <= up_wdata[0];
      end
      if ((up_addr == 5'h10) && (up_wr_s == 1'b1)) begin
        up_muladd_offset_a <= up_wdata[30:16];
        up_muladd_scale_a <= up_wdata[15:0];
      end
      if ((up_addr == 5'h11) && (up_wr_s == 1'b1)) begin
        up_muladd_offset_b <= up_wdata[30:16];
        up_muladd_scale_b <= up_wdata[15:0];
      end
      if (up_status_enable == 1'b1) begin
        up_status <= {5'd1, up_adc_capture_int, up_dma_ovf, up_dma_status};
      end else begin
        up_status <= 'd0;
      end
      if (pid == 0) begin
        up_adc_master_capture_n <= ~up_adc_capture_int;
      end else begin
        up_adc_master_capture_n <= ~up_adc_capture_ext;
      end
    end
  end

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_rdata <= 'd0;
      up_sel_d <= 'd0;
      up_sel_2d <= 'd0;
      up_ack <= 'd0;
    end else begin
      case (up_addr)
        5'h00: up_rdata <= 32'h00010061;
        5'h02: up_rdata <= {14'd0, up_ch_sel};
        5'h03: up_rdata <= {15'd0, up_adc_capture_int, up_capture_count};
        5'h04: up_rdata <= {29'd0, up_dma_unf_hold, up_dma_ovf_hold, up_dma_status};
        5'h05: up_rdata <= {26'd0, up_adc_pn_err_hold, up_adc_pn_oos_hold, up_adc_or_hold};
        5'h06: up_rdata <= {30'd0, up_dmode};
        5'h07: up_rdata <= {14'd0, up_delay_sel, up_delay_rwn, 4'd0, up_delay_addr,
                            3'd0, up_delay_wdata};
        5'h08: up_rdata <= {23'd0, up_delay_locked, 3'd0, up_delay_rdata};
        5'h09: up_rdata <= {30'd0, up_pn_type};
        5'h0b: up_rdata <= {28'd0, up_muladd_offbin, up_muladd_enable,
                            up_signext_enable, up_status_enable};
        5'h0c: up_rdata <= {24'd0, pid};
        5'h10: up_rdata <= {1'b0, up_muladd_offset_a, up_muladd_scale_a};
        5'h11: up_rdata <= {1'b0, up_muladd_offset_b, up_muladd_scale_b};
        default: up_rdata <= 0;
      endcase
      up_sel_d <= up_sel;
      up_sel_2d <= up_sel_d;
      up_ack <= up_ack_s;
    end
  end

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_dma_ovf_m1 <= 'd0;
      up_dma_ovf_m2 <= 'd0;
      up_dma_ovf <= 'd0;
      up_dma_unf_m1 <= 'd0;
      up_dma_unf_m2 <= 'd0;
      up_dma_unf <= 'd0;
      up_dma_complete_m1 <= 'd0;
      up_dma_complete_m2 <= 'd0;
      up_dma_complete_m3 <= 'd0;
      up_dma_complete <= 'd0;
    end else begin
      up_dma_ovf_m1 <= dma_ovf_s;
      up_dma_ovf_m2 <= up_dma_ovf_m1;
      up_dma_ovf <= up_dma_ovf_m2;
      up_dma_unf_m1 <= dma_unf_s;
      up_dma_unf_m2 <= up_dma_unf_m1;
      up_dma_unf <= up_dma_unf_m2;
      up_dma_complete_m1 <= dma_complete_s;
      up_dma_complete_m2 <= up_dma_complete_m1;
      up_dma_complete_m3 <= up_dma_complete_m2;
      up_dma_complete <= up_dma_complete_m3 ^ up_dma_complete_m2;
    end
  end

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_adc_or_m1 <= 'd0;
      up_adc_or_m2 <= 'd0;
      up_adc_or <= 'd0;
      up_adc_pn_oos_m1 <= 'd0;
      up_adc_pn_oos_m2 <= 'd0;
      up_adc_pn_oos <= 'd0;
      up_adc_pn_err_m1 <= 'd0;
      up_adc_pn_err_m2 <= 'd0;
      up_adc_pn_err <= 'd0;
      up_delay_ack_m1 <= 'd0;
      up_delay_ack_m2 <= 'd0;
      up_delay_ack_m3 <= 'd0;
      up_delay_ack <= 'd0;
      up_delay_rdata <= 'd0;
      up_delay_locked <= 'd0;
    end else begin
      up_adc_or_m1 <= adc_or_s;
      up_adc_or_m2 <= up_adc_or_m1;
      up_adc_or <= up_adc_or_m2;
      up_adc_pn_oos_m1 <= adc_pn_oos_s;
      up_adc_pn_oos_m2 <= up_adc_pn_oos_m1;
      up_adc_pn_oos <= up_adc_pn_oos_m2;
      up_adc_pn_err_m1 <= adc_pn_err_s;
      up_adc_pn_err_m2 <= up_adc_pn_err_m1;
      up_adc_pn_err <= up_adc_pn_err_m2;
      up_delay_ack_m1 <= delay_ack_s;
      up_delay_ack_m2 <= up_delay_ack_m1;
      up_delay_ack_m3 <= up_delay_ack_m2;
      up_delay_ack <= up_delay_ack_m3 ^ up_delay_ack_m2;
      if (up_delay_ack == 1'b1) begin
        up_delay_rdata <= delay_rdata_s;
        up_delay_locked <= delay_locked_s;
      end
    end
  end

  FDCE #(.INIT(1'b0)) i_m_capture (
    .CE (1'b1),
    .D (1'b1),
    .CLR (up_adc_master_capture_n),
    .C (adc_clk),
    .Q (adc_master_capture_s));

  cf_dma_wr i_dma_wr (
    .adc_clk (adc_clk),
    .adc_valid (adc_valid_s),
    .adc_data (adc_data_s),
    .adc_master_capture (adc_master_capture_s),
    .dma_clk (dma_clk),
    .dma_valid (dma_valid),
    .dma_data (dma_data),
    .dma_be (dma_be),
    .dma_last (dma_last),
    .dma_ready (dma_ready),
    .dma_ovf (dma_ovf_s),
    .dma_unf (dma_unf_s),
    .dma_complete (dma_complete_s),
    .up_capture_count (up_capture_count),
    .dma_dbg_data (dma_dbg_data),
    .dma_dbg_trigger (dma_dbg_trigger),
    .adc_dbg_data (adc_dbg_data),
    .adc_dbg_trigger (adc_dbg_trigger));

  cf_adc_wr #(.C_CF_BUFTYPE(C_CF_BUFTYPE)) i_adc_wr (
    .adc_clk_in_p (adc_clk_in_p),
    .adc_clk_in_n (adc_clk_in_n),
    .adc_data_in_p (adc_data_in_p),
    .adc_data_in_n (adc_data_in_n),
    .adc_data_or_p (adc_data_or_p),
    .adc_data_or_n (adc_data_or_n),
    .adc_clk (adc_clk),
    .adc_valid (adc_valid_s),
    .adc_data (adc_data_s),
    .adc_or (adc_or_s),
    .adc_pn_oos (adc_pn_oos_s),
    .adc_pn_err (adc_pn_err_s),
    .up_signext_enable (up_signext_enable),
    .up_muladd_enable (up_muladd_enable),
    .up_muladd_offbin (up_muladd_offbin),
    .up_muladd_scale_a (up_muladd_scale_a),
    .up_muladd_offset_a (up_muladd_offset_a),
    .up_muladd_scale_b (up_muladd_scale_b),
    .up_muladd_offset_b (up_muladd_offset_b),
    .up_pn_type (up_pn_type),
    .up_dmode (up_dmode),
    .up_ch_sel (up_ch_sel),
    .up_delay_sel (up_delay_sel),
    .up_delay_rwn (up_delay_rwn),
    .up_delay_addr (up_delay_addr),
    .up_delay_wdata (up_delay_wdata),
    .delay_rst (delay_rst),
    .delay_clk (delay_clk),
    .delay_ack (delay_ack_s),
    .delay_rdata (delay_rdata_s),
    .delay_locked (delay_locked_s),
    .debug_data (),
    .debug_trigger (),
    .adc_mon_valid (adc_mon_valid),
    .adc_mon_data (adc_mon_data));

endmodule

// ***************************************************************************
// ***************************************************************************

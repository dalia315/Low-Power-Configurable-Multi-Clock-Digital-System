module UART_RX(
  input        CLK,
  input        RST,
  input        RX_IN,
  input  [4:0] prescale,
  input        PAR_EN,
  input        PAR_TYP,
  output       Data_valid,
  output [7:0] P_DATA,
  output       parity_error,
  output       framing_error
  );
  
wire enable,
     data_samp_en,
     par_chk_en,
     strt_chk_en,
     strt_glitch,
     stp_chk_en,
     deser_en,
     sampled_bit;
     
wire [4:0] bit_cnt,
           edge_cnt;
           
FSM_RX F0(
.CLK(CLK),
.RST(RST),
.RX_IN(RX_IN),
.bit_cnt(bit_cnt),
.edge_cnt(edge_cnt),
.PAR_EN(PAR_EN),
.par_err(parity_error),
.strt_glitch(strt_glitch),
.stp_err(framing_error),
.enable(enable),
.data_samp_en(data_samp_en),
.par_chk_en(par_chk_en),
.strt_chk_en(strt_chk_en),
.stp_chk_en(stp_chk_en),
.deser_en(deser_en),
.data_valid(Data_valid)
);

data_sampling S0(
.clk(CLK),
.RX_IN(RX_IN),
.prescale(prescale),
.data_samp_en(data_samp_en),
.edge_cnt(edge_cnt),
.sampled_bit(sampled_bit)
);

deserializer D0(
.clk(CLK),
.deser_en(deser_en),
.sampled_bit(sampled_bit),
.edge_cnt(edge_cnt),
.bit_cnt(bit_cnt),
.P_DATA(P_DATA)
);

edge_bit_counter E0(
.enable(enable),
.clk(CLK),
.PAR_EN(PAR_EN),
.bit_cnt(bit_cnt),
.edge_cnt(edge_cnt)
);

parity_check P0(
.par_chk_en(par_chk_en),
.PAR_TYP(PAR_TYP),
.P_DATA(P_DATA),
.sampled_bit(sampled_bit),
.par_err(parity_error)
);

stop_check S_C0 (
.stp_chk_en(stp_chk_en),
.sampled_bit(sampled_bit),
.stp_err(framing_error)
);

strt_check S_C1(
.strt_chk_en(strt_chk_en),
.sampled_bit(sampled_bit),
.strt_glitch(strt_glitch)
);


endmodule

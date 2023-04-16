module UART_TX #(parameter width = 8)
(
  input               CLK,RST,
  input [width-1:0]   P_DATA,
  input               data_valid,
  input               PAR_EN,PAR_TYP,
  output              TX_OUT,
  output              busy
  );
  
  wire done,enable,data,parity;
  wire [1:0] selector;
  
  serializer S0(
  .P_DATA(P_DATA),
  .ser_en(enable),
  .CLK(CLK),
  .RST(RST),
  .ser_done(done),
  .ser_data(data)
  );
  
  FSM F0(
  .data_valid(data_valid),
  .ser_done(done),
  .PAR_EN(PAR_EN),
  .CLK(CLK),
  .RST(RST),
  .ser_en(enable),
  .mux_sel(selector),
  .busy(busy)
  );
  
  mux4_1 M0(
  .mux_sel(selector),
  .parity_bit(parity),
  .ser_data(data),
  .TX_OUT(TX_OUT)
  );
  
  parity_calc P0(
  .P_DATA(P_DATA),
  .data_valid(data_valid),
  .PAR_TYP(PAR_TYP),
  .par_bit(parity)
  );


  
endmodule
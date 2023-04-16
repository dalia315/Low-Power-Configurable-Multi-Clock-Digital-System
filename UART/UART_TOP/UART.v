module UART 
(
 input         TX_CLK,RX_CLK,RST,
 input         RX_IN_S,
 input  [7:0]  REG2,
 output        data_RX_P_valid,
 output [7:0]  RX_P_DATA,
 input  [7:0]  TX_P_DATA,
 input         data_TX_P_valid,
 output        TX_OUT_S,
 output        TX_OUT_S_valid,
 output        parity_error,framing_error
   );

UART_RX U_RX0 (
 .CLK(RX_CLK),
 .RST(RST),
 .RX_IN(RX_IN_S),
 .prescale(REG2[6:2]),
 .PAR_EN(REG2[0]),
 .PAR_TYP(REG2[1]),
 .Data_valid(data_RX_P_valid),
 .P_DATA(RX_P_DATA),
 .parity_error(parity_error),
 .framing_error(framing_error)
);

/*UART_RX U0_UART_RX (
.CLK(RX_CLK),
.RST(RST),
.RX_IN(RX_IN_S),
.Prescale(REG2[6:2]),
.parity_enable(REG2[0]),
.parity_type(REG2[1]),
.P_DATA(RX_OUT_P), 
.data_valid(RX_OUT_V),
.parity_error(parity_error),
.framing_error(framing_error)
);*/

UART_TX U_TX0 (
.CLK(TX_CLK),
.RST(RST),
.P_DATA(TX_P_DATA),
.data_valid(data_TX_P_valid),
.PAR_EN(REG2[0]),
.PAR_TYP(REG2[1]),
.TX_OUT(TX_OUT_S),
.busy(TX_OUT_S_valid)
);

endmodule
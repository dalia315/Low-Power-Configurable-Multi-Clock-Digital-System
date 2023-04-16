//////////////////////////////////////////////////////////////////////////////////////
//====================================================================================
// Author: Dalia Amgad
// Creation Date:  3/9/2023
//====================================================================================
//  This design takes commands from UART and stores it in register file or do       
//  operations in ALU.. 
//  The RTL is titally written by me under the supervision of ENG. Ali El Temsah                                                    
//  things to be modified later: - consider the pipelining
//                               - add FIFO between the 2 clocks domain 
//                               - send data with word size bigger than 8 bits
//  NOTE that the UART is designed to send MSB first then LSB
//====================================================================================
//////////////////////////////////////////////////////////////////////////////////////

module SYS_TOP #(parameter n = 4, m = 8)
  (
  input    Ref_Clk,UART_Clk,
  input    Rst,
  input    RX_IN,
  output   TX_OUT,
  output   parity_error,framing_error
  );
  
  //Regfile wires
  wire [m-1:0]  op_A,op_B;
  wire          Rst_sync;
  wire          Rd_En,Wr_En,Rd_data_valid;
  wire [n-1:0]  address;
  wire [m-1:0]  Wr_data,Rd_data;
  wire [m-1:0]  UART_config;
  wire [3:0]    div_ratio;
  
  //ALU wires
  wire        clk_gated,enable,ALU_out_valid;
  wire [3:0]  func;
  wire [15:0] ALU_OUT;
  
  //UART wires
  wire       P_DATA_RX_VALID,P_DATA_TX_VALID,S_DATA_RX_VALID;
  wire [7:0] RX_P_DATA,TX_P_DATA;
  
  //ClkDiv wires
  wire CLKDiv_EN;
  wire TX_CLK;
  
  //RST sync wires
  wire Rst_UART_sync;
  
  //data sync wires
  wire [7:0] UART_OUT_P_DATA,UART_IN_P_DATA;
  wire       UART_OUT_DATA_VALID,UART_IN_DATA_VALID;
  
  //Clock gate
  wire CLK_EN;
  
  RegFile r0(
  .Clk(Ref_Clk),
  .Rst(Rst_sync),
  .RdEn(Rd_En),
  .WrEn(Wr_En),
  .address(address),
  .WrData(Wr_data),
  .RdData(Rd_data),
  .Rd_dataValid(Rd_data_valid),
  .REG0(op_A),
  .REG1(op_B),
  .REG2(UART_config),
  .REG3({4'b0,div_ratio})
  );
  
  ALU A0(
  .A(op_A), 
  .B(op_B),
  .EN(enable),
  .ALU_FUN(func),
  .CLK(clk_gated),
  .RST(Rst_sync),  
  .ALU_OUT(ALU_OUT),
  .OUT_VALID(ALU_out_valid)
  );
  
  RST_SYNC RS0 (
  .CLK(Ref_Clk),
  .RST(Rst),
  .SYNC_RST(Rst_sync)
  );
  
  RST_SYNC RS_UART0 (
  .CLK(UART_Clk),
  .RST(Rst),
  .SYNC_RST(Rst_UART_sync)
  );
  
  UART U0 (
  .TX_CLK(TX_CLK),
  .RX_CLK(UART_Clk),
  .RST(Rst_UART_sync),
  .RX_IN_S(RX_IN),
  .REG2(UART_config),
  .data_RX_P_valid(P_DATA_RX_VALID),
  .RX_P_DATA(RX_P_DATA),
  .TX_P_DATA(TX_P_DATA),
  .data_TX_P_valid(P_DATA_TX_VALID),
  .TX_OUT_S(TX_OUT),
  .TX_OUT_S_valid(S_DATA_TX_VALID),
  .parity_error(parity_error),
  .framing_error(framing_error)
  );
  
  ClkDiv C0 (
  .i_ref_clk(UART_Clk),
  .i_rst(Rst_UART_sync),
  .i_clk_en(CLKDiv_EN),
  .i_div_ratio(div_ratio),
  .o_div_clk(TX_CLK)
 );
 
  DATA_SYNC D0(
 .unsync_bus(RX_P_DATA),
 .CLK(Ref_Clk),
 .RST(Rst_SYNC),
 .bus_enable(P_DATA_RX_VALID),
 .sync_bus(UART_OUT_P_DATA),
 .enable_pulse(UART_OUT_DATA_VALID)
 );

  DATA_SYNC D1(
 .unsync_bus(UART_IN_P_DATA),
 .CLK(TX_CLK),
 .RST(Rst_UART_sync),
 .bus_enable(UART_IN_DATA_VALID),
 .sync_bus(TX_P_DATA),
 .enable_pulse(P_DATA_TX_VALID)
 );
 
CLK_GATE C_G0 (
.CLK_EN(CLK_EN),
.CLK(Ref_Clk),
.GATED_CLK(clk_gated)
);

BIT_SYNC  U0_bit_sync (
.CLK(Ref_Clk),
.RST(Rst_sync),
.ASYNC(S_DATA_TX_VALID),
.SYNC(UART_TX_Busy_SYNC)
);

SYS_CTRL S_C0(
.Clk(Ref_Clk),
.Rst(Rst_sync),
.ALU_OUT(ALU_OUT),
.OUT_valid(ALU_out_valid),
.RdData_valid(Rd_data_valid),
.RdData(Rd_data),
.EN(enable),
.ALU_FUN(func),
.CLK_EN(CLK_EN),
.address(address),
.WrEn(Wr_En),
.RdEn(Rd_En),
.WrData(Wr_data),
.Rx_P_data(UART_OUT_P_DATA),
.Rx_D_VLD(UART_OUT_DATA_VALID),
.TX_P_DATA(UART_IN_P_DATA),
.TX_D_VLD(UART_IN_DATA_VALID),
.busy(UART_TX_Busy_SYNC),
.clk_div_en(CLKDiv_EN)
);

endmodule

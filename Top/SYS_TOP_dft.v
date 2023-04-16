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

module SYS_TOP_dft #(parameter n = 4, m = 8)
  (
  input    Ref_Clk,UART_Clk,
  input    scan_clk,
  input    scan_rst,
  input    test_mode,
  input    SE,
  input [2:0]   SI,
  output [2:0]  SO,
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
  
  //dft wires
wire REF_SCAN_CLK;
wire RX_SCAN_CLK;
wire TX_SCAN_CLK;

wire RST_SCAN_RST;
wire RES_SCAN_RST;
wire UART_SCAN_RST;

///////////clock/////////////////
mux2X1 U0_mux2x1 (
.IN_0(Ref_Clk),
.IN_1(scan_clk),
.SEL(test_mode),
.OUT(REF_SCAN_CLK)
);

mux2X1 U1_mux2x1 (
.IN_0(UART_Clk),
.IN_1(scan_clk),
.SEL(test_mode),
.OUT(RX_SCAN_CLK)
);

mux2X1 U2_mux2x1 (
.IN_0(TX_CLK),
.IN_1(scan_clk),
.SEL(test_mode),
.OUT(TX_SCAN_CLK)
);

//////////////RST///////////////
mux2X1 U3_mux2x1 (
.IN_0(Rst),
.IN_1(scan_rst),
.SEL(test_mode),
.OUT(RST_SCAN_RST)
);

mux2X1 U4_mux2x1 (
.IN_0(Rst_sync),
.IN_1(scan_rst),
.SEL(test_mode),
.OUT(REF_SCAN_RST)
);

mux2X1 U5_mux2x1 (
.IN_0(Rst_UART_sync),
.IN_1(scan_rst),
.SEL(test_mode),
.OUT(UART_SCAN_RST)
);

////////////////////////////////////////////////////////////////////////////

  RegFile r0(
  .Clk(REF_SCAN_CLK),
  .Rst(REF_SCAN_RST),
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
  .RST(REF_SCAN_RST),  
  .ALU_OUT(ALU_OUT),
  .OUT_VALID(ALU_out_valid)
  );
  
  RST_SYNC RS0 (
  .CLK(REF_SCAN_CLK),
  .RST(RST_SCAN_RST),
  .SYNC_RST(Rst_sync)
  );
  
  RST_SYNC RS_UART0 (
  .CLK(RX_SCAN_CLK),
  .RST(RST_SCAN_RST),
  .SYNC_RST(Rst_UART_sync)
  );
  
  UART U0 (
  .TX_CLK(TX_SCAN_CLK),
  .RX_CLK(RX_SCAN_CLK),
  .RST(UART_SCAN_RST),
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
  .i_ref_clk(RX_SCAN_CLK),
  .i_rst(UART_SCAN_RST),
  .i_clk_en(CLKDiv_EN),
  .i_div_ratio(div_ratio),
  .o_div_clk(TX_CLK)
 );
 
  DATA_SYNC D0(
 .unsync_bus(RX_P_DATA),
 .CLK(REF_SCAN_CLK),
 .RST(REF_SCAN_RST),
 .bus_enable(P_DATA_RX_VALID),
 .sync_bus(UART_OUT_P_DATA),
 .enable_pulse(UART_OUT_DATA_VALID)
 );

  DATA_SYNC D1(
 .unsync_bus(UART_IN_P_DATA),
 .CLK(TX_SCAN_CLK),
 .RST(UART_SCAN_RST),
 .bus_enable(UART_IN_DATA_VALID),
 .sync_bus(TX_P_DATA),
 .enable_pulse(P_DATA_TX_VALID)
 );
 
CLK_GATE C_G0 (
.CLK_EN(CLK_EN),
.CLK(REF_SCAN_CLK),
.GATED_CLK(clk_gated)
);

BIT_SYNC  U0_bit_sync (
.CLK(REF_SCAN_CLK),
.RST(REF_SCAN_RST),
.ASYNC(S_DATA_TX_VALID),
.SYNC(UART_TX_Busy_SYNC)
);

SYS_CTRL S_C0(
.Clk(REF_SCAN_CLK),
.Rst(REF_SCAN_RST),
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

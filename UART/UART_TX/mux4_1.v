module mux4_1(
  input       [1:0]  mux_sel,
  input              parity_bit,
  input              ser_data,
  output reg         TX_OUT
  );
  
  parameter start_bit = 0,
            stop_bit = 1;
  
  always@(*)
  begin
    case(mux_sel)
      2'b00: TX_OUT = start_bit;
      2'b01: TX_OUT = stop_bit;
      2'b10: TX_OUT = ser_data;
      2'b11: TX_OUT = parity_bit;
    endcase
  end
endmodule
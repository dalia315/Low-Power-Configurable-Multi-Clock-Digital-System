module parity_calc(
  input       [7:0] P_DATA,
  input             data_valid,
  input             PAR_TYP,
  output reg        par_bit
  );
  
  parameter Even = 0,
            Odd = 1;
            
  always @(*) 
  begin
   case(PAR_TYP)
     Even: par_bit = ^P_DATA;
     Odd:  par_bit = ~^P_DATA;
   endcase
 end
 
endmodule

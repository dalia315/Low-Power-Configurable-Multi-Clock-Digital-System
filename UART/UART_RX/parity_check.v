module parity_check (
input        par_chk_en,
input        PAR_TYP,
input [7:0]  P_DATA,
input        sampled_bit,
output       par_err
);
parameter Even = 0,
          Odd = 1;
          
reg par_calc;

always @(*)
begin
  case(PAR_TYP)
     Even: par_calc = ^P_DATA;
     Odd:  par_calc = ~^P_DATA;
   endcase
 end
 
 assign par_err = ( par_calc != sampled_bit ) & par_chk_en;
 
 endmodule 

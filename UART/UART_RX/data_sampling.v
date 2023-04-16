module data_sampling(
  input            clk,
  input            RX_IN,
  input  [4:0]     prescale,
  input            data_samp_en,
  input  [4:0]     edge_cnt,
  output           sampled_bit
  );
  
  reg [2:0] s;
  
  always @(posedge clk)
   begin
    if(data_samp_en)
      begin
      if( edge_cnt == (prescale/2)-1 )
        s[0] <= RX_IN;
      else if( edge_cnt == (prescale/2) )
        s[1] <= RX_IN;
      else if( edge_cnt == (prescale/2)+1 )
        s[2] <= RX_IN;
     end
    else
      s <= 3'b0;
   end
   
 assign sampled_bit = (~s[2]&s[0]&s[1]) | ( s[2]& ( ( s[0]^s[1] ) | (s[0]&s[1]) ));
   
 endmodule


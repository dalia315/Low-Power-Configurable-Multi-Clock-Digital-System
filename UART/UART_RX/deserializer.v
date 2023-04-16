module deserializer(
  input                clk,
  input                deser_en,
  input                sampled_bit,
  input        [4:0]   edge_cnt,bit_cnt,
  output reg   [7:0]   P_DATA
  );
  
  always @(posedge clk)
  begin
    if(deser_en)
      begin
        if (edge_cnt == 6 && bit_cnt < 9)
           P_DATA <= {sampled_bit,P_DATA[7:1]};
       end
     else
       begin
        P_DATA <= 0;
      end
  end
endmodule  
         


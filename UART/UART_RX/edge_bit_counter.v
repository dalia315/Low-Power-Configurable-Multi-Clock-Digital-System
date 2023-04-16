module edge_bit_counter(
  input           enable,
  input           clk,
  input           PAR_EN,
  output  [4:0]   bit_cnt,
  output  [4:0]   edge_cnt
  );
  
reg [4:0] bit_cnt_wire,edge_cnt_wire;

always @(posedge clk)
 begin
  if(enable)
    begin
    if(edge_cnt_wire == 7)
     begin
      edge_cnt_wire = 1'b0;
      bit_cnt_wire = bit_cnt_wire + 1'b1;
      
      // condition for consecutive frames
      if( !PAR_EN && bit_cnt_wire == 10)
          bit_cnt_wire = 0;
      else if ( PAR_EN && bit_cnt_wire == 11)
        bit_cnt_wire = 0;
      
     end
     else 
      edge_cnt_wire = edge_cnt_wire + 1'b1;
    
    end
  else 
    begin
     edge_cnt_wire = 0;
     bit_cnt_wire = 0; 
    end
 end
 
assign bit_cnt = bit_cnt_wire;
assign edge_cnt = edge_cnt_wire;

endmodule

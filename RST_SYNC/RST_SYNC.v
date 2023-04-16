module RST_SYNC(
  input         CLK,RST,
  output reg    SYNC_RST
  );
  
  reg  sync_rst;
  
  always@(posedge CLK or negedge RST)
  begin
    if (!RST)
      begin
        sync_rst <= 0;
        SYNC_RST <=0;
      end
    else 
      begin
        sync_rst <= 1;
        SYNC_RST <= sync_rst;
      end
    end
    
  endmodule
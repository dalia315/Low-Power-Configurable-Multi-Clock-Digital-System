
module BIT_SYNC (
  input    wire     ASYNC,
  input            CLK,RST,
  output   reg     SYNC
  );
  
  reg [1:0] sync_stage;
  
  always @(posedge CLK or negedge RST) 
  begin
    if ( !RST)
      SYNC <= 0;
    else
      begin
        sync_stage[0] <= ASYNC;
        sync_stage[1]<=sync_stage[0];
        SYNC <= sync_stage[1];
      end
    end
  endmodule

module DATA_SYNC (
  input      [7:0]   unsync_bus,
  input              CLK,RST,
  input              bus_enable,
  output reg [7:0]   sync_bus,
  output reg         enable_pulse
  );
  
  wire         enable;
  reg          pulse_Gen;
  wire         pulse_gen_out;
  wire [7:0]   in_bus;
  
  
  BIT_SYNC B0(
  .ASYNC(bus_enable),
  .CLK(CLK),
  .RST(RST),
  .SYNC(enable)
  );
      
    always @(posedge CLK or negedge RST)
    begin
      if(!RST)
       pulse_Gen <= 0;
      else
       pulse_Gen <= enable;
    end
    
    always @(posedge CLK or negedge RST)
    begin
      if(!RST)
        begin
        sync_bus <= 0;
        enable_pulse <= 0;
      end
      else
        begin
        sync_bus <= in_bus;
        enable_pulse <= pulse_gen_out;
      end
    end
      
    assign pulse_gen_out = ~pulse_Gen & enable;
    assign in_bus = pulse_gen_out? unsync_bus: sync_bus;
    
  endmodule
  
  
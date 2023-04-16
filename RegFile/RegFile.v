module RegFile #( parameter n = 4 , m = 8 )
  ( 
  input                Clk,Rst,
  input                RdEn,WrEn,
  input       [n-1:0]  address,
  input       [m-1:0]  WrData,
  output reg  [m-1:0]  RdData,
  output reg           Rd_dataValid,
  output      [m-1:0]  REG0,REG1,REG2,REG3
  );
  
  reg [m-1:0] register [15:0];
  
  always @(posedge Clk or negedge Rst)
  begin
    if ( !Rst )
      begin
        RdData <= 0;
        Rd_dataValid <= 0;
        register[0] <= 0;
        register[1] <= 0;
        register[2] <= 'b001000_01;
        register[3] <= 'b0000_1000;
     end
    else
      begin
        if ( WrEn & ! RdEn)
            register[address] <= WrData;
        else if ( RdEn & ! WrEn)
          begin
            RdData <= register[address];
            Rd_dataValid <= 1'b1;
          end
        else
          Rd_dataValid <= 1'b0;
    end
 end  
 
 assign REG0 = register[0];
 assign REG1 = register[1]; 
 assign REG2 = register[2]; 
 assign REG3 = register[3];         

endmodule
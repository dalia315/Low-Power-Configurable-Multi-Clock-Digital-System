module SYS_CTRL 
 (
  input              Clk,Rst,
  input       [15:0]  ALU_OUT,
  input              OUT_valid,RdData_valid,
  input       [7:0]  RdData,
  output reg         EN,
  output reg  [3:0]  ALU_FUN,
  output reg         CLK_EN,
  output reg  [3:0]  address,
  output reg         WrEn,RdEn,
  output reg  [7:0]  WrData,
  input       [7:0]  Rx_P_data,
  input              Rx_D_VLD,
  output reg  [7:0]  TX_P_DATA,
  output reg         TX_D_VLD,
  input              busy,
  output reg         clk_div_en
);
  reg [3:0] current_state,next_state;
  
  parameter RF_Wr_CMD = 8'b10101010, 
            RF_Rd_CMD = 8'b10111011,
            ALU_OPER_W_OP_CMD=8'b11001100,
            ALU_OPER_W_NOP_CMD = 8'b11011101;
  
  parameter idle = 4'b0000,
            wr_wait_address = 4'b0001,
            write_data_reg = 4'b0010,
            rd_wait_address = 4'b0011,
            ALU_OP_A = 4'b0100,
            ALU_OP_B = 4'b0101,
            ALU_FUNCTION = 4'b0111,
            ALU_result = 4'b1000,
            read_data_reg = 4'b1001;
  
 always @(posedge Clk or negedge Rst)
 begin
   if (!Rst)
     current_state <= idle;
   else
     current_state <= next_state;
 end
 
 always @(*)
 begin
   WrEn=1'b0;
   RdEn=1'b0;
   EN=1'b0;
   TX_D_VLD=1'b0;
   CLK_EN=1'b0;
   clk_div_en=1'b1;
   TX_P_DATA = 8'b0;
   address= 4'b0;
   WrData=8'b0;
   ALU_FUN=4'b0;

   
   case(current_state)
     idle:
     begin
       if(Rx_P_data == RF_Wr_CMD && Rx_D_VLD)
         begin
           next_state = wr_wait_address;
         end
       else if ( Rx_P_data == RF_Rd_CMD && Rx_D_VLD )
         next_state = rd_wait_address;
       else if (Rx_P_data == ALU_OPER_W_OP_CMD && Rx_D_VLD)
         next_state = ALU_OP_A;
       else if ( Rx_P_data == ALU_OPER_W_NOP_CMD && Rx_D_VLD)
         begin
         next_state = ALU_FUNCTION;
         CLK_EN=1'b1;
       end
       else
         next_state = idle;
     end
     
     wr_wait_address:
     begin
       WrEn = 1'b1;
       if (Rx_D_VLD)
         begin
          address = Rx_P_data;
          next_state = write_data_reg;
          end
        else
          next_state = wr_wait_address;
     end
     
     rd_wait_address:
     begin
       RdEn = 1'b1;
       if (Rx_D_VLD)
         begin
          address = Rx_P_data;
          next_state = read_data_reg;
          end
        else
          next_state = rd_wait_address;
     end
     
     write_data_reg:
     begin
       WrEn = 1'b1;
       if (Rx_D_VLD)
         begin
          WrData = Rx_P_data;
          next_state = idle;
          end
        else
          next_state = write_data_reg;
     end
     
     ALU_OP_A:
     begin
       WrEn = 1'b1;
       address=8'b0;
       if (Rx_D_VLD)
         begin
          WrData = Rx_P_data;
          next_state = ALU_OP_B;
          end
        else
          next_state = ALU_OP_A;
     end
     
     ALU_OP_B:
     begin
       WrEn = 1'b1;
       address=1;
       CLK_EN=1'b1;
       if (Rx_D_VLD)
         begin
          WrData = Rx_P_data;
          next_state = ALU_FUNCTION;
          end
        else
          next_state = ALU_OP_B;
     end
     
     read_data_reg:
     begin
       if(!busy)
         begin
           RdEn = 1'b1;
           TX_P_DATA = RdData;
           TX_D_VLD = 1'b1;
           next_state = read_data_reg;
         end
       else
         begin
           TX_D_VLD = 1'b0;
           next_state = idle;
       end
     end
     
     ALU_FUNCTION:
     begin
       EN = 1'b1;
       CLK_EN=1'b1;
       if (Rx_D_VLD)
         begin
          ALU_FUN = Rx_P_data;
          next_state = ALU_result;
          end
        else
          next_state = ALU_FUNCTION;
     end
     
     ALU_result:
     begin
       if(OUT_valid)
         begin
          TX_P_DATA = ALU_OUT;
          if(!busy)
            begin
             TX_D_VLD = 1'b1;
             next_state=ALU_result;
           end
           else
           begin
             TX_D_VLD=1'b0;
             next_state = idle;
           end
         end
        else
          next_state = ALU_result;
     end

default:
begin
 WrEn=1'b0;
   RdEn=1'b0;
   EN=1'b0;
   TX_D_VLD=1'b0;
   CLK_EN=1'b0;
   clk_div_en=1'b1;
   TX_P_DATA = 8'b0;
   address= 4'b0;
   WrData=8'b0;
   ALU_FUN=4'b0;
   next_state=idle;
end

     
 endcase
 end
  
endmodule

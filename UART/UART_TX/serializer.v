module serializer #(parameter width = 8)
(
  input       [width-1:0] P_DATA,
  input                   ser_en,
  input                   CLK,RST,
  output  reg             ser_done,
  output  reg             ser_data 
  );
  
  reg [width-1:0] shift_reg;
  parameter reset_value = 8'b0;
  
  integer i ;
  
  always @(posedge CLK or negedge RST)
  begin
    if(!RST) 
    begin
      shift_reg <= reset_value;
      i<=0;
      ser_done <=1'b0;
      ser_data <=1'b0;
    end
      
    else if (ser_en && i==0 )
      begin
        shift_reg <= P_DATA;
        i <= 1;
      end
      
    else if (i > 0 && i <= 10 )
      begin
        {shift_reg[width-2:0],ser_data} <= shift_reg ;
       
    /*  ser_data <= shift_reg[0];
		    shift_reg[0] <= shift_reg[1];
		    shift_reg[1] <= shift_reg[2];
		    shift_reg[2] <= shift_reg[3];
		    shift_reg[3] <= shift_reg[4];
		    shift_reg[4] <= shift_reg[5];
		    shift_reg[5] <= shift_reg[6];
		    shift_reg[6] <= shift_reg[7]; */
		    
        i <= i+1;
        if(i==9) 
        begin
          i <= 0;
          ser_done <= 1'b1;
        end
      end
      
    end
/*
		OUT <= LFSR[0]
		LFSR[0] <= LFSR[1]
		LFSR[1] <= LFSR[2]
		LFSR[2] <= LFSR[3]
		LFSR[3] <= LFSR[4]
		LFSR[4] <= LFSR[5]
		LFSR[5] <= LFSR[6]
		LFSR[6] <= LFSR[7]
		*/
  
endmodule

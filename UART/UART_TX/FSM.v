module FSM (
  input              data_valid,
  input              ser_done,
  input              PAR_EN,
  input              CLK,RST,
  output reg         ser_en,
  output reg  [1:0]  mux_sel,
  output reg         busy
  );
  
  reg [2:0] current_state,next_state;
  
  parameter IDLE = 3'b000,
            start = 3'b001,
            send_data=3'b010,
            parity = 3'b011,
            stop = 3'b100;
            
  parameter start_bit = 2'b00,
            stop_bit = 2'b01,
            serial_data = 2'b10,
            parity_bit = 2'b11;
  
  always @(posedge CLK or negedge RST)
  begin
    if(!RST)
      current_state<=IDLE;
    else
      current_state<=next_state;
    end
    
    always @(*)
    begin
      ser_en=0;
      mux_sel=2'b01;
      busy=0;
      
      case(current_state)
        
        IDLE: 
        begin
          if(data_valid)
            begin
              ser_en=1;
              busy=1;
              next_state = start;
            end
          else next_state = IDLE;
        end
        
        start: 
        begin
          next_state = send_data;
          mux_sel=start_bit;
          ser_en=1;
          busy=1;
        end
        
        send_data: 
        begin
          mux_sel=serial_data;
          ser_en=1;
          busy=1;
          if (ser_done && PAR_EN) 
          begin
            ser_en=0;
            next_state = parity;
          end
          else if (ser_done && !PAR_EN)
            begin
              ser_en=0;
              next_state = stop;
            end
          else 
            next_state = send_data;
        end
        
        parity: 
        begin
         next_state = stop;
         mux_sel=parity_bit;
         ser_en=0;
         busy=1;
        end
        
        stop: 
        begin 
          mux_sel=stop_bit;
          busy=1;
          next_state = IDLE;
        end

default:
begin
next_state=IDLE;
end
        
      endcase
    end
    
endmodule

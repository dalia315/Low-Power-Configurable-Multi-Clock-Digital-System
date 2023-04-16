module FSM_RX(
  input                CLK,
  input                RST,
  input                RX_IN,
  input        [4:0]   bit_cnt,edge_cnt,
  input                PAR_EN,par_err,
  input                strt_glitch,
  input                stp_err,
  output  reg          enable,
  output  reg          data_samp_en,
  output  reg          par_chk_en,
  output  reg          strt_chk_en,
  output  reg          stp_chk_en,
  output  reg          deser_en,
  output  reg          data_valid 
  );

  reg [1:0] current_state,next_state;
  
  parameter IDLE = 2'b00,
            receive_data=2'b01,
            parity = 2'b10,
            stop = 2'b11;
            
  always @(posedge CLK or negedge RST)
  begin
    if(!RST)
      current_state<=IDLE;
    else
      current_state<=next_state;
    end
    
    always @(*)
    begin
      enable = 0;
      data_samp_en=0;
      par_chk_en=0;
      strt_chk_en=0;
      stp_chk_en=0;
      deser_en=0;
      data_valid=0;
      
      case(current_state)  
        
        IDLE: 
        begin
          if(!RX_IN)
            begin
              enable=1;
              data_samp_en=1;
              if (edge_cnt ==5)
               strt_chk_en=1;
               
              if(strt_glitch)
                 next_state = IDLE;
              else if(edge_cnt == 7)
               next_state = receive_data;
             else
               next_state = IDLE;
            end
            
          else 
          begin
          next_state = IDLE;
          enable = 0;
          data_samp_en=0;
          par_chk_en=0;
          strt_chk_en=0;
          stp_chk_en=0;
          deser_en=0;
          data_valid=0;
          end
        end
        
        receive_data: 
        begin
          enable=1;
          data_samp_en=1;
          deser_en=1;
          if (bit_cnt == 8 && edge_cnt == 7)
            begin
              if (PAR_EN)
              next_state = parity;
              else
              next_state = stop;
            end
         else
            next_state = receive_data;
        end
        
        parity: 
        begin
          enable=1;
          data_samp_en=1;
          deser_en=1;
          if(edge_cnt == 5)
            par_chk_en = 1;
          if(par_err)
            next_state = IDLE;
          else if(bit_cnt == 9 && edge_cnt ==7)
           next_state = stop;
          else 
           next_state = parity;
        end
        
        stop: 
        begin
          enable=1;
          data_samp_en=1;
          deser_en=1;
           
          if(edge_cnt ==5)
            begin
            stp_chk_en = 1;
            if (stp_err)
             begin
              next_state = IDLE;
              data_valid=0;
             end
            else
              data_valid=1;
          end
          
          if(edge_cnt == 7 )
            begin
             next_state = IDLE;
             data_valid=1;
            end
          else if(edge_cnt == 6 )
            begin
             next_state = stop;
             data_valid=1;
            end
          else
           next_state = stop;
           
          end
        
      endcase
    end 
endmodule


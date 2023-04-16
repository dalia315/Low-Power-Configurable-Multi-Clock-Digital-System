module stop_check (
 input        stp_chk_en,
 input        sampled_bit,
 output       stp_err
 );
 
parameter stop_bit = 1;

assign stp_err = ( sampled_bit != stop_bit ) & stp_chk_en;

endmodule



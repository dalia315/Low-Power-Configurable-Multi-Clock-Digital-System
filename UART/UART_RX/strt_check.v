module strt_check(
 input        strt_chk_en,
 input        sampled_bit,
 output       strt_glitch
 );
 
parameter start_bit = 0;

assign strt_glitch = ( sampled_bit != start_bit ) & strt_chk_en;

endmodule


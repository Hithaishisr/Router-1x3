//Testbench for Register for Router
module router_reg_tb;

  reg
      clock,
      resetn,
      pkt_valid,
      fifo_full,
      rst_int_reg,
      detect_add,
      ld_state,
      laf_state,
      full_state,
      lfd_state;
  reg [7:0] data_in;
  wire parity_done, low_pkt_valid, err;
  wire [7:0] dout;
  integer i;

  router_reg DUT (
      clock,
      resetn,
      pkt_valid,
      data_in,
      fifo_full,
      rst_int_reg,
      detect_add,
      ld_state,
      laf_state,
      full_state,
      lfd_state,
      parity_done,
      low_pkt_valid,
      err,
      dout
  );

  task initialize;
    begin
      {clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,data_in} = 0;
    end
  endtask

  always #5 clock = ~clock;

  task monitor;
    begin
      $dumpfile("router_reg_tb.vcd");
      $dumpvars(0, router_reg_tb);
    end
  endtask

  initial begin
    monitor;
    initialize;
    @(negedge clock) resetn = 1;
    pkt_valid = 1;
    detect_add = 1;
    lfd_state = 1;
    data_in = {$random} % 256;
    @(negedge clock) detect_add = 0;
    lfd_state = 0;
    ld_state  = 1;
    for (i = 0; i < 14; i = i + 1) begin
      @(negedge clock) data_in = {$random} % 256;
    end
    @(negedge clock) fifo_full = 1;
    data_in = {$random} % 256;
    @(negedge clock) laf_state = 1;
    @(negedge clock) full_state = 1;
    @(negedge clock) fifo_full = 0;
    laf_state  = 0;
    full_state = 0;
    pkt_valid  = 0;
    @(negedge clock) data_in = 8'd55;
    #100 $finish;
  end

endmodule

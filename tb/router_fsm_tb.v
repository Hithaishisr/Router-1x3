//Testbench for FSM for Router
module router_fsm_tb;

  reg
      clock,
      resetn,
      pkt_valid,
      parity_done,
      soft_reset_0,
      soft_reset_1,
      soft_reset_2,
      fifo_full,
      low_pkt_valid,
      fifo_empty_0,
      fifo_empty_1,
      fifo_empty_2;
  reg [1:0] data_in;
  wire busy, detect_add, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg, lfd_state;

  router_fsm DUT (
      clock,
      resetn,
      pkt_valid,
      parity_done,
      data_in,
      soft_reset_0,
      soft_reset_1,
      soft_reset_2,
      fifo_full,
      low_pkt_valid,
      fifo_empty_0,
      fifo_empty_1,
      fifo_empty_2,
      busy,
      detect_add,
      ld_state,
      laf_state,
      full_state,
      write_enb_reg,
      rst_int_reg,
      lfd_state
  );

  task initialize;
    begin
      {clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,data_in} = 0;
    end
  endtask

  always #5 clock = ~clock;

  task t1;
    begin
      @(negedge clock);
      pkt_valid = 1;
      data_in = 1;
      fifo_empty_1 = 1;
      repeat (2) @(negedge clock);
      fifo_full = 0;
      pkt_valid = 0;
      repeat (2) @(negedge clock);
      fifo_full = 0;
    end
  endtask

  task t2;
    begin
      @(negedge clock);
      pkt_valid = 1;
      data_in = 2;
      fifo_empty_2 = 1;
      repeat (2) @(negedge clock);
      fifo_full = 0;
      pkt_valid = 0;
      repeat (2) @(negedge clock);
      fifo_full = 1;
      @(negedge clock) fifo_full = 0;
      @(negedge clock) parity_done = 1;
    end
  endtask

  task t3;
    begin
      @(negedge clock);
      pkt_valid = 1;
      data_in = 0;
      fifo_empty_0 = 1;
      repeat (2) @(negedge clock);
      fifo_full = 1;
      @(negedge clock) fifo_full = 0;
      @(negedge clock) parity_done = 0;
      low_pkt_valid = 1;
      repeat (2) @(negedge clock);
      fifo_full = 0;
    end
  endtask

  task t4;
    begin
      @(negedge clock);
      pkt_valid = 1;
      data_in = 1;
      fifo_empty_1 = 1;
      repeat (2) @(negedge clock);
      fifo_full = 1;
      @(negedge clock) fifo_full = 0;
      @(negedge clock) parity_done = 0;
      low_pkt_valid = 0;
      @(negedge clock) pkt_valid = 0;
      repeat (3) @(negedge clock);
    end
  endtask

  task monitor;
    begin
      $dumpfile("router_fsm_tb.vcd");
      $dumpvars(0, router_fsm_tb);
    end
  endtask

  initial begin
    monitor;
    initialize;
    @(negedge clock) resetn = 1;
    // t1;
    // t2;
    // t3;
    t4;
    #100 $finish;
  end

endmodule

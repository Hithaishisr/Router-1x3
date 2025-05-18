//Testbench for Synchronizer for Router
module router_sync_tb;

  reg
      clock,
      resetn,
      detect_add,
      write_enb_reg,
      read_enb_0,
      read_enb_1,
      read_enb_2,
      empty_0,
      empty_1,
      empty_2,
      full_0,
      full_1,
      full_2;
  reg [1:0] data_in;
  wire fifo_full, soft_reset_0, soft_reset_1, soft_reset_2;
  wire vld_out_0, vld_out_1, vld_out_2;
  wire [2:0] write_enb;

  router_sync DUT (
      clock,
      resetn,
      detect_add,
      data_in,
      write_enb_reg,
      read_enb_0,
      read_enb_1,
      read_enb_2,
      empty_0,
      empty_1,
      empty_2,
      full_0,
      full_1,
      full_2,
      vld_out_0,
      vld_out_1,
      vld_out_2,
      write_enb,
      fifo_full,
      soft_reset_0,
      soft_reset_1,
      soft_reset_2
  );

  task initialize;
    begin
      {clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2} = 0;
      data_in = 0;
    end
  endtask

  always #5 clock = ~clock;

  task stimulus;
    input [1:0] i;
    begin
      @(negedge clock);
      data_in = i;
    end
  endtask

  task monitor;
    begin
      $dumpfile("router_sync_tb.vcd");
      $dumpvars(0, router_sync_tb);
    end
  endtask

  initial begin
    monitor;
    initialize;
    @(negedge clock) resetn = 1;
    detect_add = 1;
    stimulus(2'b01);
    // read_enb_0 = 1;
    write_enb_reg = 1;
    // empty_0 = 1;
    full_1 = 1;
    #1000 $finish;
  end

endmodule

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

  task reset;
    begin
      resetn = 0;
      @(negedge clock) resetn = 1;
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

  //Task for verifying signals for FIFO 0
  task sync_1;
    reg [1:0] addr;
    begin
      @(negedge clock);
      detect_add = 1;
      addr = 2'd0;
      data_in = addr;
      @(negedge clock);
      write_enb_reg = 1;
      @(negedge clock);
      {empty_0,empty_1,empty_2} = 3'b011;
      @(negedge clock);
      {full_0,full_1,full_2} = 3'b100;
    end
  endtask

  //Task for verifying signals for FIFO 1
  task sync_2;
    reg [1:0] addr;
    begin
      @(negedge clock);
      detect_add = 1;
      addr = 2'd1;
      data_in = addr;
      @(negedge clock);
      write_enb_reg = 1;
      @(negedge clock);
      {empty_0,empty_1,empty_2} = 3'b101;
      @(negedge clock);
      {full_0,full_1,full_2} = 3'b010;
    end
  endtask

  //Task for verifying signals for FIFO 2
  task sync_3;
    reg [1:0] addr;
    begin
      @(negedge clock);
      detect_add = 1;
      addr = 2'd2;
      data_in = addr;
      @(negedge clock);
      write_enb_reg = 1;
      @(negedge clock);
      {empty_0,empty_1,empty_2} = 3'b110;
      @(negedge clock);
      {full_0,full_1,full_2} = 3'b001;
    end
  endtask

  //Task for checking Soft Reset signal
  task sync_4;
    begin
      {empty_0,empty_1,empty_2} = 3'd0;
    end
  endtask

  initial begin
    initialize;
    //Task 1
    reset;
    sync_1;
    //Task 2
    @(negedge clock) reset;
    sync_2;
    //Task 3
    @(negedge clock) reset;
    sync_3;
    //Task 4
    @(negedge clock) reset;
    sync_4;
    #400 $finish;
  end

endmodule

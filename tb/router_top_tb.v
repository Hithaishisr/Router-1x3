//Testbench for Topmodule of Router 
module router_top_tb;

  reg clock, resetn, read_enb_0, read_enb_1, read_enb_2, pkt_valid;
  reg [7:0] data_in;
  wire valid_out_0, valid_out_1, valid_out_2, error, busy;
  wire [7:0] data_out_0, data_out_1, data_out_2;
  integer i;

  router_top DUT (
      clock,
      resetn,
      read_enb_0,
      read_enb_1,
      read_enb_2,
      data_in,
      pkt_valid,
      data_out_0,
      data_out_1,
      data_out_2,
      valid_out_0,
      valid_out_1,
      valid_out_2,
      error,
      busy
  );

  task initialize;
    begin
      {clock, resetn, read_enb_0, read_enb_1, read_enb_2, pkt_valid, data_in} = 0;
    end
  endtask

  always #5 clock = ~clock;

  task stimulus;
    input [7:0] data;
    begin
      @(negedge clock) data_in = data;
    end
  endtask

  task monitor;
    begin
      $dumpfile("router_top_tb.vcd");
      $dumpvars(0, router_top_tb);
    end
  endtask

  always @(negedge clock) begin
    if (valid_out_1) begin
      read_enb_1 = 1;
    end else read_enb_1 = 0;
  end

  initial begin
    monitor;
    initialize;
    @(negedge clock) resetn = 1;
    pkt_valid = 1;
    data_in   = {6'd40, 2'd1};
    @(negedge clock);
    for (i = 0; i < 40; i = i + 1) begin
      stimulus({$random} % 256);
    end
    @(negedge clock) pkt_valid = 0;
    data_in = 8'd234;
    #300 $finish;
  end

endmodule

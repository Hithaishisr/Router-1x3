//Testbench for FIFO-Router
module router_fifo_tb;

  reg clock, resetn, write_enb, soft_reset, read_enb, lfd_state;
  reg [7:0] data_in;
  wire full, empty;
  wire [7:0] data_out;
  integer i, count;
  reg j;

  router_fifo DUT (
      clock,
      resetn,
      write_enb,
      soft_reset,
      read_enb,
      data_in,
      lfd_state,
      empty,
      full,
      data_out
  );

  task initialize;
    begin
      {clock, resetn, write_enb, soft_reset, read_enb, lfd_state} = 0;
      data_in = 0;
      j = 1;
      count = 0;
    end
  endtask

  always #5 clock = ~clock;

  task stimulus;
    input [7:0] i;
    begin
      @(negedge clock);
      data_in = i;
    end
  endtask

  always begin
    #1;
    if (full) disable not_full;
  end

  task monitor;
    begin
      $dumpfile("router_fifo_tb.vcd");
      $dumpvars(0, router_fifo_tb);
    end
  endtask

  initial begin
    monitor;
    initialize;
    fork
      @(negedge clock) resetn = 1;
      @(negedge clock) write_enb = 1;
      @(negedge clock) lfd_state = 1;
      begin
        repeat (2) @(negedge clock);
        lfd_state = 0;
      end
      begin
        stimulus(8'b01010001);
        while (j) begin
          if (count == 21) j = 0;
          else if (~full) begin : not_full
            write_enb = 1;
            read_enb  = 0;
            stimulus({$random} % 256);
            count = count + 1;
          end else begin
            #0.1;
            write_enb = 0;
            read_enb  = 1;
          end
        end
      end
    join
    read_enb = 1;
    #200 $finish;
  end

endmodule

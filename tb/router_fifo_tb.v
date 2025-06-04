//Testbench for FIFO-Router
module router_fifo_tb;

  reg clock, resetn, write_enb, soft_reset, read_enb, lfd_state;
  reg [7:0] data_in;
  wire full, empty;
  wire [7:0] data_out;
  integer i, count;
  reg tx_in_progress; //Transmission in progress

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
      tx_in_progress = 1;
      count = 0;
    end
  endtask

  task reset;
    begin
      resetn = 0;
      @(negedge clock) resetn = 1;
    end
  endtask

  always #5 clock = ~clock;

  //Task for generating and storing the packet into FIFO of length < 14
  task pkt_gen_1;
    reg [7:0] header, parity, payload_data;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      write_enb = 1;
      lfd_state = 1;
      payload_len = 6'd12;
      addr = 2'd0;
      parity = 0;
      header = {payload_len, addr};
      data_in = header;
      parity = parity ^ header;
      for (i = 0; i < payload_len; i = i + 1) begin
        @(negedge clock);
        lfd_state = 0;
        payload_data = {$random} % 256;
        data_in = payload_data;
        parity = parity ^ payload_data;
      end
      @(negedge clock);
      data_in = parity;
    end
  endtask

  //Task for generating and storing the packet into FIFO of length = 14
  task pkt_gen_2;
    reg [7:0] header, parity, payload_data;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      write_enb = 1;
      lfd_state = 1;
      payload_len = 6'd14;
      addr = 2'd1;
      parity = 0;
      header = {payload_len, addr};
      data_in = header;
      parity = parity ^ header;
      for (i = 0; i < payload_len; i = i + 1) begin
        @(negedge clock);
        lfd_state = 0;
        payload_data = {$random} % 256;
        data_in = payload_data;
        parity = parity ^ payload_data;
      end
      @(negedge clock);
      data_in = parity;
    end
  endtask

  //Task for generating and storing the packet into FIFO of length > 14
  task pkt_gen_3;
    reg [7:0] header, parity, payload_data;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      write_enb = 1;
      lfd_state = 1;
      payload_len = 6'd50;
      addr = 2'd1;
      parity = 0;
      header = {payload_len, addr};
      data_in = header;
      parity = parity ^ header;
      while (tx_in_progress) begin
        if (count == payload_len + 2) begin
          tx_in_progress = 0;
        end else if (count == payload_len + 1) begin
          write_enb = 0;
          read_enb  = 1;
          @(negedge clock);
          count = count + 1;
          write_enb = 1;
          read_enb = 0;
        end else if (~full && count == payload_len) begin
          @(negedge clock);
          write_enb = 1;
          read_enb = 0;
          data_in = parity;
          count = count + 1;
        end else if (~full && count != payload_len + 1) begin
          @(negedge clock);
          lfd_state = 0;
          write_enb = 1;
          read_enb = 0;
          payload_data = {$random} % 256;
          data_in = payload_data;
          parity = parity ^ payload_data;
          count = count + 1;
        end else begin
          write_enb = 0;
          read_enb  = 1;
          @(negedge clock);
          write_enb = 1;
          read_enb  = 0;
        end
      end
    end
  endtask

  initial begin
    initialize;
    //Task 1
    reset;
    pkt_gen_1;
    @(negedge clock);
    write_enb = 0;
    read_enb  = 1;
    wait (empty) repeat (3) @(negedge clock);
    read_enb = 0;
    //Task 2
    @(negedge clock) reset;
    pkt_gen_2;
    @(negedge clock);
    write_enb = 0;
    read_enb  = 1;
    wait (empty);
    repeat (3) @(negedge clock);
    read_enb = 0;
    //Task 3
    @(negedge clock) reset;
    pkt_gen_3;
    @(negedge clock);
    write_enb = 0;
    read_enb  = 1;
    wait (empty) repeat (3) @(negedge clock);
    read_enb = 0;
    #50 $finish;
  end

endmodule

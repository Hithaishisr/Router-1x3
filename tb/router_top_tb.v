//Task based testbench for Router 1x3 top module
module router_top_tb;

  reg clock, resetn, read_enb_0, read_enb_1, read_enb_2, pkt_valid;
  reg [7:0] data_in;
  wire valid_out_0, valid_out_1, valid_out_2, error, busy;
  wire [7:0] data_out_0, data_out_1, data_out_2;
  integer i;

  event read_task4, read_task5;

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

  task reset;
    begin
      resetn = 0;
      @(negedge clock) resetn = 1;
    end
  endtask

  always #5 clock = ~clock;

  initial begin
    @read_task4;
    read_enb_0 = 1;
  end

  initial begin
    @read_task5;
    read_enb_2 = 1;
  end

  //Task for generating the source packet which has payload data length < 14
  task pkt_gen_1;
    reg [7:0] payload_data, parity, header;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      wait (~busy) @(negedge clock);
      payload_len = 6'd10;
      addr = 2'd1;
      header = {payload_len, addr};
      parity = 0;
      data_in = header;
      pkt_valid = 1;
      parity = parity ^ header;
      @(negedge clock);
      wait (~busy)
        for (i = 0; i < payload_len; i = i + 1) begin
          @(negedge clock);
          wait (~busy) payload_data = {$random} % 256;
          data_in = payload_data;
          parity  = parity ^ payload_data;
        end
      @(negedge clock);
      wait (~busy) pkt_valid = 0;
      data_in = parity;
    end
  endtask

  //Task for generating the source packet which has payload data length = 14
  task pkt_gen_2;
    reg [7:0] payload_data, parity, header;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      wait (~busy) @(negedge clock);
      payload_len = 6'd14;
      addr = 2'd0;
      header = {payload_len, addr};
      parity = 0;
      data_in = header;
      pkt_valid = 1;
      parity = parity ^ header;
      @(negedge clock);
      wait (~busy)
        for (i = 0; i < payload_len; i = i + 1) begin
          @(negedge clock);
          wait (~busy) payload_data = {$random} % 256;
          data_in = payload_data;
          parity  = parity ^ payload_data;
        end
      @(negedge clock);
      wait (~busy) pkt_valid = 0;
      data_in = parity;
    end
  endtask

  //Task for generating the source packet which has payload data length = 16
  task pkt_gen_3;
    reg [7:0] payload_data, parity, header;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      wait (~busy) @(negedge clock);
      payload_len = 6'd16;
      addr = 2'd2;
      header = {payload_len, addr};
      parity = 0;
      data_in = header;
      pkt_valid = 1;
      parity = parity ^ header;
      @(negedge clock);
      wait (~busy)
        for (i = 0; i < payload_len - 1; i = i + 1) begin
          @(negedge clock);
          wait (~busy) payload_data = {$random} % 256;
          data_in = payload_data;
          parity  = parity ^ payload_data;
        end
      @(negedge clock);
      read_enb_2 = 1;
      payload_data = {$random} % 256;
      data_in = payload_data;
      parity = parity ^ payload_data;
      @(negedge clock);
      wait (~busy) pkt_valid = 0;
      data_in = parity;
    end
  endtask

  //Task for generating the source packet which has payload data length = 17
  task pkt_gen_4;
    reg [7:0] payload_data, parity, header;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      wait (~busy) @(negedge clock);
      payload_len = 6'd17;
      addr = 2'd0;
      header = {payload_len, addr};
      parity = 0;
      data_in = header;
      pkt_valid = 1;
      parity = parity ^ header;
      @(negedge clock);
      wait (~busy)
        for (i = 0; i < payload_len; i = i + 1) begin
          @(negedge clock);
          if(i == 15) begin
            -> read_task4; //Triggering the read event
          end
          wait (~busy) payload_data = {$random} % 256;
          data_in = payload_data;
          parity  = parity ^ payload_data;
        end
      @(negedge clock);
      wait (~busy) pkt_valid = 0;
      data_in = parity;
    end
  endtask

  //Task for generating the source packet which has payload data of random length
  task pkt_gen_5;
    reg [7:0] payload_data, parity, header;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      wait (~busy) @(negedge clock);
      -> read_task5; //Triggering the read event
      payload_len = {$random} % 64;
      addr = 2'd2;
      header = {payload_len, addr};
      parity = 0;
      data_in = header;
      pkt_valid = 1;
      parity = parity ^ header;
      @(negedge clock);
      wait (~busy)
        for (i = 0; i < payload_len; i = i + 1) begin
          @(negedge clock);
          wait (~busy) payload_data = {$random} % 256;
          data_in = payload_data;
          parity  = parity ^ payload_data;
        end
      @(negedge clock);
      wait (~busy) pkt_valid = 0;
      data_in = parity;
    end
  endtask

  initial begin
    initialize;
    //Task 1
    reset;
    pkt_gen_1;
    @(negedge clock);
    read_enb_1 = 1;
    wait (~valid_out_1) @(negedge clock);
    read_enb_1 = 0;
    //Task 2
    @(negedge clock) reset;
    pkt_gen_2;
    @(negedge clock);
    read_enb_0 = 1;
    wait (~valid_out_0) @(negedge clock);
    read_enb_0 = 0;
    //Task 3
    @(negedge clock) reset;
    pkt_gen_3;
    wait (~valid_out_2) @(negedge clock);
    read_enb_2 = 0;
    //Task 4
    @(negedge clock) reset;
    pkt_gen_4;
    wait (~valid_out_0) @(negedge clock);
    read_enb_0 = 0;
    //Task 5
    @(negedge clock) reset;
    pkt_gen_5;
    wait (~valid_out_2) @(negedge clock);
    read_enb_2 = 0;
    #50 $finish;
  end

endmodule

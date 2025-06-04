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

  task reset;
    begin
      @(negedge clock) resetn = 1;
    end
  endtask

  always #5 clock = ~clock;

  //Task for generating packet to check the register functionality
  task reg_input;
    reg [7:0] header,payload_data,parity;
    reg [5:0] payload_len;
    reg [1:0] addr;
    begin
      @(negedge clock);
      pkt_valid = 1;
      detect_add = 1;
      payload_len = 6'd10;
      addr = 2'd2;
      parity = 0;
      header = {payload_len,addr};
      data_in = header;
      parity = parity ^ header;
      @(negedge clock) lfd_state = 1;
      detect_add = 0;
      for(i=0;i<payload_len-1;i=i+1) begin
        @(negedge clock);
        lfd_state = 0;
        ld_state = 1;
        payload_data = {$random} % 256;
        data_in = payload_data;
        parity = parity ^ payload_data;
      end
      @(negedge clock) fifo_full = 1;
      full_state = 1; //Check this case once
      payload_data = {$random} % 256;
      data_in = payload_data;
      parity = parity ^ payload_data;
      @(negedge clock) fifo_full = 0;
      full_state = 0;
      pkt_valid = 0;
      laf_state = 1;
      data_in = parity;
      @(negedge clock) laf_state = 0;
      @(negedge clock) ld_state = 0;
    end
  endtask

  initial begin
    initialize;
    reset;
    reg_input;
    #50 $finish;
  end

endmodule

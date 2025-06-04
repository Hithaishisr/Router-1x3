//Register for Router
module router_reg (
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

  input clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
  input [7:0] data_in;
  output reg parity_done, low_pkt_valid, err;
  output reg [7:0] dout;

  reg [7:0] header, FIFO_full_state, internal_parity, pkt_parity;

  //Parity Done signal
  always @(posedge clock) begin
    if (~resetn || detect_add) parity_done <= 1'b0;
    else if((ld_state && !fifo_full && !pkt_valid) || (laf_state && low_pkt_valid && !parity_done))
      parity_done <= 1'b1;
    else parity_done <= parity_done;
  end

  //Low packet valid signal
  always @(posedge clock) begin
    if (~resetn || rst_int_reg) low_pkt_valid <= 1'b0;
    else if (ld_state && !pkt_valid) low_pkt_valid <= 1'b1;
    else low_pkt_valid <= low_pkt_valid;
  end

  //Header Register
  always @(posedge clock) begin
    if (~resetn) header <= 8'd0;
    else if (detect_add && pkt_valid && data_in[1:0] != 2'd3) header <= data_in;
    else header <= header;
  end

  //FIFO Full-state Register
  always @(posedge clock) begin
    if (~resetn) FIFO_full_state <= 8'd0;
    else if(ld_state && fifo_full) FIFO_full_state <= data_in;
    else FIFO_full_state <= FIFO_full_state;
  end

  //Internal Parity Register
  always @(posedge clock) begin
    if (~resetn || (detect_add && pkt_valid)) internal_parity <= 8'd0;
    else if (lfd_state) internal_parity <= internal_parity ^ header;
    else if (ld_state && !full_state && pkt_valid) internal_parity <= internal_parity ^ data_in;
    else if (laf_state) internal_parity <= internal_parity ^ FIFO_full_state;
    else internal_parity <= internal_parity;
  end

  //Packet Parity Register
  always @(posedge clock) begin
    if (~resetn || detect_add) begin
      pkt_parity <= 8'd0;
    end else if (ld_state && !pkt_valid) begin
      pkt_parity <= data_in;
    end else pkt_parity <= pkt_parity;
  end

  //Error Checking
  always @(posedge clock) begin
    if(~resetn) begin
      err <= 1'b0;
    end else if(parity_done) begin
      err <= (internal_parity == pkt_parity) ? 1'b0 : 1'b1;
    end else err <= 1'b0;
  end

  //Data-out
  always @(posedge clock) begin
    if (~resetn) dout <= 8'd0;
    else if (lfd_state) dout <= header;
    else if (laf_state) dout <= FIFO_full_state;
    else if (ld_state && !fifo_full) dout <= data_in;
    else dout <= dout;
  end

endmodule

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
  reg [7:0] parity_reg;
  reg flag;

  always @(posedge clock) begin
    if (~resetn) begin
      parity_done   <= 1'b0;
      low_pkt_valid <= 1'd0;
    end else begin
      if (detect_add) parity_done <= 1'b0;
      else if((ld_state && !(fifo_full && pkt_valid)) || (laf_state && low_pkt_valid && !parity_done))
        parity_done <= 1'b1;
      else parity_done <= 1'b0;
      if (rst_int_reg) low_pkt_valid <= 1'b0;
      else if (ld_state && !pkt_valid) low_pkt_valid <= 1'b1;
      else low_pkt_valid <= 1'b0;
    end
  end

  always @(posedge clock) begin
    if (~resetn) begin
      header <= 8'd0;
      FIFO_full_state <= 8'd0;
      internal_parity <= 8'd0;
      pkt_parity <= 8'd0;
      dout = 8'd0;
      parity_reg <= 8'd0;
      err <= 1'b0;
      flag <= 1'b0;
    end else begin
      if (detect_add && pkt_valid) begin
        header <= data_in;
        parity_reg <= data_in;
      end
      if (lfd_state) dout <= header;
      else if (ld_state && !fifo_full) begin
        dout <= data_in;
        parity_reg <= parity_reg ^ data_in;
      end else if (laf_state) dout <= FIFO_full_state;
      if (ld_state && fifo_full) begin
        FIFO_full_state <= data_in;
        parity_reg <= parity_reg ^ data_in;
      end
      if (full_state) internal_parity <= parity_reg;
      if (low_pkt_valid) begin
        pkt_parity <= data_in;
        flag <= 1'b1;
      end else flag <= 1'b0;
      if (flag) begin
        err  <= (internal_parity == pkt_parity) ? 1'b0 : 1'b1;
        flag <= 1'b0;
      end else err <= 1'b0;
    end
  end

endmodule

//FSM Controller for Router
module router_fsm (
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

  input clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
  input [1:0] data_in;
  output busy, detect_add, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg, lfd_state;

  parameter DECODE_ADDRESS = 4'd0,

            LOAD_FIRST_DATA = 4'd1,

            LOAD_DATA = 4'd2,

            LOAD_PARITY = 4'd3,

            FIFO_FULL_STATE = 4'd4,

            LOAD_AFTER_FULL = 4'd5,

            WAIT_TILL_EMPTY = 4'd6,

            CHECK_PARITY_ERROR = 4'd7;

  reg [3:0] state, next_state;

  always @(posedge clock) begin
    if (~resetn) begin
      state <= DECODE_ADDRESS;
    end else begin
      state <= next_state;
    end
  end

  always @(*) begin
    case (state)
      DECODE_ADDRESS: begin
        if (soft_reset_0 || soft_reset_1 || soft_reset_2) next_state = DECODE_ADDRESS;
        else if((pkt_valid && (data_in[1:0] == 0) && fifo_empty_0) || (pkt_valid && (data_in[1:0] == 1) && fifo_empty_1) || (pkt_valid && (data_in[1:0] == 2) && fifo_empty_2))
          next_state = LOAD_FIRST_DATA;
        else if((pkt_valid && (data_in[1:0] == 0) && !fifo_empty_0) || (pkt_valid && (data_in[1:0] == 1) && !fifo_empty_1) || (pkt_valid && (data_in[1:0] == 2) && !fifo_empty_2))
          next_state = WAIT_TILL_EMPTY;
        else next_state = DECODE_ADDRESS;
      end
      LOAD_FIRST_DATA: next_state = LOAD_DATA;
      LOAD_DATA: begin
        if (soft_reset_0 || soft_reset_1 || soft_reset_2) next_state = DECODE_ADDRESS;
        else if (fifo_full) next_state = FIFO_FULL_STATE;
        else if (!fifo_full && !pkt_valid) next_state = LOAD_PARITY;
        else next_state = LOAD_DATA;
      end
      LOAD_PARITY: next_state = CHECK_PARITY_ERROR;
      FIFO_FULL_STATE: begin
        if (soft_reset_0 || soft_reset_1 || soft_reset_2) next_state = DECODE_ADDRESS;
        else if (fifo_full) next_state = FIFO_FULL_STATE;
        else if (!fifo_full) next_state = LOAD_AFTER_FULL;
        else next_state = FIFO_FULL_STATE;
      end
      LOAD_AFTER_FULL: begin
        if (soft_reset_0 || soft_reset_1 || soft_reset_2) next_state = DECODE_ADDRESS;
        else if (!parity_done && low_pkt_valid) next_state = LOAD_PARITY;
        else if (!parity_done && !low_pkt_valid) next_state = LOAD_DATA;
        else if (parity_done) next_state = DECODE_ADDRESS;
        else next_state = LOAD_AFTER_FULL;
      end
      WAIT_TILL_EMPTY: begin
        if (soft_reset_0 || soft_reset_1 || soft_reset_2) next_state = DECODE_ADDRESS;
        else if((fifo_empty_0 && (data_in[1:0] == 0)) || (fifo_empty_1 && (data_in[1:0] == 1)) || (fifo_empty_2 && (data_in[1:0] == 2)))
          next_state = LOAD_FIRST_DATA;
        else next_state = WAIT_TILL_EMPTY;
      end
      CHECK_PARITY_ERROR: begin
        if (soft_reset_0 || soft_reset_1 || soft_reset_2) next_state = DECODE_ADDRESS;
        else if (fifo_full) next_state = FIFO_FULL_STATE;
        else if (!fifo_full) next_state = DECODE_ADDRESS;
        else next_state = CHECK_PARITY_ERROR;
      end
      default: next_state = DECODE_ADDRESS;
    endcase
  end

  assign detect_add = (state == DECODE_ADDRESS) ? 1'b1 : 1'b0;
  assign lfd_state = (state == LOAD_FIRST_DATA) ? 1'b1 : 1'b0;
  assign busy = ((state == LOAD_FIRST_DATA) || (state == LOAD_PARITY) || (state == FIFO_FULL_STATE) || (state == LOAD_AFTER_FULL) || (state == WAIT_TILL_EMPTY)) ? 1'b1 : 1'b0;
  assign ld_state = (state == LOAD_DATA) ? 1'b1 : 1'b0;
  assign write_enb_reg = ((state == LOAD_DATA) || (state == LOAD_PARITY) || (state == LOAD_AFTER_FULL)) ? 1'b1 : 1'b0;
  assign full_state = (state == FIFO_FULL_STATE) ? 1'b1 : 1'b0;
  assign laf_state = (state == LOAD_AFTER_FULL) ? 1'b1 : 1'b0;
  assign rst_int_reg = (state == CHECK_PARITY_ERROR) ? 1'b1 : 1'b0;

endmodule

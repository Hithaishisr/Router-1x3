//Top block of Router
module router_top (
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

  input clock, resetn, read_enb_0, read_enb_1, read_enb_2, pkt_valid;
  input [7:0] data_in;
  output valid_out_0, valid_out_1, valid_out_2, error, busy;
  output [7:0] data_out_0, data_out_1, data_out_2;

  wire [2:0] write_enb;
  wire soft_reset_0,soft_reset_1,soft_reset_2,lfd_state,empty_0,empty_1,empty_2,full_0,full_1,full_2;
  wire detect_add, write_enb_reg, fifo_full;
  wire parity_done, low_pkt_valid, ld_state, laf_state, full_state, rst_int_reg;
  wire [7:0] dout;


  router_fifo FIFO_0 (
      clock,
      resetn,
      write_enb[0],
      soft_reset_0,
      read_enb_0,
      dout,
      lfd_state,
      empty_0,
      full_0,
      data_out_0
  );
  router_fifo FIFO_1 (
      clock,
      resetn,
      write_enb[1],
      soft_reset_1,
      read_enb_1,
      dout,
      lfd_state,
      empty_1,
      full_1,
      data_out_1
  );
  router_fifo FIFO_2 (
      clock,
      resetn,
      write_enb[2],
      soft_reset_2,
      read_enb_2,
      dout,
      lfd_state,
      empty_2,
      full_2,
      data_out_2
  );

  router_sync Synchronizer (
      clock,
      resetn,
      detect_add,
      data_in[1:0],
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
      valid_out_0,
      valid_out_1,
      valid_out_2,
      write_enb,
      fifo_full,
      soft_reset_0,
      soft_reset_1,
      soft_reset_2
  );

  router_fsm FSM (
      clock,
      resetn,
      pkt_valid,
      parity_done,
      data_in[1:0],
      soft_reset_0,
      soft_reset_1,
      soft_reset_2,
      fifo_full,
      low_pkt_valid,
      empty_0,
      empty_1,
      empty_2,
      busy,
      detect_add,
      ld_state,
      laf_state,
      full_state,
      write_enb_reg,
      rst_int_reg,
      lfd_state
  );

  router_reg Register (
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
      error,
      dout
  );

endmodule

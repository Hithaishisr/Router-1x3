//FIFO for Router
module router_fifo (
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

  input clock, resetn, write_enb, soft_reset, read_enb, lfd_state;
  input [7:0] data_in;
  output empty, full;
  output reg [7:0] data_out;

  reg [8:0] mem[0:15];
  reg [4:0] write_ptr, read_ptr;
  reg [5:0] payload_count;
  reg lfd_state_reg;
  integer i;

  task payload;
    begin
      if (mem[read_ptr[3:0]][8] == 1'b1) begin
        payload_count <= mem[read_ptr[3:0]][7:2] + 1'b1;
        data_out <= mem[read_ptr[3:0]][7:0];
        read_ptr <= read_ptr + 1'b1;
      end else begin
        if (payload_count != 0) begin
          payload_count <= payload_count - 1'b1;
          data_out <= mem[read_ptr[3:0]][7:0];
          read_ptr <= read_ptr + 1'b1;
        end
      end
    end
  endtask

  always @(posedge clock) begin
    if (~resetn) lfd_state_reg <= 0;
    else lfd_state_reg <= lfd_state;
  end

  always @(posedge clock) begin
    if (~resetn || soft_reset) begin
      for (i = 0; i < 16; i = i + 1) begin
        mem[i] <= 9'd0;
      end
      write_ptr <= 0;
      read_ptr  <= 0;
      data_out  <= resetn ? 8'bzz : 8'b0;
    end else begin
      if (write_enb && ~full) begin
        mem[write_ptr[3:0]] <= {lfd_state_reg, data_in};
        write_ptr <= write_ptr + 1'b1;
      end else mem[write_ptr[3:0]] <= mem[write_ptr[3:0]];
      if (read_enb && ~empty) begin
        payload;
      end else data_out <= data_out;
      if (payload_count == 0) data_out <= 8'bzz;
    end
  end

  assign empty = (write_ptr == read_ptr) ? 1'b1 : 1'b0;
  assign full  = ((write_ptr[4] != read_ptr[4]) && (write_ptr[3:0] == read_ptr[3:0])) ? 1'b1 : 1'b0;

endmodule


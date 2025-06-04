//Synchronizer for Router
module router_sync (
    clock,
    resetn,
    detect_add,
    data_in,
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
    vld_out_0,
    vld_out_1,
    vld_out_2,
    write_enb,
    fifo_full,
    soft_reset_0,
    soft_reset_1,
    soft_reset_2
);

  input clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
  input [1:0] data_in;
  output reg fifo_full, soft_reset_0, soft_reset_1, soft_reset_2;
  output vld_out_0, vld_out_1, vld_out_2;
  output reg [2:0] write_enb;
  reg [1:0] addr_reg;
  reg [4:0] clk_counter_0, clk_counter_1, clk_counter_2;

  //Address storing into internal register
  always @(posedge clock) begin
    if (~resetn) begin
      addr_reg <= 2'd0;
    end else begin
      if (detect_add) addr_reg <= data_in; 
      else addr_reg <= addr_reg;
    end
  end

  //Write Enable
  always @(*) begin
    if (write_enb_reg) begin
      case (addr_reg)
        2'd0: write_enb = 3'b001;
        2'd1: write_enb = 3'b010;
        2'd2: write_enb = 3'b100;
        default: write_enb = 3'd0;
      endcase
    end else write_enb = 3'd0;
  end

  //FIFO full state
  always @(*) begin
    case (addr_reg)
      2'd0: fifo_full = full_0;
      2'd1: fifo_full = full_1;
      2'd2: fifo_full = full_2;
      default: fifo_full = 0;
    endcase
  end

  //Soft reset for FIFO 0
  always @(posedge clock) begin
    if (~resetn) begin
      soft_reset_0 <= 1'b0;
      clk_counter_0 <= 5'd0;
    end else begin
      if (vld_out_0) begin
        if (read_enb_0) begin
          clk_counter_0 <= 5'd0;
          soft_reset_0  <= 1'b0;
        end else if (clk_counter_0 < 5'd30) begin
          clk_counter_0 <= clk_counter_0 + 1'b1;
          soft_reset_0  <= 1'b0;
        end else begin
          clk_counter_0 <= 5'd0;
          soft_reset_0  <= 1'b1;
        end
      end else begin
        clk_counter_0 <= 5'd0;
        soft_reset_0  <= 1'b0;
      end
    end
  end

  //Soft reset for FIFO 1
  always @(posedge clock) begin
    if (~resetn) begin
      soft_reset_1 <= 1'b0;
      clk_counter_1 <= 5'd0;
    end else begin
      if (vld_out_1) begin
        if (read_enb_1) begin
          clk_counter_1 <= 5'd0;
          soft_reset_1  <= 1'b0;
        end else if (clk_counter_1 < 5'd30) begin
          clk_counter_1 <= clk_counter_1 + 1'b1;
          soft_reset_1  <= 1'b0;
        end else begin
          clk_counter_1 <= 5'd0;
          soft_reset_1  <= 1'b1;
        end
      end else begin
        clk_counter_1 <= 5'd0;
        soft_reset_1  <= 1'b0;
      end
    end
  end

  //Soft reset for FIFO 2
  always @(posedge clock) begin
    if (~resetn) begin
      soft_reset_2 <= 1'b0;
      clk_counter_2 <= 5'd0;
    end else begin
      if (vld_out_2) begin
        if (read_enb_2) begin
          clk_counter_2 <= 5'd0;
          soft_reset_2  <= 1'b0;
        end else if (clk_counter_2 < 5'd30) begin
          clk_counter_2 <= clk_counter_2 + 1'b1;
          soft_reset_2  <= 1'b0;
        end else begin
          clk_counter_2 <= 5'd0;
          soft_reset_2  <= 1'b1;
        end
      end else begin
        clk_counter_2 <= 5'd0;
        soft_reset_2  <= 1'b0;
      end
    end
  end
      
  //Valid out signal
  assign vld_out_0 = empty_0 ? 1'b0 : 1'b1;
  assign vld_out_1 = empty_1 ? 1'b0 : 1'b1;
  assign vld_out_2 = empty_2 ? 1'b0 : 1'b1;

endmodule

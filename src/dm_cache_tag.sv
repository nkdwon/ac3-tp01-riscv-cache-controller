import cache_def::*;

/* cache: tag memory, single port, 1024 blocks */
module dm_cache_tag(
    input  bit             clk,        // write clock
  input  logic [9:0]     tag_index,      // tag index
  input  logic           tag_we,         // tag write enable
  input  logic           tag_write_valid,
  input  logic           tag_write_dirty,
  input  logic [TAGMSB:TAGLSB] tag_write_tag,
  output logic           tag_read_valid,
  output logic           tag_read_dirty,
  output logic [TAGMSB:TAGLSB] tag_read_tag
);

  timeunit 1ns;
  timeprecision 1ps;

  bit tag_valid_mem [0:1023];
  bit tag_dirty_mem [0:1023];
  bit [TAGMSB:TAGLSB] tag_tag_mem [0:1023];

  initial begin
    for (int i = 0; i < 1024; i++) begin
      tag_valid_mem[i] = 1'b0;
      tag_dirty_mem[i] = 1'b0;
      tag_tag_mem[i] = '0;
    end
  end

  assign tag_read_valid = tag_valid_mem[tag_index];
  assign tag_read_dirty = tag_dirty_mem[tag_index];
  assign tag_read_tag = tag_tag_mem[tag_index];

  always_ff @(posedge clk) begin
    if (tag_we) begin
      tag_valid_mem[tag_index] <= tag_write_valid;
      tag_dirty_mem[tag_index] <= tag_write_dirty;
      tag_tag_mem[tag_index] <= tag_write_tag;
    end
  end

endmodule
import cache_def::*;

module tb_smoke_memories;

  bit clk;

  logic [9:0] data_index;
  logic       data_we;
  cache_data_type data_write;
  cache_data_type data_read;

  logic [9:0] tag_index;
  logic       tag_we;
  logic       tag_write_valid;
  logic       tag_write_dirty;
  logic [TAGMSB:TAGLSB] tag_write_tag;
  logic       tag_read_valid;
  logic       tag_read_dirty;
  logic [TAGMSB:TAGLSB] tag_read_tag;

  dm_cache_data u_data(
      .clk(clk),
      .data_index(data_index),
      .data_we(data_we),
      .data_write(data_write),
      .data_read(data_read)
  );

  dm_cache_tag u_tag(
      .clk(clk),
      .tag_index(tag_index),
      .tag_we(tag_we),
      .tag_write_valid(tag_write_valid),
      .tag_write_dirty(tag_write_dirty),
      .tag_write_tag(tag_write_tag),
      .tag_read_valid(tag_read_valid),
      .tag_read_dirty(tag_read_dirty),
      .tag_read_tag(tag_read_tag)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("bin/wave.vcd");
    $dumpvars(0, tb_smoke_memories);

    data_index = '0;
    data_we = 1'b0;
    data_write = '0;

    tag_index = '0;
    tag_we = 1'b0;
    tag_write_valid = 1'b0;
    tag_write_dirty = 1'b0;
    tag_write_tag = '0;

    @(posedge clk);

    data_index = 10'd3;
    data_write = 128'hDEAD_BEEF_1111_2222_3333_4444_5555_6666_7777_8888;
    data_we = 1'b1;

    tag_index = 10'd3;
    tag_write_valid = 1'b1;
    tag_write_dirty = 1'b1;
    tag_write_tag = 18'h3A55;
    tag_we = 1'b1;

    @(posedge clk);

    data_we = 1'b0;
    tag_we = 1'b0;

    @(posedge clk);

    data_index = 10'd3;
    tag_index = 10'd3;

    @(posedge clk);

    $display("SMOKE MEMORIES OK");
    $finish;
  end

endmodule

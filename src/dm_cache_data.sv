import cache_def::*;

/* cache: data memory, single port, 1024 blocks */
module dm_cache_data(
    input  bit              clk,         // write clock
  input  logic [9:0]      data_index,  // data index
  input  logic            data_we,     // data write enable
    input  cache_data_type  data_write,  // write port (128-bit line)
    output cache_data_type  data_read    // read port
);

  timeunit 1ns;
  timeprecision 1ps;

  cache_data_type data_mem [0:1023];

  initial begin
    for (int i = 0; i < 1024; i++) begin
      data_mem[i] = '0;
    end
  end

  assign data_read = data_mem[data_index];

  always_ff @(posedge clk) begin
    if (data_we) begin
      data_mem[data_index] <= data_write;
    end
  end
  
endmodule
// Modelo de memória principal usado na simulação para responder às requisições da cache.

import cache_def::*;

module memory_model(
    input  bit           clk,
  input  bit [31:0]    mem_addr,
  input  cache_data_type mem_wdata,
  input  bit           mem_rw,
  input  bit           mem_valid,
  output cache_data_type mem_rdata,
  output bit           mem_ready
);

  cache_data_type memory [0:1023];

  initial begin
    mem_rdata = '0;
    mem_ready = 1'b0;

    for (int i = 0; i < 1024; i++) begin
      memory[i] = {32'h33333333 ^ i, 32'h22222222 ^ i, 32'h11111111 ^ i, 32'h00000000 ^ i};
    end
  end

  always @(posedge clk) begin
    mem_ready <= 1'b0;

    if (mem_valid) begin
      if (mem_rw) begin
        memory[mem_addr[13:4]] <= mem_wdata;
        mem_rdata <= mem_wdata;
      end
      else begin
        mem_rdata <= memory[mem_addr[13:4]];
      end

      mem_ready <= 1'b1;
    end
  end

endmodule
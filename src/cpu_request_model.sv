// Modelo de CPU usado na simulação para gerar requisições de leitura e escrita para a cache.
import cache_def::*;

module cpu_request_model(
    input  bit              clk,
  input  bit              cpu_ready,
  input  bit [31:0]       cpu_rdata,
  output bit [31:0]       cpu_addr,
  output bit [31:0]       cpu_wdata,
  output bit              cpu_rw,
  output bit              cpu_valid
);

  task automatic idle;
    cpu_addr  = '0;
    cpu_wdata = '0;
    cpu_rw    = 1'b0;
    cpu_valid = 1'b0;
  endtask

  task automatic read_word(
      input  logic [31:0] addr,
      output logic [31:0] data
  );
      cpu_addr  = addr;
      cpu_wdata = '0;
      cpu_rw    = 1'b0;
      cpu_valid = 1'b1;

    @(posedge clk);
    while (!cpu_ready) begin
      @(posedge clk);
    end

    data = cpu_rdata;

    @(negedge clk);
    cpu_valid = 1'b0;
  endtask

  task automatic write_word(
      input logic [31:0] addr,
      input logic [31:0] data
  );
      cpu_addr  = addr;
      cpu_wdata = data;
      cpu_rw    = 1'b1;
      cpu_valid = 1'b1;

    @(posedge clk);
    while (!cpu_ready) begin
      @(posedge clk);
    end

    @(negedge clk);
    cpu_valid = 1'b0;
  endtask

endmodule
// Testbench principal responsável por instanciar a cache, memória, clock/reset e executar os testes automatizados.

import cache_def::*;

module tb_dm_cache;

  bit clk;
  bit rst;

  bit [31:0]      cpu_addr;
  bit [31:0]      cpu_wdata;
  bit             cpu_rw;
  bit             cpu_valid;
  bit [31:0]      cpu_rdata;
  bit             cpu_ready;

  bit [31:0]      mem_addr;
  cache_data_type mem_wdata;
  bit             mem_rw;
  bit             mem_valid;
  cache_data_type mem_rdata;
  bit             mem_ready;

  logic [31:0] read_data;

  dm_cache_fsm dut(
      .clk(clk),
      .rst(rst),
      .cpu_addr(cpu_addr),
      .cpu_wdata(cpu_wdata),
      .cpu_rw(cpu_rw),
      .cpu_valid(cpu_valid),
      .cpu_rdata(cpu_rdata),
      .cpu_ready(cpu_ready),
      .mem_rdata(mem_rdata),
      .mem_ready(mem_ready),
      .mem_addr(mem_addr),
      .mem_wdata(mem_wdata),
      .mem_rw(mem_rw),
      .mem_valid(mem_valid)
  );

  memory_model mem(
      .clk(clk),
      .mem_addr(mem_addr),
      .mem_wdata(mem_wdata),
      .mem_rw(mem_rw),
      .mem_valid(mem_valid),
      .mem_rdata(mem_rdata),
      .mem_ready(mem_ready)
  );

  cpu_request_model cpu(
      .clk(clk),
      .cpu_ready(cpu_ready),
      .cpu_rdata(cpu_rdata),
      .cpu_addr(cpu_addr),
      .cpu_wdata(cpu_wdata),
      .cpu_rw(cpu_rw),
      .cpu_valid(cpu_valid)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("bin/wave.vcd");
    $dumpvars(0, tb_dm_cache);

    rst = 1'b1;
    cpu.idle();

    repeat (3) @(posedge clk);
    rst = 1'b0;

    repeat (2) @(posedge clk);

    $display("Teste 1: read miss");
    cpu.read_word(32'h0000_0000, read_data);
    $display("Read data = %h", read_data);

    $display("Teste 2: read hit");
    cpu.read_word(32'h0000_0000, read_data);
    $display("Read data = %h", read_data);

    $display("Teste 3: write hit");
    cpu.write_word(32'h0000_0000, 32'hDEAD_BEEF);

    $display("Teste 4: read apos escrita");
    cpu.read_word(32'h0000_0000, read_data);
    $display("Read data = %h", read_data);

    $display("SIMULACAO FINALIZADA COM SUCESSO");
    $finish;
  end

endmodule
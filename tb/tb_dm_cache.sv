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

  int erros;
  logic [31:0] resumo_read_miss;
  logic [31:0] resumo_read_hit;
  logic [31:0] resumo_write_hit;
  logic [31:0] resumo_write_miss;
  logic [31:0] resumo_writeback_mem;
  logic [31:0] resumo_consistencia_a;
  logic [31:0] resumo_consistencia_b;
  logic [31:0] resumo_edge_min;
  logic [31:0] resumo_edge_max;

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

  function automatic logic [9:0] indice_cache(input logic [31:0] addr);
    return addr[13:4];
  endfunction

  function automatic logic [17:0] tag_cache(input logic [31:0] addr);
    return addr[31:14];
  endfunction

  function automatic logic [31:0] endereco_cache(
      input logic [17:0] tag,
      input logic [9:0] indice
  );
    return {tag, indice, 4'b0000};
  endfunction

  function automatic logic [31:0] dado_inicial_memoria(input logic [31:0] addr);
    return {22'b0, addr[13:4]};
  endfunction

  task automatic espera_ciclos(input int n);
    for (int i = 0; i < n; i++) begin
      @(posedge clk);
    end
  endtask

  task automatic pausa_curta;
    cpu.idle();
    espera_ciclos(2);
  endtask

  task automatic titulo(input string texto);
    $display("\n== %s ==", texto);
  endtask

  task automatic verifica(input bit condicao, input string mensagem);
    if (condicao) begin
      $display("ok: %s", mensagem);
    end
    else begin
      erros++;
      $display("falha: %s", mensagem);
    end
  endtask

  task automatic resumo_observado;
    $display("\nresumo observado:");
    $display("- read miss em 0x00000000 => 0x%08h", resumo_read_miss);
    $display("- read hit  em 0x00000000 => 0x%08h", resumo_read_hit);
    $display("- write hit em 0x00000010 => 0x%08h", resumo_write_hit);
    $display("- write miss em 0x00000020 => 0x%08h", resumo_write_miss);
    $display("- write back em mem[7] => 0x%08h", resumo_writeback_mem);
    $display("- consistencia a => 0x%08h, b => 0x%08h", resumo_consistencia_a, resumo_consistencia_b);
    $display("- casos limite min => 0x%08h, max => 0x%08h", resumo_edge_min, resumo_edge_max);
  endtask

  task automatic leitura_com_contagem(
      input logic [31:0] endereco,
      output logic [31:0] dado,
      output int leituras_mem,
      output int escritas_mem
  );
    leituras_mem = 0;
    escritas_mem = 0;

    fork
      begin : monitor_leitura
        @(posedge clk);
        while (!cpu_valid) begin
          @(posedge clk);
        end

        while (!cpu_ready) begin
          if (mem_valid) begin
            if (mem_rw) begin
              escritas_mem++;
            end
            else begin
              leituras_mem++;
            end
          end
          @(posedge clk);
        end

        if (mem_valid) begin
          if (mem_rw) begin
            escritas_mem++;
          end
          else begin
            leituras_mem++;
          end
        end
      end
      begin : operacao_leitura
        cpu.read_word(endereco, dado);
      end
    join
  endtask

  task automatic escrita_com_contagem(
      input logic [31:0] endereco,
      input logic [31:0] dado,
      output int leituras_mem,
      output int escritas_mem
  );
    leituras_mem = 0;
    escritas_mem = 0;

    fork
      begin : monitor_escrita
        @(posedge clk);
        while (!cpu_valid) begin
          @(posedge clk);
        end

        while (!cpu_ready) begin
          if (mem_valid) begin
            if (mem_rw) begin
              escritas_mem++;
            end
            else begin
              leituras_mem++;
            end
          end
          @(posedge clk);
        end

        if (mem_valid) begin
          if (mem_rw) begin
            escritas_mem++;
          end
          else begin
            leituras_mem++;
          end
        end
      end
      begin : operacao_escrita
        cpu.write_word(endereco, dado);
      end
    join
  endtask

  `include "tests_read.sv"
  `include "tests_write.sv"
  `include "tests_replacement.sv"
  `include "tests_consistency.sv"
  `include "tests_edge_cases.sv"

  initial begin
    $dumpfile("bin/wave.vcd");
    $dumpvars(0, tb_dm_cache);

    rst = 1'b1;
    cpu.idle();
    erros = 0;
    resumo_read_miss = '0;
    resumo_read_hit = '0;
    resumo_write_hit = '0;
    resumo_write_miss = '0;
    resumo_writeback_mem = '0;
    resumo_consistencia_a = '0;
    resumo_consistencia_b = '0;
    resumo_edge_min = '0;
    resumo_edge_max = '0;

    espera_ciclos(3);
    rst = 1'b0;

    espera_ciclos(2);

    testes_leitura();
    pausa_curta();
    testes_escrita();
    pausa_curta();
    testes_substituicao();
    pausa_curta();
    testes_consistencia();
    pausa_curta();
    testes_casos_limite();

    if (erros == 0) begin
      resumo_observado();
      $display("\nSIMULACAO FINALIZADA COM SUCESSO");
    end
    else begin
      $display("\nresumo nao gerado por haver falhas");
      $display("\nSIMULACAO FINALIZADA COM %0d ERRO(S)", erros);
    end
    $finish;
  end

endmodule
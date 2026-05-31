import cache_def::*;

module tb_smoke;

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

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("bin/wave.vcd");
    $dumpvars(0, tb_smoke);

    cpu_addr = '0;
    cpu_wdata = '0;
    cpu_rw = 1'b0;
    cpu_valid = 1'b0;
    mem_rdata = '0;
    mem_ready = 1'b0;

    rst = 1'b1;
    repeat (3) @(posedge clk);
    rst = 1'b0;

    repeat (5) @(posedge clk);

    $display("SMOKE OK");
    $finish;
  end

endmodule

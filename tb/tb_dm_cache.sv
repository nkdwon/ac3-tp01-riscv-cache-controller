import cache_def::*;

module tb_dm_cache;

	timeunit 1ns;
	timeprecision 1ps;

	bit clk;
	bit rst;

	cpu_req_type    cpu_req;
	mem_req_type    mem_req;
	cpu_result_type cpu_res;
	mem_data_type   mem_data;

	dm_cache_fsm dut(
			.clk(clk),
			.rst(rst),
			.cpu_req(cpu_req),
			.mem_data(mem_data),
			.mem_req(mem_req),
			.cpu_res(cpu_res)
	);

	cpu_request_model cpu_model(
			.clk(clk),
			.cpu_res(cpu_res),
			.cpu_req(cpu_req)
	);

	memory_model mem_model(
			.clk(clk),
			.mem_req(mem_req),
			.mem_data(mem_data)
	);

	function automatic cache_data_type make_default_line(input logic [31:0] addr);
		logic [31:0] base;
		base = {4'hA, addr[31:4]};
		make_default_line = {base ^ 32'h3333_3333,
												 base ^ 32'h2222_2222,
												 base ^ 32'h1111_1111,
												 base};
	endfunction

	function automatic logic [31:0] expected_word(input logic [31:0] addr);
		cache_data_type line;

		line = make_default_line(addr);
		case (addr[3:2])
			2'b00: expected_word = line[31:0];
			2'b01: expected_word = line[63:32];
			2'b10: expected_word = line[95:64];
			2'b11: expected_word = line[127:96];
		endcase
	endfunction

	task automatic check_word(
			input string        label,
			input logic [31:0]  got,
			input logic [31:0]  expected
	);
		if (got !== expected) begin
			$fatal(1, "%s: esperado %08h, obtido %08h", label, expected, got);
		end
	endtask

	task automatic apply_reset();
		rst = 1'b1;
		cpu_model.idle();
		repeat (3) @(posedge clk);
		rst = 1'b0;
		repeat (1) @(posedge clk);
	endtask

`include "tests_read.sv"
`include "tests_write.sv"
`include "tests_replacement.sv"
`include "tests_consistency.sv"
`include "tests_edge_cases.sv"

	initial begin
		clk = 1'b0;
		forever #5 clk = ~clk;
	end

	initial begin
		// $dumpfile("bin/wave.vcd");
		// $dumpvars(0, tb_dm_cache);

		apply_reset();

		run_read_tests();
		run_write_tests();
		run_replacement_tests();
		run_consistency_tests();
		run_edge_case_tests();

		$display("SIMULACAO FINALIZADA COM SUCESSO");
		$finish;
	end

endmodule
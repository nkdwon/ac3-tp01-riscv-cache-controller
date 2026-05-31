task automatic run_consistency_tests();
	logic [31:0] addr_a;
	logic [31:0] addr_b;
	logic [31:0] data;

	$display("[CONSISTENCY] leituras repetidas e isolamento de linhas");

	addr_a = 32'h0000_0444;
	addr_b = 32'h0000_0C44;

	cpu_model.read_word(addr_a, data);
	check_word("consistent read a1", data, expected_word(addr_a));

	cpu_model.read_word(addr_a, data);
	check_word("consistent read a2", data, expected_word(addr_a));

	cpu_model.write_word(addr_b, 32'h0BAD_F00D);
	cpu_model.read_word(addr_a, data);
	check_word("a preserved after b write", data, expected_word(addr_a));

	cpu_model.read_word(addr_b, data);
	check_word("b writeback", data, 32'h0BAD_F00D);
endtask
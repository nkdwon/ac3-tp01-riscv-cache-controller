task automatic run_read_tests();
	logic [31:0] addr;
	logic [31:0] data;

	$display("[READ] read miss e read hit");

	addr = 32'h0000_0120;
	cpu_model.read_word(addr, data);
	check_word("read miss", data, expected_word(addr));

	cpu_model.read_word(addr, data);
	check_word("read hit", data, expected_word(addr));

	addr = 32'h0000_1A34;
	cpu_model.read_word(addr, data);
	check_word("read miss 2", data, expected_word(addr));

	cpu_model.read_word(addr, data);
	check_word("read hit 2", data, expected_word(addr));
endtask
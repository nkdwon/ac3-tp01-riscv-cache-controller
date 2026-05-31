task automatic run_edge_case_tests();
	logic [31:0] addr;
	logic [31:0] data;

	$display("[EDGE] enderecos extremos");

	addr = 32'h0000_0000;
	cpu_model.read_word(addr, data);
	check_word("edge read zero", data, expected_word(addr));

	addr = 32'hFFFF_FFFC;
	cpu_model.read_word(addr, data);
	check_word("edge read max", data, expected_word(addr));

	cpu_model.write_word(addr, 32'hFACE_CAFE);
	cpu_model.read_word(addr, data);
	check_word("edge write/read max", data, 32'hFACE_CAFE);
endtask
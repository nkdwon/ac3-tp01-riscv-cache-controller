task automatic run_replacement_tests();
	logic [31:0] base_addr;
	logic [31:0] alt_addr;
	logic [31:0] data;

	$display("[REPLACEMENT] dirty eviction e write-back");

	base_addr = 32'h0000_0300;
	alt_addr  = base_addr ^ 32'h0000_4000;

	data = 32'hCAFE_BABE;
	cpu_model.write_word(base_addr, data);

	cpu_model.read_word(alt_addr, data);
	check_word("alt read after eviction", data, expected_word(alt_addr));

	cpu_model.read_word(base_addr, data);
	check_word("base preserved after write-back", data, 32'hCAFE_BABE);
endtask
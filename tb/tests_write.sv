task automatic run_write_tests();
	logic [31:0] addr;
	logic [31:0] data;

	$display("[WRITE] write miss e write hit");

	addr = 32'h0000_0240;
	data = 32'hDEAD_BEEF;
	cpu_model.write_word(addr, data);
	cpu_model.read_word(addr, data);
	check_word("write miss/readback", data, 32'hDEAD_BEEF);

	data = 32'h1234_5678;
	cpu_model.write_word(addr, data);
	cpu_model.read_word(addr, data);
	check_word("write hit/readback", data, 32'h1234_5678);
endtask
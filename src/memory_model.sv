import cache_def::*;

module memory_model(
		input  bit           clk,
		input  mem_req_type   mem_req,
		output mem_data_type  mem_data
);

	timeunit 1ns;
	timeprecision 1ps;

	localparam int MEM_DEPTH = 64;

	logic [27:0]        line_addr_mem [0:MEM_DEPTH-1];
	cache_data_type     line_data_mem [0:MEM_DEPTH-1];
	bit                 line_valid_mem[0:MEM_DEPTH-1];

	bit                 request_pending;
	bit                 request_latched;
	logic [31:0]        latched_addr;
	cache_data_type     latched_data;
	bit                 latched_rw;

	function automatic cache_data_type make_default_line(input logic [27:0] line_addr);
		logic [31:0] base;
		base = {4'hA, line_addr};
		make_default_line = {base ^ 32'h3333_3333,
												 base ^ 32'h2222_2222,
												 base ^ 32'h1111_1111,
												 base};
	endfunction

	function automatic int find_slot(input logic [27:0] line_addr);
		find_slot = -1;
		for (int i = 0; i < MEM_DEPTH; i++) begin
			if (line_valid_mem[i] && line_addr_mem[i] == line_addr) begin
				find_slot = i;
				return find_slot;
			end
		end
	endfunction

	task automatic store_line(
			input logic [27:0]   line_addr,
			input cache_data_type line_data
	);
		int slot;

		slot = find_slot(line_addr);
		if (slot < 0) begin
			slot = -1;
			for (int i = 0; i < MEM_DEPTH; i++) begin
				if (!line_valid_mem[i]) begin
					slot = i;
					// `break` is not supported by some Icarus Verilog versions;
					// force loop termination by setting the loop index to the limit.
					i = MEM_DEPTH;
				end
			end

			if (slot < 0) begin
				slot = 0;
			end
		end

		line_valid_mem[slot] = 1'b1;
		line_addr_mem[slot] = line_addr;
		line_data_mem[slot] = line_data;
	endtask

	function automatic cache_data_type load_line(input logic [27:0] line_addr);
		int slot;

		slot = find_slot(line_addr);
		if (slot >= 0) begin
			load_line = line_data_mem[slot];
		end
		else begin
			load_line = make_default_line(line_addr);
		end
	endfunction

	initial begin
		mem_data = '0;
		request_pending = 1'b0;
		request_latched = 1'b0;
		latched_addr = '0;
		latched_data = '0;
		latched_rw = 1'b0;

		for (int i = 0; i < MEM_DEPTH; i++) begin
			line_valid_mem[i] = 1'b0;
			line_addr_mem[i] = '0;
			line_data_mem[i] = '0;
		end
	end

	always_ff @(posedge clk) begin
		mem_data.ready <= 1'b0;

		if (request_pending) begin
			mem_data.ready <= 1'b1;

			if (latched_rw) begin
				store_line(latched_addr[31:4], latched_data);
				mem_data.data <= latched_data;
			end
			else begin
				if (find_slot(latched_addr[31:4]) < 0) begin
					store_line(latched_addr[31:4], make_default_line(latched_addr[31:4]));
				end
				mem_data.data <= load_line(latched_addr[31:4]);
			end

			request_pending <= 1'b0;
		end

		if (!request_pending && mem_req.valid && !request_latched) begin
			latched_addr <= mem_req.addr;
			latched_data <= mem_req.data;
			latched_rw <= mem_req.rw;
			request_pending <= 1'b1;
			request_latched <= 1'b1;
		end
		else if (!mem_req.valid) begin
			request_latched <= 1'b0;
		end
	end

endmodule
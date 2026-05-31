import cache_def::*;

module cpu_request_model(
		input  bit              clk,
		input  cpu_result_type   cpu_res,
		output cpu_req_type      cpu_req
);

	timeunit 1ns;
	timeprecision 1ps;

	task automatic idle();
		cpu_req = '0;
	endtask

	task automatic read_word(
			input  logic [31:0]  addr,
			output logic [31:0]  data
	);
		int watchdog;

		watchdog = 0;
		while (cpu_res.ready) begin
			@(posedge clk);
			watchdog++;
			if (watchdog > 100)
				$fatal(1, "read_word: timeout esperando ready=0 (addr=%08h)", addr);
		end

		@(negedge clk);
		cpu_req.addr = addr;
		cpu_req.data = '0;
		cpu_req.rw = 1'b0;
		cpu_req.valid = 1'b1;

		watchdog = 0;
		while (!cpu_res.ready) begin
			@(posedge clk);
			watchdog++;
			if (watchdog > 100)
				$fatal(1, "read_word: timeout esperando ready=1 (addr=%08h)", addr);
		end

		data = cpu_res.data;

		@(negedge clk);
		cpu_req.valid = 1'b0;
	endtask

	task automatic write_word(
			input  logic [31:0]  addr,
			input  logic [31:0]  data
	);
		int watchdog;

		watchdog = 0;
		while (cpu_res.ready) begin
			@(posedge clk);
			watchdog++;
			if (watchdog > 100)
				$fatal(1, "write_word: timeout esperando ready=0 (addr=%08h)", addr);
		end

		@(negedge clk);
		cpu_req.addr = addr;
		cpu_req.data = data;
		cpu_req.rw = 1'b1;
		cpu_req.valid = 1'b1;

		watchdog = 0;
		while (!cpu_res.ready) begin
			@(posedge clk);
			watchdog++;
			if (watchdog > 100)
				$fatal(1, "write_word: timeout esperando ready=1 (addr=%08h)", addr);
		end

		@(negedge clk);
		cpu_req.valid = 1'b0;
	endtask

endmodule
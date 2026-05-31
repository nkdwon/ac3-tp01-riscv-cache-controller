import cache_def::*;

/* cache finite state machine */
module dm_cache_fsm(
    input  bit              clk,       // write clock
    input  bit              rst,
  input  bit [31:0]       cpu_addr,  // CPU request addr
  input  bit [31:0]       cpu_wdata, // CPU write data
  input  bit              cpu_rw,    // CPU request type: 0 = read, 1 = write
  input  bit              cpu_valid, // CPU request valid
  output bit [31:0]       cpu_rdata, // CPU read data
  output bit              cpu_ready, // CPU result ready
  input  cache_data_type  mem_rdata, // memory response data
  input  bit              mem_ready, // memory response ready
  output bit [31:0]       mem_addr,  // memory request addr
  output cache_data_type  mem_wdata, // memory write data
  output bit              mem_rw,    // memory request type: 0 = read, 1 = write
  output bit              mem_valid  // memory request valid
);

  timeunit 1ns;
  timeprecision 1ps;

  /* FSM state encoding */
  localparam logic [1:0] IDLE = 2'b00;
  localparam logic [1:0] COMPARE_TAG = 2'b01;
  localparam logic [1:0] ALLOCATE = 2'b10;
  localparam logic [1:0] WRITE_BACK = 2'b11;

  /* FSM state register */
  logic [1:0] vstate, rstate;


  /* interface signals to tag memory */
  logic [9:0]           tag_index;       // tag index
  logic                 tag_we;          // tag write enable
  logic                 tag_write_valid; // tag write valid
  logic                 tag_write_dirty; // tag write dirty
  logic [17:0]          tag_write_tag;   // tag write tag
  logic                 tag_read_valid;  // tag read valid
  logic                 tag_read_dirty;  // tag read dirty
  logic [17:0]          tag_read_tag;    // tag read tag

  /* interface signals to cache data memory */
  logic [9:0]           data_index;  // data index
  logic                 data_we;     // data write enable
  logic [127:0]         data_read;  // cache line read data
  logic [127:0]         data_write; // cache line write data

  logic                 tag_read_valid_r;
  logic                 tag_read_dirty_r;
  logic [17:0]          tag_read_tag_r;
  logic [127:0]         data_read_r;

  /* temporary variables for outputs */
  logic [31:0]    v_cpu_rdata;
  logic           v_cpu_ready;
  logic [31:0]    v_mem_addr;
  logic [127:0]   v_mem_wdata;
  logic           v_mem_rw;
  logic           v_mem_valid;

  logic [127:0]   mem_rdata_i;

  assign mem_rdata_i = mem_rdata;

  assign cpu_rdata = v_cpu_rdata;
  assign cpu_ready = v_cpu_ready;
  assign mem_addr  = v_mem_addr;
  assign mem_wdata = v_mem_wdata;
  assign mem_rw    = v_mem_rw;
  assign mem_valid = v_mem_valid;

  always @(rstate, cpu_addr, cpu_wdata, cpu_rw, cpu_valid, tag_read_valid_r,
           tag_read_dirty_r, tag_read_tag_r, data_read_r, mem_rdata_i,
           mem_ready) begin
    v_cpu_ready = 1'b0;
    v_cpu_rdata = 32'b0;
    v_mem_valid = 1'b0;
    v_mem_rw = 1'b0;
    v_mem_addr = 32'b0;
    v_mem_wdata = 128'b0;
    tag_we = 1'b0;
    data_we = 1'b0;
    tag_index = cpu_addr[13:4];
    data_index = cpu_addr[13:4];
    tag_write_valid = 1'b0;
    tag_write_dirty = 1'b0;
    tag_write_tag = 18'b0;
    data_write = 128'b0;

    vstate = rstate;

    case (rstate)
      IDLE: begin
        if (cpu_valid) begin
          vstate = COMPARE_TAG;
        end
      end

      COMPARE_TAG: begin
        if (tag_read_valid_r && (cpu_addr[31:14] == tag_read_tag_r)) begin
          v_cpu_ready = 1'b1;
          if (cpu_rw) begin
            data_write = data_read_r;
            data_write[31:0] = cpu_wdata;
            data_we = 1'b1;
            tag_we = 1'b1;
            tag_write_valid = 1'b1;
            tag_write_dirty = 1'b1;
            tag_write_tag = tag_read_tag_r;
          end
          else begin
            v_cpu_rdata = data_read_r[31:0];
          end
        end
        else begin
          tag_write_valid = 1'b1;
          tag_write_dirty = cpu_rw;
          tag_write_tag = cpu_addr[31:14];
          tag_we = 1'b1;
          v_mem_valid = 1'b1;
          v_mem_rw = 1'b0;
          v_mem_addr = cpu_addr;

          if ((tag_read_valid_r == 1'b0) || (tag_read_dirty_r == 1'b0)) begin
            vstate = ALLOCATE;
          end
          else begin
            v_mem_valid = 1'b1;
            v_mem_rw = 1'b1;
            v_mem_addr = {tag_read_tag_r, cpu_addr[13:0]};
            v_mem_wdata = data_read_r;
            vstate = WRITE_BACK;
          end
        end

        if (vstate == COMPARE_TAG) begin
          vstate = IDLE;
        end
      end

      ALLOCATE: begin
        if (mem_ready) begin
          data_write = mem_rdata_i;
          data_we = 1'b1;
          vstate = COMPARE_TAG;
        end
      end

      WRITE_BACK: begin
        if (mem_ready) begin
          v_mem_valid = 1'b1;
          v_mem_rw = 1'b0;
          v_mem_addr = cpu_addr;
          vstate = ALLOCATE;
        end
      end

      default: begin
        vstate = IDLE;
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      rstate <= IDLE;
    end
    else begin
      rstate <= vstate;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      tag_read_valid_r <= 1'b0;
      tag_read_dirty_r <= 1'b0;
      tag_read_tag_r <= 18'b0;
      data_read_r <= 128'b0;
    end
    else begin
      tag_read_valid_r <= tag_read_valid;
      tag_read_dirty_r <= tag_read_dirty;
      tag_read_tag_r <= tag_read_tag;
      data_read_r <= data_read;
    end
  end

  /* connect cache tag/data memory */
    dm_cache_tag ctag(
      .clk(clk),
      .tag_index(tag_index),
      .tag_we(tag_we),
      .tag_write_valid(tag_write_valid),
      .tag_write_dirty(tag_write_dirty),
      .tag_write_tag(tag_write_tag),
      .tag_read_valid(tag_read_valid),
      .tag_read_dirty(tag_read_dirty),
      .tag_read_tag(tag_read_tag)
    );

    dm_cache_data cdata(
      .clk(clk),
      .data_index(data_index),
      .data_we(data_we),
      .data_write(data_write),
      .data_read(data_read)
    );

endmodule
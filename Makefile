# Arquivos-fonte do núcleo da cache
SRC = src/cache_def.sv \
      src/dm_cache_data.sv \
      src/dm_cache_tag.sv \
      src/dm_cache_fsm.sv \
      src/memory_model.sv \
      src/cpu_request_model.sv

TB = tb/tb_dm_cache.sv
TOP = tb_dm_cache

BIN_DIR = bin
OUT = $(BIN_DIR)/simv
WAVE = $(BIN_DIR)/wave.vcd


build:
	mkdir -p $(BIN_DIR)
	iverilog -g2012 -I tb -s $(TOP) -o $(OUT) $(SRC) $(TB)

run: build
	vvp $(OUT)

wave:
	gtkwave $(WAVE)

clean:
	rm -rf $(BIN_DIR)
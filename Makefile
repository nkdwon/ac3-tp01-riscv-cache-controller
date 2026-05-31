# Arquivos-fonte do núcleo da cache
.PHONY: build run wave clean test help

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

test: run

help:
	@echo "alvos disponiveis:"
	@echo "  build  - compila o testbench"
	@echo "  run    - compila e executa a simulacao"
	@echo "  wave   - abre a waveform em bin/wave.vcd"
	@echo "  test   - alias de run"
	@echo "  clean  - remove arquivos gerados"

clean:
	rm -rf $(BIN_DIR)
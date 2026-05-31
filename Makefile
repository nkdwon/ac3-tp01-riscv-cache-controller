# Arquivos-fonte do núcleo da cache
SRC = src/cache_def.sv \
      src/dm_cache_data.sv \
      src/dm_cache_tag.sv \
      src/dm_cache_fsm.sv

# Arquivo de testbench principal
# Será usado na próxima etapa, quando tb_dm_cache.sv estiver implementado.
TB = tb/tb_dm_cache.sv

BIN_DIR = bin
OUT = $(BIN_DIR)/simv
WAVE = $(BIN_DIR)/wave.vcd

# Módulo top-level atual.
# Enquanto ainda não há testbench completo, compilamos apenas o núcleo da cache.
TOP = dm_cache_fsm

# Quando o testbench estiver pronto, trocar para:
# TOP = tb_dm_cache

build:
	mkdir -p $(BIN_DIR)
	iverilog -g2012 -s $(TOP) -o $(OUT) $(SRC)

# Futuramente, quando o testbench estiver pronto, usar:
# iverilog -g2012 -s $(TOP) -o $(OUT) $(SRC) $(TB)

run: build
	vvp $(OUT)

wave:
	gtkwave $(WAVE)

clean:
	rm -rf $(BIN_DIR)
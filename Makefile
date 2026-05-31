# Arquivos-fonte do núcleo da cache
SRC = src/cache_def.sv \
      src/dm_cache_data.sv \
      src/dm_cache_tag.sv \
      src/dm_cache_fsm.sv \
      src/memory_model.sv \
      src/cpu_request_model.sv

# Arquivo de testbench principal.
TB = tb/tb_dm_cache.sv

BIN_DIR = bin
OUT = $(BIN_DIR)/simv
WAVE = $(BIN_DIR)/wave.vcd

# Módulo top-level da simulação.
TOP = tb_dm_cache

# Portable mkdir/rm: prefer POSIX in MSYS/Cygwin, fallback to Windows cmd on native Windows
ifneq ($(MSYSTEM),)
MKDIR_CMD=mkdir -p $(BIN_DIR)
RM_CMD=rm -rf $(BIN_DIR)
else
ifeq ($(OS),Windows_NT)
MKDIR_CMD=if not exist "$(BIN_DIR)" mkdir "$(BIN_DIR)"
RM_CMD=if exist "$(BIN_DIR)" rmdir /s /q "$(BIN_DIR)"
else
MKDIR_CMD=mkdir -p $(BIN_DIR)
RM_CMD=rm -rf $(BIN_DIR)
endif
endif

build:
	$(MKDIR_CMD)
	iverilog -g2012 -I tb -s $(TOP) -o $(OUT) $(SRC) $(TB)

run: build
	vvp $(OUT)

wave:
	gtkwave $(WAVE)

clean:
	$(RM_CMD)
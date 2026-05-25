SRC = src/*.sv
TB = tb/tb_CacheController.sv

BIN_DIR = bin
OUT = $(BIN_DIR)/simv
WAVE = $(BIN_DIR)/wave.vcd

build:
	mkdir -p $(BIN_DIR)
	iverilog -g2012 -o $(OUT) $(SRC) $(TB)

run: build
	vvp $(OUT)

wave:
	gtkwave $(WAVE)

clean:
	rm -rf $(BIN_DIR)
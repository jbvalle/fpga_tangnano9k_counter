DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1N-9C

SRC_DIR = src
OUT_DIR = _out
CONSTR_DIR = constr

BITSTREAM = counter.fs

# Files 
SRC := $(wildcard $(SRC_DIR)/*.v)
CONSTR := $(CONSTR_DIR)/*.cst

all: $(OUT_DIR)/$(BITSTREAM)

# SYNTHESIS
$(OUT_DIR)/counter.json: $(SRC_DIR)/*.v
	yosys -p "read_verilog $^; synth_gowin -top counter -json $@"

# PNR
$(OUT_DIR)/counter_pnr.json : $(OUT_DIR)/counter.json
	nextpnr-gowin --json $^ --freq 27 --write $@ --device $(DEVICE) --family $(FAMILY) --cst $(CONSTR_DIR)/*.cst

# BITSTREAM GENERATION
$(OUT_DIR)/$(BITSTREAM): $(OUT_DIR)/counter_pnr.json
	gowin_pack -d $(FAMILY) -o  $@ $^

flash: FORCE
	openFPGALoader -b tangnano9k -f $(OUT_DIR)/$(BITSTREAM)

clean: FORCE
	rm -rf $(OUT_DIR)/*

FORCE:


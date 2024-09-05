DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1N-9C

SRC_DIR = src
OUT_DIR = _out
CONSTR_DIR = constr
SYNTH_LOG_DIR = log/synth
PNR_LOG_DIR = log/pnr
BITSTREAM_LOG_DIR = log/bitstream
FLASH_LOG_DIR = log/flashing


BITSTREAM = counter.fs

# Files 
SRC := $(wildcard $(SRC_DIR)/*.v)
CONSTR := $(CONSTR_DIR)/*.cst


all: $(OUT_DIR)/$(BITSTREAM)   

# SYNTHESIS
$(OUT_DIR)/counter.json: $(SRC_DIR)/*.v | synth_msg
	yosys -p "read_verilog $^; synth_gowin -top counter -json $@" > $(SYNTH_LOG_DIR)/yosys.log 2>&1

# PNR
$(OUT_DIR)/counter_pnr.json : $(OUT_DIR)/counter.json | pnr_msg
	nextpnr-gowin --json $^ --freq 27 --write $@ --device $(DEVICE) --family $(FAMILY) --cst $(CONSTR_DIR)/*.cst > $(PNR_LOG_DIR)/nextpnr.log 2>&1

# BITSTREAM GENERATION
$(OUT_DIR)/$(BITSTREAM): $(OUT_DIR)/counter_pnr.json | bitstream_msg
	gowin_pack -d $(FAMILY) -o  $@ $^ > $(BITSTREAM_LOG_DIR)/bitstream.log 2>&1

flash: FORCE | flashing_msg
	openFPGALoader -b tangnano9k -f $(OUT_DIR)/$(BITSTREAM) > $(FLASH_LOG_DIR)/flashing.log 2>&1


synth_msg:
	@echo "#################"
	@echo "### SYNTHESIS ###"
	@echo "#################"

pnr_msg:
	@echo "#######################"
	@echo "### PLACE AND ROUTE ###"
	@echo "#######################"

bitstream_msg:
	@echo "############################"
	@echo "### BITSTREAM GENERATION ###"
	@echo "############################"

flashing_msg:
	@echo "################"
	@echo "### FLASHING ###"
	@echo "################"

mkdir_log:
	@mkdir -p $(SRC_DIR)
	@mkdir -p $(OUT_DIR)
	@mkdir -p $(CONSTR_DIR)
	@mkdir -p $(SYNTH_LOG_DIR)
	@mkdir -p $(PNR_LOG_DIR)
	@mkdir -p $(BITSTREAM_LOG_DIR)
	@mkdir -p $(FLASH_LOG_DIR)

FORCE:


clean: FORCE
	rm -rf $(OUT_DIR)/* 

.PHONE: synth_msg pnr_msg bitstream_msg flashing_msg 

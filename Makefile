XRAY_DIR=/home/zipotron/movidas/tools/prjxray
XRAY_UTILS_DIR=/home/zipotron/movidas/tools/prjxray/utils
NEXTPNR_DIR=/home/zipotron/movidas/tools/nextpnr-xilinx

board = redpitaya
family = zynq7
chipfile = xc7z010clg400.bin
part = xc7z010clg400-1

.PHONY: all clean

TARGETS=axi2.bit

all: $(TARGETS)

axi2.bit: axi2.v
	yosys -p "synth_xilinx -flatten -abc9 -arch xc7 -top axi2; write_json axi2.json" axi2.v
	nextpnr-xilinx --chipdb $(NEXTPNR_DIR)/xilinx/$(chipfile) --xdc $(board).xdc --json axi2.json --write axi2_routed.json --fasm axi2.fasm
	source "${XRAY_DIR}/utils/environment.sh"
	${XRAY_UTILS_DIR}/fasm2frames.py --part $(part) --db-root ${XRAY_UTILS_DIR}/../database/$(family) axi2.fasm > axi2.frames
	xc7frames2bit --part_file ${XRAY_UTILS_DIR}/../database/$(family)/$(part)/part.yaml --part_name $(part) --frm_file axi2.frames --output_file axi2.bit

	
clean:
	rm -f $(TARGETS) *.bit *.json *.fasm *.frames *~

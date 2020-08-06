
SRCDIR=../src
OPCDIR=../../opc/opc7
SRCS= $(wildcard $(SRCDIR)/*.v)

VPATH=${SRCDIR}:${OPCDIR}

osl_tb_neg.exe: osl_tb.v osl.h osl_rxtx.v
	iverilog -DTX_ON_NEGEDGE=1 -I${SRCDIR} -o osl_tb_neg.exe osl_tb.v ${SRCDIR}/osl_rxtx.v

osl_tb.exe: osl_tb.v osl.h osl_rxtx.v
	iverilog -I${SRCDIR} -o osl_tb.exe osl_tb.v ${SRCDIR}/osl_rxtx.v

osl_tb.vcd: osl_tb.exe
	./osl_tb.exe

osl_tb_neg.vcd: osl_tb_neg.exe
	./osl_tb_neg.exe

opc7array: ${SRCS} ${OPCDIR}/opc7cpu.v ../firmware/boot.hex
	head -200 ../firmware/boot.hex > boot.hex
	iverilog -I${SRCDIR} -o opc7array.exe ${SRCS} ${OPCDIR}/opc7cpu.v


all: osl_tb_neg.vcd osl_tb.vcd

clean:
	rm *.vcd *.exe *~

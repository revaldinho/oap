
VPATH=../src

osl_tb_neg.exe: osl_tb.v osl.h osl_rxtx.v
	iverilog -DTX_ON_NEGEDGE=1 -I${VPATH} -o osl_tb_neg.exe osl_tb.v ${VPATH}/osl_rxtx.v

osl_tb.exe: osl_tb.v osl.h osl_rxtx.v
	iverilog -I${VPATH} -o osl_tb.exe osl_tb.v ${VPATH}/osl_rxtx.v

osl_tb.vcd: osl_tb.exe
	./osl_tb.exe

osl_tb_neg.vcd: osl_tb_neg.exe
	./osl_tb_neg.exe


all: osl_tb_neg.vcd osl_tb.vcd

clean:
	rm *.vcd *.exe *~

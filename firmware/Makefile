

assembler ?= ../../opc/opc7/opc7asm.py

%.hex %.lst : %.s
	python3 ${assembler} $< $*.hex -o $*.hex -g hex -z 4096 | tee  $*.lst


all: boot.hex

clean:
	rm *lst *hex \#*


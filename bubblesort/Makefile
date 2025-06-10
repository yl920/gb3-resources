BENCHMARK = benchmark
SREC2HEX = srec2hex
BLOCK_SIZE = 4096

all: $(BENCHMARK).hex

$(BENCHMARK).hex: $(BENCHMARK).sr
	$(SREC2HEX) -b $(BLOCK_SIZE) $(BENCHMARK).sr

clean:
	rm -f program.hex data.hex
	

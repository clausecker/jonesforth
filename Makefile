BUILD_ID_NONE := -Wl,--build-id=none
ASFLAGS := -m32
LDFLAGS := -nostdlib -static $(BUILD_ID_NONE)

SHELL	:= /bin/bash

all:	jonesforth test

run: jonesforth jonesforth.f
	cat jonesforth.f $(PROG) - | ./jonesforth

clean:
	$(RM) jonesforth perf_dupdrop *~ core .test_* *.o *.s

# Tests.

TESTS	:= $(patsubst %.f,%.test,$(wildcard test_*.f))

test check: $(TESTS)

test_%.test: test_%.f jonesforth
	@echo -n "$< ... "
	$(RM) -f .$@
	@cat <(echo ': TEST-MODE ;') jonesforth.f $< <(echo 'TEST') | \
	  ./jonesforth 2>&1 | \
	  sed 's/DSP=[0-9]*//g' > .$@
	@diff -u .$@ $<.out
	@$(RM) -f .$@
	@echo "ok"

# Performance.

perf_dupdrop: perf_dupdrop.c
	$(CC) $(ASFLAGS) -O3 -Wall -Werror -o $@ $<

run_perf_dupdrop: jonesforth
	cat <(echo ': TEST-MODE ;') jonesforth.f perf_dupdrop.f | ./jonesforth

.SUFFIXES:
.SUFFIXES: .S .s .o .test

.PHONY: test check run run_perf_dupdrop all

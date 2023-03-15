.PHONY: all test clean

all: example example_c

gcc = gcc -c -Wall -Wextra -std=c17 -g -Og

inverse_permutation.o: inverse_permutation.asm
	nasm -f elf64 -w+all -w+error -o $@ $<

inverse_permutation_c.o: inverse_permutation_c.c
	$(gcc) -o $@ $<

example.o: inverse_permutation_example.c
	$(gcc) -o $@ $<

example: inverse_permutation.o example.o
	gcc -g -z noexecstack -o $@ $^

example_c: inverse_permutation_c.c example.o
	gcc -g -z noexecstack -o $@ $^

test.o: test.c
	$(gcc) -o $@ $<

test: inverse_permutation.o test.o
	gcc -g -z noexecstack -o $@ $^

test_c: inverse_permutation_c.o test.o
	gcc -g -z noexecstack -o $@ $^

clean:
	rm -rf *.o ./example

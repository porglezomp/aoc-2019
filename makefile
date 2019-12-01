all: day01

ENSURE_DIR:=$(shell mkdir -p target)

day01: target/day01 input/01.txt
	target/day01 < input/01.txt

target/day01: day01.asm
	nasm -f macho64 $< -o target/day01.o
	ld -macosx_version_min 10.7.0 -lSystem -o $@ target/day01.o

set -e

# Clean

if [ -d bin ]; then
	rm -r bin
fi
mkdir bin

# Compile

as src/main.s -o bin/main.o -I src
as src/dbg.s -o bin/dbg.o -I src
as src/lex.s -o bin/lex.o -I src

# Link

ld bin/main.o bin/dbg.o bin/lex.o -o bin/simpscript -nostdlib -e "Program.main"

# Run

if [ "$1" == "dbg" ]; then
	gdb -q -x gdbinit
else
	./bin/simpscript
fi

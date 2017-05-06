GCC=$ARCH-elf-gcc
BIN=$ARCH-elf-binutils
GDB=$ARCH-elf-gdb

brew install --verbose $BIN
brew install --verbose $GCC
brew install --verbose $GDB

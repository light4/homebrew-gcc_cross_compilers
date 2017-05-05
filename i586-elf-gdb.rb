require 'formula'

class I586ElfGdb < Formula
  homepage 'https://www.gnu.org/software/gdb/'
  url 'https://ftpmirror.gnu.org/gdb/gdb-7.12.1.tar.xz'
  mirror 'https://ftp.gnu.org/gnu/gdb/gdb-7.12.1.tar.xz'
  sha256 '4607680b973d3ec92c30ad029f1b7dbde3876869e6b3a117d8a7e90081113186'

  depends_on 'i586-elf-binutils'
  depends_on 'i586-elf-gcc'

  def install
    ENV['CC'] = '/usr/local/opt/gcc/bin/gcc-7'
    ENV['CXX'] = '/usr/local/opt/gcc/bin/g++-7'
    ENV['CPP'] = '/usr/local/opt/gcc/bin/cpp-7'
    ENV['LD'] = '/usr/local/opt/gcc/bin/gcc-7'

    mkdir 'build' do
      system '../configure', '--target=i586-elf',
                             "--prefix=#{prefix}",
                             "--disable-werror"
      system 'make'

      # Don't install bfd or opcodes, as they are provided by binutils
      inreplace ["bfd/Makefile", "opcodes/Makefile"], /^install:/, "dontinstall:"

      system 'make install'
      FileUtils.rm_rf share/"locale"
    end
  end
end

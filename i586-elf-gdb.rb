require 'formula'

class I586ElfGdb < Formula
  homepage 'http://gcc.gnu.org'
  url 'http://ftpmirror.gnu.org/gnu/gdb/gdb-7.12.tar.xz'
  mirror "http://ftp.gnu.org/gnu/gdb/gdb-7.12.tar.xz"
  sha256 '834ff3c5948b30718343ea57b11cbc3235d7995c6a4f3a5cecec8c8114164f94'

  depends_on 'i586-elf-binutils'
  depends_on 'i586-elf-gcc'

  def install
    ENV['CC'] = '/usr/local/opt/gcc/bin/gcc-6'
    ENV['CXX'] = '/usr/local/opt/gcc/bin/g++-6'
    ENV['CPP'] = '/usr/local/opt/gcc/bin/cpp-6'
    ENV['LD'] = '/usr/local/opt/gcc/bin/gcc-6'

    mkdir 'build' do
      system '../configure', '--target=i586-elf', "--prefix=#{prefix}", "--disable-werror"
      system 'make'
      system 'make install'
      FileUtils.rm_rf share/"locale"
    end
  end
end

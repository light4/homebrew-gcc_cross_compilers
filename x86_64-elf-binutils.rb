require 'formula'

class X8664ElfBinutils < Formula
  homepage 'https://www.gnu.org/software/binutils/'
  url 'https://ftpmirror.gnu.org/gnu/binutils/binutils-2.29.1.tar.gz'
  mirror 'https://ftp.gnu.org/gnu/binutils/binutils-2.29.1.tar.gz'
  sha256 '0d9d2bbf71e17903f26a676e7fba7c200e581c84b8f2f43e72d875d0e638771c'

  depends_on 'gcc' => :build
  def install
    ENV['CC'] = '/usr/local/opt/gcc/bin/gcc-7'
    ENV['CXX'] = '/usr/local/opt/gcc/bin/g++-7'
    ENV['CPP'] = '/usr/local/opt/gcc/bin/cpp-7'
    ENV['LD'] = '/usr/local/opt/gcc/bin/gcc-7'

    mkdir 'build' do
      system '../configure', '--disable-nls',
                             '--target=x86_64-elf',
                             '--disable-werror',
                             '--enable-gold=yes',
                             "--prefix=#{prefix}"
      system 'make all'
      system 'make install'
    end
  end
end

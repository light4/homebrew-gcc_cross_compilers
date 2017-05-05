require 'formula'

class I586ElfBinutils < Formula
  homepage 'https://www.gnu.org/software/binutils/'
  url 'https://ftpmirror.gnu.org/gnu/binutils/binutils-2.28.tar.gz'
  mirror 'https://ftp.gnu.org/gnu/binutils/binutils-2.28.tar.gz'
  sha256 'cd717966fc761d840d451dbd58d44e1e5b92949d2073d75b73fccb476d772fcf'

  depends_on 'gcc' => :build
  def install
    ENV['CC'] = '/usr/local/opt/gcc/bin/gcc-7'
    ENV['CXX'] = '/usr/local/opt/gcc/bin/g++-7'
    ENV['CPP'] = '/usr/local/opt/gcc/bin/cpp-7'
    ENV['LD'] = '/usr/local/opt/gcc/bin/gcc-7'

    mkdir 'build' do
      system '../configure', '--disable-nls',
                             '--target=i586-elf',
                             '--disable-werror',
                             '--enable-gold=yes',
                             "--prefix=#{prefix}"
      system 'make all'
      system 'make install'
    end
  end
end

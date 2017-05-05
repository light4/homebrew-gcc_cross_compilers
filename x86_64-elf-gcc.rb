require 'formula'

class X8664ElfGcc < Formula
  homepage 'https://gcc.gnu.org'
  url 'https://ftpmirror.gnu.org/gcc/gcc-7.1.0/gcc-7.1.0.tar.bz2'
  mirror 'https://ftp.gnu.org/gnu/gcc/gcc-7.1.0/gcc-7.1.0.tar.bz2'
  sha256 '8a8136c235f64c6fef69cac0d73a46a1a09bb250776a050aec8f9fc880bebc17'

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'isl'
  depends_on 'x86_64-elf-binutils'

  def install
    binutils = Formulary.factory 'x86_64-elf-binutils'

    ENV['CC'] = '/usr/local/opt/gcc/bin/gcc-7'
    ENV['CXX'] = '/usr/local/opt/gcc/bin/g++-7'
    ENV['CPP'] = '/usr/local/opt/gcc/bin/cpp-7'
    ENV['LD'] = '/usr/local/opt/gcc/bin/gcc-7'
    ENV['PATH'] += ":#{binutils.prefix/"bin"}"

    mkdir 'build' do
      system '../configure', '--disable-nls',
                             '--target=x86_64-elf',
                             '--disable-werror',
                             "--prefix=#{prefix}",
                             "--enable-languages=c",
                             "--without-headers",
                             "--with-gmp=#{Formula["gmp"].opt_prefix}",
                             "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
                             "--with-mpc=#{Formula["libmpc"].opt_prefix}"
      system 'make all-gcc'
      system 'make install-gcc'
      FileUtils.ln_sf binutils.prefix/"x86_64-elf", prefix/"x86_64-elf"
      system 'make all-target-libgcc'
      system 'make install-target-libgcc'
      FileUtils.rm_rf share/"man"/"man7"
    end
  end
end

require 'formula'

class X8664ElfGdb < Formula
  homepage 'http://gcc.gnu.org'
  url 'https://ftpmirror.gnu.org/gdb/gdb-7.12.1.tar.xz'
  mirror 'https://ftp.gnu.org/gnu/gdb/gdb-7.12.1.tar.xz'
  sha256 '4607680b973d3ec92c30ad029f1b7dbde3876869e6b3a117d8a7e90081113186'

  depends_on 'x86_64-elf-binutils'
  depends_on 'x86_64-elf-gcc'

  def install
    ENV['CC'] = '/usr/local/opt/gcc/bin/gcc-6'
    ENV['CXX'] = '/usr/local/opt/gcc/bin/g++-6'
    ENV['CPP'] = '/usr/local/opt/gcc/bin/cpp-6'
    ENV['LD'] = '/usr/local/opt/gcc/bin/gcc-6'

    mkdir 'build' do
      system '../configure', '--target=x86_64-elf', "--prefix=#{prefix}", "--disable-werror"
      system 'make'
      system 'make install'
      FileUtils.rm_rf share/"locale"
    end
  end

  def patches
    # When debugging 64-bit kernels via qemu, gdb has a tough time on the switch
    # to long mode, and this patch helps it out by making sure that gdb keeps up
    # with the switches in architecture that qemu makes
    DATA
  end
end

__END__
diff -u a/gdb/remote.c b/gdb/remote.c
--- a/gdb/remote.c
+++ b/gdb/remote.c
@@ -7147,8 +7147,17 @@
   buf_len = strlen (rs->buf);

   /* Further sanity checks, with knowledge of the architecture.  */
-  if (buf_len > 2 * rsa->sizeof_g_packet)
-    error (_("Remote 'g' packet reply is too long: %s"), rs->buf);
+  if (buf_len > 2 * rsa->sizeof_g_packet) {
+    rsa->sizeof_g_packet = buf_len;
+    for (i = 0; i < gdbarch_num_regs (gdbarch); i++) {
+      if (rsa->regs[i].pnum == -1)
+        continue;
+      if (rsa->regs[i].offset >= rsa->sizeof_g_packet)
+        rsa->regs[i].in_g_packet = 0;
+      else
+        rsa->regs[i].in_g_packet = 1;
+    }
+  }

   /* Save the size of the packet sent to us by the target.  It is used
      as a heuristic when determining the max size of packets that the

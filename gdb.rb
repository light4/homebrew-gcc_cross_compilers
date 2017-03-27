class UniversalBrewedPython < Requirement
  satisfy { archs_for_command("python").universal? }

  def message; <<-EOS.undent
    A build of GDB using a brewed Python was requested, but Python is not
    a universal build.

    GDB requires Python to be built as a universal binary or it will fail
    if attempting to debug a 32-bit binary on a 64-bit host.
    EOS
  end
end

class Gdb < Formula
  desc "GNU debugger"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftpmirror.gnu.org/gdb/gdb-7.12.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gdb/gdb-7.12.1.tar.xz"
  sha256 "4607680b973d3ec92c30ad029f1b7dbde3876869e6b3a117d8a7e90081113186"

  bottle do
    rebuild 1
    sha256 "810225f267677d661ded76c3f8548ed9f24a03feaaa3597d229694eab654b3fd" => :sierra
    sha256 "2032ce5c512f0885171e4826d0a8a9f1a2fae2f24cec4c851a284c26eceaa221" => :el_capitan
    sha256 "eaad3b6eb64408088da0760cf0ca92c39a121a5f58d1835bd74f4b745fb2697c" => :yosemite
  end

  deprecated_option "with-brewed-python" => "with-python"

  option "with-python", "Use the Homebrew version of Python; by default system Python is used"
  option "with-version-suffix", "Add a version suffix to program"
  option "with-all-targets", "Build with support for all targets"

  depends_on "pkg-config" => :build
  depends_on "python" => :optional
  depends_on "guile" => :optional

  if MacOS.version >= :sierra
    patch do
      # Patch is needed to work on new 10.12 installs with SIP.
      # See http://sourceware-org.1504.n7.nabble.com/gdb-on-macOS-10-12-quot-Sierra-quot-td415708.html
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/9d3dbc2/gdb/0001-darwin-nat.c-handle-Darwin-16-aka-Sierra.patch"
      sha256 "a71489440781ae133eeba5a3123996e55f72bd914dbfdd3af0b0700f6d0e4e08"
    end
  end

  if build.with? "python"
    depends_on UniversalBrewedPython
  end

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-debug",
      "--disable-dependency-tracking",
    ]

    args << "--with-guile" if build.with? "guile"
    args << "--enable-targets=all" if build.with? "all-targets"

    if build.with? "python"
      args << "--with-python=#{HOMEBREW_PREFIX}"
    else
      args << "--with-python=/usr"
    end

    if build.with? "version-suffix"
      args << "--program-suffix=-#{version.to_s.slice(/^\d/)}"
    end

    system "./configure", *args
    system "make"

    # Don't install bfd or opcodes, as they are provided by binutils
    inreplace ["bfd/Makefile", "opcodes/Makefile"], /^install:/, "dontinstall:"

    system "make", "install"
  end

  def patches
    # When debugging 64-bit kernels via qemu, gdb has a tough time on the switch
    # to long mode, and this patch helps it out by making sure that gdb keeps up
    # with the switches in architecture that qemu makes
    DATA
  end

  def caveats; <<-EOS.undent
    gdb requires special privileges to access Mach ports.
    You will need to codesign the binary. For instructions, see:

      https://sourceware.org/gdb/wiki/BuildingOnDarwin

    On 10.12 (Sierra) or later with SIP, you need to run this:

      echo "set startup-with-shell off" >> ~/.gdbinit
    EOS
  end

  test do
    system bin/"gdb", bin/"gdb", "-configuration"
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

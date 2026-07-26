; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -filetype=obj \
; RUN:   -o %t.o %s
; RUN: llvm-readobj --file-headers %t.o | FileCheck %s

; The exact PlayStation 2 triple defaults to N32 even when a frontend does not
; pass an explicit target ABI.

; CHECK:      Format: elf32-mips
; CHECK:      Arch: mipsel
; CHECK:      AddressSize: 32bit
; CHECK:      Flags [
; CHECK-DAG:    EF_MIPS_ABI2
; CHECK-DAG:    EF_MIPS_ARCH_3
; CHECK-DAG:    EF_MIPS_MACH_5900

define i32 @identity(i32 %value) {
  ret i32 %value
}

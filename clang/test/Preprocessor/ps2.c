// RUN: %clang -target mips64el-scei-ps2 -dM -E %s \
// RUN:   | FileCheck --match-full-lines --implicit-check-not=__GCC_HAVE_SYNC_COMPARE_AND_SWAP %s

// CHECK-DAG: #define _EE 1
// CHECK-DAG: #define _MIPS_ARCH "r5900"
// CHECK-DAG: #define _MIPS_ARCH_R5900 1
// CHECK-DAG: #define _MIPS_ISA _MIPS_ISA_MIPS3
// CHECK-DAG: #define _MIPS_SIM _ABIN32
// CHECK-DAG: #define _MIPS_SZINT 32
// CHECK-DAG: #define _MIPS_SZLONG 32
// CHECK-DAG: #define _MIPS_SZPTR 32
// CHECK-DAG: #define __GCC_ATOMIC_INT_LOCK_FREE 1
// CHECK-DAG: #define __SIZEOF_LONG_DOUBLE__ 8
// CHECK-DAG: #define __SIZEOF_LONG__ 4
// CHECK-DAG: #define __SIZEOF_POINTER__ 4
// CHECK-DAG: #define __mips 3
// CHECK-DAG: #define __mips_hard_float 1
// CHECK-DAG: #define __mips_n32 1
// CHECK-DAG: #define __mips_single_float 1
// CHECK-DAG: #define __ps2__ 1
// CHECK-DAG: #define __ps2sdk__ 1

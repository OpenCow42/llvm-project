// RUN: %clang --target=mips64el-scei-ps2 --sysroot=%S/Inputs/ps2_tree \
// RUN:   -### -c %s 2>&1 | FileCheck --check-prefix=COMPILE %s
// RUN: %clang --target=mips64el-scei-ps2 --sysroot=%S/Inputs/ps2_tree \
// RUN:   -Wl,-Map=output.map -### %s 2>&1 | FileCheck --check-prefix=LINK %s
// RUN: not %clang --target=mips64el-scei-ps2 -mabi=n64 -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-ABI %s
// RUN: not %clang --target=mips64el-scei-ps2 -mcpu=mips64r2 -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-CPU %s
// RUN: not %clang --target=mips64el-scei-ps2 -EB -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-ENDIAN %s
// RUN: not %clang --target=mips64el-scei-ps2 -fPIC -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-PIC %s
// RUN: not %clang --target=mips64el-scei-ps2 -pie %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-PIE %s
// RUN: not %clang --target=mips64el-scei-ps2 -shared %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-SHARED %s
// RUN: not %clang --target=mips64el-scei-ps2 -msoft-float -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-SOFT-FLOAT %s
// RUN: not %clang --target=mips64el-scei-ps2 -mdouble-float -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-DOUBLE-FLOAT %s
// RUN: not %clang --target=mips64el-scei-ps2 -G8 -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=BAD-SMALL-DATA %s
// RUN: %clang --target=mips64el-scei-ps2 -### -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=FRAME-DEBUG %s
// RUN: %clang --target=mips64el-scei-ps2 -O1 -### -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=FRAME-OPT %s
// RUN: %clang --target=mips64el-scei-ps2 -O2 -### -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=FRAME-OPT %s
// RUN: %clang --target=mips64el-scei-ps2 -O3 -### -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=FRAME-OPT %s
// RUN: %clang --target=mips64el-scei-ps2 -Os -### -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=FRAME-OPT %s
// RUN: %clang --target=mips64el-scei-ps2 -Oz -### -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=FRAME-OPT %s
// RUN: %clang --target=mips64el-scei-ps2 -O2 -fno-omit-frame-pointer \
// RUN:   -### -c %s 2>&1 | FileCheck --check-prefix=FRAME-FORCED %s
// RUN: %clang --target=mips64el-scei-ps2 -O0 -fomit-frame-pointer \
// RUN:   -### -c %s 2>&1 | FileCheck --check-prefix=FRAME-OPT %s

// COMPILE: "-cc1"
// COMPILE-DAG: "-triple" "mips64el-scei-ps2"
// COMPILE-DAG: "-target-cpu" "r5900"
// COMPILE-DAG: "-target-feature" "-noabicalls"
// COMPILE-DAG: "-target-feature" "+single-float"
// COMPILE-DAG: "-target-abi" "n32"
// COMPILE-DAG: "-mfloat-abi" "hard"
// COMPILE-DAG: "-mips-ssection-threshold=0"
// COMPILE-DAG: "-mframe-pointer=all"
// COMPILE-DAG: "-nostdsysteminc"
// COMPILE-DAG: "{{.*}}Inputs/ps2_tree/ee/mips64r5900el-ps2-elf/include"
// COMPILE-DAG: "{{.*}}Inputs/ps2_tree/ps2sdk/ee/include"
// COMPILE-DAG: "{{.*}}Inputs/ps2_tree/ps2sdk/common/include"

// LINK: "{{.*}}Inputs/ps2_tree/ee/bin/mips64r5900el-ps2-elf-gcc"
// LINK-SAME: "-static"
// LINK-SAME: "-G0"
// LINK-SAME: "-T{{.*}}Inputs/ps2_tree/ps2sdk/ee/startup/linkfile"
// LINK-SAME: "-L{{.*}}Inputs/ps2_tree/ps2sdk/ee/lib"
// LINK-SAME: "-Wl,-zmax-page-size=128"
// LINK-SAME: "-Wl,-Map=output.map"

// BAD-ABI: error: unsupported option '-mabi=n64' for target 'mips64el-scei-ps2'
// BAD-CPU: error: unsupported option '-mcpu=mips64r2' for target 'mips64el-scei-ps2'
// BAD-ENDIAN: error: unsupported option '-EB' for target 'mips64el-scei-ps2'
// BAD-PIC: error: unsupported option '-fPIC' for target 'mips64el-scei-ps2'
// BAD-PIE: error: unsupported option '-pie' for target 'mips64el-scei-ps2'
// BAD-SHARED: error: unsupported option '-shared' for target 'mips64el-scei-ps2'
// BAD-SOFT-FLOAT: error: unsupported option '-msoft-float' for target 'mips64el-scei-ps2'
// BAD-DOUBLE-FLOAT: error: unsupported option '-mdouble-float' for target 'mips64el-scei-ps2'
// BAD-SMALL-DATA: error: unsupported option '-G 8' for target 'mips64el-scei-ps2'

// FRAME-DEBUG: "-mframe-pointer=all"
// FRAME-OPT: "-mframe-pointer=none"
// FRAME-FORCED: "-mframe-pointer=all"

int main(void) { return 0; }

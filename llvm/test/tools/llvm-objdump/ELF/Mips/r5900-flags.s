# RUN: llvm-mc -triple=mips64el -mcpu=r5900 -target-abi=n32 \
# RUN:   -filetype=obj %s -o %t
# RUN: llvm-objdump -dr %t | FileCheck %s

# CHECK-LABEL: <add>:
# CHECK: addu $2, $4, $5

.text
.globl add
add:
  addu $2, $4, $5

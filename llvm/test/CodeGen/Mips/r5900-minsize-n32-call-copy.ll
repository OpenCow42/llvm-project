; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -O2 \
; RUN:   -relocation-model=static -verify-machineinstrs < %s \
; RUN:   | FileCheck %s

%aggregate = type { [16 x i64] }

declare void @fill(ptr)

declare void @consume(
    ptr sret(%aggregate),
    i64 inreg, i64 inreg, i64 inreg, i64 inreg,
    i64 inreg, i64 inreg, i64 inreg, i64 inreg,
    i64 inreg, i64 inreg, i64 inreg, i64 inreg,
    i64 inreg, i64 inreg, i64 inreg, i64 inreg
)

define void @minsize_large_aggregate_call(ptr %result) minsize {
; CHECK-LABEL: minsize_large_aggregate_call:
; CHECK:       jal fill
; CHECK:       jal memcpy
; CHECK:       daddiu $6, $zero, 72
; CHECK:       jal consume
  %value = alloca %aggregate, align 8
  call void @fill(ptr %value)
  %slot0 = load i64, ptr %value, align 8
  %address1 = getelementptr inbounds i8, ptr %value, i32 8
  %slot1 = load i64, ptr %address1, align 8
  %address2 = getelementptr inbounds i8, ptr %value, i32 16
  %slot2 = load i64, ptr %address2, align 8
  %address3 = getelementptr inbounds i8, ptr %value, i32 24
  %slot3 = load i64, ptr %address3, align 8
  %address4 = getelementptr inbounds i8, ptr %value, i32 32
  %slot4 = load i64, ptr %address4, align 8
  %address5 = getelementptr inbounds i8, ptr %value, i32 40
  %slot5 = load i64, ptr %address5, align 8
  %address6 = getelementptr inbounds i8, ptr %value, i32 48
  %slot6 = load i64, ptr %address6, align 8
  %address7 = getelementptr inbounds i8, ptr %value, i32 56
  %slot7 = load i64, ptr %address7, align 8
  %address8 = getelementptr inbounds i8, ptr %value, i32 64
  %slot8 = load i64, ptr %address8, align 8
  %address9 = getelementptr inbounds i8, ptr %value, i32 72
  %slot9 = load i64, ptr %address9, align 8
  %address10 = getelementptr inbounds i8, ptr %value, i32 80
  %slot10 = load i64, ptr %address10, align 8
  %address11 = getelementptr inbounds i8, ptr %value, i32 88
  %slot11 = load i64, ptr %address11, align 8
  %address12 = getelementptr inbounds i8, ptr %value, i32 96
  %slot12 = load i64, ptr %address12, align 8
  %address13 = getelementptr inbounds i8, ptr %value, i32 104
  %slot13 = load i64, ptr %address13, align 8
  %address14 = getelementptr inbounds i8, ptr %value, i32 112
  %slot14 = load i64, ptr %address14, align 8
  %address15 = getelementptr inbounds i8, ptr %value, i32 120
  %slot15 = load i64, ptr %address15, align 8
  call void @consume(
      ptr sret(%aggregate) %result,
      i64 inreg %slot0, i64 inreg %slot1,
      i64 inreg %slot2, i64 inreg %slot3,
      i64 inreg %slot4, i64 inreg %slot5,
      i64 inreg %slot6, i64 inreg %slot7,
      i64 inreg %slot8, i64 inreg %slot9,
      i64 inreg %slot10, i64 inreg %slot11,
      i64 inreg %slot12, i64 inreg %slot13,
      i64 inreg %slot14, i64 inreg %slot15
  )
  ret void
}

define void @non_minsize_large_aggregate_call(ptr %result) {
; CHECK-LABEL: non_minsize_large_aggregate_call:
; CHECK:       jal fill
; CHECK-NOT:   jal memcpy
; CHECK:       jal consume
  %value = alloca %aggregate, align 8
  call void @fill(ptr %value)
  %slot0 = load i64, ptr %value, align 8
  %address1 = getelementptr inbounds i8, ptr %value, i32 8
  %slot1 = load i64, ptr %address1, align 8
  %address2 = getelementptr inbounds i8, ptr %value, i32 16
  %slot2 = load i64, ptr %address2, align 8
  %address3 = getelementptr inbounds i8, ptr %value, i32 24
  %slot3 = load i64, ptr %address3, align 8
  %address4 = getelementptr inbounds i8, ptr %value, i32 32
  %slot4 = load i64, ptr %address4, align 8
  %address5 = getelementptr inbounds i8, ptr %value, i32 40
  %slot5 = load i64, ptr %address5, align 8
  %address6 = getelementptr inbounds i8, ptr %value, i32 48
  %slot6 = load i64, ptr %address6, align 8
  %address7 = getelementptr inbounds i8, ptr %value, i32 56
  %slot7 = load i64, ptr %address7, align 8
  %address8 = getelementptr inbounds i8, ptr %value, i32 64
  %slot8 = load i64, ptr %address8, align 8
  %address9 = getelementptr inbounds i8, ptr %value, i32 72
  %slot9 = load i64, ptr %address9, align 8
  %address10 = getelementptr inbounds i8, ptr %value, i32 80
  %slot10 = load i64, ptr %address10, align 8
  %address11 = getelementptr inbounds i8, ptr %value, i32 88
  %slot11 = load i64, ptr %address11, align 8
  %address12 = getelementptr inbounds i8, ptr %value, i32 96
  %slot12 = load i64, ptr %address12, align 8
  %address13 = getelementptr inbounds i8, ptr %value, i32 104
  %slot13 = load i64, ptr %address13, align 8
  %address14 = getelementptr inbounds i8, ptr %value, i32 112
  %slot14 = load i64, ptr %address14, align 8
  %address15 = getelementptr inbounds i8, ptr %value, i32 120
  %slot15 = load i64, ptr %address15, align 8
  call void @consume(
      ptr sret(%aggregate) %result,
      i64 inreg %slot0, i64 inreg %slot1,
      i64 inreg %slot2, i64 inreg %slot3,
      i64 inreg %slot4, i64 inreg %slot5,
      i64 inreg %slot6, i64 inreg %slot7,
      i64 inreg %slot8, i64 inreg %slot9,
      i64 inreg %slot10, i64 inreg %slot11,
      i64 inreg %slot12, i64 inreg %slot13,
      i64 inreg %slot14, i64 inreg %slot15
  )
  ret void
}

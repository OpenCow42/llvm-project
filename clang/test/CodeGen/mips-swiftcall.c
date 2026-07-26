// RUN: %clang_cc1 -triple mips64el-scei-ps2 -target-cpu r5900 -target-abi n32 -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -triple mips64el-scei-ps2 -target-cpu r5900 -target-abi n32 -emit-obj -o %t.o %s

#define SWIFT_CALL __attribute__((swiftcall))
#define SWIFT_CONTEXT __attribute__((swift_context))
#define SWIFT_ERROR __attribute__((swift_error_result))

struct Pair {
  int first;
  int second;
};

struct Triple {
  int first;
  int second;
  int third;
};

// CHECK-LABEL: define{{.*}} swiftcc {{.*}} @return_pair(
struct Pair SWIFT_CALL return_pair(struct Pair value) {
  return value;
}

// Three pointer-width components exceed the two-register N32 return budget.
// CHECK-LABEL: define{{.*}} swiftcc void @return_triple(
// CHECK-SAME: sret(%struct.Triple)
struct Triple SWIFT_CALL return_triple(struct Triple value) {
  return value;
}

typedef float Float4 __attribute__((ext_vector_type(4)));

// Baseline PS2 Swift calls never use VU or MMI vector-register arguments.
// CHECK-LABEL: define{{.*}} swiftcc void @return_float4(
// CHECK-SAME: sret(<4 x float>)
Float4 SWIFT_CALL return_float4(Float4 value) {
  return value;
}

// CHECK-LABEL: define{{.*}} swiftcc void @context_error(
// CHECK-SAME: ptr{{.*}}swiftself
// CHECK-SAME: ptr{{.*}}swifterror
void SWIFT_CALL context_error(
    void *SWIFT_CONTEXT context,
    void **SWIFT_ERROR error) {
}

//===- MipsR5900InstrInfo.td - R5900 MMI Instructions --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains R5900-specific EE core and MMI instructions. The public
// N32 ABI remains authoritative; these definitions do not introduce a
// vector-register calling convention.
//
//===----------------------------------------------------------------------===//

let Predicates = [IsR5900] in {

// R5900 three-operand multiply writes the low 32-bit result directly to rd
// while preserving the architectural HI/LO side effects.
let Defs = [HI0, LO0], isCommutable = 1 in
def R5900_MULT : InstSE<(outs GPR32Opnd:$rd),
                        (ins GPR32Opnd:$rs, GPR32Opnd:$rt),
                        "mult\t$rd, $rs, $rt",
                        [(set GPR32Opnd:$rd,
                              (mul GPR32Opnd:$rs, GPR32Opnd:$rt))],
                        II_MULT, FrmR>,
                 R5900_MULT3_FM<0x18>;

let Defs = [HI0, LO0], isCommutable = 1 in
def R5900_MULTU : InstSE<(outs GPR32Opnd:$rd),
                         (ins GPR32Opnd:$rs, GPR32Opnd:$rt),
                         "multu\t$rd, $rs, $rt", [], II_MULTU, FrmR>,
                  R5900_MULT3_FM<0x19>;

// A divide followed by a single HI/LO extraction does not need an allocatable
// ACC64 value. Keeping the pair fused until after register allocation avoids
// spilling the R5900's sole architectural accumulator when independent
// divides overlap. MipsExpandPseudo emits the real divide and move pair.
class R5900DivResultPseudo<InstrItinClass Itin>
    : PseudoSE<(outs GPR32Opnd:$rd),
               (ins GPR32Opnd:$rs, GPR32Opnd:$rt), [], Itin> {
  let Defs = [HI0, LO0];
  let hasSideEffects = 0;
}

def R5900_PseudoSDIV_LO : R5900DivResultPseudo<II_DIV>;
def R5900_PseudoSDIV_HI : R5900DivResultPseudo<II_DIV>;
def R5900_PseudoUDIV_LO : R5900DivResultPseudo<II_DIVU>;
def R5900_PseudoUDIV_HI : R5900DivResultPseudo<II_DIVU>;

} // Predicates = [IsR5900]

let Predicates = [HasMMI] in {

let hasSideEffects = 0 in {
// The assembler/disassembler forms use the full R5900 general-purpose
// registers. Code generation uses the i32 forms below so scalar values retain
// the standard N32 ABI.
def PADDSW : InstSE<(outs GPR64Opnd:$rd),
                    (ins GPR64Opnd:$rs, GPR64Opnd:$rt),
                    "paddsw\t$rd, $rs, $rt", [], II_ADD, FrmR>,
             R5900_MMI0_FM<0b10000>;
def PADDUW : InstSE<(outs GPR64Opnd:$rd),
                    (ins GPR64Opnd:$rs, GPR64Opnd:$rt),
                    "padduw\t$rd, $rs, $rt", [], II_ADD, FrmR>,
             R5900_MMI1_FM<0b10000>;
def PSUBSW : InstSE<(outs GPR64Opnd:$rd),
                    (ins GPR64Opnd:$rs, GPR64Opnd:$rt),
                    "psubsw\t$rd, $rs, $rt", [], II_ADD, FrmR>,
             R5900_MMI0_FM<0b10001>;
def PSUBUW : InstSE<(outs GPR64Opnd:$rd),
                    (ins GPR64Opnd:$rs, GPR64Opnd:$rt),
                    "psubuw\t$rd, $rs, $rt", [], II_ADD, FrmR>,
             R5900_MMI1_FM<0b10001>;

let isCodeGenOnly = 1 in {
  let isCommutable = 1 in {
    def PADDSW_S32 : InstSE<(outs GPR32Opnd:$rd),
                            (ins GPR32Opnd:$rs, GPR32Opnd:$rt),
                            "paddsw\t$rd, $rs, $rt", [], II_ADD, FrmR>,
                     R5900_MMI0_FM<0b10000>;
    def PADDUW_S32 : InstSE<(outs GPR32Opnd:$rd),
                            (ins GPR32Opnd:$rs, GPR32Opnd:$rt),
                            "padduw\t$rd, $rs, $rt", [], II_ADD, FrmR>,
                     R5900_MMI1_FM<0b10000>;
  }

  def PSUBSW_S32 : InstSE<(outs GPR32Opnd:$rd),
                          (ins GPR32Opnd:$rs, GPR32Opnd:$rt),
                          "psubsw\t$rd, $rs, $rt", [], II_ADD, FrmR>,
                   R5900_MMI0_FM<0b10001>;
  def PSUBUW_S32 : InstSE<(outs GPR32Opnd:$rd),
                          (ins GPR32Opnd:$rs, GPR32Opnd:$rt),
                          "psubuw\t$rd, $rs, $rt", [], II_ADD, FrmR>,
                   R5900_MMI1_FM<0b10001>;
}
} // hasSideEffects = 0

def : Pat<(i32 (saddsat GPR32:$rs, GPR32:$rt)),
          (PADDSW_S32 GPR32:$rs, GPR32:$rt)>;
def : Pat<(i32 (uaddsat GPR32:$rs, GPR32:$rt)),
          (PADDUW_S32 GPR32:$rs, GPR32:$rt)>;
def : Pat<(i32 (ssubsat GPR32:$rs, GPR32:$rt)),
          (PSUBSW_S32 GPR32:$rs, GPR32:$rt)>;
def : Pat<(i32 (usubsat GPR32:$rs, GPR32:$rt)),
          (PSUBUW_S32 GPR32:$rs, GPR32:$rt)>;

} // Predicates = [HasMMI]

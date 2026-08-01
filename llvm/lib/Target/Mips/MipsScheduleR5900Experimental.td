//==- MipsScheduleR5900Experimental.td - R5900 scalar model -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This is a deliberately non-default candidate model for physical-console
// characterization of the R5900 scalar core. The ordinary "r5900" CPU keeps
// the qualified conservative model. The experimental CPU name is accepted by
// LLVM tools but rejected by the exact PS2 Clang driver contract.
//
// The resource shape and provisional timings come from the historical
// EmotionEngine backend and public architectural documentation. They are not
// release-qualified timing claims. Each value must be checked with dependent
// and independent instruction chains on a physical PS2 before the model can
// replace MipsR5900VU0Model.
//
// Optional MMI and VU0 resources intentionally remain outside this scalar
// model. They continue to use their independently qualified feature paths.
//
//===----------------------------------------------------------------------===//

def MipsR5900ExperimentalScalarModel : SchedMachineModel {
  int IssueWidth = 2;
  int MicroOpBufferSize = 0;
  int LoadLatency = 1;
  int MispredictPenalty = 4;
  int HighLatency = 37;

  let CompleteModel = 0;
  let PostRAScheduler = 1;
  let FullInstRWOverlapCheck = 1;
  list<Predicate> UnsupportedFeatures = [HasMMI, HasVU0];
}

let SchedModel = MipsR5900ExperimentalScalarModel in {

let BufferSize = 0 in {
  def R5900ExperimentalALU : ProcResource<2>;
  def R5900ExperimentalLdSt : ProcResource<1>;
  def R5900ExperimentalBranch : ProcResource<1>;
  def R5900ExperimentalMAC0 : ProcResource<1>;
  def R5900ExperimentalCOP1 : ProcResource<1>;
  def R5900ExperimentalCOP1DivSqrt : ProcResource<1>;
}

def R5900ExperimentalWriteALU
    : SchedWriteRes<[R5900ExperimentalALU]> {
  let Latency = 1;
}

def : InstRW<[R5900ExperimentalWriteALU],
             (instrs ADD, ADDi, ADDiu, ADDu, AND, ANDi, LEA_ADDiu, LUi, NOP,
                     NOR, OR, ORi, SLL, SLLV, SLT, SLTi, SLTiu, SLTu, SRA,
                     SRAV, SRL, SRLV, SSNOP, SUB, SUBu, XOR, XORi, COPY)>;

def : InstRW<[R5900ExperimentalWriteALU],
             (instrs DADD, DADDi, DADDiu, DADDu, DSLL, DSLL32, DSLLV, DSRA,
                     DSRA32, DSRAV, DSRL, DSRL32, DSRLV, DSUB, DSUBu, AND64,
                     ANDi64, OR64, ORi64, NOR64, XOR64, XORi64, SLL64_32,
                     SLL64_64, SLT64, SLTi64, SLTiu64, SLTu64, LUi64,
                     LEA_ADDiu64)>;

def R5900ExperimentalWriteLoad
    : SchedWriteRes<[R5900ExperimentalLdSt]> {
  let Latency = 1;
}

def R5900ExperimentalWriteStore
    : SchedWriteRes<[R5900ExperimentalLdSt]> {
  let Latency = 1;
}

def : InstRW<[R5900ExperimentalWriteLoad],
             (instrs LB, LBu, LH, LHu, LW, LWL, LWR, LD, LDL, LDR, LWu,
                     LB64, LBu64, LH64, LHu64, LW64, LWL64, LWR64)>;
def : InstRW<[R5900ExperimentalWriteStore],
             (instrs SB, SH, SW, SWL, SWR, SD, SDL, SDR, SB64, SH64, SW64,
                     SWL64, SWR64)>;

def R5900ExperimentalWriteBranch
    : SchedWriteRes<[R5900ExperimentalBranch]> {
  let Latency = 1;
}

def R5900ExperimentalWriteCall
    : SchedWriteRes<[R5900ExperimentalBranch]> {
  let Latency = 2;
}

def : InstRW<[R5900ExperimentalWriteBranch],
             (instrs B, BEQ, BEQL, BGEZ, BGEZL, BGTZ, BGTZL, BLEZ, BLEZL,
                     BLTZ, BLTZL, BNE, BNEL, J, JR, RetRA, TAILCALL,
                     TAILCALLREG, BEQ64, BGEZ64, BGTZ64, BLEZ64, BLTZ64,
                     BNE64, JR64, TAILCALLREG64, PseudoReturn,
                     PseudoReturn64)>;
def : InstRW<[R5900ExperimentalWriteCall],
             (instrs BAL, BAL_BR, BGEZAL, BGEZALL, BLTZAL, BLTZALL, JAL,
                     JALR, JALRPseudo, JALR64, JALR64Pseudo)>;

def R5900ExperimentalWriteMul
    : SchedWriteRes<[R5900ExperimentalALU, R5900ExperimentalMAC0]> {
  let Latency = 4;
  let ReleaseAtCycles = [1, 2];
}

def R5900ExperimentalWriteDiv
    : SchedWriteRes<[R5900ExperimentalALU, R5900ExperimentalMAC0]> {
  let Latency = 37;
  let ReleaseAtCycles = [1, 37];
}

def R5900ExperimentalWriteHILO
    : SchedWriteRes<[R5900ExperimentalALU]> {
  let Latency = 1;
}

def : InstRW<[R5900ExperimentalWriteMul],
             (instrs R5900_MULT, R5900_MULTU, MULT, MULTu, PseudoMULT,
                     PseudoMULTu)>;
def : InstRW<[R5900ExperimentalWriteDiv],
             (instrs PseudoSDIV, SDIV, PseudoUDIV, UDIV)>;
def : InstRW<[R5900ExperimentalWriteHILO],
             (instrs MFHI, MFLO, PseudoMFHI, PseudoMFLO, MFHI64, MFLO64,
                     PseudoMFHI64, PseudoMFLO64, MTHI, MTLO, PseudoMTLOHI,
                     MTHI64, MTLO64, PseudoMTLOHI64)>;

def R5900ExperimentalWriteCOP1Arith
    : SchedWriteRes<[R5900ExperimentalCOP1]> {
  let Latency = 4;
}

def R5900ExperimentalWriteCOP1Div
    : SchedWriteRes<[R5900ExperimentalCOP1,
                     R5900ExperimentalCOP1DivSqrt]> {
  let Latency = 8;
  let ReleaseAtCycles = [1, 7];
}

def R5900ExperimentalWriteCOP1Load
    : SchedWriteRes<[R5900ExperimentalLdSt]> {
  let Latency = 2;
}

def R5900ExperimentalWriteCOP1Store
    : SchedWriteRes<[R5900ExperimentalLdSt]> {
  let Latency = 1;
}

def R5900ExperimentalWriteCOP1Transfer
    : SchedWriteRes<[R5900ExperimentalLdSt]> {
  let Latency = 2;
}

def : InstRW<[R5900ExperimentalWriteCOP1Arith],
             (instrs FADD_S, FSUB_S, FMUL_S, FABS_S, FNEG_S, FMOV_S,
                     FCMP_S32, BC1F, BC1T, BC1FL, BC1TL, CVT_S_W, CVT_W_S)>;
def : InstRW<[R5900ExperimentalWriteCOP1Div], (instrs FDIV_S, FSQRT_S)>;
def : InstRW<[R5900ExperimentalWriteCOP1Load], (instrs LWC1)>;
def : InstRW<[R5900ExperimentalWriteCOP1Store], (instrs SWC1)>;
def : InstRW<[R5900ExperimentalWriteCOP1Transfer],
             (instrs MFC1, MTC1, CFC1, CTC1)>;

} // SchedModel = MipsR5900ExperimentalScalarModel

//==- MipsScheduleR5900VU0.td - R5900 VU0 scheduling -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This focused model records the R5900 VU0 macro-mode hazards needed by the
// initial PS2 vector kernels. Unlisted scalar instructions retain LLVM's
// conservative default timing until a complete R5900 dual-issue model is
// qualified independently.
//
//===----------------------------------------------------------------------===//

def MipsR5900VU0Model : SchedMachineModel {
  int IssueWidth = 1;
  int MicroOpBufferSize = 0;
  int LoadLatency = 1;
  int MispredictPenalty = 4;
  int HighLatency = 37;

  let CompleteModel = 0;
  let PostRAScheduler = 1;
  let FullInstRWOverlapCheck = 1;
}

let SchedModel = MipsR5900VU0Model in {

let BufferSize = 0 in {
  def R5900VU0UnitALU : ProcResource<1>;
  def R5900VU0UnitLdSt : ProcResource<1>;
  def R5900VU0UnitCOP2 : ProcResource<1>;
}

def R5900VU0WriteALU : SchedWriteRes<[R5900VU0UnitALU]> {
  let Latency = 1;
}

// Historical R5900 documentation and the reference backend describe a
// four-cycle result latency with one multiply accepted every two cycles. This
// remains conservative until the complete scalar model is hardware-qualified.
def R5900WriteMul : SchedWriteRes<[R5900VU0UnitALU]> {
  let Latency = 4;
  let ReleaseAtCycles = [2];
}

def : InstRW<[R5900WriteMul], (instrs R5900_MULT, R5900_MULTU)>;

// Preserve the qualified timing of the first MMI family.
def : InstRW<[R5900VU0WriteALU],
             (instrs PADDSW, PADDUW, PSUBSW, PSUBUW,
                     PADDSW_S32, PADDUW_S32, PSUBSW_S32, PSUBUW_S32)>;

// A VF result is visible to a dependent macro instruction after four cycles.
def R5900VU0WriteVF : SchedWriteRes<[R5900VU0UnitCOP2]> {
  let Latency = 4;
}

// ACC has no dependency stall in macro mode, so accumulator chains can issue
// on consecutive cycles.
def R5900VU0WriteACC : SchedWriteRes<[R5900VU0UnitCOP2]> {
  let Latency = 1;
}

// Transfers from the EE core to VU0 impose one extra macro-instruction stall.
def R5900VU0WriteLoad : SchedWriteRes<[R5900VU0UnitLdSt,
                                      R5900VU0UnitCOP2]> {
  let Latency = 2;
  let ReleaseAtCycles = [1, 2];
}

def R5900VU0WriteStore : SchedWriteRes<[R5900VU0UnitLdSt]> {
  let Latency = 1;
}

def R5900VU0WriteFromCOP2 : SchedWriteRes<[R5900VU0UnitLdSt]> {
  let Latency = 2;
}

def R5900VU0WriteToCOP2 : SchedWriteRes<[R5900VU0UnitLdSt,
                                        R5900VU0UnitCOP2]> {
  let Latency = 2;
  let ReleaseAtCycles = [1, 2];
}

def R5900VU0WriteQ : SchedWriteRes<[R5900VU0UnitCOP2]> {
  let Latency = 7;
  let ReleaseAtCycles = [7];
}

def : InstRW<[R5900VU0WriteLoad], (instrs LQC2)>;
def : InstRW<[R5900VU0WriteStore], (instrs SQC2)>;
def : InstRW<[R5900VU0WriteFromCOP2], (instrs CFC2, QMFC2)>;
def : InstRW<[R5900VU0WriteToCOP2], (instrs CTC2, QMTC2)>;

def : InstRW<[R5900VU0WriteVF],
             (instrs VADD, VSUB, VMUL, VMADD, VMSUB,
                     VADDm, VSUBm, VMULm, VMOVEm,
                     VABS, VMAX, VMINI,
                     VADDQ, VSUBQ, VMULQ,
                     VOPMSUB,
                     VADD_ISel, VSUB_ISel, VMUL_ISel,
                     VABS_ISel, VMAX_ISel, VMINI_ISel)>;

def : InstRW<[R5900VU0WriteVF],
             (instrs VADDbcx, VADDbcy, VADDbcz, VADDbcw,
                     VSUBbcx, VSUBbcy, VSUBbcz, VSUBbcw,
                     VMULbcx, VMULbcy, VMULbcz, VMULbcw,
                     VMADDbcx, VMADDbcy, VMADDbcz, VMADDbcw,
                     VMSUBbcx, VMSUBbcy, VMSUBbcz, VMSUBbcw,
                     VMULbc_ISelx, VMULbc_ISely,
                     VMULbc_ISelz, VMULbc_ISelw)>;

def : InstRW<[R5900VU0WriteACC],
             (instrs VADDA, VSUBA, VMULA, VMADDA, VMSUBA, VOPMULA,
                     VADDAbcx, VADDAbcy, VADDAbcz, VADDAbcw,
                     VSUBAbcx, VSUBAbcy, VSUBAbcz, VSUBAbcw,
                     VMULAbcx, VMULAbcy, VMULAbcz, VMULAbcw,
                     VMADDAbcx, VMADDAbcy, VMADDAbcz, VMADDAbcw,
                     VMSUBAbcx, VMSUBAbcy, VMSUBAbcz, VMSUBAbcw)>;

def : InstRW<[R5900VU0WriteQ], (instrs VDIV, VRSQRT, VSQRT)>;
def : InstRW<[R5900VU0WriteACC], (instrs VNOP, VWAITQ, VCLIPW)>;

} // SchedModel = MipsR5900VU0Model

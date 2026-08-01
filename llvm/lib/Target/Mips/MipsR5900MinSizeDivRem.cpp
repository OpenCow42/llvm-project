//===- MipsR5900MinSizeDivRem.cpp - Fuse minsize divide results ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// The R5900 has one architectural HI/LO accumulator. Generic MIPS lowering
// models each divide result as an ACC64 virtual register, which is useful when
// both quotient and remainder are live but can force an eight-instruction
// spill/reload sequence when independent single-result divides overlap.
//
// For minsize R5900 functions, fuse a divide with its sole MFLO/MFHI consumer
// into a result-producing pseudo before register allocation. The pseudo keeps
// the architectural HI/LO clobber explicit and is expanded after allocation.
//
//===----------------------------------------------------------------------===//

#include "Mips.h"
#include "MipsInstrInfo.h"
#include "MipsSubtarget.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/ErrorHandling.h"
#include <utility>

using namespace llvm;

#define DEBUG_TYPE "mips-r5900-minsize-divrem"

namespace {

class MipsR5900MinSizeDivRem : public MachineFunctionPass {
public:
  static char ID;

  MipsR5900MinSizeDivRem() : MachineFunctionPass(ID) {}

  StringRef getPassName() const override {
    return "R5900 minsize divide-result fusion";
  }

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties().setIsSSA();
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};

} // namespace

INITIALIZE_PASS(MipsR5900MinSizeDivRem, DEBUG_TYPE,
                "R5900 minsize divide-result fusion", false, false)

char MipsR5900MinSizeDivRem::ID = 0;

static unsigned getFusedOpcode(unsigned DivideOpcode, unsigned ExtractOpcode) {
  switch (DivideOpcode) {
  case Mips::PseudoSDIV:
    return ExtractOpcode == Mips::PseudoMFLO ? Mips::R5900_PseudoSDIV_LO
                                             : Mips::R5900_PseudoSDIV_HI;
  case Mips::PseudoUDIV:
    return ExtractOpcode == Mips::PseudoMFLO ? Mips::R5900_PseudoUDIV_LO
                                             : Mips::R5900_PseudoUDIV_HI;
  default:
    llvm_unreachable("unexpected R5900 divide opcode");
  }
}

bool MipsR5900MinSizeDivRem::runOnMachineFunction(MachineFunction &MF) {
  const MipsSubtarget &STI = MF.getSubtarget<MipsSubtarget>();
  if (!STI.isR5900() || !MF.getFunction().hasMinSize())
    return false;

  MachineRegisterInfo &MRI = MF.getRegInfo();
  const MipsInstrInfo &TII = *STI.getInstrInfo();
  SmallVector<std::pair<MachineInstr *, MachineInstr *>, 4> Candidates;

  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &MI : MBB) {
      if (MI.getOpcode() != Mips::PseudoSDIV &&
          MI.getOpcode() != Mips::PseudoUDIV)
        continue;

      Register Accumulator = MI.getOperand(0).getReg();
      if (!Accumulator.isVirtual() || !MRI.hasOneNonDBGUse(Accumulator))
        continue;

      MachineInstr &Extract = *MRI.use_nodbg_instructions(Accumulator).begin();
      if ((Extract.getOpcode() != Mips::PseudoMFLO &&
           Extract.getOpcode() != Mips::PseudoMFHI) ||
          Extract.getOperand(1).getReg() != Accumulator)
        continue;

      Candidates.emplace_back(&MI, &Extract);
    }
  }

  for (auto [Divide, Extract] : Candidates) {
    Register Accumulator = Divide->getOperand(0).getReg();
    unsigned FusedOpcode =
        getFusedOpcode(Divide->getOpcode(), Extract->getOpcode());

    MachineInstrBuilder Fused =
        BuildMI(*Divide->getParent(), Divide->getIterator(),
                Divide->getDebugLoc(), TII.get(FusedOpcode));
    Fused.add(Extract->getOperand(0));
    Fused.add(Divide->getOperand(1));
    Fused.add(Divide->getOperand(2));
    Fused.setMIFlags(Divide->getFlags());

    MRI.markUsesInDebugValueAsUndef(Accumulator);
    Extract->eraseFromParent();
    Divide->eraseFromParent();
  }

  return !Candidates.empty();
}

FunctionPass *llvm::createMipsR5900MinSizeDivRemPass() {
  return new MipsR5900MinSizeDivRem();
}

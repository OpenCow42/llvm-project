//===-- MipsTargetTransformInfo.cpp - Mips specific TTI ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MipsTargetTransformInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"

using namespace llvm;

// Count the unique shift/add/sub nodes produced by genConstMult. SelectionDAG
// common-subexpression elimination shares repeated decomposition nodes, so a
// worklist with a visited set matches the final R5900 expansion more closely
// than merely counting the constant's set bits.
static unsigned getR5900ConstantMultiplyCost(const APInt &Multiplier) {
  SmallVector<APInt, 16> Worklist(1, Multiplier);
  SmallVector<APInt, 16> Seen;
  unsigned Cost = 0;

  while (!Worklist.empty()) {
    APInt Value = Worklist.pop_back_val();
    if (Value == 0 || Value == 1 || is_contained(Seen, Value))
      continue;
    Seen.push_back(Value);
    ++Cost;

    if (Value.isPowerOf2())
      continue;

    unsigned BitWidth = Value.getBitWidth();
    APInt Floor = APInt(BitWidth, 1) << Value.logBase2();
    APInt Ceil = Value.isNegative()
                     ? APInt(BitWidth, 0)
                     : APInt(BitWidth, 1) << Value.ceilLogBase2();
    if ((Value - Floor).ule(Ceil - Value)) {
      Worklist.push_back(Floor);
      Worklist.push_back(Value - Floor);
    } else {
      Worklist.push_back(Ceil);
      Worklist.push_back(Ceil - Value);
    }
  }

  return Cost;
}

bool MipsTTIImpl::hasDivRemOp(Type *DataType, bool IsSigned) const {
  EVT VT = TLI->getValueType(DL, DataType);
  return TLI->isOperationLegalOrCustom(IsSigned ? ISD::SDIVREM : ISD::UDIVREM,
                                       VT);
}

InstructionCost MipsTTIImpl::getArithmeticInstrCost(
    unsigned Opcode, Type *Ty, TTI::TargetCostKind CostKind,
    TTI::OperandValueInfo Op1Info, TTI::OperandValueInfo Op2Info,
    ArrayRef<const Value *> Args, const Instruction *CxtI) const {
  if (ST->isR5900() && Opcode == Instruction::Mul && Ty->isIntegerTy(64) &&
      Args.size() == 2) {
    const auto *Multiplier = dyn_cast<ConstantInt>(Args[1]);
    if (!Multiplier)
      Multiplier = dyn_cast<ConstantInt>(Args[0]);
    if (Multiplier)
      return getR5900ConstantMultiplyCost(Multiplier->getValue());
  }

  return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Op1Info, Op2Info,
                                       Args, CxtI);
}

void MipsTTIImpl::getUnrollingPreferences(
    Loop *L, ScalarEvolution &SE, TTI::UnrollingPreferences &UP,
    OptimizationRemarkEmitter *ORE) const {
  BaseT::getUnrollingPreferences(L, SE, UP, ORE);
  if (!ST->isR5900())
    return;

  for (BasicBlock *BB : L->blocks()) {
    for (Instruction &I : *BB) {
      if (I.getOpcode() != Instruction::Mul || !I.getType()->isIntegerTy(64))
        continue;

      const auto *Multiplier = dyn_cast<ConstantInt>(I.getOperand(1));
      if (!Multiplier)
        Multiplier = dyn_cast<ConstantInt>(I.getOperand(0));
      if (Multiplier &&
          getR5900ConstantMultiplyCost(Multiplier->getValue()) > 2) {
        // Full unrolling duplicates the late SelectionDAG shift/add expansion.
        // Preserve profitable two- and three-iteration unrolling, but keep
        // longer loops rolled when each iteration contains a complex i64
        // constant multiply.
        UP.FullUnrollMaxCount = std::min(UP.FullUnrollMaxCount, 3U);
        return;
      }
    }
  }
}

bool MipsTTIImpl::isLSRCostLess(const TargetTransformInfo::LSRCost &C1,
                                const TargetTransformInfo::LSRCost &C2) const {
  // MIPS specific here are "instruction number 1st priority".
  // If we need to emit adds inside the loop to add up base registers, then
  // we need at least one extra temporary register.
  unsigned C1NumRegs = C1.NumRegs + (C1.NumBaseAdds != 0);
  unsigned C2NumRegs = C2.NumRegs + (C2.NumBaseAdds != 0);
  return std::tie(C1.Insns, C1NumRegs, C1.AddRecCost, C1.NumIVMuls,
                  C1.NumBaseAdds, C1.ScaleCost, C1.ImmCost, C1.SetupCost) <
         std::tie(C2.Insns, C2NumRegs, C2.AddRecCost, C2.NumIVMuls,
                  C2.NumBaseAdds, C2.ScaleCost, C2.ImmCost, C2.SetupCost);
}

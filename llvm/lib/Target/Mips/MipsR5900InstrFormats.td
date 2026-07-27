//===- MipsR5900InstrFormats.td - R5900 Instruction Formats -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the instruction formats used by the R5900 MMI.
//
//===----------------------------------------------------------------------===//

// R5900 MMI0 format:
// | 31-26  | 25-21 | 20-16 | 15-11 | 10-6  | 5-0    |
// | MMI    | rs    | rt    | rd    | subfn | MMI0   |
// | 011100 | rs    | rt    | rd    | subfn | 001000 |
class R5900_MMI0_FM<bits<5> subfn> : StdArch {
  bits<5> rd;
  bits<5> rs;
  bits<5> rt;
  bits<32> Inst;

  let Inst{31-26} = 0b011100;
  let Inst{25-21} = rs;
  let Inst{20-16} = rt;
  let Inst{15-11} = rd;
  let Inst{10-6} = subfn;
  let Inst{5-0} = 0b001000;
}

// R5900 MMI1 format:
// | 31-26  | 25-21 | 20-16 | 15-11 | 10-6  | 5-0    |
// | MMI    | rs    | rt    | rd    | subfn | MMI1   |
// | 011100 | rs    | rt    | rd    | subfn | 101000 |
class R5900_MMI1_FM<bits<5> subfn> : StdArch {
  bits<5> rd;
  bits<5> rs;
  bits<5> rt;
  bits<32> Inst;

  let Inst{31-26} = 0b011100;
  let Inst{25-21} = rs;
  let Inst{20-16} = rt;
  let Inst{15-11} = rd;
  let Inst{10-6} = subfn;
  let Inst{5-0} = 0b101000;
}

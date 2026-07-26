//===--- PS2.h - PlayStation 2 toolchain ------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_PS2_H
#define LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_PS2_H

#include "Gnu.h"

namespace clang {
namespace driver {

namespace toolchains {

class LLVM_LIBRARY_VISIBILITY PS2 : public Generic_ELF {
public:
  PS2(const Driver &D, const llvm::Triple &Triple,
      const llvm::opt::ArgList &Args);

  bool isBareMetal() const override { return true; }
  bool isCrossCompiling() const override { return true; }
  bool isPICDefault() const override { return false; }
  bool isPIEDefault(const llvm::opt::ArgList &) const override { return false; }
  bool isPICDefaultForced() const override { return false; }
  bool IsIntegratedAssemblerDefault() const override { return true; }
  bool SupportsProfiling() const override { return false; }

  RuntimeLibType GetDefaultRuntimeLibType() const override {
    return ToolChain::RLT_Libgcc;
  }

  UnwindTableLevel
  getDefaultUnwindTableLevel(const llvm::opt::ArgList &) const override {
    return UnwindTableLevel::None;
  }

  void AddClangSystemIncludeArgs(
      const llvm::opt::ArgList &DriverArgs,
      llvm::opt::ArgStringList &CC1Args) const override;

  void addClangTargetOptions(const llvm::opt::ArgList &DriverArgs,
                             llvm::opt::ArgStringList &CC1Args,
                             Action::OffloadKind DeviceOffloadKind) const override;

  std::string computeSysRoot() const override { return PS2Root; }
  std::string getGCCPath() const;
  std::string getPS2SDKPath() const;

protected:
  Tool *buildLinker() const override;

private:
  std::string PS2Root;
};

} // namespace toolchains

namespace tools {
namespace ps2 {

class LLVM_LIBRARY_VISIBILITY Linker final : public Tool {
public:
  explicit Linker(const ToolChain &TC) : Tool("ps2::Linker", "linker", TC) {}

  bool hasIntegratedCPP() const override { return false; }
  bool isLinkJob() const override { return true; }

  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &Args,
                    const char *LinkingOutput) const override;
};

} // namespace ps2
} // namespace tools

} // namespace driver
} // namespace clang

#endif

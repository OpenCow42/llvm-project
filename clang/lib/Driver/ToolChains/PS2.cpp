//===--- PS2.cpp - PlayStation 2 toolchain ----------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "PS2.h"

#include "clang/Basic/DiagnosticDriver.h"
#include "clang/Driver/CommonArgs.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/InputInfo.h"
#include "clang/Options/Options.h"
#include "llvm/Option/ArgList.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/Process.h"
#include "llvm/Support/VirtualFileSystem.h"

using namespace clang;
using namespace clang::driver;
using namespace clang::driver::toolchains;
using namespace llvm::opt;

static constexpr llvm::StringLiteral PS2GCCName =
    "mips64r5900el-ps2-elf-gcc";

static bool isEnabledPICOption(const Arg *A) {
  if (!A)
    return false;
  const Option &O = A->getOption();
  return O.matches(options::OPT_fPIC) || O.matches(options::OPT_fpic) ||
         O.matches(options::OPT_fPIE) || O.matches(options::OPT_fpie);
}

PS2::PS2(const Driver &D, const llvm::Triple &Triple, const ArgList &Args)
    : Generic_ELF(D, Triple, Args) {
  if (!D.SysRoot.empty())
    PS2Root = D.SysRoot;
  else if (std::optional<std::string> Env = llvm::sys::Process::GetEnv("PS2DEV"))
    PS2Root = *Env;

  if (!PS2Root.empty()) {
    SmallString<128> Bin(PS2Root);
    llvm::sys::path::append(Bin, "ee", "bin");
    getProgramPaths().insert(getProgramPaths().begin(), std::string(Bin));
  }

  auto Diagnose = [&](const Arg *A) {
    if (A)
      D.Diag(diag::err_drv_unsupported_opt_for_target)
          << A->getAsString(Args) << Triple.str();
  };

  llvm::Triple RequestedTriple(D.getTargetTriple());
  if (RequestedTriple.isPS2() && Triple.getArch() == llvm::Triple::mips64) {
    D.Diag(diag::err_drv_unsupported_opt_for_target)
        << "-EB" << RequestedTriple.str();
  } else if (Triple.getArch() != llvm::Triple::mips64el ||
             Triple.getVendor() != llvm::Triple::SCEI) {
    D.Diag(diag::err_drv_unsupported_opt_for_target)
        << Triple.str() << "mips64el-scei-ps2";
  }

  if (const Arg *A =
          Args.getLastArg(options::OPT_march_EQ, options::OPT_mcpu_EQ))
    if (StringRef(A->getValue()) != "r5900")
      Diagnose(A);

  if (const Arg *A = Args.getLastArg(options::OPT_mabi_EQ))
    if (StringRef(A->getValue()) != "n32")
      Diagnose(A);

  Diagnose(Args.getLastArg(options::OPT_msoft_float));
  Diagnose(Args.getLastArg(options::OPT_mdouble_float));
  Diagnose(Args.getLastArg(options::OPT_shared));
  Diagnose(Args.getLastArg(options::OPT_pie));
  Diagnose(Args.getLastArg(options::OPT_static_pie));
  Diagnose(Args.getLastArg(options::OPT_dynamic));

  if (Arg *A = Args.getLastArg(options::OPT_fPIC, options::OPT_fno_PIC,
                               options::OPT_fpic, options::OPT_fno_pic,
                               options::OPT_fPIE, options::OPT_fno_PIE,
                               options::OPT_fpie, options::OPT_fno_pie))
    if (isEnabledPICOption(A))
      Diagnose(A);

  if (const Arg *A = Args.getLastArg(options::OPT_G))
    if (StringRef(A->getValue()) != "0")
      Diagnose(A);
}

void PS2::AddClangSystemIncludeArgs(const ArgList &DriverArgs,
                                    ArgStringList &CC1Args) const {
  if (DriverArgs.hasArg(options::OPT_nostdinc))
    return;

  const Driver &D = getDriver();
  if (!DriverArgs.hasArg(options::OPT_nobuiltininc)) {
    SmallString<128> ResourceDir(D.ResourceDir);
    llvm::sys::path::append(ResourceDir, "include");
    addSystemInclude(DriverArgs, CC1Args, ResourceDir);
  }

  if (DriverArgs.hasArg(options::OPT_nostdlibinc) || PS2Root.empty())
    return;

  auto AddIfPresent = [&](ArrayRef<StringRef> Components) {
    SmallString<128> Path(PS2Root);
    for (StringRef Component : Components)
      llvm::sys::path::append(Path, Component);
    if (getVFS().exists(Path))
      addExternCSystemInclude(DriverArgs, CC1Args, Path);
  };

  AddIfPresent({"ee", "mips64r5900el-ps2-elf", "include"});
  AddIfPresent({"ee", "include"});
  AddIfPresent({"ps2sdk", "ee", "include"});
  AddIfPresent({"ps2sdk", "common", "include"});
}

void PS2::addClangTargetOptions(const ArgList &DriverArgs,
                                ArgStringList &CC1Args,
                                Action::OffloadKind DeviceOffloadKind) const {
  Generic_ELF::addClangTargetOptions(DriverArgs, CC1Args, DeviceOffloadKind);
  CC1Args.push_back("-nostdsysteminc");

  if (!DriverArgs.hasArg(options::OPT_G)) {
    CC1Args.push_back("-mllvm");
    CC1Args.push_back("-mips-ssection-threshold=0");
  }
}

std::string PS2::getGCCPath() const {
  if (!PS2Root.empty()) {
    SmallString<128> GCC(PS2Root);
    llvm::sys::path::append(GCC, "ee", "bin", PS2GCCName);
    if (getVFS().exists(GCC))
      return std::string(GCC);
  }
  return GetProgramPath(PS2GCCName.data());
}

std::string PS2::getPS2SDKPath() const {
  SmallString<128> SDK(PS2Root);
  llvm::sys::path::append(SDK, "ps2sdk");
  return std::string(SDK);
}

Tool *PS2::buildLinker() const { return new tools::ps2::Linker(*this); }

static bool forwardToPS2GCC(const Option &O) {
  if (O.hasFlag(options::LinkerInput))
    return false;
  if (O.matches(options::OPT__sysroot_EQ))
    return false;
  return O.matches(options::OPT_Link_Group) || O.hasFlag(options::LinkOption);
}

static void addPS2GCCInputs(const ToolChain &TC, const InputInfoList &Inputs,
                            const ArgList &Args, ArgStringList &CmdArgs,
                            const JobAction &JA) {
  const Driver &D = TC.getDriver();

  // These linker inputs are produced by translated -Xarch_ arguments rather
  // than represented in Inputs.
  for (const Arg *A : Args.filtered(options::OPT_Zlinker_input))
    CmdArgs.push_back(
        Args.MakeArgString(Twine("-Wl,") + StringRef(A->getValue())));

  for (const InputInfo &II : Inputs) {
    if (auto *IA = II.getAction())
      if (JA.isHostOffloading(Action::OFK_OpenMP) &&
          IA->isDeviceOffloading(Action::OFK_OpenMP))
        continue;

    if (!TC.HasNativeLLVMSupport() && types::isLLVMIR(II.getType()))
      D.Diag(diag::err_drv_no_linker_llvm_support) << TC.getTripleString();

    if (II.isFilename()) {
      CmdArgs.push_back(II.getFilename());
      continue;
    }
    if (II.isNothing())
      continue;

    const Arg &A = II.getInputArg();
    if (A.getOption().matches(options::OPT_Z_reserved_lib_stdcxx)) {
      TC.AddCXXStdlibLibArgs(Args, CmdArgs);
    } else if (A.getOption().matches(options::OPT_Z_reserved_lib_cckext)) {
      TC.AddCCKextLibArgs(Args, CmdArgs);
    } else if (A.getOption().matches(options::OPT_Wl_COMMA) ||
               A.getOption().matches(options::OPT_Xlinker)) {
      // The PS2 final link is performed by GCC, not by ld directly. Preserve
      // the driver boundary for options such as -Map and --gc-sections.
      for (StringRef Value : A.getValues())
        CmdArgs.push_back(Args.MakeArgString(Twine("-Wl,") + Value));
    } else {
      A.renderAsInput(Args, CmdArgs);
    }
  }
}

void tools::ps2::Linker::ConstructJob(
    Compilation &C, const JobAction &JA, const InputInfo &Output,
    const InputInfoList &Inputs, const ArgList &Args,
    const char *LinkingOutput) const {
  const auto &TC = static_cast<const toolchains::PS2 &>(getToolChain());
  ArgStringList CmdArgs;

  for (const Arg *A : Args) {
    if (forwardToPS2GCC(A->getOption())) {
      A->claim();
      if (A->getOption().matches(options::OPT_Wl_COMMA)) {
        for (StringRef Value : A->getValues())
          CmdArgs.push_back(Args.MakeArgString(Twine("-Wl,") + Value));
      } else {
        A->render(Args, CmdArgs);
      }
    }
  }

  CmdArgs.push_back("-static");
  CmdArgs.push_back("-G0");

  if (!TC.computeSysRoot().empty()) {
    SmallString<128> LinkerScript(TC.getPS2SDKPath());
    llvm::sys::path::append(LinkerScript, "ee", "startup", "linkfile");
    CmdArgs.push_back(
        Args.MakeArgString(Twine("-T") + StringRef(LinkerScript)));

    SmallString<128> LibraryPath(TC.getPS2SDKPath());
    llvm::sys::path::append(LibraryPath, "ee", "lib");
    CmdArgs.push_back(
        Args.MakeArgString(Twine("-L") + StringRef(LibraryPath)));
    CmdArgs.push_back("-Wl,-zmax-page-size=128");
  }

  addPS2GCCInputs(TC, Inputs, Args, CmdArgs, JA);

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  const char *Exec = Args.MakeArgString(TC.getGCCPath());
  C.addCommand(std::make_unique<Command>(
      JA, *this, ResponseFileSupport::AtFileCurCP(), Exec, CmdArgs, Inputs,
      Output));
}

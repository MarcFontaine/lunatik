{ lib
, fetchFromGitHub
, stdenv
, kernelPackages
, lua5_4
}:
let
  kernel = kernelPackages.kernel;
in
stdenv.mkDerivation rec {
  pname = "lunatik-linux-module";
  version = "nix-unstable";

  src = fetchFromGitHub {
    owner = "MarcFontaine";
    repo = "lunatik";
    rev = "dc54816bba9c11c00f2044678e4f96a158d03299";
    hash = "sha256-kdO9GwbqRz0vbuYskKeeE7PbI4TmlRhmIa47Cb32Uho=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  passthru = {
    kernel-version = kernel.version;
  };

  setSourceRoot = ''
    export sourceRoot=$(pwd)/source
  '';

  patchPhase = "patchShebangs gensymbols.sh bin/lunatik";

  makeFlags = kernelPackages.kernelModuleMakeFlags ++ [
    "MODULES_BUILD_PATH=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "PWD=/build/source"
    "INSTALL=install"
    "MODULES_INSTALL_PATH=${placeholder "out"}/lib/modules/${kernel.modDirVersion}/kernel/lunatik"
    "SCRIPTS_INSTALL_PATH=${placeholder "out"}/scripts"
    "LUNATIK_INSTALL_PATH=${placeholder "out"}/"
  ];

  buildFlags = [ "all" ];
  installTargets = [
    "modules_install"
    "scripts_install"
    "examples_install"
    "tests_install"
  ];
  
  meta = with lib; {
    description = "Lua in kernel";
    platforms = platforms.linux;
  };
}

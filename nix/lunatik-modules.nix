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

#  src = fetchFromGitHub {
#    owner = "MarcFontaine";
#    repo = "lunatik";
#    rev = "32409b2c848306e9c606b08c790b8109336d544b";
#    hash = "sha256-8roDITTTK8rqvjCN0wc/xJw28FY55UZhapDGs93NFFs=";
#    fetchSubmodules = true;
#    name = "lunatik";
#  };

  src = builtins.path {
    path = /v/lunatik;
    name = "lunatik";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  passthru = {
    kernel-version = kernel.version;
  };

  setSourceRoot = ''
    export sourceRoot=$(pwd)/lunatik
  '';

  patchPhase = "patchShebangs gensymbols.sh bin/lunatik";

  makeFlags = kernelPackages.kernelModuleMakeFlags ++ [
    "MODULES_BUILD_PATH=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "PWD=/build/lunatik" # todo: fix
    "INSTALL=install"
    "MODULES_INSTALL_PATH=${placeholder "out"}/lib/modules/${kernel.modDirVersion}/kernel"
    "SCRIPTS_INSTALL_PATH=${placeholder "out"}/lib/modules/${kernel.modDirVersion}/lua"
    "LUNATIK_INSTALL_PATH=${placeholder "out"}/bin"
    "LUNATIK_ROOT=/run/current-system/kernel-modules/lib/modules/6.10.0-rc4/${kernel.modDirVersion}/"
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

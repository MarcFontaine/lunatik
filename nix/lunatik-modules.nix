{ self
, lib
, fetchFromGitHub
, stdenv
, kernelPackages
, lua5_4
}:
let
  kernel = kernelPackages.kernel;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lunatik-linux-module";
  version = "nix-unstable";

  src = self;

#  src = builtins.fetchGit {
#    url = ./.;
#    submodules = true;
#  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  passthru = {
    kernel-version = kernel.version;
  };

#  setSourceRoot = ''
#    export sourceRoot=$(pwd)/source
#  '';

  patchPhase = "patchShebangs gensymbols.sh bin/lunatik";

  makeFlags = kernelPackages.kernelModuleMakeFlags ++ [
    "MODULES_BUILD_PATH=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "PWD=/build/source" # todo: fix
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
})

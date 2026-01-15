{
  description = "Luntic";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=25.11";
    self.submodules = true;
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
    in
    {    
    packages.x86_64-linux.lunatik = pkgs.callPackage ./nix/lunatik-modules.nix {
      inherit self;
      kernelPackages = pkgs.linuxPackages_6_12;
    };

    packages.x86_64-linux.default = self.packages.x86_64-linux.lunatik;

  };
}

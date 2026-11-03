{
  description = "Original vpsFree PhotoShow gallery on PHP 8.5";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let pkgs = import nixpkgs { system = "x86_64-linux"; }; in {
      default = import ./photoshow/package.nix { inherit pkgs; };
      php = import ./photoshow/runtime.nix { inherit pkgs; };
      tools = import ./photoshow/tools.nix { inherit pkgs; };
    };
    nixosModules.default = import ./nixos/gallery.nix;
  };
}

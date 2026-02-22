{ self, pkgs }:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  mkCheck = file: import file { inherit self pkgs; };
in
{
  nixfmt = mkCheck ./nixfmt.nix;
  statix = mkCheck ./statix.nix;
  deadnix = mkCheck ./deadnix.nix;
}
// pkgs.lib.optionalAttrs isLinux {
  navi-scripts = mkCheck ./navi-scripts.nix;
  ssh-hardening = mkCheck ./ssh-hardening.nix;
  firewall = mkCheck ./firewall.nix;
  nfs-mount = mkCheck ./nfs-mount.nix;
  clamav = mkCheck ./clamav.nix;
}

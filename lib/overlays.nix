{ self }:
final: _prev: {
  navi-scripts = final.callPackage (self + /packages/navi-scripts/package.nix) { };
}

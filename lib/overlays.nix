{ inputs, self }:
[
  inputs.niri.overlays.niri
  inputs.slippi.overlays.default
  (final: _prev: {
    navi-scripts = final.callPackage (self + /packages/navi-scripts/package.nix) { };
  })
]

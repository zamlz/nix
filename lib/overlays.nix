{ inputs, self }:
[
  inputs.niri.overlays.niri
  inputs.slippi.overlays.default
  (final: _prev: {
    navi-scripts = final.callPackage (self + /packages/navi-scripts/package.nix) { };
    caddy-with-cloudflare = final.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.3" ];
      hash = "sha256-mmkziFzEMBcdnCWCRiT3UyWPNbINbpd3KUJ0NMW632w=";
    };
  })
]

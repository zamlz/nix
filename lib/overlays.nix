{ inputs, self }:
[
  inputs.niri.overlays.niri
  inputs.slippi.overlays.default
  (final: _prev: {
    navi-scripts = final.callPackage (self + /packages/navi-scripts/package.nix) { };
    caddy-with-cloudflare = final.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.3" ];
      hash = "sha256-bJO2RIa6hYsoVl3y2L86EM34Dfkm2tlcEsXn2+COgzo=";
    };
  })
]

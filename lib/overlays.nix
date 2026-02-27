{ inputs, self }:
[
  inputs.niri.overlays.niri
  inputs.slippi.overlays.default
  (final: _prev: {
    navi-scripts = final.callPackage (self + /packages/navi-scripts/package.nix) { };
    caddy-with-cloudflare = final.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e" ];
      hash = "sha256-qFJsoubtQPllBcWqyRgJj1oN9X6u4L+9j1i+uMDiDlw=";
    };
  })
]

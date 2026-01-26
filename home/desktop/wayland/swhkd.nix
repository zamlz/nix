{
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    inputs.swhkd.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

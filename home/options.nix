{ lib, ... }:
{
  options.my = {
    fontScale = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Font scaling factor for terminal emulators and other applications";
    };
  };
}

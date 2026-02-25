{ inputs, config, ... }:
{
  imports = [ inputs.slippi.homeManagerModules.default ];

  slippi-launcher = {
    enable = true;
    isoPath = "${config.home.homeDirectory}/usr/media/roms/gamecube/Super Smash Bros Melee (2001).iso";
    launchMeleeOnPlay = true;
    enableJukebox = true;
  };
}

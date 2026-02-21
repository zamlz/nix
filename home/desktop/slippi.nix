{ inputs, ... }:
{
  imports = [ inputs.slippi.homeManagerModules.default ];

  slippi-launcher = {
    enable = true;
    # TODO: Set this to the path of your NTSC Melee ISO
    isoPath = "";
    launchMeleeOnPlay = true;
    enableJukebox = true;
  };
}

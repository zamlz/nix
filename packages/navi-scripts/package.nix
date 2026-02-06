{
  python3Packages,
  makeWrapper,
  lib,
  ty,
  ruff,
  # Runtime dependencies for the CLI tools
  fzf,
  fd,
  ripgrep,
  bat,
  tree,
  mediainfo,
  wmctrl,
  xdotool,
  alacritty,
  lazygit,
  xclip,
  qrencode,
  imagemagick,
  feh,
  i3lock,
  swaylock,
  pass,
  coreutils,
  gnugrep,
  gawk,
  git,
  man,
}:

python3Packages.buildPythonApplication {
  pname = "navi-scripts";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = [ python3Packages.setuptools ];

  dependencies = [ python3Packages.loguru ];

  nativeCheckInputs = [
    python3Packages.pytest
    python3Packages.pytest-cov
    ty
    ruff
  ];

  checkPhase = ''
    runHook preCheck
    ty check src/ tests/
    ruff check src/ tests/
    pytest
    runHook postCheck
  '';

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    chmod +x $out/lib/python*/site-packages/navi/data/*.sh
  '';

  postFixup = ''
    for bin in $out/bin/navi-*; do
      wrapProgram "$bin" \
        --prefix PATH : ${
          lib.makeBinPath [
            fzf
            fd
            ripgrep
            bat
            tree
            mediainfo
            wmctrl
            xdotool
            alacritty
            lazygit
            xclip
            qrencode
            imagemagick
            feh
            i3lock
            swaylock
            pass
            coreutils
            gnugrep
            gawk
            git
            man
          ]
        }
    done
  '';

  meta = {
    description = "Personal CLI scripts for system management";
    mainProgram = "navi-launcher";
    platforms = lib.platforms.linux;
  };
}

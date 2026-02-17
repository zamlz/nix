{
  python3Packages,
  lib,
  ty,
  ruff,
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

  postInstall = ''
    chmod +x $out/lib/python*/site-packages/navi/data/*.sh
  '';

  meta = {
    description = "Personal CLI scripts for system management";
    mainProgram = "navi-launcher";
    platforms = lib.platforms.linux;
  };
}

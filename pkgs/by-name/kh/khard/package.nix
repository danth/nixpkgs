{
  lib,
  python3,
  fetchPypi,
  khard,
  testers,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "khard";
  version = "0.19.1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WfMKDaPD2j6wT02+GO5HY5E7aF2Z7IQY/VdKiMSRxJA=";
  };

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
    sphinxHook
    sphinx-autoapi
    sphinx-autodoc-typehints
  ];

  sphinxBuilders = [ "man" ];

  dependencies = with python3.pkgs; [
    atomicwrites
    configobj
    ruamel-yaml
    unidecode
    vobject
  ];

  postInstall = ''
    install -D misc/zsh/_khard $out/share/zsh/site-functions/_khard
  '';

  preCheck = ''
    # see https://github.com/scheibler/khard/issues/263
    export COLUMNS=80
  '';

  pythonImportsCheck = [ "khard" ];

  passthru.tests.version = testers.testVersion { package = khard; };

  meta = {
    homepage = "https://github.com/scheibler/khard";
    description = "Console carddav client";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "khard";
  };
}

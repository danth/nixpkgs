{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  python3,
  libxcb,
}:

rustPlatform.buildRustPackage rec {
  pname = "kbs2";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = "kbs2";
    rev = "v${version}";
    hash = "sha256-o8/ENAWzVqs7rokST6xnyu9Q/pKqq/UnKWOFRuIuGes=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-+TJ/QG+6ZILcSZEIXj6B4qYF0P5pQpo1kw2qEfE0FDw=";

  nativeBuildInputs = [ installShellFiles ] ++ lib.optionals stdenv.hostPlatform.isLinux [ python3 ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libxcb ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  checkFlags = [
    "--skip=kbs2::config::tests::test_find_config_dir"
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ "--skip=test_ragelib_rewrap_keyfile" ];

  postInstall =
    ''
      mkdir -p $out/share/kbs2
      cp -r contrib/ $out/share/kbs2
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd kbs2 \
        --bash <($out/bin/kbs2 --completions bash) \
        --fish <($out/bin/kbs2 --completions fish) \
        --zsh <($out/bin/kbs2 --completions zsh)
    '';

  meta = with lib; {
    description = "Secret manager backed by age";
    mainProgram = "kbs2";
    homepage = "https://github.com/woodruffw/kbs2";
    changelog = "https://github.com/woodruffw/kbs2/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ ];
  };
}

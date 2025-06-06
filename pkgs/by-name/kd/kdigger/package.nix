{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "kdigger";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "quarkslab";
    repo = "kdigger";
    rev = "v${version}";
    hash = "sha256-hpLhtTENtOBQjm+CZRAcx1BG9831JUFIsLL57wZIrso=";
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };
  vendorHash = "sha256-kMoTkrDuAJmgWAj7+V3a8VEYpPbTv3UdLscTdkpzud0=";

  nativeBuildInputs = [ installShellFiles ];

  # static to be easily copied into containers since it's an in-pod pen-testing tool
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/quarkslab/kdigger/commands.VERSION=v${version}"
    "-X github.com/quarkslab/kdigger/commands.BUILDERARCH=${stdenv.hostPlatform.linuxArch}"
  ];

  preBuild = ''
    ldflags+=" -X github.com/quarkslab/kdigger/commands.GITCOMMIT=$(cat COMMIT)"
  '';

  postInstall = ''
    installShellCompletion --cmd kdigger \
      --bash <($out/bin/kdigger completion bash) \
      --fish <($out/bin/kdigger completion fish) \
      --zsh <($out/bin/kdigger completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/kdigger --help

    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/quarkslab/kdigger";
    changelog = "https://github.com/quarkslab/kdigger/releases/tag/v${version}";
    description = "In-pod context discovery tool for Kubernetes penetration testing";
    mainProgram = "kdigger";
    longDescription = ''
      kdigger, short for "Kubernetes digger", is a context discovery tool for
      Kubernetes penetration testing. This tool is a compilation of various
      plugins called buckets to facilitate pentesting Kubernetes from inside a
      pod.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
    ];
  };
}

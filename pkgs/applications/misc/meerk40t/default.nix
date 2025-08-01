{
  lib,
  fetchFromGitHub,
  meerk40t-camera,
  python3Packages,
  gtk3,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication rec {
  pname = "MeerK40t";
  version = "0.9.7051";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "meerk40t";
    repo = pname;
    tag = version;
    hash = "sha256-v3lwFl4Qls+NzR2rYwNF8PyFTH0nNcLlF/uwc0h3Pc0=";
  };

  nativeBuildInputs =
    [
      wrapGAppsHook3
    ]
    ++ (with python3Packages; [
      setuptools
    ]);

  # prevent double wrapping
  dontWrapGApps = true;

  # https://github.com/meerk40t/meerk40t/blob/main/setup.py
  propagatedBuildInputs =
    with python3Packages;
    [
      meerk40t-camera
      numpy
      pyserial
      pyusb
      setuptools
      wxpython
    ]
    ++ lib.flatten (lib.attrValues optional-dependencies);

  optional-dependencies = with python3Packages; {
    cam = [
      opencv4
    ];
    camhead = [
      opencv4
    ];
    dxf = [
      ezdxf
    ];
    gui = [
      wxpython
      pillow
      opencv4
      ezdxf
    ];
  };

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
    )
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  nativeCheckInputs = with python3Packages; [
    unittestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  meta = with lib; {
    changelog = "https://github.com/meerk40t/meerk40t/releases/tag/${src.tag}";
    description = "MeerK40t LaserCutter Software";
    mainProgram = "meerk40t";
    homepage = "https://github.com/meerk40t/meerk40t";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}

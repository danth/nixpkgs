{
  lib,
  aiolifx,
  async-timeout,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "aiolifx-themes";
  version = "1.0.0";
  pyproject = true;

  disabled = pythonOlder "3.12";

  src = fetchFromGitHub {
    owner = "Djelibeybi";
    repo = "aiolifx-themes";
    tag = "v${version}";
    hash = "sha256-02ciRYc5aQ1nES/uctKUWwyBM9dO0hZ5OEWC5MT4Nuo=";
  };

  build-system = [ poetry-core ];

  dependencies = [ aiolifx ];

  nativeCheckInputs = [
    async-timeout
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  pythonImportsCheck = [ "aiolifx_themes" ];

  meta = with lib; {
    description = "Color themes for LIFX lights running on aiolifx";
    homepage = "https://github.com/Djelibeybi/aiolifx-themes";
    changelog = "https://github.com/Djelibeybi/aiolifx-themes/releases/tag/${src.tag}";
    license = licenses.mit;
    maintainers = with maintainers; [ lukegb ];
  };
}

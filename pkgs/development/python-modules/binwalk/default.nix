{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  stdenv,
  zlib,
  xz,
  gzip,
  bzip2,
  gnutar,
  p7zip,
  cabextract,
  cramfsprogs,
  cramfsswap,
  sasquatch,
  setuptools,
  squashfsTools,
  matplotlib,
  pycrypto,
  pyqtgraph,
  pyqt5,
  pytestCheckHook,
  yaffshiv,
  visualizationSupport ? false,
}:

buildPythonPackage rec {
  pname = "binwalk${lib.optionalString visualizationSupport "-full"}";
  version = "2.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "OSPG";
    repo = "binwalk";
    rev = "refs/tags/v${version}";
    hash = "sha256-kabibUMh5HyAJCXOyZo3QSNIVz8fER4Xivuv9E3CfEE=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs =
    [
      zlib
      xz
      gzip
      bzip2
      gnutar
      p7zip
      cabextract
      squashfsTools
      xz
      pycrypto
      yaffshiv
    ]
    ++ lib.optionals visualizationSupport [
      matplotlib
      pyqtgraph
      pyqt5
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      cramfsprogs
      cramfsswap
      sasquatch
    ];

  # setup.py only installs version.py during install, not test
  postPatch = ''
    echo '__version__ = "${version}"' > src/binwalk/core/version.py
  '';

  # binwalk wants to access ~/.config/binwalk/magic
  preCheck = ''
    HOME=$(mktemp -d)
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "binwalk" ];

  meta = with lib; {
    homepage = "https://github.com/OSPG/binwalk";
    description = "Tool for searching a given binary image for embedded files";
    mainProgram = "binwalk";
    maintainers = [ maintainers.koral ];
    license = licenses.mit;
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  pythonOlder,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  matplotlib,
  numpy,
  packaging,
  torch,
  tqdm,
  flask,
  flask-compress,
}:

buildPythonPackage rec {
  pname = "captum";
  version = "0.7.0";
  pyproject = true;

  build-system = [ setuptools ];

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "captum";
    rev = "refs/tags/v${version}";
    hash = "sha256-1VOvPqxn6CNnmv7M8fl7JrqRfJQUH2tnXRCUqKnl7i0=";
  };

  dependencies = [
    matplotlib
    numpy
    packaging
    torch
    tqdm
  ];

  pythonImportsCheck = [ "captum" ];

  nativeCheckInputs = [
    pytestCheckHook
    flask
    flask-compress
  ];

  disabledTestPaths =
    [
      # These tests requires `parametrized` module (https://pypi.org/project/parametrized/) which seem to be unavailable on Nix.
      "tests/attr/test_dataloader_attr.py"
      "tests/attr/test_interpretable_input.py"
      "tests/attr/test_llm_attr.py"
      "tests/influence/_core/test_dataloader.py"
      "tests/influence/_core/test_tracin_aggregate_influence.py"
      "tests/influence/_core/test_tracin_intermediate_quantities.py"
      "tests/influence/_core/test_tracin_k_most_influential.py"
      "tests/influence/_core/test_tracin_regression.py"
      "tests/influence/_core/test_tracin_self_influence.py"
      "tests/influence/_core/test_tracin_show_progress.py"
      "tests/influence/_core/test_tracin_validation.py"
      "tests/influence/_core/test_tracin_xor.py"
      "tests/insights/test_contribution.py"
      "tests/module/test_binary_concrete_stochastic_gates.py"
      "tests/module/test_gaussian_stochastic_gates.py"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # These tests are failing on macOS:
      # > E   AttributeError: module 'torch.distributed' has no attribute 'init_process_group'
      "tests/attr/test_data_parallel.py"
    ];

  disabledTests =
    [
      # Failing tests
      "test_softmax_classification_batch_multi_target"
      "test_softmax_classification_batch_zero_baseline"
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
      # Failing tests: AssertionError: 1.0 != 0.5 within 0.0001 delta (0.5 difference)
      "test_TCAV_0_0"
      "test_TCAV_0_1"
      "test_TCAV_0_1_attr_to_inputs"
      "test_TCAV_1_0_1"
      "test_TCAV_1_0_b"
      "test_TCAV_1_1_a"
      "test_TCAV_1_1_a_wo_acc_metric"
      "test_TCAV_1_1_b"
      "test_TCAV_1_1_c"
      "test_TCAV_1_1_d"
      "test_TCAV_x_1_0_1"
      "test_TCAV_x_1_0_1_attr_to_inputs"
      "test_TCAV_x_1_0_1_w_flipped_class_id"
      "test_TCAV_x_1_0_a"
      "test_TCAV_x_1_0_b"
      "test_TCAV_x_1_1_a"
      "test_TCAV_x_1_1_b"
      "test_TCAV_x_1_1_c"
      "test_TCAV_x_1_1_c_concept_order_changed"
      "test_TCAV_x_1_1_"
    ];

  meta = {
    description = "Model interpretability and understanding for PyTorch";
    homepage = "https://github.com/pytorch/captum";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ drupol ];
  };
}

final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (_: pythonPrev:
        final.lib.optionalAttrs (final.config.cudaSupport or false) {
          # CUDAExtension caches CUDA_HOME when torch.utils.cpp_extension is imported. Point that cached value at the
          # merged CUDA toolkit so it can discover the headers and runtime libraries.
          torchvision = pythonPrev.torchvision.overridePythonAttrs (oldAttrs: {
            postPatch =
              (oldAttrs.postPatch or "")
              + ''
                substituteInPlace setup.py \
                  --replace-fail \
                  'from torch.utils.cpp_extension import BuildExtension, CppExtension, CUDA_HOME, CUDAExtension, ROCM_HOME' \
                  $'from torch.utils.cpp_extension import BuildExtension, CppExtension, CUDA_HOME, CUDAExtension, ROCM_HOME\n\nimport torch.utils.cpp_extension as cpp_extension\ncpp_extension.CUDA_HOME = "${final.cudaPackages.cudatoolkit}"\nCUDA_HOME = cpp_extension.CUDA_HOME'
              '';
          });
        })
    ];
}

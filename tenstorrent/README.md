# Using Tenstorrent accelerator on Daisytuner runners

## Metal

The examples are taken from the programming examples of [tt-metal](https://github.com/tenstorrent/tt-metal/tree/main/tt_metal/programming_examples), but transformed into standalone CMake projects that use the provided runtime. 

This uses the `libtt_metal.so` directly to run low level kernels. Taken from programming example and refactored into a standalone project, removing any dependency on the build-time dependencies of the runtime itself.

### Prerequisites

To compile locally, tt-metal must be available with the ENV-var `TT_METAL_INSTALL_DIR` pointing to the directory under which the collected headers (`/include`) and libraries (`/lib`) are available. This can be the build-directory of the tt-metal git or a locally installed distribition.

It was tested against v0.58.0 of tt-metal.

During runtime, the tt-metal library will look for the ENV-var `TT_METAL_HOME` to point to a directory including all the runtime dependencies (object files, headers, compilers, target architecture definitions) to build the actual kernels. This can also be the full git directly (as in the tt-metal installation guide) or the provided distribution

### Daisytuner Workflows

Our runners provide a runtime pointed to by `TT_METAL_INSTALL_DIR` and `TT_METAL_INSTALL_HOME` respectively. To use the runtime for executions, only `TT_METAL_HOME` must be set to `$TT_METAL_INSTALL_HOME`. This is not done by default as other tenstorrent parts, like ttnn would also pick it up and attempt to replace the builtin runtime with the provided one. Sadly, the installed runtime is not yet ready for ttnn and missing dependencies.

Example: [test_metal.yml](.daisy/test_metal.yml)

Note: the examples use a relative path to the kernel-sources, which are only compiled at runtime. Thus, the working directory must be matched for the provided examples to find the kernel-sources.

## ttnn

A python / pytorch-based example following [the matrix multiplcation tutorial](https://docs.tenstorrent.com/tt-metal/latest/ttnn/ttnn/tutorials/ttnn_tutorials/002.html).

It uses a python-ttnn distribution similar to the one already available from tenstorrent directly as [docker image](https://github.com/orgs/tenstorrent/packages?q=tt-metalium-ubuntu&amp;tab=packages&amp;q=tt-metalium-ubuntu-22.04-release-amd64) or [wheel](https://github.com/tenstorrent/tt-metal/releases).
It is rebuilt to use the same source revision as the metal library and built to run on our runners, which use Ubuntu 24.04 as base.

ttnn includes most parts of the tt_metal distribution. Only the RISC-V compilers need to be provided externally and are already installed on our runners.

### Daisytuner Workflows

Ideally, within a venv, pytorch repositories are added and the wheel provided on each tenstorrent-equipped runner is installed:
```
pip config set global.extra-index-url https://download.pytorch.org/whl/cpu
pip install /opt/tenstorrent/wheels/ttnn-0.58.0rc25+gg33cbd50ba3-cp312-cp312-linux_x86_64.whl
```
Following that, the ttnn runtime is ready for execution. ENV-Var `TT_METAL_HOME` must *not* be set, as ttnn would then replace many of its included and working parts with whatever is provided and the binary installation does not currently include all parts of ttnn that are required for that.

Example: [test_ttnn.yml](.daisy/test_ttnn.yml)

Any other external ttnn wheels that were built to run on Ubuntu 24.04 according to the official tenstorrent guides would also work instead of the provided one.
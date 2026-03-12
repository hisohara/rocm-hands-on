# Hands-on Training for ROCm
[「計算物理春の学校2026」](https://compphysschool.github.io/2026/) 個別講義Cの
ROCm向けハンズオンの資料です。

## Table of Contents
- [How to deploy this repository](#how-to-deploy-this-repository)
- [Check system environment](#check-system-environment)
- [Managed Memory](#managed-memory)
- [HIP Transpose](#hip-transpose)
- [hipSOLVER Library](#hipsolver-library)
- [APU Programming with OpenMP on MI300A](#apu-programming-with-openmp-on-mi300a)
- [HIP-Python](#hip-python)
- [HIPIFY](#hipify)
- [References](#references)

## How to deploy this repository
[amd/HPCTrainingExamples](https://github.com/amd/HPCTrainingExamples),
[ROCm/rocm-examples](https://github.com/ROCm/rocm-examples)をsubmoduleとして
取り込みます。

```bash
git clone --recurse-submodules https://github.com/hisohara/rocm-hands-on.git
```

## Check system environment
GPUの統計情報や構成を確認します。`rocminfo`はアーキテクチャ名を確認する際に
有用です。MI300Aの場合、`gfx942`です。`lscpu`では`Model name`を確認してください。

```bash
rocm-smi
amd-smi version
rocminfo
lscpu
```

実行にあたっては、`script-0_check-system-env.sh` を参考にしてください。

## Managed Memory
配列の各要素を2倍にするという単純な計算を例にとって、コンパイル方法と
CPUコードとGPUコードの違い、`HSA_XNACK`の役割について見ていきます。

### CPU Code

```bash
cd third_party/HPCTrainingExamples/ManagedMemory
cd CPU_Code
make
./cpu_code
```

実行にあたっては、`script-1_managed-memory-cpu.sh` を参考にしてください。

### GPU Code
HIP化されたコードです。`cpu_code.c`との違いを見てみましょう。
GPU用のメモリ領域の確保、GPUへのデータ転送、同期処理が追加されていることを
確認してください。

```bash
cd GPU_Code
make
./gpu_code
```

実行にあたっては、`script-1_managed-memory-gpu.sh` を参考にしてください。

#### For advanced user
どのようなHIPのAPIが呼び出されているのかを確認するためにプロファイラを用いましょう。

```bash
rocprofv3 --sys-trace --output-format csv -- ./gpu_code
```

`hip_api_trace.csv`, `memory_copy_trace.csv`を参照してみましょう。

### Managed Memory Code
APUプログラミングを体感してみましょう。ソースコードの違いをまず確認してください。
`hipMalloc`, `hipMemcpy`が無くなっています。
環境変数`HSA_XNACK`による実行の違いも見てみましょう。

```bash
cd Managed_Memory_Code
diff -u ../GPU_Code gpu_code.hip
make
HSA_XNACK=1 ./gpu_code
HSA_XNACK=0 ./gpu_code
```

実行にあたっては、`script-1_managed-memory-managed.sh` を参考にしてください。

#### For advanced user
どのようなHIPのAPIが呼び出されているのかを確認するためにプロファイラを用いましょう。

```bash
HSA_XNACK=1 rocprofv3 --sys-trace --output-format csv -- ./gpu_code
```

`hipMemcpy`が無くなっていることを確認してください。


### OpenMP Code
OpenMPはCPUコードをGPU向けコードに移行するにあたって非常に有用なツールです。
まず、OpenMP化されたコードをCPU上で動作させてみましょう。
OpenMP向けのコンパイラオプションを付けなければCPU向けのコードを生成します。

```bash
cd OpenMP_Code
amdclang -O3 -fstrict-aliasing -fno-lto -lm -o openmp_code-cpu openmp_code.c
./openmp_code-cpu
```

次にOpenMPのコンパイラオプションを付けてGPU上で実行させましょう。

```bash
amdclang -O3 -fstrict-aliasing -fopenmp --offload-arch=gfx942 -fno-lto -lm -o openmp_code-gpu openmp_code.c
HSA_XNACK=1 ./openmp_code-gpu
```

OpenMPを用いれば、処理の重いループ構造を少しずつGPUに移行させることが可能です。

## HIP Transpose
行列の転置処理を例にアルゴリズムの違い、ROCmの標準ライブラリの導入について
見ていきます。

### Transpose Read Contiguous
行列のデータ読み込みのindexで並列化する例です。

```bash
cd third_party/HPCTrainingExamples/HIP/transpose
make transpose_read_contiguous
./transpose_read_contiguous
```

実行にあたっては、`script-2_hip-transpose.sh` を参考にしてください。

### Transpose Write Contiguous
行列のデータ書き込みのindexで並列化する例です。
transpose_read_contiguousと比較して大きく性能が上回ります。

```bash
make transpose_write_contiguous
./transpose_write_contiguous
```

### Tiled Matrix Transpose
行列を行方向、列方向で分割してタイル化したものです。さらに性能は
上回りますが、コードは複雑になります。

```bash
make transpose_tiled
./transpose_tiled
```

### Transpose from the rocblas library
ROCmの標準ライブラリであるrocBLASにある転置処理の関数を呼び出します。
行列処理のエキスパートでなくとも、そこそこの性能を得ることができます。

```bash
make transpose_rocblas
./transpose_rocblas
```

手法の違いを以下のアプリケーションで比較してみましょう。

```bash
make transpose_timed
./transpose_timed
```

## hipSOLVER Library
LAPACK相当のAPIをサポートしているhipSOLVERのサンプルプログラムを見ていきます。
サポートされているAPIのリストは[hipSOLVER documentation](https://rocm.docs.amd.com/projects/hipSOLVER/en/latest/index.html)
を参照してください。

### QR Factorization Example
行列のQR分解の例です。[`hipsolverDgeqrf`](https://rocm.docs.amd.com/projects/hipSOLVER/en/latest/reference/api/lapack.html#hipsolver-type-geqrf)
を用いています。パラメータ`-m`, `-n`で行列のサイズを変更可能です。

```bash
cd third_party/rocm-examples/Libraries/hipSOLVER
cd geqrf
make
./hipsolver_geqrf
```

実行にあたっては、`script-3_hipsolver.sh` を参考にしてください。

### hipSOLVER Symmetric Eigenvalue Example
対称行列の固有値分解の例です。[`hipsolverDsyevd`](https://rocm.docs.amd.com/projects/hipSOLVER/en/latest/reference/api/lapack.html#hipsolver-type-syevd)
を用いています。

```bash
cd syevd
make
./hipsolver_syevd
```

## APU Programming with OpenMP on MI300A
MI300AはCPUとGPUが物理的にアドレス空間を共有するためdata copyせずに
GPUで処理を行わせることが可能です。ROCmのOpenMPランタイムはdata copyの
必要性を自動的に判断します。

ここでは2種類のコードを用います。`vector_add_auto_zero_copy.cpp`では
map clauseを用いてGPUと受け渡しする配列を明示的に記述しています。
`vector_add_usm.cpp`では、`#pragma omp requires unified_shared_memory`を
宣言した上で、map clauseなしでGPUに処理を渡しています。

```c++
//vector_add_auto_zero_copy.cpp
  #pragma omp target teams loop map(from:a[:n]) map(to:b[:n],c[:n])
  for(size_t i = 0; i < n; i++) {
    a[i] = b[i] + c[i];
  }
```

```c++
//vector_add_usm.cpp
#pragma omp requires unified_shared_memory

  #pragma omp target teams loop
  for(size_t i = 0; i < n; i++) {
    a[i] = b[i] + c[i];
  }
```

どのように実行されるのかOpenMPランタイムのデバッグ用環境変数を用いて
見てみましょう。`HSA_XNACK=1`の時にdata copyが発生していないことを
確認してください。

```bash
cd third_party/HPCTrainingExamples/Pragma_Examples/OpenMP/USM/vector_add_auto_zero_copy
make # if failed, try "make CXX=amdclang++"
export LIBOMPTARGET_INFO=-1
HSA_XNACK=1 ./vector_add_auto_zero_copy
HSA_XNACK=0 ./vector_add_auto_zero_copy
```

map clauseなしの場合は、`HSA_XNACK=1`で期待通りdata copyが発生しません。
また、`HSA_XNACK=0`では実行に失敗することを確認してください。

```bash
cd third_party/HPCTrainingExamples/Pragma_Examples/OpenMP/USM/vector_add_usm
make # if failed, try "make CXX=amdclang++"
export LIBOMPTARGET_INFO=-1
HSA_XNACK=1 ./vector_add_usm
HSA_XNACK=0 ./vector_add_usm
```

実行にあたっては、`script-4_apu-openmp.sh` を参考にしてください。

map clauseがあってもなくてもOpenMPランタイムが適切にdata copyを
処理することを確認しました。

## HIP-Python
HIPの主要なライブラリをPythonから呼び出すことが可能です。対応しているAPIについては
[HIP Python](https://rocm.docs.amd.com/projects/hip-python/en/latest/)を
参照してください。
インストールが必要です。venvなどのPythonの仮想環境を用いることを推奨します。

```bash
python3 -m venv venv
source venv/bin/activate
python3 -m pip install -i https://test.pypi.org/simple hip-python~=7.1.1
pip install numpy
```

rocBLASを用いた例です。C/C++ベースのHIPと同様に、`HSA_XNACK=1`を用いた
APU Programmingにより、GPUデバイス用のメモリ確保、データコピーを記述する
必要がないことをソースコードを比較して確認してください。

```bash
cd third_party/HPCTrainingExamples/Python/hip-python
python hipblas_numpy_example.py
HSA_XNACK=1 python hipblas_numpy_USM_example.py
```

実行にあたっては、`script-5_hip-python.sh` を参考にしてください。

## HIPIFY
CUDAのソースコードをHIPに変換するHIPIFYを使ってみましょう。

```bash
cd third_party/HPCTrainingExamples/HIPIFY/mini-nbody/cuda
cp ../timer.h .
hipify-perl -examine nbody-orig.cu
hipify-perl nbody-orig.cu > nbody-orig.cpp
hipcc nbody-orig.cpp -o nbody-orig
./nbody-orig
```

## References
- [AMD ROCm documentation](https://rocm.docs.amd.com/en/latest/)
- [AMD ROCm Blogs](https://rocm.blogs.amd.com/)
  - [MI300A - Exploring the APU advantage](https://rocm.blogs.amd.com/software-tools-optimization/mi300a-programming/README.html)
- ROCm Examples
  - [GitHub:HPCTrainingExamples](https://github.com/amd/HPCTrainingExamples)
  - [GitHub:rocm-examples](https://github.com/ROCm/rocm-examples)
- [MI300A Lecture at University of Tsukuba](https://www.ccs.tsukuba.ac.jp/amd-mi300a/)

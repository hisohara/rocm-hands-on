# Hands-on Training for ROCm
[「計算物理春の学校2026」](https://compphysschool.github.io/2026/) 個別講義Cの
ROCm向けハンズオンの資料です。

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
amd-smi
rocminfo
lscpu
```

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

### GPU Code
HIP化されたコードです。`cpu_code.c`との違いを見てみましょう。
GPU用のメモリ領域の確保、GPUへのデータ転送、同期処理が追加されていることを
確認してください。

```bash
cd GPU_Code
make
./gpu_code
```

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



## References
- [AMD ROCm documentation](https://rocm.docs.amd.com/en/latest/)
- [AMD ROCm Blogs](https://rocm.blogs.amd.com/)
  - [MI300A - Exploring the APU advantage](https://rocm.blogs.amd.com/software-tools-optimization/mi300a-programming/README.html)

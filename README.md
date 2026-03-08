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





## References
- [AMD ROCm documentation](https://rocm.docs.amd.com/en/latest/)
- [AMD ROCm Blogs](https://rocm.blogs.amd.com/)
  - [MI300A - Exploring the APU advantage](https://rocm.blogs.amd.com/software-tools-optimization/mi300a-programming/README.html)

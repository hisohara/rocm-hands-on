# Hands-on Training for ROCm
「計算物理春の学校2026」個別講義CのROCm向けハンズオンの資料です。

## How to deploy this repository
[amd/HPCTrainingExamples](https://github.com/amd/HPCTrainingExamples),
[ROCm/rocm-examples](https://github.com/ROCm/rocm-examples)をsubmoduleとして
取り込んでいます。

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

#!/bin/bash
#PBS -A EDU3
#PBS -q edu1
#PBS -l walltime=00:10:00
#PBS -m n
#PBS -j oe
#PBS -o LOG_check-system-env.log

module load rocm/7.2.0

echo "### rocm-smi"
rocm-smi
echo
echo "### amd-smi version"
amd-smi version
echo
echo "### rocminfo"
rocminfo
echo
echo "### lscpu"
lscpu

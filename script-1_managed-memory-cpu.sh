#!/bin/bash
#PBS -A EDU3
#PBS -q edu1
#PBS -l walltime=00:10:00
#PBS -m n
#PBS -j oe
#PBS -o LOG_managed-memory-cpu.log

module load rocm/7.2.0

cd $PBS_O_WORKDIR
cd third_party/HPCTrainingExamples/ManagedMemory
cd CPU_Code

./cpu_code

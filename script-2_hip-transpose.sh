#!/bin/bash
#PBS -A EDU3
#PBS -q edu1
#PBS -l walltime=00:10:00
#PBS -m n
#PBS -j oe
#PBS -o LOG_hip-transpose.log

module load rocm/7.2.0

cd $PBS_O_WORKDIR
cd rocm-hands-on/third_party/HPCTrainingExamples/HIP/transpose

./transpose_read_contiguous

#!/bin/bash
#PBS -A EDU3
#PBS -q edu1
#PBS -l walltime=00:10:00
#PBS -m n
#PBS -j oe
#PBS -o LOG_apu-openmp.log

module load rocm/7.2.0

cd $PBS_O_WORKDIR
cd rocm-hands-on/third_party/HPCTrainingExamples/Pragma_Examples/OpenMP/USM
cd vector_add_auto_zero_copy

export LIBOMPTARGET_INFO=-1

echo "### HSA_XNACK=1"
HSA_XNACK=1 ./vector_add_auto_zero_copy
echo
echo "### HSA_XNACK=0"
HSA_XNACK=0 ./vector_add_auto_zero_copy

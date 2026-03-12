#!/bin/bash
#PBS -A EDU3
#PBS -q edu1
#PBS -l walltime=00:10:00
#PBS -m n
#PBS -j oe
#PBS -o LOG_hip-python.log

module load rocm/7.2.0

cd $PBS_O_WORKDIR
cd third_party/HPCTrainingExamples/Python/hip-python

echo "### No USM"
$PBS_O_WORKDIR/venv/bin/python hipblas_numpy_example.py
echo
echo "### USM"
HSA_XNACK=1 $PBS_O_WORKDIR/venv/bin/python hipblas_numpy_USM_example.py

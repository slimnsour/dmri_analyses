#!/bin/bash

inputfolder=$1
subject=$2
dwi=$3
bval=$4
bvec=$5
mask=$6
outputfolder=$7

tractFolder="${outputfolder}/Tracts/${subject}"
vtk_file="${tractFolder}/${subject}_desc-preproc_tractography.vtk"
mkdir -p $tractFolder
if [ ! -f "$vtk_file" ]; then
  ${PYTHONPATH}/scripts/ukf.py \
    -i ${dwi} \
    --bvals ${bval} \
    --bvecs ${bvec} \
    -m ${mask} \
    -o ${vtk_file}
fi

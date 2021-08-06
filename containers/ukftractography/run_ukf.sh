#!/bin/bash

inputfolder=$1
subject=$2

vtk_file="${inputfolder}/${subject}_desc-preproc_tractography.vtk"
if [ ! -f "$vtk_file" ]; then
  ${PYTHONPATH}/scripts/ukf.py \
    -i ${inputfolder}/${subject}_desc-preproc_dwi.nii.gz \
    --bvals {inputfolder}/${subject}_desc-preproc_dwi.bval \
    --bvecs {inputfolder}/${subject}_desc-preproc_dwi.bvec \
    -m {inputfolder}/${subject}_desc-brain_mask.nii.gz \
    -o ${vtk_file}
fi

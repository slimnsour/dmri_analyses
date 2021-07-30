#!/bin/bash
#SBATCH --account=rrg-arisvoin
#SBATCH --array=1-n%25
#SBATCH --nodes=4
#SBATCH --cpus-per-task=80
#SBATCH --ntasks-per-node=1
#SBATCH --time=20:00:00
#SBATCH --job-name ukf
#SBATCH --output=ukf_%j.txt

cd $SLURM_SUBMIT_DIR

# EDIT THE FOLLOWING FOR YOUR INPUTS
# NOTE: Also edit the --array variable (n) in this file's header to be the number of subjects to process (number of lines in $sublist).
# This will allow for parallel processing on SciNet.

# Slicer tractography repo directory
slicer_tract_home=$SCRATCH/slicer_tractography
# List of subjects to process (line separated, sub-xxx)
sublist=$SCRATCH/study/scripts/asc_subs.txt
# Input BIDS directory of preprocessed diffusion data
dmri_dir=${SCRATCH}/ASCEND/dmriprep_output/dmripreproc/

index() {
   head -n $SLURM_ARRAY_TASK_ID $sublist \
   | tail -n 1
}

# Select next sub
sub="`index`"
sing_home=$slicer_tract_home/sing_home
sing_img=$slicer_tract_home/ukf/ukf.simg
mkdir -p $sing_home

# Strip the beginning of the sub string and get subject directory
sub_dir="${dmri_dir}/${sub}"

for ses in "ses-01" "ses-02"; do 
    ses_dir="/dmri/${ses}/dwi"
    dwi="${ses_dir}/${sub}_${ses}_desc-preproc_dwi.nii.gz"
    bval="${ses_dir}/${sub}_${ses}_desc-preproc_dwi.bval"
    bvec="${ses_dir}/${sub}_${ses}_desc-preproc_dwi.bvec"
    mask_file="${ses_dir}/${sub}_${ses}_desc-preproc_mask.nii.gz"
    vtk_file="${ses_dir}/${sub}_${ses}_desc-preproc_tractography.vtk"

    singularity run \
      -B ${sing_home}:/pnlNipype/tmp \
      -B ${dmri_dir}:/dmri \
      ${sing_img} \
        "python /pnlNipype/scripts/ukf.py \
        -i ${dwi} \
        --bvals ${bval} \
        --bvecs ${bvec} \
        -m ${mask_file} \
        -o ${vtk_file}"
    fi
done

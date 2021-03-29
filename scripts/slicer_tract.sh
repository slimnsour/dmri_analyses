#!/bin/bash
#SBATCH --account=rrg-arisvoin
#SBATCH --array=1-n%25
#SBATCH --nodes=4
#SBATCH --cpus-per-task=80
#SBATCH --ntasks-per-node=1
#SBATCH --time=20:00:00
#SBATCH --job-name slicer
#SBATCH --output=slicer_%j.txt

cd $SLURM_SUBMIT_DIR

# EDIT THE FOLLOWING FOR YOUR INPUTS
# NOTE: Also edit the --array variable (n) in this file's header to be the number of subjects to process (number of lines in $sublist).
# This will allow for parallel processing on SciNet.

# Slicer tractography repo directory
slicer_tract_home=$SCRATCH/slicer_tractography
# List of subjects to process (line separated, sub-xxx)
sublist=$SCRATCH/study/scripts/asc_subs.txt
# Input BIDS directory of preprocessed diffusion data and ukf tracts
inputDirectory=${SCRATCH}/ASCEND/dmriprep_output/dmripreproc/
# Output tract directory
outputDirectory=${SCRATCH}/ASCEND/tractography/
# Directory of where the ORG-atlas is (can use ORG-800FC-100HCP from https://github.com/SlicerDMRI/ORG-Atlases)
atlasDirectory=${SCRATCH}/slicer/atlasDirectory/

index() {
   head -n $SLURM_ARRAY_TASK_ID $sublist \
   | tail -n 1
}

# Select next sub
sub="`index`"
sing_home=$slicer_tract_home/sing_home
sing_img=$slicer_tract_home/slicer/slicer_tract.simg
slicerDirectory=/Slicer-SuperBuild-Debug/Slicer-build
mkdir -p $sing_home

# Get a short form for the singularity setup for each slicer container command
sing_command="singularity run -B ${sing_home}:/pnlNipype/tmp \
  -B ${inputDirectory}:/inputDirectory \
  -B ${atlasDirectory}:/atlasDirectory \
  -B ${outputDirectory}:/outputDirectory \
  ${sing_img}"

for ses in "ses-01" "ses-02"; do 
  # STEP 1
  if [ ! -f "${outputDirectory}/TractRegistration/${sub}_${ses}_desc-preproc_tractography/output_tractography/${sub}_${ses}_desc-preproc_tractography_reg.vtk" ]; then
  ${sing_command} \
    "wm_register_to_atlas_new.py \
      -mode rigid_affine_fast \
      /inputDirectory/${sub}/${ses}/dwi/${sub}_${ses}_desc-preproc_tractography.vtk \
      /atlasDirectory/atlas.vtp \
      /outputDirectory/TractRegistration"
  fi

  # STEP 2
  if [ ! -f "${outputDirectory}/FiberClustering/InitialClusters/${sub}_${ses}_desc-preproc_tractography_reg/cluster_00800.vtp" ]; then
  ${sing_command} \
    "wm_cluster_from_atlas.py \
      /outputDirectory/TractRegistration/${sub}_${ses}_desc-preproc_tractography/output_tractography/${sub}_${ses}_desc-preproc_tractography_reg.vtk \
      /atlasDirectory \
      /outputDirectory/FiberClustering/InitialClusters"
  fi

  # STEP 3
  if [ ! -f "${outputDirectory}/FiberClustering/OutlierRemovedClusters/${sub}_${ses}_desc-preproc_tractography_reg_outlier_removed/cluster_00800.vtp" ]; then
  ${sing_command} \
    "wm_cluster_remove_outliers.py \
      -cluster_outlier_std 4 \
      /outputDirectory/FiberClustering/InitialClusters/${sub}_${ses}_desc-preproc_tractography_reg \
      /atlasDirectory \
      /outputDirectory/FiberClustering/OutlierRemovedClusters"
  fi

  # STEP 4
  if [ ! -f "${outputDirectory}/FiberClustering/OutlierRemovedClusters/${sub}_${ses}_desc-preproc_tractography_reg_outlier_removed/cluster_location_by_hemisphere.log" ]; then
  ${sing_command} \
    "wm_assess_cluster_location_by_hemisphere.py \
      /outputDirectory/FiberClustering/OutlierRemovedClusters/${sub}_${ses}_desc-preproc_tractography_reg_outlier_removed \
      -clusterLocationFile /atlasDirectory/cluster_hemisphere_location.txt"
  fi

  # STEP 5
  if [ ! -f "${outputDirectory}/FiberClustering/TransformedClusters/${sub}_${ses}_desc-preproc_tractography/cluster_00800.vtp" ]; then
  ${sing_command} \
    "xvfb-run -a -s \"-screen 0 640x480x24 +iglx\" \
    wm_harden_transform.py \
      /outputDirectory/FiberClustering/OutlierRemovedClusters/${sub}_${ses}_desc-preproc_tractography_reg_outlier_removed \
      /outputDirectory/FiberClustering/TransformedClusters/${sub}_${ses}_desc-preproc_tractography \
      ${slicerDirectory}/Slicer \
      -i \
      -t /outputDirectory/TractRegistration/${sub}_${ses}_desc-preproc_tractography/output_tractography/itk_txform_${sub}_${ses}_desc-preproc_tractography.tfm"
  fi
    
  # STEP 6
  if [ ! -f "${outputDirectory}/FiberClustering/SeparatedClusters/${sub}_${ses}/tracts_commissural/cluster_00800.vtp" ]; then
  ${sing_command} \
    "wm_separate_clusters_by_hemisphere.py \
      /outputDirectory/FiberClustering/TransformedClusters/${sub}_${ses}_desc-preproc_tractography \
      /outputDirectory/FiberClustering/SeparatedClusters/${sub}_${ses}"
  fi

  # STEP 7
  if [ ! -f "${outputDirectory}/AnatomicalTracts/${sub}_${ses}/T_CPC.vtp" ]; then
  ${sing_command} \
    "wm_append_clusters_to_anatomical_tracts.py \
      /outputDirectory/FiberClustering/SeparatedClusters/${sub}_${ses} \
      /atlasDirectory/ \
      /outputDirectory/AnatomicalTracts/${sub}_${ses}"
  fi

  # STEP 8
  #left
  if [ ! -f "${outputDirectory}/DiffusionMeasurements/${sub}_${ses}_left_hemisphere_clusters.csv" ]; then
  ${sing_command} \
    "xvfb-run -a -s \"-screen 0 640x480x24 +iglx\" \
    wm_diffusion_measurements.py \
      /outputDirectory/FiberClustering/SeparatedClusters/${sub}_${ses}/tracts_left_hemisphere/ \
      /outputDirectory/DiffusionMeasurements/${sub}_${ses}_left_hemisphere_clusters.csv \
      ${slicerTract}"
  fi

  #right
  if [ ! -f "${outputDirectory}/DiffusionMeasurements/${sub}_${ses}_right_hemisphere_clusters.csv" ]; then
  ${sing_command} \
    "xvfb-run -a -s \"-screen 0 640x480x24 +iglx\" \
    wm_diffusion_measurements.py \
      /outputDirectory/FiberClustering/SeparatedClusters/${sub}_${ses}/tracts_right_hemisphere/ \
      /outputDirectory/DiffusionMeasurements/${sub}_${ses}_right_hemisphere_clusters.csv \
      ${slicerTract}"
  fi

  #commissural
  if [ ! -f "${outputDirectory}/DiffusionMeasurements/${sub}_${ses}_commissural_clusters.csv" ]; then
  ${sing_command} \
    "xvfb-run -a -s \"-screen 0 640x480x24 +iglx\" \
    wm_diffusion_measurements.py \
      /outputDirectory/FiberClustering/SeparatedClusters/${sub}_${ses}/tracts_commissural/ \
      /outputDirectory/DiffusionMeasurements/${sub}_${ses}_commissural_clusters.csv \
      ${slicerTract}"
  fi

  # STEP 9
  #anatomical tracts
  if [ ! -f "${outputDirectory}/DiffusionMeasurements/${sub}_${ses}_anatomical_tracts.csv" ]; then
  ${sing_command} \
    "xvfb-run -a -s \"-screen 0 640x480x24 +iglx\" \
    wm_diffusion_measurements.py \
      /outputDirectory/AnatomicalTracts/${sub}_${ses} \
      /outputDirectory/DiffusionMeasurements/${sub}_${ses}_anatomical_tracts.csv \
      ${slicerTract}"
  fi

done

#!/bin/bash

inputfolder=$1
outputfolder=$2
subject=$3

#define environment variables
inputfile=${inputfolder}/${subject}/${subject}_desc-preproc_tractography.vtk

#--------------------------------------------------------------------------------------------------------------------
#STEP 1 OF 9
#--------------------------------------------------------------------------------------------------------------------

if [ ! -f "${outputfolder}/TractRegistration/${subject}_desc-preproc_tractography/output_tractography/${subject}_desc-preproc_tractography_reg.vtk" ]; then
  wm_register_to_atlas_new.py \
    -mode rigid_affine_fast \
    $inputfile \
    $ATLASDIR/atlas.vtp \
    $outputfolder/TractRegistration
fi

#--------------------------------------------------------------------------------------------------------------------
#STEP 2 OF 9
#--------------------------------------------------------------------------------------------------------------------

if [ ! -f "${outputfolder}/FiberClustering/InitialClusters/${subject}_desc-preproc_tractography_reg/cluster_00800.vtp" ]; then
  xvfb-run -a -s "-screen 0 640x480x24 +iglx" wm_cluster_from_atlas.py \
    -j 4 \
    $outputfolder/TractRegistration/${subject}_desc-preproc_tractography/output_tractography/${subject}_desc-preproc_tractography_reg.vtk \
    $ATLASDIR \
    $outputfolder/FiberClustering/InitialClusters
fi

#--------------------------------------------------------------------------------------------------------------------
#STEP 3 OF 9
#--------------------------------------------------------------------------------------------------------------------

if [ ! -f "${outputfolder}/FiberClustering/OutlierRemovedClusters/${subject}_desc-preproc_tractography_reg_outlier_removed/cluster_00800.vtp" ]; then
  wm_cluster_remove_outliers.py \
    -cluster_outlier_std 4 \
    $outputfolder/FiberClustering/InitialClusters/${subject}_desc-preproc_tractography_reg \
    $ATLASDIR \
    $outputfolder/FiberClustering/OutlierRemovedClusters
fi

#--------------------------------------------------------------------------------------------------------------------
#STEP 4 OF 9
#--------------------------------------------------------------------------------------------------------------------

if [ ! -f "${outputfolder}/FiberClustering/OutlierRemovedClusters/${subject}_desc-preproc_tractography_reg_outlier_removed/cluster_location_by_hemisphere.log" ]; then
  wm_assess_cluster_location_by_hemisphere.py \
    $outputfolder/FiberClustering/OutlierRemovedClusters/${subject}_desc-preproc_tractography_reg_outlier_removed \
    -clusterLocationFile $ATLASDIR/cluster_hemisphere_location.txt
fi

#--------------------------------------------------------------------------------------------------------------------
#STEP 5 OF 9
#--------------------------------------------------------------------------------------------------------------------

#transform fiber locations

if [ ! -f "${outputfolder}/FiberClustering/TransformedClusters/${subject}_desc-preproc_tractography/cluster_00800.vtp" ]; then
  xvfb-run -a -s "-screen 0 640x480x24 +iglx" wm_harden_transform.py \
    $outputfolder/FiberClustering/OutlierRemovedClusters/${subject}_desc-preproc_tractography_reg_outlier_removed \
    $outputfolder/FiberClustering/TransformedClusters/${subject}_desc-preproc_tractography \
    $SLICER \
    -i \
    -t $outputfolder/TractRegistration/${subject}_desc-preproc_tractography/output_tractography/itk_txform_${subject}_desc-preproc_tractography.tfm
fi

#--------------------------------------------------------------------------------------------------------------------
#STEP 6 OF 9
#--------------------------------------------------------------------------------------------------------------------

if [ ! -f "${outputfolder}/FiberClustering/SeparatedClusters/${subject}/tracts_commissural/cluster_00800.vtp" ]; then
  wm_separate_clusters_by_hemisphere.py \
    $outputfolder/FiberClustering/TransformedClusters/${subject}_desc-preproc_tractography \
    $outputfolder/FiberClustering/SeparatedClusters/${subject}
fi

#--------------------------------------------------------------------------------------------------------------------
#STEP 7 OF 9
#--------------------------------------------------------------------------------------------------------------------

if [ ! -f "${outputfolder}/AnatomicalTracts/${subject}/T_CPC.vtp" ]; then
  wm_append_clusters_to_anatomical_tracts.py \
    $outputfolder/FiberClustering/SeparatedClusters/${subject} \
    $ATLASDIR \
    $outputfolder/AnatomicalTracts/${subject}
fi

#--------------------------------------------------------------------------------------------------------------------
#STEP 8 OF 9
#--------------------------------------------------------------------------------------------------------------------

#left
if [ ! -f "${outputfolder}/DiffusionMeasurements/${subject}_left_hemisphere_clusters.csv" ]; then
  wm_diffusion_measurements.py \
    $outputfolder/FiberClustering/SeparatedClusters/${subject}/tracts_left_hemisphere/ \
    $outputfolder/DiffusionMeasurements/${subject}_left_hemisphere_clusters.csv \
    $SLICER/lib/Slicer-4.10/cli-modules/FiberTractMeasurements
fi

#right
if [ ! -f "${outputfolder}/DiffusionMeasurements/${subject}_right_hemisphere_clusters.csv" ]; then
  wm_diffusion_measurements.py \
    $outputfolder/FiberClustering/SeparatedClusters/${subject}/tracts_right_hemisphere/ \
    $outputfolder/DiffusionMeasurements/${subject}_right_hemisphere_clusters.csv \
    $SLICER/lib/Slicer-4.10/cli-modules/FiberTractMeasurements
fi

#commissural
if [ ! -f "${outputfolder}/DiffusionMeasurements/${subject}_commissural_clusters.csv" ]; then
  wm_diffusion_measurements.py \
    $outputfolder/FiberClustering/SeparatedClusters/${subject}/tracts_commissural/ \
    $outputfolder/DiffusionMeasurements/${subject}_commissural_clusters.csv \
    $SLICER/lib/Slicer-4.10/cli-modules/FiberTractMeasurements
fi

#--------------------------------------------------------------------------------------------------------------------
#STEP 9 OF 9
#--------------------------------------------------------------------------------------------------------------------

#anatomical tracts
if [ ! -f "${outputfolder}/DiffusionMeasurements/${subject}_anatomical_tracts.csv" ]; then
  wm_diffusion_measurements.py \
    $outputfolder/AnatomicalTracts/${subject} \
    $outputfolder/DiffusionMeasurements/${subject}_anatomical_tracts.csv \
    $SLICER/lib/Slicer-4.10/cli-modules/FiberTractMeasurements
fi

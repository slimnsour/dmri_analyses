# UKF Tractography and White Matter Analysis

<p float="left">
  <img src="https://user-images.githubusercontent.com/54225067/112897813-1373d680-90ae-11eb-8254-044c38df1594.png"/> 
</p>

### About

In the lab, there has been a growing interest in the new diffusion tractography method we call **Slicer Tractography**. This method is based on generating tracts recursively using a [two-tensor model](https://doi.org/10.1007/978-3-642-04268-3_110) and clustering the tracts using the [ORG atlas](https://doi.org/10.1016/j.neuroimage.2018.06.027).

The purpose of this repo is to help anyone get started with running this pipeline locally or on [SciNet](https://docs.scinet.utoronto.ca/index.php/Main_Page) using Singularity containers. 

If you are working with a bunch of high quality data, you may have to run this pipeline on SciNet. Tractography generation is very resource-intensive, so you may experience memory issues when running it locally/submitting it to our nodes. Luckily, SciNet helps with this by just giving us enough power to generate what we need. If you are just getting started with SciNet, you can find out how to sign up on [our wiki](https://github.com/TIGRLab/admin/wiki/SciNet) and get a basic start for submitting jobs on [theirs](https://docs.scinet.utoronto.ca/index.php/Niagara_Quickstart).

### Requirements

**Data**

The data must already be diffusion preprocessed, ideally using **dmriprep**. Specifically, the pipeline needs the following files to be available for each subject you plan to generate tracts for:

1. Preprocessed DWI
2. Bval file
3. Bvec file
4. Mask for preprocessed DWI

**Containers**

Since we are using [Singularity](https://sylabs.io/singularity/) containers to run this data, there are not a real list of dependencies you need to worry about. You just need a way to run Singularity (version 2.xx) on your platform. This is good news since this is already available on our system as a module, as well as on SciNet.

The singularity containers are available on our system in the archive. There are two containers: one for the tract generation (UKFTractography) and another for the fiber clustering (whitematteranalysis).

You can also rebuild the containers from scratch using [Docker](https://docs.docker.com/get-started/) on the appropriate Dockerfile and using [docker2singularity](https://github.com/singularityhub/docker2singularity) to convert it into a Singularity image. For example, you can rebuild the UKFTractography container by running the following in the directory with its Dockerfile:

```
docker build . -t slicer:ukf
docker run --privileged -t --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${output_directory}:/output \
  singularityware/docker2singularity \
  slicer:ukf
```

### SciNet Usage

As mentioned previously, the pipeline is comprised of two major parts: the tract generation using UKFTractography and the fibre clustering using whitematteranalysis.

First, you must generate the UKF tracts. This is done by submitting `scripts/ukf.sh` to the slurm queue. Note: First you must edit the input variables in the script itself for your study. This includes the destination of where the singularity image is, the subject list, and the directory of where the preprocessed diffusion data is.

Then, you must run the whitematteranalysis pipeline. This is done by submitting `scripts/slicer_tract.sh` to the slurm queue. Note: Again you must edit the input variables in the script itself for your study. This includes the destination of where the singularity image is, the subject list, and the directory of where the preprocessed diffusion and tract data is, the output directory, and the atlas directory. You can get the atlas from the [ORG repository](https://github.com/SlicerDMRI/ORG-Atlases).



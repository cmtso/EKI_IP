# EKI_IP
extending [EKI_geophysics_2020](https://github.com/cmtso/EKI_geophysics_2020/) to induced polarization. Prepared for paper submission.

Tso, C.-H.M., M. Iglesias, A.Binley (2023) Ensemble Kalman Inversion of Induced Polarization Data. Geophysical Journal International

In particular, we use the above approach first for DC resistivity, then fixed the mean DC resistivity and invert for phase angles only.

# Getting started
Download cR2 [here](http://www.es.lancs.ac.uk/people/amb/Freeware/cR2/cR2.htm) and put **cR2.exe** in each of the `<project>` subfolders. You will need to install Wine to run it in a Linux-like system.

You can find each of the subfolders as a self-contained use case.

# Use case
Each of these are referred as `<project>` directories below.
- `Surf_IP2`: surface synthetic example with 1/2 inclusions, not used in paper
- `Surf50m_IP`: surface synthetic example with 1/2 inclusions, a longer survey line than the previous case
- `2D_Pow`: Pow catchment surface example (from Mejus thesis 2014)
- `PRB_iso`: 2D cross-borehole for imaging permeable reactive barrier (Slater and Binley 2006 Geophysics), synthetic and field data versions
- `Drigg_iso`: not used in paper
- `arb3layers_IP`: 3 layers synthetic model with pinch-out

See more detailed description of each case in the paper. Note some cases have not been included in the paper.

Order of appearance in Paper: 
| Figure # | folder                       |
| -------- | ---------------------------- |
| 2        | `surf50m_IP`                 |
| 3        | `arb3layers_IP`              |
| 4        | `LS2_arb3layers_IP`          |
| 5        | `LS4_arb3layers_IP_separate` |
| 6        | `LS2_arb3layers_uniform`     |
| 7        | `LS4_arb3layers_IP`          |
| 9        | `2D_Pow_HEC`                 |
| 10       | `PRBsyn_iso`                 |
| 11       | `PRB_iso`                    |
| 12       | `PRBnoise_syn_iso`           |

Unlike the others, Fig. 6 and 7 uses a non-informative prior distribution (i.e. prior ranges of zones overlap).

All examples uses an ensemble size of 300 samples, with the exception of 2D_Pow (100).

All use cases uses 1 level-set function to estimate 2 or 3 zones, unless otherwise specified. `LS2*` uses two level sets function for the 3 zone problem, while `LS4` estimates four zones.

# Creating your own use cases
Follow these steps:
1. Make sure you can run the problem in cR2 as forward problem (put it in `inv/fwd`). ResIPy is a python package that you may find useful
2. Copy the folder to the <root subfolder>. Copy minimal input files to <root subfolder>/template
3. Double check lines in `EKI.m` that it is reading the right data files. Add noise if needed.
4. Change prior ranges in `Set_Prior*.m`


# Major difference from the DC resistivity version:
- Not much! except it uses the code cR2 rather than R2 for forward modelling and SCI
- Note that in EKI, we first perform a resistvity-only (fixing phase angles as zeros, because they are small) inversion, and then a separate phase angle-only (fixing resistivity as mean from the previous step) inversion (in constrat to a joint resistivity/phase angle inversion in EKI)


U size of R2 grid

- Un{1,1}=RN; %size(EKI_grid) x 1
- Un{1,2}=L_means; %n_fields x1, `tempo = Un{1,2}` by the end of `Inversion.m`
- Un{1,3}=L_per_x; %zeros
- Un{1,4}=L_per_y; %zeros
- Un{1,5}=fields_means; %n_fields x1



`physical.m`: remove change to take away log conversions for IP

For DC resisitvity, the values are log-transformed. For IP field, we are working with negative phase angles, so we add negative sign in `write_R2_sigma.m`

# Plotting results
- You can simply run `plot_tiled.m` to plot the EKI resultant images. Note it will need a recent version of MATLAB. Note dialog boxes will pop up to ask you which vtk file to plot. To plot EKI results, you need to choose `forward_model.vtk`. To plot SCI results, choose `inv/f001_res.vtk`. Then simply choose the variable to plot. 
- You can use `plot_prior.m` to plot some realizations of the prior model.

## plotting (update, because I only had MATLAB R2018)
- The main plotting script is `plot_subplots.m`, which relies on subplots
- There will be dropdown boxes asking for mesh files for true/SCI/EKI. Note that for the EKI bits, we only care about the mesh and the data is read separately. I think they should be in this order `forward_dat.vtk`, `inv/f001_res.vtk`, `forward_dat.vtk`, `forward_dat.vtk`
- And then there will be dropdowns for fields to plot in each subplot. You can probably figure out what matches what. Feel free to change the script as you see fit.
- I was originally using `plot_tiled.m` as my plotting script but I stopped becauses I did not have MATLAB R2019+ at that time. You will probably find it to be easier to use since it supports tiled layout (but you have to adopt it yourself).


## Troubleshoot
- solution converge immediately: most likely data used for synthetic generation is used for inversion. Check whether you are using `protocol.dat` (field data) or `cR2_forward.dat` (synthetic data) in the `get_R2_data()` lines in `EKI.m`
- Solution not updating and/or only 1 sigma_mean value (instead of 2 or 3). Double in `cR2.in`, `num_region=0` and file path is `resistivity.dat`. Otherwise your updated field is not wirtten!
- Duouble check `forward_model.dat`. Make sure domain is not cropped in template R2 forward run.
- Make sure `<project>/protocol.dat` has data and not just survey data (i.e. column 6 and 7 are present). If not, run `cp inv/protocol.dat .` at `<project>`.
- Make sure you are in the right  `<project>` directories!
- The line `system('wine64 ../../cR2.exe');` in `Tools/Inversion.m` may need to change to `system('wine ../../cR2.exe');` depending on your wine version.
- The codes are developed for Linux/Mac desktops or HPC (see `myjob.com` for an example job submission script. Modify the MATLAB script accordingly to run on Windows (and you won't need Wine to run cR2.exe if you do so).

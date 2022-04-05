# EKI_IP
extending [EKI_geophysics_2020](https://github.com/cmtso/EKI_geophysics_2020/) to induced polarization. Prepared for paper submission.

In particular, we use the above approach first for DC resistivity, then fixed the mean DC resistivity and invert for phase angles only.

# Getting started
Download cR2 [here](http://www.es.lancs.ac.uk/people/amb/Freeware/cR2/cR2.htm) and put **cR2.exe** in each of the subfolders.

You can find each of the subfolders as a use case.

# Use case
- `Surf_IP2`: surface synthetic example with 1/2 inclusions
- `Pow`: Pow catchment surface example (from Mejus thesis 2014)
- `PRB`: 2D cross-borehole for imaging permeable reactive barrier (Slater and Binley 2006 Geophysics)

# Plotting results
- You can simply run `plot_tiled.m` to plot the EKI resultant images. Note it will need a recent version of MATLAB. Note dialog boxes will pop up to ask you which vtk file to plot. To plot EKI results, you need to choose `forward_model.vtk`. To plot SCI results, choose `inv/f001_res.vtk`. Then simply choose the variable to plot. 
- You can use `plot_prior.m` to plot some realizations of the prior model.

# Creating your own use cases
Follow these steps:
1. Make sure you can run the problem in cR2 as forward problem (put it in `inv/fwd`). ResIPy is a python package that you may find useful
2. Copy the folder to the <root subfolder>. Copy minimal input files to <root subfolder>/template
3. Double check lines in `EKI.m` that it is reading the right data files. Add noise if needed.
4. Change prior ranges in `Set_Prior*.m`


# Major difference from the DC resistivity version:
-


U size of R2 grid

- Un{1,1}=RN; %size(EKI_grid) x 1
- Un{1,2}=L_means; %n_fields x1, `tempo = Un{1,2}` by the end of `Inversion.m`
- Un{1,3}=L_per_x; %zeros
- Un{1,4}=L_per_y; %zeros
- Un{1,5}=fields_means; %n_fields x1



`physical.m`: remove change to take away log conversions for IP

For DC resisitvity, the values are log-transformed. For IP field, we are working with negative phase angles, so we add negative sign in `write_R2_sigma.m`


## Troubleshoot
- solution converge immediately: most likely data used for synthetic generation is used for inversion. Check whether you are using `protocol.dat` (field data) or `cR2_forward.dat` (synthetic data) in the `get_R2_data()` lines in `EKI.m`
- Solution not updating and/or only 1 sigma_mean value (instead of 2 or 3). Double in `cR2.in`, `num_region=0` and file path is `resistivity.dat`. Otherwise your updated field is not wirtten!
- Duouble check `forward_model.dat`. Make sure domain is not cropped in template R2 forward run.

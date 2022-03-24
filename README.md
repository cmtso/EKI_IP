# EKI_IP
extending [EKI_geophysics_2020](https://github.com/cmtso/EKI_geophysics_2020/) to induced polarization. Prepared for paper submission.

# Use case
- `Surf_IP2`: surface synthetic example with 1/2 inclusions
- `Pow`: Pow catchment surface example (from Mejus thesis 2014)
- `PRB`: 2D cross-borehole for imaging permeable reactive barrier (Slater and Binley 2006 Geophysics)



# Major difference from the DC resistivity version:
-


EKI put everything in log so that it's positive, maybe should add negative sign to phase angle later.


U size of R2 grid

- Un{1,1}=RN; %size(EKI_grid) x 1
- Un{1,2}=L_means; %n_fields x1
- Un{1,3}=L_per_x; %zeros
- Un{1,4}=L_per_y; %zeros
- Un{1,5}=fields_means; %n_fields x1



`physical.m`: remove change to take away log conversions for IP

All fileds must be positive. For IP field, keep it that way and add negative sign in `write_R2_sigma.m`


## Troubleshoot
- solution converge immediately: most likely data used for synthetic generation is used for inversion. Check whether you are using `protocol.dat` (field data) or `cR2_forward.dat` (synthetic data) in the `get_R2_data()` lines in `EKI.m`
- Solution not updating and/or only 1 sigma_mean value (instead of 2 or 3). Double in `cR2.in`, `num_region=0` and file path is `resistivity.dat`. Otherwise your updated field is not wirtten!
- Duouble check `forward_model.dat`. Make sure domain is not cropped in template R2 forward run.

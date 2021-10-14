# EKI_IP
extending EKI_geophysics_2020 to induced polarization


# Major difference from the DC resistivity version:
-


EKI put everything in log so thatit's positive, maybe should add negative sign to phase angle later.


U size ofo R2 grid

Un{1,1}=RN; %size(EKI_grid) x 1
Un{1,2}=L_means; %n_fields x1
Un{1,3}=L_per_x; %zeros
Un{1,4}=L_per_y; %zeros
Un{1,5}=fields_means; %n_fields x1

clear all

%%%% Procedure %%%
% -- set up grid and run forward problem in R2
% -- obs. data format should be in that of protocol.dat for R2

addpath('Tools')
nseed=1;
rng(nseed*129)
%R2_path = pwd ; %'C:\Users\mtso\Downloads\pyr2-master\src\resipy\exe' ;


cond_file='resistivity.dat'; 


%%Write a routine to read grid from Andy's code and change the line below.
% trn is optional below, defaults to [0,0]. for translating the grid so that it kind of centers at (0,0) 

trn = [2 -4]; %(+ve x to move domain right,-ve y to move domain up,)
R2_Grid=get_R2_Grid('forward_model.dat',trn); % mustn't be cropped, use f001_res.dat or forward_model.dat

%%define conductivity values (these must be consisten with the ones from
%%the truth)
% note: R2 write files as resistivities

%%DON't NEED THIS ANYMORE (SEE Set_prior.m)
sigma2= 1;
sigma1= 1/100;


L=[6,14]; %dimensions of the 2D domain where we wish to recover conductivity 
%%for this choice of L 16x12 the domain is [-8, 8]x [-6,6]. Change if needed in Set_Grid. 

n=[24,56];

plot(R2_Grid.x,R2_Grid.y,'o'); hold on;
rectangle('Position',[-L(1)/2 -L(2)/2 L(1) L(2)]); hold off

Grid=Set_Grid(n,L);

option=0; %option=1 for variable lengthscale and option=0 for constant lengthscale
%%test code with option=0 first
n_fields=2;  %number of fields 2 or 3 

Pr=Set_prior(Grid,sigma1,sigma2,option,n_fields);

%sigma_truth = dlmread('forward_model.dat'); sigma_truth = 1./ sigma_truth(:,3);

%%generate synthetic data
%cd .. % 
noise=0.05;%0.01; %% percentage of noise added to true data

% NOTE: IP data more suitable to read actual modelled data errors that set
% 'noise', set a_wgt and b_wgt =0 in cR2.in

%%change this routine to read output (i.e. voltages) from Andy's code
data=get_R2_data('inv/fwd_full/cR2_forward.dat'); % protocol.dat for field problems, cR2_forward.dat for synthetic

%plot(get_R2_data('protocol.dat',7),get_R2_data('protocol.dat',9),'o') % error plot

%%get data from e4d for the simulation with the true conductivity
Data.data_noise_free=data;
noise_data1= noise*data; %get_R2_data('cR2_forward.dat',8); %noise*data;
noise_data2= 0.001; % Andy specifies %abs(max(data))*1e-5;%(max(abs(data))-min(abs(data)))*1e-4;
Data.data=data+noise_data1.*randn(length(data),1)+noise_data2.*randn(length(data),1); %%add two components of noise to the data
Data.inv_sqrt_C=diag(1./sqrt(noise_data1.^2+noise_data2.^2)); %inverse of square root of measurement error covariance
save('Data_DC','Data')
%%%%%%%%%%%%%%%%%%We need this for the prior%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%****************************Prior Definition %****************************


N_En=300;  %ensemble size

Un=Get_prior(Grid,Pr,N_En); 
save('Un_DC','Un')
load('Un_DC.mat')

out_file=strcat('Results_DC');
tuning=30;
data_type='DC';
sigma_mean=Inversion(R2_Grid,Grid,N_En,Pr,Un,Data,out_file,cond_file,tuning);
%% **************************** IP inversion %****************************


%%% can uncomment and modify if differ from DC

% option=0; %option=1 for variable lengthscale and option=0 for constant lengthscale, %%test code with option=0 first
%n_fields=3;  %number of fields 2 or 3 
% 
Pr=Set_prior_phase(Grid,sigma1,sigma2,option,n_fields);
% 
% %sigma_truth = dlmread('forward_model.dat'); sigma_truth = 1./ sigma_truth(:,3);
% 
% %%generate synthetic data
% %cd .. % 
noise=0.05;%0.01; %% percentage of noise added to true data
% 
% 
%%change this routine to read output (i.e. voltages) from Andy's code
data=get_R2_data('inv/fwd_full/cR2_forward.dat',7); % protocol.dat for field problems, cR2_forward.dat for synthetic

%%get data from e4d for the simulation with the true conductivity
Data.data_noise_free=data;
noise_data1= noise*data; %5.0; % abs phase error  %noise*data; %get_R2_data('protocol.dat',9); %noise*data;
noise_data2= 1.0; %mrad % Andy specifies %abs(max(data))*1e-5;%(max(abs(data))-min(abs(data)))*1e-4;
Data.data=data+noise_data1.*randn(length(data),1)+noise_data2.*randn(length(data),1); %%add two components of noise to the data
Data.inv_sqrt_C=diag(1./sqrt(noise_data1.^2+noise_data2.^2)); %inverse of square root of measurement error covariance
save('Data_IP','Data')

%%get reference sigma from DC inversion
sigma0 = getfield(load('Results_DC.mat', 'sigma_mean'),'sigma_mean');
%****************************Prior Definition %****************************


%N_En=300;  %ensemble size

Un=Get_prior(Grid,Pr,N_En); % Get_prior.m not doing anything different for phase
save('Un_IP','Un')
load('Un_IP.mat')

out_file=strcat('Results_IP');
tuning=30;
data_type='IP';

sigma_mean=Inversion(R2_Grid,Grid,N_En,Pr,Un,Data,out_file,cond_file,tuning,data_type,sigma0);


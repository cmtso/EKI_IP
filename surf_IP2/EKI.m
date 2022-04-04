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

trn = [6 0]; %(+ve x to move domain right,-ve y to move domain up,)
R2_Grid=get_R2_Grid('forward_model.dat',trn); % mustn't be cropped, use f001_res.dat or forward_model.dat

%%define conductivity values (these must be consisten with the ones from
%%the truth)
% note: R2 write files as resistivities

%%DON't NEED THIS ANYMORE (SEE Set_prior.m)
sigma2= 1;
sigma1= 1/100;


L=[24,8]; %dimensions of the 2D domain where we wish to recover conductivity 
%%for this choice of L 16x12 the domain is [-8, 8]x [-6,6]. Change if needed in Set_Grid. 

n=[96,32];

plot(R2_Grid.x,R2_Grid.y,'o')

Grid=Set_Grid(n,L);

option=0; %option=1 for variable lengthscale and option=0 for constant lengthscale
%%test code with option=0 first
n_fields=2;  %number of fields 2 or 3 

Pr=Set_prior(Grid,sigma1,sigma2,option,n_fields);

%sigma_truth = dlmread('forward_model.dat'); sigma_truth = 1./ sigma_truth(:,3);

%%generate synthetic data
%cd .. % 
noise=0.02;%0.01; %% percentage of noise added to true data

% NOTE: IP data more suitable to read actual modelled data errors that set
% 'noise', set a_wgt and b_wgt =0 in cR2.in

%%change this routine to read output (i.e. voltages) from Andy's code
data=get_R2_data('cR2_forward.dat');

%plot(get_R2_data('protocol.dat',7),get_R2_data('protocol.dat',9),'o') % error plot

%%get data from e4d for the simulation with the true conductivity
Data.data_noise_free=data;
noise_data1= noise*data; %get_R2_data('cR2_forward.dat',8); %noise*data;
noise_data2= 0.0015; % Andy specifies %abs(max(data))*1e-5;%(max(abs(data))-min(abs(data)))*1e-4;
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
n_fields=3;  %number of fields 2 or 3 
% 
Pr=Set_prior_phase(Grid,sigma1,sigma2,option,n_fields);
% 
% %sigma_truth = dlmread('forward_model.dat'); sigma_truth = 1./ sigma_truth(:,3);
% 
% %%generate synthetic data
% %cd .. % 
noise=0.02;%0.01; %% percentage of noise added to true data
% 
% 
%%change this routine to read output (i.e. voltages) from Andy's code
data=get_R2_data('cR2_forward.dat',7);

%%get data from e4d for the simulation with the true conductivity
Data.data_noise_free=data;
noise_data1= noise*data; %get_R2_data('protocol.dat',9); %noise*data;
noise_data2= 0.0015; % Andy specifies %abs(max(data))*1e-5;%(max(abs(data))-min(abs(data)))*1e-4;
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

%% **************************** Post processing %****************************
% read vtk file (get mesh info), then add results to the vtk. struct

clear vtk

load('Results_DC.mat') % change iter # if needed

for i = 1:size(sigma,2)
    sigma_zone(:,i) = unique(sigma(:,i))' ;
    [~,~,zones(:,i)] = unique(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std(log10(1./sigma(i,:)))';
end
% a(1,:) = sum(zones'==1);
% a(2,:) = sum(zones'==2);
% a(3,:) = sum(zones'==3);
%a(any(zones' ==1)' & any(zones' ==2)'& any(zones' ==3)',:);
cells_123 = find(any(zones' ==1)' & any(zones' ==2)'& any(zones' ==3)');

subplot(131), histogram(log10(1./sigma_zone(1,:))),title('zone 1'),ylabel('counts')
subplot(132), histogram(log10(1./sigma_zone(2,:))),title('zone 2'),xlabel('$\mathrm{log_{10}} (\rho)$','Interpreter','latex','FontSize',16) 
subplot(133), histogram(log10(1./sigma_zone(3,:))),title('zone 3')
subplot(131), histogram((sigma_zone(1,:))),title('zone 1'),ylabel('counts')
subplot(132), histogram((sigma_zone(2,:))),title('zone 2'),xlabel('$\mathrm{phase (mrad)}$','Interpreter','latex','FontSize',16) 
subplot(133), histogram((sigma_zone(3,:))),title('zone 3')

% (1) histogram
% (2) zone 1/2/3 probability map


vtk = read_vtk() ; 
% ##vtk = add_vtk_scalar(vtk,{"Mean resistivity","Zone 1 probability"}, ...
% ##          [1./sigma_mean (zone1_prob/300)'] ) ; % add scalar variable to the vtk struct

vtk.scalar_data = [vtk.scalar_data log10(1./sigma_mean) ...
    sum(zones'==2)'./300 sigma_std' sigma_std'./log10(1./sigma_mean)] ;
add_list = {"mean log_1_0 resistivity","Zone 2 probability",...
    "std(log_1_0 resistivity)", "CV(log_1_0 resistivity)"} ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

fieldnames(vtk)


plot_vtk_2D()  % will show drop down menu to let you selct variable

elec = dlmread("electrodes.dat"); hold on;
plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
xlabel('$X [\mathrm{m}]$','Interpreter','latex','FontSize',16)
ylabel('$Z [\mathrm{m}]$','Interpreter','latex','FontSize',16)
axis equal


%%% also for IP
load('Results_IP_35.mat')
for i = 1:size(sigma,2)
    sigma_zone(:,i) = unique(sigma(:,i))' ;
    [~,~,zones(:,i)] = unique(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std((1./sigma(i,:)))';
end
vtk.scalar_data = [vtk.scalar_data (1./sigma_mean) ...
    sum(zones'==2)'./300 sigma_std' sigma_std'./(1./sigma_mean)] ;
add_list = {"mean phase (mrad)","Zone 2 probability_phase", ...
    "std(phase)", "CV(phase)"} ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

%%%


fwd = dlmread("forward_model.dat"); hold on;
fwd = fwd(cells_123,:);
plot(fwd(:,1),fwd(:,2),'rX','Markersize',10); hold off;

poly = dlmread("polyline.txt"); hold on;
for i=1:2,plot(poly(:,1),poly(:,2),'LineWidth',2);end; hold off

text(60,-2,'168.8 \Omega m')
text(60,-7,'55.8 \Omega m','color','w')
%%% optional
rectangle('Position',[-29 1270 250 150],'LineStyle',':','LineWidth',1.5)
axis tight
xlim([-8 8])
ylim([-8 8])
axis square
%set(gca,'CLim',[0 0.2]) % for sd
% get(gcf,'Position')
% 
% ans =
% 
%      1     1   808   390
%      1     1   808   471
% 1     1   498   567


%EKI.m

% for i = 1:size(res0,1)
%     if(res0(i,1) > -2.5 && res0(i,1) < 0.5 && res0(i,2) > -3.5 && res0(i,2) < 0.5)
%         res0(i,3) = 1;
%     end
% end
% res0(:,4) = log10(res0(:,3));

%scatter(R2_Grid.x,R2_Grid.y,[],1./sigma_mean)

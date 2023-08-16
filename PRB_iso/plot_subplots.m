
% 20220610: not working yet for PRB field

% % make sure to uncomment 'figure' in plot_vtk_2D.m first
% 
% t = tiledlayout(2,1); % Requires R2019b or later
% ax1 = nexttile;
% plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
% ax2 = nexttile;
% plot_vtk_2D()  % will show drop down menu to let you selct variable
% % Link the axes
% linkaxes([ax1,ax2],'x');
% 
% %title(t,'My Title')% joint tile
% xlabel(t,'x-values')
% ylabel(t,'y-values')
% 
% % Move plots closer together
% xticklabels(ax1,{})
% t.TileSpacing = 'compact';


%%


elec = dlmread("electrodes.dat"); 
sigma_clim = [-1. 2.];
mrad_clim = [-20 0];

%% part1: read true first
clear vtk
vtk = read_vtk() ; % choose f001_res_SCI.vtk
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));
subplot(271);
plot_vtk_str = 'Magnitude(log10)'; plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title({'True:',' log10 resistivity in \Omegam'})
caxis(sigma_clim)
draw_interface


subplot(278);
plot_vtk_str = 'Phase(mrad)'; plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title('True: phase (mrad)')
caxis(mrad_clim)
draw_interface

%% read smooth
clear vtk
vtk = read_vtk() ; % choose f001_res_SCI.vtk
vtk.scalar_list(end+1:end+2) = {'SCI: log10 resistivity in \Omegam', 'SCI: Phase(mrad)'}; 
vtk.scalar_data = [vtk.scalar_data log10(vtk.scalar_data(:,1)) vtk.scalar_data(:,2)] ;
subplot(272);
plot_vtk_str='SCI: log10 resistivity in \Omegam';plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title({'SCI (smooth):',' log10 resistivity in \Omegam'})
caxis(sigma_clim)
draw_interface


subplot(279);
plot_vtk_str = 'SCI: Phase(mrad)'; plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title({'SCI(smooth): ','phase (mrad)'})
caxis(mrad_clim)
draw_interface
%% part2read SCI
subplot(273);
clear vtk
vtk = read_vtk() ; %inv/f001_res.vtk

vtk.scalar_list(end+1:end+2) = {'SCI: log10 resistivity in \Omegam', 'SCI: Phase(mrad)'}; 
vtk.scalar_data = [vtk.scalar_data log10(vtk.scalar_data(:,1)) vtk.scalar_data(:,2)] ;
plot_vtk_str='SCI: log10 resistivity in \Omegam';plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title({'SCI (blocky):',' log10 resistivity in \Omegam'})
caxis(sigma_clim)
draw_interface


subplot(2,7,10);
plot_vtk_str = 'SCI: Phase(mrad)';plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title({'SCI (blocky):',' phase (mrad)'})
caxis(mrad_clim)
draw_interface
%%% part 2a: read_vtk from forward model then add other vtk.

clear vtk
vtk = read_vtk() ;vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

load('Results_DC.mat') % change iter # if needed
N_En=size(sigma,2);  %ensemble size
clear sigma_zone zones

for i = 1:size(sigma,2)
    sigma_zone(:,i) = uniquetol(sigma(:,i))' ;
    [~,~,zones(:,i)] = uniquetol(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std(log10(1./sigma(i,:)))';
    sigma_mean2(i) = mean(log10(1./sigma(i,:)));
end
cells_123 = find(any(zones' ==1)' & any(zones' ==2)'& any(zones' ==3)');

vtk.scalar_data = [vtk.scalar_data log10(1./sigma_mean) sigma_mean2'...
    sum(zones'==2)'./N_En sigma_std' sigma_std'./sigma_mean2'] ;
add_list = {"LS mean log_1_0 resistivity","mean log_1_0 resistivity","Zone 2 probability",...
    "std(log_1_0 resistivity)", "CV(log_1_0 resistivity)"} ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

fieldnames(vtk)

clear sigma_zone
%%% also for IP
load('Results_IP.mat')
for i = 1:size(sigma,2)
    sigma_zone(:,i) = uniquetol(sigma(:,i))' ;
    [~,~,zones(:,i)] = uniquetol(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std((sigma(i,:)))';
    sigma_mean2(i) = mean((sigma(i,:)));
end
vtk.scalar_data = [vtk.scalar_data (sigma_mean) sigma_mean2' ...
    sum(zones'==2)'./N_En sigma_std' sigma_std'./(sigma_mean2')] ;
add_list = {"LS mean phase (mrad)","mean phase (mrad)","Zone 2 probability_phase", ...
    "std(phase)", "CV(phase)"} ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

%%% Part 2b: plot EKI plots
subplot(274);
plot_vtk_str = 'mean log_1_0 resistivity';plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
caxis(sigma_clim)
title({'EKI: mean log10 ','resistivity in \Omegam'})
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
draw_interface

subplot(2,7,11);
cla
plot_vtk_str = 'mean phase (mrad)'; plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title({'EKI: mean ','phase (mrad)'})
caxis(mrad_clim)
draw_interface

subplot(275);
plot_vtk_str = 'LS mean log_1_0 resistivity'; plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
caxis(sigma_clim)
title({'EKI: log10 resistivity in \Omegam',' from mean level sets'})
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
draw_interface

subplot(2,7,12);
cla
plot_vtk_str = 'LS mean phase (mrad)'; plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title({'EKI: phase (mrad) from',' mean level sets'})
caxis(mrad_clim)
draw_interface

subplot(2,7,6);
plot_vtk_str = 'Zone 2 probability'; plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
caxis([0 1])
title({'EKI: zone 2 ','probability (resistivity)'})
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
draw_interface

subplot(2,7,13);
cla
plot_vtk_str = 'Zone 2 probability_phase';plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title({'EKI: zone 2 ','probability (phase)'})
caxis([0 1])
draw_interface

subplot(2,7,7);
plot_vtk_str = 'std(log_1_0 resistivity)'; plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title({'EKI: STD of',' log10 resistivity in \Omegam'})
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
draw_interface

subplot(2,7,14);
cla
plot_vtk_str = 'std(phase)'; plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title({'EKI: STD of ','phase (mrad)'})
draw_interface




%% imaginary conductivity
figure
sigma0 = load('Results_DC.mat','sigma'); sigma0 = sigma0.sigma; % keep as S/m
phase = load('Results_IP.mat','sigma'); phase = phase.sigma; % change iter # if needed
phase(phase > -1.0) = mean(mean(phase));% fix positive phase angle
sigma2 = -phase/1000.*sigma0; % mrad to rad first
sigma0_mean = mean(log10(sigma0),2);
sigma0_std = std(log10(sigma0),0,2);
sigma2_mean = mean(log10(sigma2),2);
sigma2_std = std(log10(sigma2),0,2);

vtk.scalar_data = [vtk.scalar_data sigma2_mean sigma2_std] ;
add_list = {"mean log_1_0 imag cond","std(log_1_0 imag cond)"} ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 


subplot(121);
plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title({'EKI: mean of log10 imaginary ','conductivity in S/m'})
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
draw_interface

subplot(122);
cla
plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title({'EKI: STD of log10 imaginary ','conductivity in S/m'})
draw_interface

%%
ax = nexttile(9); cla;
plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title('EKI: CV of log10 resistivity in \Omegam')
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)


ax = nexttile(10);
cla
plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title('EKI: CV of phase (mrad)')

for i = 1:10
    ax=nexttile(i)
    rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
    ylim([-3.8333 0])
end

set(findall(gcf,'-property','FontSize'),'FontSize',11)
set(gcf,'color','w'); % full screen
exportgraphics(gcf,'img/tiled_R1.eps')
exportgraphics(gcf,'img/tiled_R1.png')

%% prior and posterior samples and histogram
% prior histogram

load('Prior_DC.mat')
for i = 1:size(sigma,2)
    sigma_zone(:,i) = uniquetol(sigma(:,i))' ;
    [~,~,zones(:,i)] = uniquetol(sigma(:,i)) ;
end

subplot(221)
hist(log10(1./sigma_zone'), 500,'facecolor',{'r','b'}), title('Prior')
legend('Zone 1', 'Zone 2')
xlabel('log_1_0 resistivity in \Omegam')
ylabel('count'), xlim([-1 3])
legend('boxoff')

load('Prior_IP.mat')
for i = 1:size(sigma,2)
    sigma_zone(:,i) = uniquetol(sigma(:,i))' ;
    [~,~,zones(:,i)] = uniquetol(sigma(:,i)) ;
end
subplot(223)
hist((sigma_zone'), 500), title('Prior')
legend('Zone 1', 'Zone 2')
xlabel('Phase angle in mrad')
ylabel('count'), xlim(mrad_clim)
legend('boxoff')


% posterior histogram
load('Results_DC.mat')
for i = 1:size(sigma,2)
    sigma_zone(:,i) = uniquetol(sigma(:,i))' ;
    [~,~,zones(:,i)] = uniquetol(sigma(:,i)) ;
end

subplot(222)
hist(log10(1./sigma_zone'), 500), title('Posterior')
legend('Zone 1', 'Zone 2')
xlabel('log_1_0 resistivity in \Omegam')
ylabel('count'), xlim(sigma_clim)
legend('boxoff')

load('Results_IP.mat')
for i = 1:size(sigma,2)
    sigma_zone(:,i) = uniquetol(sigma(:,i))' ;
    [~,~,zones(:,i)] = uniquetol(sigma(:,i)) ;
end
subplot(224)
hist((sigma_zone'), 500), title('Posterior')
legend('Zone 1', 'Zone 2')
xlabel('Phase angle in mrad')
ylabel('count'), %xlim(mrad_clim)
legend('boxoff')



%% prior and posterior realizations
elec = dlmread("electrodes.dat"); 
sigma_clim = [-1. 2.5];
mrad_clim = [-20 0];

clear vtk
sample_i = [3 30 50 60 145];
vtk = read_vtk() ; % choose f001_res_SCI.vtk
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));
figure
% DC
load('Prior_DC.mat')
for iii = 1:5
    %subplot(5,1,iii);
    subplot(2,5,ceil(iii*2/2))
    vtk.scalar_list(end+1) = {num2str(sample_i(iii))}; 
    vtk.scalar_data = [vtk.scalar_data log10(1./sigma(:,sample_i(iii)))] ; % resistivity
    plot_vtk_str= num2str(sample_i(iii)); plot_vtk_2D(); %pre-select varaible  
    hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
    axis equal
    title(sprintf('Prior resistivity: #%d', sample_i(iii)))
    caxis(sigma_clim)
end

load('Results_DC.mat') % posterior
for iii = 1:5
    %subplot(5,1,iii);
    subplot(2,5,5+ceil(iii*2/2))
    vtk.scalar_list(end+1) = {num2str(sample_i(iii))}; 
    vtk.scalar_data = [vtk.scalar_data log10(1./sigma(:,sample_i(iii)))] ; % resistivity
    plot_vtk_str= num2str(sample_i(iii)); plot_vtk_2D(); %pre-select varaible  
    hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
    axis equal
    title(sprintf('Posterior resistivity: #%d', sample_i(iii)))
    caxis(sigma_clim)
end
set(findall(gcf,'-property','FontSize'),'FontSize',11)
set(gcf,'color','w');

%IP
figure
load('Prior_IP.mat')
for iii = 1:5
    %subplot(5,1,iii);
    subplot(2,5,ceil(iii*2/2))
    vtk.scalar_list(end+1) = {num2str(sample_i(iii))}; 
    vtk.scalar_data = [vtk.scalar_data (sigma(:,sample_i(iii)))] ; % phase
    plot_vtk_str= num2str(sample_i(iii)); plot_vtk_2D(); %pre-select varaible  
    hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
    axis equal
    title(sprintf('Prior phase angle: #%d', sample_i(iii)))
    caxis(mrad_clim)
end

load('Results_IP.mat') % posterior
for iii = 1:5
    %subplot(5,1,iii);
    subplot(2,5,5+ceil(iii*2/2))
    vtk.scalar_list(end+1) = {num2str(sample_i(iii))}; 
    vtk.scalar_data = [vtk.scalar_data (sigma(:,sample_i(iii)))] ; % phase
    plot_vtk_str= num2str(sample_i(iii)); plot_vtk_2D(); %pre-select varaible  
    hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
    axis equal
    title(sprintf('Posterior phase angle: #%d', sample_i(iii)))
    caxis(mrad_clim)
end
set(findall(gcf,'-property','FontSize'),'FontSize',11)
set(gcf,'color','w');


%% misfit
figure
load('Results_DC.mat')
semilogy(Misfit./N_En,"LineWidth",2)
hold on
load('Results_IP.mat')
semilogy(Misfit./N_En,'LineWidth',2)
ylabel('Un-normalized misfit')
xlabel('Iteration')
legend('ERT inversion','IP inversion')
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
sigma_clim = [1. 2.5];
mrad_clim = [-20 0];

%% part1: read true first
clear vtk
vtk = read_vtk() ; % choose f001_res_SCI.vtk
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

subplot(521);
plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title('True: log10 resistivity in \Omegam')
caxis(sigma_clim)



subplot(522);
plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title('True: phase (mrad)')
caxis(mrad_clim)

%% part2read SCI
subplot(523);
clear vtk
vtk = read_vtk() ; %inv/f001_res.vtk

vtk.scalar_list(end+1:end+2) = {'SCI: log10 resistivity in \Omegam', 'SCI: Phase(mrad)'}; 
vtk.scalar_data = [vtk.scalar_data log10(vtk.scalar_data(:,1)) vtk.scalar_data(:,2)] ;
plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title('SCI: log10 resistivity in \Omegam')
caxis(sigma_clim)



subplot(524);
plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title('SCI: phase (mrad)')
caxis(mrad_clim)

%%% part 2a: read_vtk from forward model then add other vtk.

clear vtk
vtk = read_vtk() ;vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

load('Results_DC.mat') % change iter # if needed
clear sigma_zone zones

for i = 1:size(sigma,2)
    sigma_zone(:,i) = unique(sigma(:,i))' ;
    [~,~,zones(:,i)] = unique(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std(log10(1./sigma(i,:)))';
end
cells_123 = find(any(zones' ==1)' & any(zones' ==2)'& any(zones' ==3)');

vtk.scalar_data = [vtk.scalar_data log10(1./sigma_mean) ...
    sum(zones'==2)'./300 sigma_std' sigma_std'./log10(1./sigma_mean)] ;
add_list = {"mean log_1_0 resistivity","Zone 2 probability",...
    "std(log_1_0 resistivity)", "CV(log_1_0 resistivity)"} ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

fieldnames(vtk)

clear sigma_zone
%%% also for IP
load('Results_IP.mat')
for i = 1:size(sigma,2)
    sigma_zone(:,i) = unique(sigma(:,i))' ;
    [~,~,zones(:,i)] = unique(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std((sigma(i,:)))';
end
vtk.scalar_data = [vtk.scalar_data (sigma_mean) ...
    sum(zones'==2)'./300 sigma_std' sigma_std'./(sigma_mean)] ;
add_list = {"mean phase (mrad)","Zone 2 probability_phase", ...
    "std(phase)", "CV(phase)"} ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

%%% Part 2b: plot EKI plots
subplot(5,2,5);
plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
caxis(sigma_clim)
title('EKI: mean log10 resistivity in \Omegam')
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)


subplot(5,2,6);
cla
plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title('EKI: mean phase (mrad)')
caxis(mrad_clim)

subplot(5,2,7);
plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
caxis([0 1])
title('EKI: zone 2 probability (resistivity)')
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)


subplot(5,2,8);
cla
plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title('EKI: zone 2 probability (phase)')
caxis([0 1])

subplot(5,2,9);
plot_vtk_2D()  % will show drop down menu to let you selct variableax2 = nexttile;
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
title('EKI: STD of log10 resistivity in \Omegam')
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)


subplot(5,2,10);
cla
plot_vtk_2D() 
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
rectangle('Position',[min(vtk.polyline(:,1)) min(vtk.polyline(:,2)) range(vtk.polyline(:,1)) range(vtk.polyline(:,2))],'LineStyle','-','LineWidth',0.5)
title('EKI: STD of phase (mrad)')



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
%%

%% misfit
figure
load('Results_DC.mat')
semilogy(Misfit./300,"LineWidth",2)
hold on
load('Results_IP.mat')
semilogy(Misfit./300,'LineWidth',2)
ylabel('Un-normalized misfit')
xlabel('Iteration')
legend('ERT inversion','IP inversion')
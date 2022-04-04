% plot some priors
load('Prior_DC.mat')
elec = dlmread('electrodes.dat');

vtk = read_vtk() ; % choose f001_res_SCI.vtk
vtk.scalar_data = [vtk.scalar_data log10(1./sigma) ] ;
add_list = cellstr(num2str([1:size(sigma,2)].','%d'))' ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));
isub = [1,3,4,8,9,19,44] +5
for i = 1:length(isub)
    subplot(length(isub),1,i)
    if i==4,ylabel('$Y [\mathrm{m}]$','Interpreter','latex','FontSize',16), end
    if i~=length(isub),set(gca,'xticklabel',[]) ;end

    vtk_ii = isub(i)
    plot_vtk_2D()
    caxis([1 2.5])
    hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;

end
xlabel('$X [\mathrm{m}]$','Interpreter','latex','FontSize',16)


load('Prior_IP.mat')
vtk = read_vtk() ; % choose f001_res_SCI.vtk
vtk.scalar_data = [vtk.scalar_data sigma ] ;
add_list = cellstr(num2str([1:size(sigma,2)].','%d'))' ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

isub = [1,3,4,8,9,19,44] +5
for i = 1:length(isub)
    subplot(length(isub),1,i)
    if i==4,ylabel('$Y [\mathrm{m}]$','Interpreter','latex','FontSize',16), end
    if i~=length(isub),set(gca,'xticklabel',[]) ;end

    vtk_ii = isub(i)
    plot_vtk_2D()
    caxis([-20 0])
    hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;

end
xlabel('$X [\mathrm{m}]$','Interpreter','latex','FontSize',16)


find(strcmp(vtk.scalar_list, 'Phase(mrad)'))
find(strcmp(vtk.scalar_list, ))

%% plot prior mean, zone 2 and std
clear vtk_ii sigma_mean sigma_zone
load('Prior_DC.mat')
vtk =read_vtk();
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

sigma_mean = mean(sigma,2);

for i = 1:size(sigma,2)
    sigma_zone(:,i) = unique(sigma(:,i))' ;
    [~,~,zones(:,i)] = unique(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std((1./log10(sigma(i,:))))';
end
vtk.scalar_data = [vtk.scalar_data log10(1./sigma_mean) ...
    sum(zones'==2)'./size(sigma,2) sigma_std' sigma_std'./log10(1./sigma_mean)] ;
add_list = {"mean log_1_0 resistivity","Zone 2 probability",...
    "std(log_1_0 resistivity)", "CV(log_1_0 resistivity)"} ; 
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

%% IP
clear all
vtk =read_vtk();
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));
load('Prior_IP.mat')

sigma_mean = mean(sigma,2);

for i = 1:size(sigma,2)
    %sigma_zone(:,i) = unique(sigma(:,i))' ;
    [~,~,zones(:,i)] = unique(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std((sigma(i,:)))';
end
vtk.scalar_data = [vtk.scalar_data (sigma_mean) ...
    sum(zones'==2)'./size(sigma,2) sigma_std' sigma_std'./(sigma_mean)] ;
add_list = {"mean phase (mrad)","Zone 2 probability_phase", ...
    "std(phase)", "CV(phase)"} ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

for i = 1:3
    
    subplot(3,1,i)
    if i==2,ylabel('$Y [\mathrm{m}]$','Interpreter','latex','FontSize',16), end
    if i~=3,set(gca,'xticklabel',[]) ;end
    plot_vtk_2D()
    hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;

end
xlabel('$X [\mathrm{m}]$','Interpreter','latex','FontSize',16)
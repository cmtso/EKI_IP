% plot some priors
load('Prior_DC.mat')
vtk = read_vtk() ; % choose f001_res_SCI.vtk
vtk.scalar_data = [vtk.scalar_data log10(1./sigma) ] ;
add_list = cellstr(num2str([1:size(sigma,2)].','%d'))' ;
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

isub = [1,3,4] +5
for i = 1:length(isub)
    subplot(length(isub),1,i)
    vtk_ii = isub(i)
    plot_vtk_2D()
end

find(strcmp(vtk.scalar_list, 'Phase(mrad)'))
find(strcmp(vtk.scalar_list, ))

%% plot prior mean, zone 2 and std
clear vtk_ii sigma_mean

sigma_mean = mean(sigma,2);

for i = 1:size(sigma,2)
    sigma_zone(:,i) = unique(sigma(:,i))' ;
    [~,~,zones(:,i)] = unique(sigma(:,i)) ;
end
for i = 1:size(sigma,1)
    sigma_std(i) = std((1./sigma(i,:)))';
end
vtk.scalar_data = [vtk.scalar_data log10(1./sigma_mean) ...
    sum(zones'==2)'./size(sigma,2) sigma_std' sigma_std'./log10(1./sigma_mean)] ;
add_list = {"mean log_1_0 resistivity","Zone 2 probability",...
    "std(log_1_0 resistivity)", "CV(log_1_0 resistivity)"} ; 
vtk.scalar_list(end+1:end+numel(add_list)) = add_list; 

for i = 1:3
    subplot(3,1,i)
    plot_vtk_2D()
    
end

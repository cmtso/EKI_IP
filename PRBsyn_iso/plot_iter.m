% plot results of all iterations
load('Results_DC.mat')
sigmean = zeros(length(Misfit),3);

for iter = 1:34 %length(Misfit)
    subplot(6,6,iter)
    %subplot(3,1,jj)
    load(sprintf('Results_DC_%d.mat',iter))
    sigmean(iter,1:2) =unique(1./sigma_mean);
    
    
    for i = 1:size(sigma,2)
    sigma_zone(:,i) = unique(sigma(:,i))' ;
    [~,~,zones(:,i)] = unique(sigma(:,i)) ;
    end
    for i = 1:size(sigma,1)
    sigma_std(i) = std(log10(1./sigma(i,:)))';
    end
    vtk = read_vtk('forward_model.vtk') ;
    % ##vtk = add_vtk_scalar(vtk,{"Mean resistivity","Zone 1 probability"}, ...
    % ##          [1./sigma_mean (zone1_prob/300)'] ) ; % add scalar variable to the vtk struct
    vtk.scalar_data = [vtk.scalar_data log10(1./sigma_mean) ...
    sum(zones'==2)'./300 sigma_std' sigma_std'./log10(1./sigma_mean)] ;
    add_list = {"mean log_1_0 resistivity","Zone 2 probability",...
    "std(log_1_0 resistivity)", "CV(log_1_0 resistivity)"} ;
    vtk.scalar_list(end+1:end+numel(add_list)) = add_list;
    vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));
    fieldnames(vtk);
    vtk_ii = 6; % override selection in plot_vtk_2D() to select mean resistivity
    plot_vtk_2D();  % will show drop down menu to let you selct variable
    elec = dlmread("electrodes.dat"); hold on;
    plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
%     xlabel('$X [\mathrm{m}]$','Interpreter','latex','FontSize',16)
%     ylabel('$Z [\mathrm{m}]$','Interpreter','latex','FontSize',16)
    title(iter)
    axis equal
end
clear vtk_ii
figure
subplot(121)
semilogy(1:length(Misfit),sigmean(:,1),1:length(Misfit),sigmean(:,2))
xlabel('iteration'), ylabel('Resistvity'), legend('zone 1', 'zone 2','Location','east')
subplot(122)
semilogy(1:length(Misfit),Misfit)
xlabel('iteration'), ylabel('Misfit'),

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
load('Results_IP.mat')
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


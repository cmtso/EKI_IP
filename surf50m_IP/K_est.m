% K estimatio from IP with uncertainty propagation
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vtk = read_vtk();
elec = dlmread('electrodes.dat');
vtk.polyline = dlmread(fullfile(vtk.folder, 'polyline.txt'));

sigma0 = load('Results_DC.mat','sigma'); sigma0 = sigma0.sigma; % keep as S/m
phase = load('Results_IP.mat','sigma'); phase = phase.sigma; % change iter # if needed
phase(phase > -1.0) = mean(mean(phase));% fix positive phase angle
sigma2 = -phase/1000.*sigma0; % mrad to rad first


%%
sigma0_mean = mean(log10(sigma0),2);
sigma0_std = std(log10(sigma0),0,2);
sigma2_mean = mean(log10(sigma2),2);
sigma2_std = std(log10(sigma2),0,2);
sigma0_true = vtk.scalar_data(:,4); % Sigma_real(log10)
sigma2_true = vtk.scalar_data(:,5); % Sigma_imag(log10)

% fitting Weller et al (2015) model eqn 24
a_mean = -15.1;
b_mean = 0.97;
c_mean = 2.29;
constant = 0; %3; % account for S/m to mS/m in sigma0 and sigma2
%k_mean = a_mean*sigma0_mean.^b_mean.*sigma2_mean.^(-c_mean); %normal
k_mean = (a_mean)+b_mean*sigma0_mean-c_mean*sigma2_mean + constant; %log10 

k_true = (a_mean)+b_mean*sigma0_true-c_mean*sigma2_true + constant; %log10 

subplot(411)
vtk.scalar_list(end+1) = {'true log_1_0 k (m^2)'}; 
vtk.scalar_data = [vtk.scalar_data k_true] ;
plot_vtk_2D()
set(gca,'ColorScale','linear')
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
caxis ([min(k_true),max(k_true)])
caxis([-10 -8])

subplot(412)
vtk.scalar_list(end+1) = {'mean log_1_0 k (m^2)'}; 
vtk.scalar_data = [vtk.scalar_data k_mean] ;
plot_vtk_2D()
set(gca,'ColorScale','linear')
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
axis equal
caxis ([min(k_mean),max(k_mean)])
%% std(log10 K)
a_var = 1.01 ^2;
b_var = 0.66 ^2;
c_var = 0.25 ^2;

k_varterm.a = zeros(length(k_mean),1);
k_varterm.b = zeros(length(k_mean),1);
k_varterm.c = zeros(length(k_mean),1);
k_varterm.s0 = zeros(length(k_mean),1);
k_varterm.s2 = zeros(length(k_mean),1);



for i = 1:length(sigma0_mean)
    da = 1;
    db = sigma0_mean(i);
    dc = sigma2_mean(i); %-ve but doesn't matter
    d0 = b_mean;
    d2 = c_mean; %-ve but doesn't matter
    k_varterm.a(i) =  da^2*a_var;
    k_varterm.b(i) =  db^2*b_var;
    k_varterm.c(i) =  dc^2*c_var;
    k_varterm.s0(i)=  d0^2*sigma0_std(i)^2 ;
    k_varterm.s2(i)=  d2^2*sigma2_std(i)^2 ;
end

k_var = k_varterm.a + k_varterm.b + k_varterm.c + ...
        k_varterm.s0 + k_varterm.s2;
vtk.scalar_list(end+1) = {'std log_1_0 k (m^2)'}; 
vtk.scalar_data = [vtk.scalar_data sqrt(k_var)] ;
vtk.scalar_list(end+1) = {'|CV| log_1_0 k'}; 
vtk.scalar_data = [vtk.scalar_data abs(sqrt(k_var)./k_mean)] ;

subplot(413)

plot_vtk_2D()
%set(gca,'ColorScale','log')
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
%caxis([0 0.045])
ylabel('$Y [\mathrm{m}]$','Interpreter','latex','FontSize',16)
axis equal

subplot(414)
plot_vtk_2D()
%set(gca,'ColorScale','log')
hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
xlabel('$X [\mathrm{m}]$','Interpreter','latex','FontSize',16)
axis equal

%%
figure
vtk.scalar_list(end+1:end+5) = {'a component','b component','c component',...
    '\sigma'' component','\sigma'''' component'}; 
vtk.scalar_data = [vtk.scalar_data [k_varterm.a k_varterm.b k_varterm.c k_varterm.s0 k_varterm.s2]./k_var] ;
for ii = 1:5
    subplot(5,1,ii)
    if ii==3,ylabel('$Y [\mathrm{m}]$','Interpreter','latex','FontSize',16), end
    plot_vtk_2D()
    %set(gca,'ColorScale','log')
    hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
    caxis([0 inf])

end
xlabel('$X [\mathrm{m}]$','Interpreter','latex','FontSize',16)

%% std(k)-- remove
% a_var = (10^(2e-15)) ^2;
% b_var = 0.18 ^2;
% c_var = 0.14 ^2;
% 
% k_var = zeros(length(k_mean),1);
% 
% for i = 1:length(sigma0_mean)
%     da = (sigma0_mean(i)^b_mean*sigma2_mean(i)^(-c_mean))^2;
%     db = da*(a_mean*log(sigma0_mean(i)))^2;
%     dc = da*(a_mean*log(sigma2_mean(i)))^2;
%     d0 = da*(a_mean*b_mean/sigma0_mean(i))^2;
%     d2 = da*(a_mean*c_mean/sigma2_mean(i))^2;
%     k_var(i) =  da^2*a_var + db^2*b_var + dc^2*c_var + ...
%                 d0^2*sigma0_std(i)^2 + d2^2*sigma2_std(i)^2;
% end
% 
% vtk.scalar_list(end+1) = {'std k (m^2)'}; 
% vtk.scalar_data = [vtk.scalar_data sqrt(k_var)] ;
% vtk.scalar_list(end+1) = {'CV k'}; 
% vtk.scalar_data = [vtk.scalar_data sqrt(k_var)./k_mean] ;
% plot_vtk_2D()
% set(gca,'ColorScale','log')
% hold on; plot(elec(:,1),elec(:,2),'ko','Markersize',2,'MarkerFaceColor','k'); hold off;
% axis equal

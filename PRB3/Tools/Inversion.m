function sigma_mean=Inversion(R2_Grid,Grid,N_En,Pr,Un,Data,out_file,cond_file,tuning,data_type, sigma0)

% data_type and sigma0 are optional argument

if ~exist('data_type','var')
 % data_type does not exist, so default it to something
    data_type = 'DC';
end

switch data_type
    case 'IP'
        icol = 7;
    case 'DC'
        icol = 6;
end

disp(icol)

%% 
%%%Generate prior of conductivities 
f_mean= @(A) mean(A,2);
%%Mean 
Un_m = cellfun(f_mean,Un,'un',0);

sigma=zeros(length(R2_Grid.x),N_En);


for en=1:N_En
    [sigma(:,en), U(:,en)]=physical(Grid,R2_Grid,Pr,cell_en(Un,en),data_type);
end

% ****convert sigma for IP****

save(strcat('Prior_',strrep(out_file,'Results_','')),'sigma');
Cond=0;
M=length(Data.data);
Z=zeros(M,N_En);
Output=zeros(M,N_En);

iter=0;
t(1)=0;

%%% initiallize MC folder %%%
unix('rm -r MC');
unix('mkdir MC');
unix(sprintf('mkdir MC/{1..%d}',N_En));
% for en=1:N_En, unix(sprintf('cp -r template MC/%d',en)); end % << I think
% this is wrong and we don't need this


%%%EnKI%%%%%%%%%%%%%%%%%%%%%
% delete(gcp('nocreate'))
% i=10;
% fprintf('Number of slots available: %d\n', i);
% parpool('local', i);

while (Cond==0)
    cd MC
    iter=iter+1;
    for en=1:N_En
        system(sprintf('cp -r ../template/* %d',en));
        if strcmp(data_type, 'IP')
            write_R2_sigma(fullfile(num2str(en),cond_file),sigma0,sigma(:,en)) 
        else
            write_R2_sigma(fullfile(num2str(en),cond_file),sigma(:,en)) 
        end
    end
    for en=1:N_En % or parfor
%        system(sprintf('cp -r ../template/* %d',en));

        cd(num2str(en))
% %         if strcmp(data_type, 'IP')
% %             write_R2_sigma(fullfile(num2str(en),cond_file),sigma0,sigma(:,en)) 
% %             fprintf('IP')
% %         else
% %             write_R2_sigma(fullfile(num2str(en),cond_file),sigma(:,en)) 
% %         end 
        
        %%% we need command to run e4d here for this new sigma
        system('wine64 ../../cR2.exe');
        cd ..
        dlmwrite(sprintf('%d.txt',en),en)
    end
    for en=1:N_En
        Output(:,en)=get_R2_data(fullfile(num2str(en),'cR2_forward.dat'),icol);  %%output
        %%data misfit (weighted by inverse of sqrt of measurement covariance):
        Z(:,en)=Data.inv_sqrt_C*(Data.data-Output(:,en));
        
    end
    cd ..
    Z_m=mean(Z,2);  %compute mean of misfits
    Delta_Z=Z-Z_m; %compute deviations for data misfit
    
%     if (iter==1)
%         alpha_0=mean(sum(Z.^2,1))/M;%max(sigma_mean^2,Inv.Maxiter);
%         alpha=alpha_0;
%     else
%         phi=1/alpha_0;
%         MM=tuning-1;
%         inverse=phi^((MM-(iter-1))/MM)*(1-phi^(1/MM));
%         alpha=1/inverse;
%     end
%     
    
    [alpha, Ave_mis(iter)]=compute_alpha(Z,N_En,M);

    save_alpha(iter)=alpha;
    Misfit(iter)=norm(Z_m(:,1))^2; %this is mean data misfit
    
    %%EKI code to update U
    
    if (t(iter)+1/alpha>1)
%     if (Ave_mis(iter)<M*1.1)
        alpha=1/(1-t(iter));
        disp('EnKI converged') %the sum of 1/alpha's should be 1 for convergence
        Cond=1;
    end    
    t(iter+1)=t(iter)+1/alpha;
    alpha
    t
    Un=update_unkown(M,N_En,Un,Un_m,Z,Delta_Z,alpha);
    Un_m = cellfun(f_mean,Un,'un',0);
    %%update conductivities
    for en=1:N_En % or parfor
        %[sigma(:,en), U(:,en)]=physical(Grid,R2_Grid,Pr,cell_en(Un,en));
        [sigma(:,en), U(:,en)]=physical(Grid,R2_Grid,Pr,cell_en(Un,en),data_type);

        %visualise(Grid.n,E4D_Grid.ec,sigma(:,en))    
    end
    %%%compute mean
    %sigma_mean=physical(Grid,R2_Grid,Pr,Un_m);
    sigma_mean=physical(Grid,R2_Grid,Pr,Un_m,data_type);
    tempo=Un{1,2};
    %%note sigma_m and sigma_m1 are not the same
%    if (iter==tuning)
%        Cond=1;
%    end

%    if (mod(iter,5))
        save([out_file,'_',num2str(iter)],  'iter',...'
        'alpha','t', 'Misfit','sigma_mean','Output','sigma','tempo','U','save_alpha','Un_m')
 %   end
end
    save(out_file,  'iter',...'
        'alpha','t', 'Misfit','sigma_mean','Output','sigma','tempo','U','save_alpha','Un_m')




,

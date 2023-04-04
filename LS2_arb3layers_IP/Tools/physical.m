function [sigma, U]=physical(Grid,R2_Grid,Pr,Un,data_type)

RN=Un{1,1};
L_mean=Un{1,2};
L_per.x=Un{1,3};
L_per.y=Un{1,4};
fields_mean=Un{1,5};
RN2=Un{1,6};
L_mean2=Un{1,7};
L_per2.x=Un{1,8};
L_per2.y=Un{1,9};

grf=Get_level_set(Grid,Pr,L_mean,L_per,RN);
U_temp=grf';
U = interp2(Grid.X,Grid.Y,U_temp,R2_Grid.x,R2_Grid.y,'spline',0);

grf2=Get_level_set(Grid,Pr,L_mean2,L_per2,RN2);
U_temp2=grf2';
U2 = interp2(Grid.X,Grid.Y,U_temp2,R2_Grid.x,R2_Grid.y,'spline',0);


%%compute physical conductivity
%sigma=Pr.sigma1+(Pr.sigma2-Pr.sigma1).*(U<=-0.25);
NF=Pr.n_fields;
cut=[1.0,0.0];


K=Get_Fields(fields_mean,NF,Grid);%,Model,prior,field_le,Inv);

fprintf('%s\n',data_type)

switch data_type
    case 'IP' % no log conversion
	sigma_prev=(K{3})+((K{1})-(K{3})).*(U2>cut(2));
	sigma=sigma_prev+((K{2})-sigma_prev).*(U<cut(1));

    case 'DC' % convert from log to normal space
	sigma_prev=exp(K{3})+(exp(K{1})-exp(K{3})).*(U2>cut(2));
	sigma=sigma_prev+(exp(K{2})-sigma_prev).*(U<cut(1));
	%sigma_prev_temp=exp(K{3})+(exp(K{1})-exp(K{3})).*(U_temp2>cut(2));
	%sigma_temp=sigma_prev_temp+(exp(K{2})-sigma_prev_temp).*(U_temp>cut(1));


end
end



function K=Get_Fields(fields_mean,NF,Grid)%,Model,prior,field_le,Inv)
N=Grid.N;
K=cell(NF,1);
%vargout=cell(NF,1);
for nf=1:NF
    K{nf}=fields_mean(nf);
%     vargout{nf}=fields_mean(nf);
%     if strcmp(Inv.field_check.update_length,'no')
%         vargout{nf}=K{nf}+fields_per(1+(nf-1)*N:N+(nf-1)*N,1);
%         K{nf}=interp2(opt.mesh.X,opt.mesh.Y,reshape(vargout{nf},Model.Grid.Nx,Model.Grid.Nx)',opt.mesh.elem_center(:,1),opt.mesh.elem_center(:,2),'nearest');
%     elseif strcmp(Inv.field_check.update_length,'yes')
%         for idim=1:Model.Grid.dim
%             pri.len{idim}=field_le(idim+(nf-1)*NF)*ones(N,1);
%         end
%         pri.sigma=prior.K(nf).per.sigma; pri.nu=prior.K(nf).per.nu;
%         vargout{nf}=K{nf}+grf2D(Model, pri,fields_per(1+(nf-1)*N:N+(nf-1)*N,1));
%         K{nf}=interp2(opt.mesh.X,opt.mesh.Y,reshape(vargout{nf},Model.Grid.Nx,Model.Grid.Nx)',opt.mesh.elem_center(:,1),opt.mesh.elem_center(:,2),'nearest');
%     end

end    
end

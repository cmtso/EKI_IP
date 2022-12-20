function Un=Get_prior(Grid,Pr,N_En)
  
% requires machine learning toolbox

dim=Grid.dim;
%load Truth
%xi=RN;
L_means=zeros(dim,N_En); %%check the 3 hard coded here
L_per_x=zeros(Grid.N,N_En);
L_per_y=zeros(Grid.N,N_En);
RN=zeros(Grid.N,N_En);
X = lhsdesign(N_En,dim);


for i=1:N_En  % was using parfor
    RN(:,i)=randn(Grid.N,1);
    for idim=1:dim
        Y=exp(Pr.level.len(idim).mean.lim(1))+(exp(Pr.level.len(idim).mean.lim(2))-exp(Pr.level.len(idim).mean.lim(1)))*X(i,idim);
        L_means(idim,i)= log(Y);
    end
    if (Pr.level.len(idim).per.sigma>0)
        L_per_x(:,i)=grf2D(Grid, Pr.level.len(1).per,randn(Grid.N,1),1);
        L_per_y(:,i)=grf2D(Grid, Pr.level.len(2).per,randn(Grid.N,1),1);        
    end
end

fields_means=zeros(Pr.n_fields,N_En); %%check the 3 hard coded here

for ifield=1:Pr.n_fields
    X = lhsdesign(N_En,dim);
    X2 = lhsdesign(N_En,1);
    for i=1:N_En
        Y2=exp(Pr.K(ifield).mean.lim(1))+(exp(Pr.K(ifield).mean.lim(2))-exp(Pr.K(ifield).mean.lim(1)))*X2(i,1);
        fields_means(ifield,i)=log(Y2);
%         if strcmp(Inv.field_check.update_length,'no')            
%             pri.sigma=Pr.K(ifield).per.sigma;
%             pri.nu=Pr.K(ifield).per.nu;
%             pri.len{1}=mean(Pr.K(ifield).per.len(1).lim)*ones(N,1);
%             pri.len{2}=mean(Pr.K(ifield).per.len(2).lim)*ones(N,1);
%             if (pri.sigma>0)
%                 fields_per(1+(ifield-1)*N:N+(ifield-1)*N,i)=grf2D(Model, pri,randn(N,1));
%             end
%         elseif strcmp(Inv.field_check.update_length,'yes')
%             fields_per(1+(ifield-1)*N:N+(ifield-1)*N,i)=randn(N,1);
%             for idim=1:dim
%                 Y=exp(Pr.K(ifield).per.len(idim).lim(1))+(exp(Pr.K(ifield).per.len(idim).lim(2))-exp(Pr.K(ifield).per.len(idim).lim(1)))*X(i,idim);
%                 field_le(idim+(ifield-1)*dim,i)=log(Y);%unifrnd(Pr.K(ifield).per.len(idim).lim(1),Pr.K(ifield).per.len(idim).lim(2));
%             end
%         end
    end
end

Un{1,1}=RN;
Un{1,2}=L_means;
Un{1,3}=L_per_x;
Un{1,4}=L_per_y;
Un{1,5}=fields_means;
%Un{1,5}=fields_per;
%Un{1,6}=field_le;

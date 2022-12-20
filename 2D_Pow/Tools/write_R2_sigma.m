function write_sigma(file,sigma,sigmaIP)
% assuming cR2 just read mag and phase angle in col 3 and 4
% optional IP column
if ~exist('sigmaIP','var')
 % sigmaIP does not exist, so default it to something
  sigmaIP = zeros(size(sigma));
end
    if size(sigma,2) == 1 % making sure sigma is a column vector
        sigma = sigma';
    elseif min(size(sigma)) ~= 1
        fprintf('Quitting! Sigma is not a vector')
        return
    end
    
    % change R2.in (should just change it in template)
    
    %write resistivity.dat (in the format of  _res.dat)
    
    fid = fopen(file,'w');
    fid
    fprintf(fid,'\t%8.6e\t%8.6e\t%8.6e\t%8.6e \n', ...
                [zeros(numel(sigma),2)  1./ sigma' sigmaIP]') ;
    fclose(fid);
end
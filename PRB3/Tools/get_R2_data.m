
function data=get_R2_data(srv_file,icol) % updated to read icol as user spcecifies

fid = fopen(srv_file,'r');
%nelec = str2double(fgetl(fid)) ;
%fscanf(fid,'%f',[5 nelec])';
%fgetl(fid);
%fgetl(fid);

if ~exist('icol','var')
 % icol does not exist, so default it to something
  icol = 6;
end

nd = str2double(fgetl(fid)) ;
data = fscanf(fid, strcat(strcat((repmat('%f',1,icol)), '%*[^\n]')),[icol nd])'; %skip all after the 6th column
data = data(:,icol);

if numel(data) < nd
  frewind(fid);
  nd = str2double(fgetl(fid)) ;
  data = fscanf(fid,repmat('%f',1,icol),[icol nd])'; % read strictly six columns
  data = data(:,icol);
end

if numel(data) < nd
  
  fprintf('WARNING: not all data points read.');
end

fclose(fid);
end
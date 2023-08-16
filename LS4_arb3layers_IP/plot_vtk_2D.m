
% https://uk.mathworks.com/help/matlab/ref/patch.html

% need to implement polyline crop

% in the future:
% if I want a smoother value, interp c to nodes and make vtk.c nodal


%%% !! uncomment if needed
%   clear vtk
%   vtk = read_vtk();

%figure
%figure('units','points','position',[0,0,808,140])

%fprintf('Using plot_vtk_2D.m. Make sure the variable ii is empty.\n')

for i=1:size(vtk.cells,1)
    mesh1 = (vtk.cells(i,1)) ;
    mesh2 = (vtk.cells(i,2)) ;
    mesh3 = (vtk.cells(i,3)) ;

    
    if (size(vtk.cells,2) == 4) % rectangular mesh
        mesh4 = (vtk.cells(i,4)) ;
        vtk.x(:,i)=[vtk.nodes(mesh1,1);vtk.nodes(mesh2,1);vtk.nodes(mesh3,1);vtk.nodes(mesh4,1)]; 
        vtk.y(:,i)=[vtk.nodes(mesh1,2);vtk.nodes(mesh2,2);vtk.nodes(mesh3,2);vtk.nodes(mesh4,2)];     
      else  % triangular mesh
        vtk.x(:,i)=[vtk.nodes(mesh1,1);vtk.nodes(mesh2,1);vtk.nodes(mesh3,1)]; 
        vtk.y(:,i)=[vtk.nodes(mesh1,2);vtk.nodes(mesh2,2);vtk.nodes(mesh3,2)]; 
    
    end
end


%% polyline subsetting
% remove cells if not all nodes are within (in or on) polygon
if (isfield(vtk,'polyline'))
   within = zeros(size(vtk.cells,1),1);
   [in,on] = inpolygon(vtk.nodes(:,1),vtk.nodes(:,2), ...
                       vtk.polyline(:,1),vtk.polyline(:,2) ); % check nodes
    for jj = 1:size(vtk.cells,1)
        a = ismember(vtk.cells(jj,:) , find(in == 1) ) ;
        if (sum(a) == size(vtk.cells,2)), within(jj) = 1 ; end, 
    end 
    
end


%% use dropdown selection if selection string does not exist
if (exist('plot_vtk_str','var'))
    ii = find(strcmp(string(vtk.scalar_list), plot_vtk_str),1,'last'); % e.g. plot_vtk_str = 'Phase(mrad)'
end
if (isempty(ii))
    ii =  listdlg('ListString', vtk.scalar_list,'selectionMode','single');
end

vtk.c = vtk.scalar_data(:,ii);
if (isfield(vtk,'polyline'))
    vtk.x = vtk.x(:,within==1);   
    vtk.y = vtk.y(:,within==1);   
    vtk.c = vtk.c(within==1);   
end
h = patch(vtk.x,vtk.y,vtk.c, 'EdgeAlpha',0.0);
c=colorbar;
%c.Label.String = vtk.scalar_list{ii};
%c.Label.FontSize = 18;
title(vtk.scalar_list{ii})
axis tight % axis equal
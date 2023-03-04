function m_color_point(lon,lat,value,cmap,colL,Marker,Msize,edgecol)

% lon: lontitude of points (vector)
% lat: latitude of points (vector)
% value: value to plot color
% colL: colorbar interval
% cmap: colormap
% Marker: marker to plot (string)

if length(lon)~=length(lat) || length(value)~=length(lon) 
    error('Error: the length of the input values must be the same!')
end

% edgecol=[0.3 0.3 0.3];

hold on
for i=1:length(value)          
      
    if value(i)<=colL(1)
        
      m_plot(lon(i),lat(i),Marker,'color',cmap(1,:),'Markerfacecolor',cmap(1,:),'MarkerSize',Msize,'MarkerEdgeColor',edgecol);  
      
    elseif value(i)>colL(end)
        
      m_plot(lon(i),lat(i),Marker,'color',cmap(end,:),'Markerfacecolor',cmap(end,:),'MarkerSize',Msize,'MarkerEdgeColor',edgecol);   
      
    else
        
      for ci=1:length(colL)-1
        if value(i)>colL(ci) && value(i)<=colL(ci+1)
          m_plot(lon(i),lat(i),Marker,'color',cmap(ci+1,:),'Markerfacecolor',cmap(ci+1,:),'MarkerSize',Msize,'MarkerEdgeColor',edgecol);
        end
      end
      
    end
    
end
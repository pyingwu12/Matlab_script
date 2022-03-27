function m_color_point(lon,lat,value,cmap,colL,Marker,Msize)

% lon: lontitude of points (vector)
% lat: latitude of points (vector)
% value: value to plot color
% colL: colorbar interval
% cmap: colormap
% Marker: marker to plot (string)


hold on
for i=1:length(lat)          
      
    if value(i)<=colL(1)
        
      m_plot(lon(i),lat(i),Marker,'color',cmap(1,:),'Markerfacecolor',cmap(1,:),'MarkerSize',10);  
      
    elseif value(i)>colL(end)
        
      m_plot(lon(i),lat(i),Marker,'color',cmap(end,:),'Markerfacecolor',cmap(end,:),'MarkerSize',10);   
      
    else
        
      for ci=1:length(colL)-1
        if value(i)>colL(ci) && value(i)<=colL(ci+1)
          m_plot(lon(i),lat(i),Marker,'color',cmap(ci+1,:),'Markerfacecolor',cmap(ci+1,:),'MarkerSize',10);
        end
      end
      
    end
    
end
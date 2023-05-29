function plot_dot(x,y,plotvar,cmap,Lmap,Marker,Msize)

clen=length(cmap);

 for i=1:length(plotvar)     
    for k=1:clen-2
      if (plotvar(i) > Lmap(k) &&  plotvar(i)<=Lmap(k+1))
%         plot(x(i),y(i),Marker,'MarkerEdgeColor','k','MarkerFaceColor',cmap(k+1,:),'MarkerSize',Msize); hold on   
        plot(x(i),y(i),Marker,'MarkerEdgeColor',cmap(k+1,:),'MarkerFaceColor',cmap(k+1,:),'MarkerSize',Msize,'linewidth',2); hold on 
      end      
    end
    if plotvar(i)>Lmap(clen-1)
%       plot(x(i),y(i),Marker,'MarkerEdgeColor','k','MarkerFaceColor',cmap(clen,:),'MarkerSize',Msize); hold on
      plot(x(i),y(i),Marker,'MarkerEdgeColor',cmap(clen,:),'MarkerFaceColor',cmap(clen,:),'MarkerSize',Msize,'linewidth',2); hold on
    end
    if plotvar(i)<=Lmap(1)
%       plot(x(i),y(i),Marker,'MarkerEdgeColor','k','MarkerFaceColor',cmap(1,:),'MarkerSize',Msize); hold on
      plot(x(i),y(i),Marker,'MarkerEdgeColor',cmap(1,:),'MarkerFaceColor',cmap(1,:),'MarkerSize',Msize,'linewidth',2); hold on
    end   
 end
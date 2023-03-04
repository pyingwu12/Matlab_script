function hp=plot_point2(Var,lon,lat,cmap,L,psize)

%    psize=6;

  clen=length(cmap);
  for i=1:length(Var)
    for k=1:clen-2
      if (Var(i) > L(k) && Var(i)<=L(k+1))
        c=cmap(k+1,:);
        hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','k','MarkerFaceColor',c,'MarkerSize',psize); hold on
        set(hp,'linestyle','none');
      end
    end
    if Var(i)>L(clen-1)
       c=cmap(clen,:);
       hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','k','MarkerFaceColor',c,'MarkerSize',psize); hold on
       set(hp,'linestyle','none');
    end
    if Var(i)<L(1)
       c=cmap(1,:);
       hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','k','MarkerFaceColor',c,'MarkerSize',psize); hold on
       set(hp,'linestyle','none');
    end
  end






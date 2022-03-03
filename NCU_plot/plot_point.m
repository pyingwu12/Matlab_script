function hp=plot_point(Var,lon,lat,cmap,L)

  clen=length(cmap);
  for i=1:length(Var)
    for k=1:clen-2;
      if (Var(i) > L(k) && Var(i)<=L(k+1))
        c=cmap(k+1,:);
        hp=m_plot(lon(i),lat(i),'s','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',7); hold on
        set(hp,'linestyle','none');
      end
    end
    if Var(i)>L(clen-1)
       c=cmap(clen,:);
       hp=m_plot(lon(i),lat(i),'s','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',7); hold on
       set(hp,'linestyle','none');
    end
    if Var(i)<L(1)
       c=cmap(1,:);
       hp=m_plot(lon(i),lat(i),'s','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',7); hold on
       set(hp,'linestyle','none');
    end
  end






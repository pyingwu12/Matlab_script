function hp=plot_point(Vari,lon,lat,cmap,L,psize)

%    psize=6;

  clen=length(cmap);
  for i=1:length(Vari)
    for k=1:clen-2
      if (Vari(i) > L(k) && Vari(i)<=L(k+1))
        c=cmap(k+1,:);
        hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor',c,'MarkerFaceColor',c,'MarkerSize',psize); hold on
%         set(hp,'linestyle','none');
      end
    end
    if Vari(i)>L(clen-1)
       c=cmap(clen,:);
       hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor',c,'MarkerFaceColor',c,'MarkerSize',psize); hold on
%        set(hp,'linestyle','none');
    end
    if Vari(i)<L(1)
       c=cmap(1,:);
       hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor',c,'MarkerFaceColor',c,'MarkerSize',psize); hold on
%        set(hp,'linestyle','none');
    end
  end


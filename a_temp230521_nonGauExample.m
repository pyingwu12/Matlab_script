
  x=hist_Edge-0.5;
  sig=std(plotvar); ens_me=mean(plotvar); 
   normal_dis=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2);

hf=figure('Position',[100 100 1000 630]);
h1=histogram(plotvar,'Normalization','probability','BinEdges',hist_Edge);
hold on

plot(x,normal_dis,'linewidth',3,'Marker','.','Markersize',25)

  xlabel('Wind speed (m/s)'); ylabel('Frequency (%)')
  set(gca,'fontsize',18,'linewidth',1.4) ;    
%    set(gca,'ylim',[0 0.5],'fontsize',18,'linewidth',1.4) ;    
  yticklabels(yticks*100)

  
  outfile=[outdir,'/nonGau_example1'];
  
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   
   plot([ens_me-sig ens_me-sig ],[0 0.45])
     plot([ens_me+sig ens_me+sig ],[0 0.45],'color',[ 0.929,0.694,0.125])
   set(gca,'Ylim',[0 0.45]) ;   
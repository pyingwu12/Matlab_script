close all
clear
%---setting
expri='ens02';  member=2;
year='2018'; mon='06'; s_date='22';  hr=2:15; minu=0; 
dirmem='pert'; infilenam='wrfout';  dom='01';  

%indir=['/HDD001/expri_ens200323/',expri];
indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
titnam='OLR';   fignam=[expri,'_olr_'];

load('colormap/colormap_parula.mat')
cmap=flipud(colormap_parula); %cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[130 145 160 175 190 205 220 235 250 265];
%---
%%
for ti=hr   
  s_hr=num2str(ti,'%.2d');  % start time string
  for tmi=minu    
    s_min=num2str(tmi,'%.2d');   
    for mi=member
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];
      %------read netcdf data--------
      OLR = ncread(infile,'OLR');      
%     end
%   end
% end    
      %---plot---
      plotvar=OLR';   %plotvar(plotvar<=0)=NaN;
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
       %
      hf=figure('position',[-900 200 800 600]);
      [c, hp]=contourf(plotvar,L2,'linestyle','none');
      set(gca,'fontsize',16,'LineWidth',1.2)

      tit=[expri,'  mem',nen,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
      title(tit,'fontsize',17)
%---
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      h=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);
      colormap(cmap)
   
      drawnow;
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
         hFills(idx).ColorData=uint8(cmap2(idx,:)');
      end   
%---    
      outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_m',nen];
      print(hf,'-dpng',[outfile,'.png']) 
      
      %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);
      %system(['rm ',[outfile,'.pdf']]);  
   end
 end
end
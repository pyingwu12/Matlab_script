clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;
%
pltensize=1000;  hr=7; minu=[00];  
pltdmsize=200; %range from the center for plotting (unit: grid point)
%
expnam='H01km';
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='Wind speed spread (recenter)';   fignam=[expnam,'_windsprd-recent_'];  unit='m/s';
%
% plon=[134 144]; plat=[30 38];
%     plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'2_']; 
 plon=[134.5 143.5]; plat=[32 38.5]; %fignam=[fignam,'3_']; 
%
load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd; %cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17 19],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.5 1 1.5 2 3 4 5 6 7 8 9 10 11 12];
%---
load('H01km_center.mat')
%%
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');   s_hr=num2str(mod(ti,24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');  
    %
    ntrack=1+(ti-0)*6+(tmi-0)/10;  %!!!!!!!!!!!!!!
    %
    % read ensemble
    tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
    for imem=1:pltensize     
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      if imem==1
       lon = double(ncread(infile,'lon'));
       lat = double(ncread(infile,'lat'));
       [nx, ny]=size(lon);
       spd10_ens=zeros(pltdmsize*2+1,pltdmsize*2+1,pltensize);
      end  
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      spd10=double(u10.^2+v10.^2).^0.5;  
      
      cen_idx=typhoon_center(ntrack,member(imem));      
      [xp, yp]=ind2sub([nx ny],cen_idx);
      
      spd10_ens(:,:,imem)=spd10(xp-pltdmsize:xp+pltdmsize,yp-pltdmsize:yp+pltdmsize);
    end  %imem

    %---
  
   ensmean=repmat(mean(spd10_ens,3),[1,1,pltensize]);
   enspert=spd10_ens-ensmean;
   sprd=sqrt(sum(enspert.^2,3)./(pltensize-1));  

    %%
      %
      %---plot
      plotvar=sprd';
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
      %  
      hf=figure('Position',[100 100 800 680]);
      [~, hp]=contourf(plotvar,L2,'linestyle','none');
      hold on 
      plotcnt=[10 20 30];
      [c,hdis]=contour(mean(spd10_ens,3)',plotcnt,'color','k','linewidth',1.8);     
clabel(c,hdis,plotcnt,'fontsize',15,'LabelSpacing',500)   


  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'xtick',100:100:pltdmsize*2-1,'Xticklabel',-pltdmsize+100:100:pltdmsize-100,...
          'ytick',100:100:pltdmsize*2-1,'yticklabel',-pltdmsize+100:100:pltdmsize-100)
  xlabel('distance from center (km)')
  ylabel('distance from center (km)')

      tit={[titnam];[month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem)']};
      title(tit,'fontsize',18)

      %---colorbar---
      fi=find(L>pmin,1);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
      colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
      end
      %
      outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize)];
      if saveid==1
       print(hf,'-dpng',[outfile,'.png'])    
       system(['convert -trim ',outfile,'.png ',outfile,'.png']);
      end

  end %min
end %hr

clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;
%
pltensize=50;  hr=[14]; minu=[00]; 

plotid=[1];  % 1:mean, 2:PM, 3:PMmod
type={'mean';'PM';'PMmod'};
%
expnam='H01km';
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam=['Wind speed'];   fignam=[expnam,'_wind-mean'];  unit='m/s';
%
% plon=[134.5 143.5]; plat=[32 38.5]; %fignam=[fignam,'3_']; 
plon=[138 141]; plat=[34.5 36.5];
%
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([3 4 6 7 8 9 10 11 12 13],:); 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[3 6 9 12 15 18 21 25 30];

%---

%%
%---
for ti=hr
  s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');    
    %
    % read ensemble
    tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
    for imem=1:pltensize     
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      if imem==1
       lon = double(ncread(infile,'lon'));
       lat = double(ncread(infile,'lat'));
       [nx, ny]=size(lon);
       spd10_ens=zeros(nx,ny,pltensize);
      end  
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      spd10_ens(:,:,imem)=double(u10(:,:).^2+v10(:,:).^2).^0.5;  
      spd10_ens2{imem}=double(u10(:,:).^2+v10(:,:).^2).^0.5;  
    end  %imem
%
[mathmean, PM, PMmod]=calPM(spd10_ens2);
  %%
    for pi=plotid   % 1:mean, 2:PM, 3:PMmod
      switch (pi); case 1; plotvar=mathmean;  case 2; plotvar=PM; case 3; plotvar=PMmod;  end 
    %---plot
    %
    pmin=min(plotvar(:));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end  
      
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
 
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on
        
    m_usercoast('gumby','linewidth',1,'color',[0.2 0.2 0.2],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 

    tit={[titnam,'  (',type{pi},')'];[month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem)']};
    title(tit,'fontsize',18)   
   
    %---colorbar--- 
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
      colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
      
      plttedval=plotvar(lon>plon(1) & lon<plon(2) & lat>plat(1) & lat<plat(2));
      pmin2=min(plttedval(:));      
      fi=find(L>pmin2,1);
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1:numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
      end
      %
   outfile=[outdir,'/',fignam,'_',month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'_',type{pi}];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    
    end
    %
  end
end

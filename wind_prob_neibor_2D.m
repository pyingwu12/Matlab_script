clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

%
pltensize=50;  hr=[14]; minu=[30];  thresholds=15; 

neighbor=3;
%
expnam='Hagibis01kme02'; 
expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expnam]; 
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='Wind speed probability';   fignam=[expnam,'_wind-prob-nbh_'];  unit='%';
%
% plon=[134 144]; plat=[30 38];
%     plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'2_']; 
%  plon=[134.5 143.5]; plat=[32 38.5]; fignam=[fignam,'3_']; 

%
% load('colormap/colormap_ncl.mat') 
% cmap0=colormap_ncl;  % cmap=cmap0([18 75 126 149 187 221],:);
load('colormap/colormap_PQPF.mat') 
cmap0=colormap_PQPF; cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17 19],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[5 10 30 50 70 90];
L=[5 15 25 35 45 55];
%---
infile_hm='/data8/wu_py/mfhm.nc';
terr = double(ncread(infile_hm,'terrain'));
land = double(ncread(infile_hm,'landsea_mask'));
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');   s_hr=num2str(mod(ti,24),'%2.2d');  
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
    end  %imem
%%
    % probability for different thresholds
    for thi=thresholds      
      wind_pro=zeros(nx,ny);  
     
      for i=1:nx
          for j=1:ny
              
              i1=floor(i-neighbor/2)+1; if i1<=0; i1=1; end
              i2=floor(i+neighbor/2); if i2>nx; i2=nx; end
              
              j1=floor(j-neighbor/2)+1; if j1<=0; j1=1; end
              j2=floor(j+neighbor/2); if j2>ny; j2=ny; end
              
              wind_pro(i,j)=length(find(spd10_ens(i1:i2,j1:j2,:)>=thi));
          end
      end
      
      
      
      wind_pro=wind_pro/(pltensize*neighbor*neighbor)*100;
      wind_pro(wind_pro+1==1)=NaN;
%       wind_pro(land+1==1)=NaN;
% wind_pro(terr+1==1)=NaN;
      % 
%---plot
      plotvar=wind_pro;
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
      %  
      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%       [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      
      m_pcolor(lon,lat,plotvar); hold on 
      colorbar
      %---
      % m_coast('color','k');
      % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
      m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
%       m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:1:150,'ytick',25:1:50,'color',[0.3 0.3 0.3]); 
      % ens mean
%       m_contour(lon,lat,mean(spd10_ens,3),[thi thi],'r','linewidth',2); 
      %
      tit={[titnam,' (',num2str(thi),' m/s)'];...
          [month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem, nei=',num2str(neighbor),')']};
      title(tit,'fontsize',18)
      %
% xp=666;yp=653; m_plot(lon(xp,yp),lat(xp,yp),'kx','markersize',20,'linewidth',3)
      %---colorbar---
% %       fi=find(L>pmin,1);
% %       L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
% %       hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
% %       colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
% %       hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
% %       for idx = 1 : numel(hFills)
% %         hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
% %       end
% %       %
      outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'thrd',num2str(thi),'_d4-2'];
      if saveid==1
       print(hf,'-dpng',[outfile,'.png'])    
       system(['convert -trim ',outfile,'.png ',outfile,'.png']);
      end
    end %thi
  end %min
end %hr

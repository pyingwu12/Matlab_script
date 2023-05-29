clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;
%
pltensize=1000;  hr=[11];  minu=[30];  pltspds=[25]; 
%
expri='H01km';
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Wind speed';   fignam=[expri,'_typhoon-spagh_'];   unit='m s^-^1';
%
% plon=[134 144]; plat=[30 38];
%   plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'2_']; 
  plon=[134.5 143.5]; plat=[32 38.5]; fignam=[fignam,'3_']; 
%---
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2; 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.5 1 2 4 6 9 12 15 18 21 25 30 35];
%
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
       xp=zeros(1,pltensize);yp=zeros(1,pltensize);
      end  
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      spd10_ens(:,:,imem)=double(u10(:,:).^2+v10(:,:).^2).^0.5; 
      
       ptemp= ncread(infile,'pmsl');
       [xp0, yp0]=find(ptemp==min(ptemp(:)));
       xp(imem)=xp0(1); yp(imem)=yp0(1);
    end  %imem
%%  
    for plti=pltspds      
      %---plot
       
      %
      plotvar=mean(spd10_ens,3);
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     

      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
      [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on 
      
      m_contour(lon,lat,plotvar,[plti plti],'linewidth',1.5,'color',[0.1 0.1 0.1]);  

%       m_coast('color','k');
%       m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
      m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
      %
      
      pltensize=1000;
      for imem=1:pltensize
       m_contour(lon,lat,spd10_ens(:,:,imem),[plti plti],'linewidth',0.8,'color',[0.5 0.5 0.5]); 
       drawnow
      end   
      for imem=1:pltensize
       m_plot(lon(xp(imem),yp(imem)),lat(xp(imem),yp(imem)),'.','color',[0.3 0.3 0.3],'markersize',10)
       drawnow
      end  
outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'spd',num2str(plti)];
% outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'spd',num2str(plti),'_2'];

%---
      tit={[titnam,' (',num2str(plti),' m/s)'];[month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem)']};
      title(tit,'fontsize',18)
      %
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

      
      if saveid==1
       print(hf,'-dpng',[outfile,'.png'])    
       system(['convert -trim ',outfile,'.png ',outfile,'.png']);
      end
    end %thi
  end %min
end %hr

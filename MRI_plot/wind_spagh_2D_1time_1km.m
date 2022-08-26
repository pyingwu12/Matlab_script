
% !!! still need to adopt to different radius for different direction

clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

% pltime=43; 
memsize=279;  pltspd=[15 25];

dtime='201910121200';

maxmem=279;
tmp=randperm(maxmem);
member=tmp(1:memsize);

% indir='/home/wu_py/plot_5kmEns/201910101800';
indir='/obs262_data01/wu_py/Experiments/Hagibis01km1000';
iname='sfc';

% outdir='/data8/wu_py/Result_fig/Hagibis_5km';
outdir='/data8/wu_py/Result_fig/Hagibis_1km';

%%
nmem=0;
for imem=member
  nmem=nmem+1;
  infile= [indir,'/',num2str(imem,'%.4d'),'/',iname,dtime,'.nc'];

  if nmem==1
%     data_time = (ncread(infile,'time'));
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);
    spd10_ens=zeros(nx,ny,memsize);
  end
  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');  
  spd10_ens(:,:,nmem)=double(u10(:,:).^2+v10(:,:).^2).^0.5;

%   u = ncread(infile,'u');
%   v = ncread(infile,'v');
%   spd_ens(:,:,nmem)=double(u(:,:,lev,pltt).^2+v(:,:,lev,pltt).^2).^0.5;
end
%%
fignam='wind-spagh';
% pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));
pltdate = datetime([dtime(1:4),'-',dtime(5:6),'-',dtime(7:8),' ',dtime(9:10),':',dtime(11:12)],...
    'InputFormat','yyyy-MM-dd HH:mm');

%%
spd_mean=mean(spd10_ens,3);

pltrangex=4; pltrangey=3.5;
%    plon=[137 142]; plat=[34 38];
%    plon=[135 145]; plat=[31 39];
    plon=[140-pltrangex 140+pltrangex]; plat=[35-pltrangey 35+pltrangey]; 
%    plon=[135 144]; plat=[32 39];
%   plon=[135 143]; plat=[32 38];

for spd_ctr=pltspd
  % probability
  wind_threshold=spd_ctr;
  wind_pro=zeros(nx,ny);
  for i=1:nx
    for j=1:ny
      wind_pro(i,j)=length(find(spd10_ens(i,j,:)>=wind_threshold));
    end
  end
  wind_pro=wind_pro/(memsize)*100;

%
%---plot
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

    for imem=1:memsize
      [~, ~]=m_contour(lon,lat,spd10_ens(:,:,imem),[spd_ctr spd_ctr],'linewidth',0.8,'color',[1 0.8 0]); hold on
    end

    m_contour(lon,lat,wind_pro,[50  90],'linewidth',1.5,'color','r')

%    m_contour(lon,lat,spd_mean,[spd_ctr spd_ctr],'linewidth',2,'color',[0.2 0.6 0.1],'linestyle','--')
   
   
    time_str=datestr(pltdate);
    m_text(plon(1)+0.25,plat(1)+0.3,{['Wind speed: ',num2str(spd_ctr),' m/s'],['Valid: ',time_str(1,:)]},'color','k','fontsize',14)
%
%    m_coast('color','k');
%    m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color','k')
%    m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',136:2:144,'ytick',33:2:39,'fontsize',13,'tickdir','out'); 
    m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',132:2:145,'ytick',26:2:40,'fontsize',13); 
%     m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',[130 130],'ytick',[],'fontsize',13,'xaxisloc','top');
% 
    title(['10-m wind (',num2str(memsize),' mem)'],'fontsize',16)
%
drawnow
    %---
    outfile=[outdir,'/',fignam,'_',dtime,'_m',num2str(memsize),'spd',num2str(spd_ctr)]; 
    if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
end %spd_ctr

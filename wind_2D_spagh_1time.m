


% !!! still need to adopt to different radius for different direction

clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')


saveid=1;

pltime=43;  memsize=1000;  pltspd=[15 25];

%plt_bst_time=[12 15];
plt_bst_time=[12]; % for plot typhoon center and radius of best track



tmp=randperm(1000);
member=tmp(1:memsize);

indir='/home/wu_py/plot_5kmEns/201910101800/';
outdir='/data8/wu_py/Result_fig/Hagibis_5km';

nmem=0;
for imem=member
  nmem=nmem+1;
  infile= [indir,num2str(imem,'%.4d'),'/201910101800.nc'];
  
  if nmem==1
    data_time = (ncread(infile,'time'));
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);
    spd10_ens=zeros(nx,ny,memsize);
  end
  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');  
  spd10_ens(:,:,nmem)=double(u10(:,:,pltime).^2+v10(:,:,pltime).^2).^0.5;

%   u = ncread(infile,'u');
%   v = ncread(infile,'v');
%   spd_ens(:,:,nmem)=double(u(:,:,lev,pltt).^2+v(:,:,lev,pltt).^2).^0.5;
end

fignam='wind-spagh';
pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));
%
% spd_mean=mean(spd10_ens,3);


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

  for bst_time=plt_bst_time

    if bst_time==12
      % 10/12 2100 JST (1200 UTC)
      bst_loc=[139.6 35.6];
      if spd_ctr==25; bst_rad=[260 330];  elseif spd_ctr==15; bst_rad=650; end
      bst_max=35;
    elseif bst_time==15
      % 10/13 0000 JST (1500 UTC)
      bst_loc=[140.6 36.9];
      if spd_ctr==25; bst_rad=280;  elseif spd_ctr==15; bst_rad=600; end
      bst_max=30;
    end
    dis2bst=Great_circle_distance(lon,lat,bst_loc(1),bst_loc(2),'d');

    % !!! set to NW only!! need to be modified!
    if length(bst_rad)>1
      mask_rad=zeros(nx,ny);
      mask_rad(dis2bst<=bst_rad(2) & lon>bst_loc(1) & lat>bst_loc(2))=1;
      mask_rad(dis2bst<=bst_rad(2) & lon>bst_loc(1) & lat<bst_loc(2))=1;
      mask_rad(dis2bst<=bst_rad(2) & lon<bst_loc(1) & lat<bst_loc(2))=1;
      mask_rad(dis2bst<=bst_rad(1) & lon<bst_loc(1) & lat>bst_loc(2))=1;
    end
%%
%---plot
    hf=figure('Position',[100 100 800 630]);
%    plon=[137 142]; plat=[34 38];
%    plon=[135 145]; plat=[31 39];
    plon=[139.6-8 139.6+8]; plat=[35.6-7 35.6+7]; 
%    plon=[135 144]; plat=[32 39];
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

    for imem=1:memsize
      [~, ~]=m_contour(lon,lat,spd10_ens(:,:,imem),[spd_ctr spd_ctr],'linewidth',0.8,'color',[1 0.8 0]); hold on
    end

    m_plot(bst_loc(1),bst_loc(2),'^','color','b','Markersize',12,'Markerfacecolor','b')
    m_contour(lon,lat,wind_pro,[50  90],'linewidth',1.5,'color','r')
    if length(bst_rad)>1
      m_contour(lon,lat,mask_rad,[1 1],'linewidth',2,'color','b')
    else
      m_contour(lon,lat,dis2bst,[bst_rad bst_rad],'linewidth',2,'color','b')
    end
%    m_contour(lon,lat,spd_mean,[spd_ctr spd_ctr],'linewidth',2,'color',[0.2 0.6 0.1],'linestyle','--')
    time_str=datestr(pltdate);
    m_text(plon(1)+0.25,plat(1)+0.3,{['Wind speed: ',num2str(spd_ctr),' m/s'],['Valid: ',time_str(1,:)]},'color','k','fontsize',14)
%
%    m_coast('color','k');
%    m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color','k')
%    m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',136:2:144,'ytick',33:2:39,'fontsize',13,'tickdir','out'); 
    m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',135:5:145,'ytick',25:5:40,'fontsize',13); 
    m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',[130 130],'ytick',[],'fontsize',13,'xaxislocatio','top');
% 
% 
    title(['10-m wind (',num2str(memsize),' mem)'],'fontsize',16)
%%
    outfile=[outdir,'/',fignam,'_t',num2str(pltime),'m',num2str(memsize),'spd',num2str(spd_ctr),'bst',num2str(bst_time)]; 
    if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
  end %bst_time
end %spd_ctr

function wind_2D_prob_MultiT(pltime,memsize,thrd)

%clear
close all
saveid=1;
addpath('/data8/wu_py/MATLAB/m_map/')

%pltime=45;  memsize=50;  thrd=[15 20 25 30 35];

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
    spd10_ens=zeros(nx,ny,length(pltime),memsize);
  end
  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  ntime=0;
  for itime=pltime
    ntime=ntime+1;
    spd10_ens(:,:,ntime,nmem)=double(u10(:,:,itime).^2+v10(:,:,itime).^2).^0.5;
  end
%   u = ncread(infile,'u');
%   v = ncread(infile,'v');
%   spd_ens(:,:,nmem)=double(u(:,:,lev,pltt).^2+v(:,:,lev,pltt).^2).^0.5;
end

%%
load('colormap/colormap_PQPF.mat') 
cmap0=colormap_PQPF; cmap0(1,:)=[0.9 0.9 0.9];
cmap=cmap0([1 2 3 12 13 14 15 17 19],:);
fignam='wind-prob';
pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));
colL=10:10:100;
%%
% close all
for thi=thrd
    
wind_threshold=thi;

wind_pro=zeros(nx,ny);   
for i=1:nx
  for j=1:ny
    wind_pro(i,j)=length(find(spd10_ens(i,j,:,:)>=wind_threshold));
  end
end
wind_pro=wind_pro/(memsize*length(pltime))*100;
% wind_pro(wind_pro+1==1)=NaN;
%%
%---plot
  hf=figure('Position',[100 100 800 630]);
%
% plon=[137 142]; plat=[34 38];
%  plon=[135 145]; plat=[31 39];
 plon=[139.6-8 139.6+8]; plat=[35.6-7 35.6+7];
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, ~]=m_contourf(lon,lat,wind_pro,colL,'linestyle','none'); hold on
% m_contour(lon,lat,wind_pro,[70 70],'linewidth',2,'color','k')
% 
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
  m_usercoast('gumby','linewidth',1,'color','k')
% 
  time_str=datestr(pltdate);
  if length(pltdate)==1
    m_text(plon(1)+0.25,plat(1)+0.3,{['Threshold: ',num2str(thi),' m/s'],['Valid: ',time_str(1,:)]},'color','k','fontsize',14)
    outfile=[outdir,'/',fignam,'_t',num2str(pltime(1)),'m',num2str(memsize),'thrd',num2str(thi)];
  else
    m_text(plon(1)+0.25,plat(1)+0.3,{['Threshold: ',num2str(thi),' m/s'],['Valid: ',time_str(1,:),'~',time_str(end,:)]},'color','k','fontsize',14)
    outfile=[outdir,'/',fignam,'_t',num2str(pltime(1)),num2str(pltime(end)),'m',num2str(memsize),'thrd',num2str(thi)];
  end
m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',135:5:145,'ytick',25:5:40,'fontsize',13);
m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',[130 130],'ytick',[],'fontsize',13,'xaxislocatio','top');
% 
% 
  colormap(cmap)
  hc=colorbar('fontsize',14);   caxis([colL(1) colL(end)])
  title(hc,'%','fontsize',13)
% 
  title(['10-m wind speed probability (',num2str(memsize),' mem)'],'fontsize',16)


  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

end %thi


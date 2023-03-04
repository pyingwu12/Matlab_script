clear
close all
saveid=1;


pltime=19:54;  

% xp=556; yp=325;
xp=554; yp=335;
% xp=558; yp=331;

% xp=656;yp=683; % 1km 1101*1201

memsize=50; 
% tmp=randperm(1000);
% member=tmp(1:memsize);
member=1:50;
% member=1;

ntime=length(pltime);

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
    spd10_ens=zeros(ntime,memsize);
  end
  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  spd10_ens(:,nmem)=double(u10(xp,yp,pltime).^2+v10(xp,yp,pltime).^2).^0.5;
  
%   u = ncread(infile,'u');
%   v = ncread(infile,'v');
%   spd_ens(:,:,nmem)=double(u(:,:,lev,pltt).^2+v(:,:,lev,pltt).^2).^0.5;
end

%%
fignam='Wind-Ts';
pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));

%%
% close all
%     
wind_thd=25;
% 
wind_pro=zeros(1,ntime);   
for itime=1:ntime
   wind_pro(itime)=length(find(spd10_ens(itime,:)>=wind_thd))/memsize*100;
end

%%
close all
%---plot
hf=figure('Position',[100 100 1000 630]);

colororder({'k','k'})

yyaxis left
plot(spd10_ens,'linewidth',2,'color',[0,0.447,0.741],'linestyle','-','Marker','none')  
ylabel('Speed (m/s)');
set(gca,'Ylim',[-5 40],'YTick',0:5:40)
yl=get(gca,'ylim');
text(0,yl(1)-4,datestr(pltdate(1),'mmm-dd'),'fontsize',16)

  
yyaxis right
% bar(wind_pro,'color',[0.85,0.325,0.098])
hb=bar(wind_pro);    set(hb,'FaceColor',[0.95,0.555,0.358])
% plot(wind_pro,'linewidth',3,'color',[0.85,0.325,0.098],'linestyle','-','Marker','none')
ylabel('');
set(gca,'Ylim',[0 300],'YTick',0:20:100)
label_h=ylabel('Probability (%)');  label_h.Position(2) = 50; label_h.Position(1) = ntime+ntime/17;


set(gca,'fontsize',16,'linewidth',1.2) 
% set(gca,'Xlim',[1 length(pltime)],'xtick',1:5:length(pltime),...
%     'Xticklabel',datestr(pltdate(1:5:end),'mm/dd HHMM'))
% xtickangle(-45)
set(gca,'Xlim',[1 length(pltime)],'xtick',1:3:length(pltime),...
    'Xticklabel',datestr(pltdate(1:3:end),'HH'))
% 
 xlabel('Time (UTC)')
 s_lon=num2str(lon(xp,yp),'%.1f');
 s_lat=num2str(lat(xp,yp),'%.1f');
tit={['10-m wind speed at (',s_lon,', ',s_lat,')'];[num2str(memsize),' member, threshold=',num2str(wind_thd),'m/s']};
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,'_','m',num2str(memsize),'thrd',num2str(wind_thd),'_x',num2str(xp),'y',num2str(yp)];

if saveid~=0
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

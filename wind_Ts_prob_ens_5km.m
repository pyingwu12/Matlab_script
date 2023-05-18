clear
% close all

saveid=1;

pltensize=1000;  thresholds=[15];  


randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
xp=[];

% xp=561; yp=339; % near Haneda
% 
%  expnam='Hagibis05kme02'; infilename='201910101800'; pltime=33:33+16; obs_lag=17;  tint=1; %hagibis05
% xp=569; yp=349; %Ryuhgasaki 5km

%  expnam='Hagibis01kme02'; infilename='201910111800'; pltime=9:9+16; obs_lag=41;  tint=1; %hagibis01
  expnam='Hagibis01kme02'; infilename='201910111800'; pltime=9:9+16; obs_lag=41;  tint=1; %hagibis01

%  xp=711; yp=755; %Ryuhgasaki KTOPO roughness~0

 expsize=1000; 
%
ntime=length(pltime);
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
%
titnam=[expnam,'  10-m wind speed'];   fignam=[expnam,'_wind-Ts_'];
%
%---
%%
%---obs
staid=6;

station.name={'Tokyo';'Rinkai';'Haneda';'Narita';'Choshi';'Yokohama';'Utsunomiya';'Ryuhgasaki'};
station.lon=[139.75 139.863 139.78 140.385 140.857, 139.652, 139.8680, 140.2130];
station.lat=[35.692 35.638 35.553 35.763 35.738, 35.44, 36.5490,35.8910];
% amdsdata   UTC TIME
% start 2019/10/10 01:00
% end   2019/10/13 00:00
sta=station.name{staid};
indirobs='/data8/wu_py/Data/obs/';
  infileo=[indirobs,'amds_',sta,'.txt'];
  obs=importdata(infileo);
  dir_o=obs(:,2);
  spd_o=obs(:,1);
lonp= station.lon(staid); latp=station.lat(staid);
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
spd10_ens=zeros(ntime,pltensize);
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  
  if imem==1
   lon = double(ncread(infile,'lon'));
   lat = double(ncread(infile,'lat'));  
   if isempty(xp)
   dis_sta=(lon-lonp).^2+(lat-latp).^2;    [xp,yp]=find(dis_sta==min(dis_sta(:))); %!!!!!
   end
  end
  
  spd10_ens(:,imem)= double(u10(xp,yp,pltime).^2+v10(xp,yp,pltime).^2).^0.5;
  
end
data_time = (ncread(infile,'time'));
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
%%
for thi=thresholds      
  wind_pro=zeros(1,ntime);   
  for itime=1:ntime
   wind_pro(itime)=length(find(spd10_ens(itime,:)>=thi))/pltensize*100;
  end
%%
  %---plot
  hf=figure('Position',[100 100 1000 630]);
  colororder({'k','k'})
  
  %---wind speed
  yyaxis left
  plot(spd10_ens,'linewidth',2,'color',[0,0.447,0.741],'linestyle','-','Marker','none')  ; hold on

  plot(mean(spd10_ens,2),'linewidth',2.5,'color',[0 0.2 0.5],'linestyle','-','Marker','none')  

  ylabel('Speed (m/s)');
  set(gca,'Ylim',[-5 25],'YTick',0:5:40)
  yl=get(gca,'ylim');  text(0,yl(1)-4.5,datestr(pltdate(pltime(1)),'mmm-dd'),'fontsize',16)
  %obs
  hold on; 
  plot(spd_o(obs_lag+pltime(1):obs_lag+pltime(end)),'linewidth',2.5,'linestyle','-.','Marker','x')
    %threshold
  line([1 ntime],[thi thi],'linewidth',1.5,'color','r','linestyle','--')
  %---probability
  yyaxis right
  hb=bar(wind_pro);    set(hb,'FaceColor',[0.95,0.555,0.358])
  ylabel('');
  set(gca,'Ylim',[0 250],'YTick',0:20:100,'tickdir','out')
  label_h=ylabel('Probability (%)');  label_h.Position(2) = 50; label_h.Position(1) = ntime+ntime/17;
  %---
  xlabel('Time (UTC)')
  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'Xlim',[1 length(pltime)],'xtick',1:tint:length(pltime),'Xticklabel',datestr(pltdate(pltime(1:tint:end)),'HH'))
  %   
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
%   s_lon=num2str(lonp,'%.1f');   s_lat=num2str(latp,'%.1f');
%   tit={[titnam,'  ',num2str(pltensize),' member'];['threshold=',num2str(thi),'m/s  ',sta,'(',s_lon,', ',s_lat,')']};
  tit={[titnam];[num2str(pltensize),' member, ',sta,'(',s_lon,', ',s_lat,')']};
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,'x',num2str(xp),'y',num2str(yp),'_thrd',num2str(thi),'_m',num2str(pltensize),'rnd',num2str(randmem)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

end %thi

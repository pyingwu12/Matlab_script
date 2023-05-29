clear
close all

saveid=0;

pltensize=10;  thresholds=[15]; 

xp=656;yp=683; % 1km 1101*1201; (139.6, 35.2), near Haneda

sth=6; lenh=13; minu=[00];   tint=1;
%
expri='H01km';
expri='Hagibis01km1000';  expsize=1000;
yyyy='2019'; mm='10'; stday=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam='Wind speed';   fignam=[expri,'_wind-Ts_'];
%
nminu=length(minu);  ntime=lenh*nminu;

%---
tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members 
spd10_ens=zeros(ntime,pltensize);
%%
%---obs
station.name={'Tokyo';'Rinkai';'Haneda';'Narita';'Choshi'};
station.lon=[139.75 139.863 139.78 140.385 140.857];
station.lat=[35.692 35.638 35.553 35.763 35.738];
% amdsdata   UTC TIME
% start 2019/10/10 01:00
% end   2019/10/13 00:00
staid=2;
sta=station.name{staid};
indirobs='/data8/wu_py/Data/obs/';
  infileo=[indirobs,'amds_',sta,'.txt'];
  obs=importdata(infileo);
  dir_o=obs(:,2);
  spd_o=obs(:,1);
lonp= station.lon(staid); latp=station.lat(staid);
%%
nti=0;
for ti=1:lenh    
  hr=sth+ti-1;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  for tmi=minu
    nti=nti+1;   s_min=num2str(tmi,'%.2d');
    for imem=1:pltensize 
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,yyyy,mm,s_date,s_hr,s_min,'.nc'];
    if imem==1 && nti==nti
     lon = double(ncread(infile,'lon'));
     lat = double(ncread(infile,'lat'));  
   % !!!!!!!!!!near obs point!!!!!!!!!!!!!1
     dis_sta=(lon-lonp).^2+(lat-latp).^2;     [xp,yp]=find(dis_sta==min(dis_sta(:))); % !!!!!!!!!!obs
    end

      u10 = ncread(infile,'u10m');  v10 = ncread(infile,'v10m');
      spd_2d=double(u10.^2+v10.^2).^0.5;            
%       spd10_ens(nti,imem)= griddata(lon(300:800,300:800),lat(300:800,300:800),spd_2d(300:800,300:800),lonp,latp);
      spd10_ens(nti,imem)=spd_2d(xp,yp);
      
    end
  end
end
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
  plot(spd10_ens,'linewidth',2,'color',[0,0.447,0.741],'linestyle','-','Marker','none')  
  ylabel('Speed (m/s)');
  set(gca,'Ylim',[-5 35],'YTick',0:5:40)
  yl=get(gca,'ylim');  text(0,yl(1)-4.5,[mm,'/',s_date],'fontsize',16)
  %obs
  hold on; plot(spd_o(54:54+lenh),'linewidth',2.5,'linestyle','-.','Marker','none')
  %threshold
  line([1 ntime],[thi thi],'linewidth',1.5,'color','r','linestyle','--')

  %---probability
  yyaxis right
  hb=bar(wind_pro);    set(hb,'FaceColor',[0.95,0.555,0.358])
  ylabel('');
  set(gca,'Ylim',[0 300],'YTick',0:20:100,'tickdir','out')
  label_h=ylabel('Probability (%)');  label_h.Position(2) = 50; label_h.Position(1) = ntime+ntime/17;

  %---
  xlabel('Time (UTC)')
  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'Xticklabel',sth:tint:sth+lenh-1)

  %---
  %   
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
%   s_lon=num2str(lonp,'%.1f');   s_lat=num2str(latp,'%.1f');
  tit={['10-m wind speed at ',sta,'(',s_lon,', ',s_lat,')'];[num2str(pltensize),' member, threshold=',num2str(thi),'m/s']};
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,'m',num2str(pltensize),'thrd',num2str(thi),'_x',num2str(xp),'y',num2str(yp)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

end %thi

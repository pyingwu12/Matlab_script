% function wind_hist_mem(pltensize,staid)
clear
% close all

saveid=0;
%
pltensize=50; 
hr=17; minu=[00];  obstime=48+hr;
staid=5;
%
expnam='H01km';
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='10-m wind speed';   fignam=[expnam,'_wind-hist_']; 
%---
hist_Edge=0:35;
%% obs
%
%---obs
station.name={'Tokyo';'Rinkai';'Haneda';'Narita';'Choshi'};
station.lon=[139.75 139.863 139.78 140.385 140.857];
station.lat=[35.692 35.638 35.553 35.763 35.738];
% amdsdata  UTC TIME
% start 2019/10/10 01:00; % end   2019/10/13 00:00
sta=station.name{staid};
indirobs='/data8/wu_py/Data/obs/';
  infileo=[indirobs,'amds_',sta,'.txt'];
  obs=importdata(infileo);
%   dir_o=obs(:,2);
%   spd_o=obs(:,1);
lonp= station.lon(staid); latp=station.lat(staid);
%}
%%
for ti=1:length(hr)
  s_date=num2str(day+fix(hr(ti)/24),'%2.2d');   s_hr=num2str(mod(hr(ti),24),'%2.2d'); 
  obs_wind_spd=obs(obstime(ti),1);
%   obs_wind_dir=obs(obstime(ti),2);
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
       dis_sta=(lon-lonp).^2+(lat-latp).^2;     [xp,yp]=find(dis_sta==min(dis_sta(:))); % !!!!!!!!!!obs
      end  
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      spd10_ens(:,:,imem)=double(u10(:,:).^2+v10(:,:).^2).^0.5;  
    end  %imem

%%
    %---plot
    hf=figure('Position',[100 100 1000 630]);
    h1=histogram(spd10_ens(xp,yp,:),'Normalization','probability','BinEdges',hist_Edge); hold on
    
    xline(obs_wind_spd,'linewidth',2,'color','r');
    %
    xlabel('Wind speed (m/s)'); ylabel('Frequency (%)')
    set(gca,'xlim',[hist_Edge(1) hist_Edge(end)],'ylim',[0 0.5],'fontsize',18,'linewidth',1.4) ;    
%     set(gca,'xlim',[0 35],'fontsize',18,'linewidth',1.4) ;    
    yticklabels(yticks*100)
    %
    x_lim=xlim; y_lim=ylim;
    text(x_lim(2)-5,y_lim(2)+0.01,['xp=',num2str(xp),', yp=',num2str(yp)])
    %
    s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
    tit={[titnam,' at ',sta,'(',s_lon,', ',s_lat,')'];...
         [expnam,'  ',month,'/',s_date,' ',s_hr,s_min,' (',num2str(pltensize),' member)']};
    title(tit,'fontsize',18)
  
 outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

  end %min  
end %hr

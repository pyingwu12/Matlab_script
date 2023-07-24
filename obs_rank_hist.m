clear
close all

saveid=1;

pltensize=25;  nsmp=10;

expri='Hagibis05kme02'; infilename='201910101800'; %pltime=25:6:49;  %hagibis05
% pltime=[37 40 43 46];
pltime=1:55;
% expri='Hagibis01kme06'; infilename='201910111800'; pltime=1:6:25;  %hagibis01

expsize=1000; 
%
ntime=length(pltime);
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
indir_obs='/data8/wu_py/Data/obs/';
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  10-m wind speed'];   fignam=[expri,'_WindRankHist_'];
%
%---
%%
% plon=[138 142]; plat=[33 36.5];
n=0
for ti=1:length(pltime)
  if ti==1
  infile=[indir,'/',num2str(1,'%.4d'),'/',infilename,'.nc'];  
  lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat')); [nx, ny]=size(lon);  
  data_time = (ncread(infile,'time'));
  end
    
%   spd_ens=zeros(nx,ny,expsize);
%   for imem=1:expsize 
%   infile=[indir,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];     
%   u10= ncread(infile,'u10m',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]);
%   v10= ncread(infile,'v10m',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]); 
%   spd_ens(:,:,imem)= double(u10.^2+v10.^2).^0.5; 
%   end
%   disp('end reading ensemble')
  
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime(ti)));
  infileo=[indir_obs,'amds_',datestr(pltdate,'YYYY'),datestr(pltdate,'mm'),datestr(pltdate,'dd'),...
                            datestr(pltdate,'HH'),datestr(pltdate,'MM'),'.txt']                    
  A=importdata(infileo);  
  lono0=A(:,7); lato0=A(:,8); 
%   fin=find(lono0>=plon(1) & lono0<=plon(2) & lato0>=plat(1) & lato0<=plat(2) )  ;
%   lono=A(fin,7); lato=A(fin,8); windiro=A(fin,10); windspdo=A(fin,9);
  lono=A(:,7); lato=A(:,8); windiro=A(:,10); windspdo=A(:,9);
  
  uo=windspdo.*cos((270-windiro)*pi/180);
  vo=windspdo.*sin((270-windiro)*pi/180);

  
   for p=1:length(lono)
  
  n=n+1;  
  obswind(n)=windspdo(p);
   obsu(n)=uo(p);
   obsv(n)=vo(p);
   end
  
  %%
  %{
  rank=zeros(pltensize+1,1);n=0; 
  
  for i=1:nsmp
  tmp=randperm(expsize); member=tmp(1:pltensize);
  ens0=spd_ens(:,:,member);
  for p=1:length(lono)
    n=n+1;   
    obs=windspdo(p);
    dis_sta=(lon-lono(p)).^2+(lat-lato(p)).^2;    [xp,yp]=find(dis_sta==min(dis_sta(:))); 
 
    ens=sort(squeeze(ens0(xp,yp,:)));
    
%   ens_ck(n)=ens(1);  
    tmp=find(ens>obs,1); 
    if isempty(tmp); rank(pltensize+1)=rank(pltensize+1)+1; else; rank(tmp)=rank(tmp)+1; end  
  end % for p=1:length(obs)  
  end
% end %ti
rank=rank/n;
RI=sum(abs(rank-1/pltensize))*100;

%%
hf=figure('Position',[100 100 800 630]);
bar(rank,'hist')
set(gca,'xlim',[0.5 pltensize+1.5],'ylim',[0 1/pltensize*5],'fontsize',16,'linewidth',1.5)
line([-1 pltensize+2],[1/pltensize 1/pltensize],'color','r','linewidth',2)

tit={titnam;['  ',datestr(pltdate,'mm/dd HHMM'),'  (rank ',num2str(pltensize),')']};   
title(tit,'fontsize',18)

tick={['nsmp=',num2str(nsmp),', nobs=',num2str(n/nsmp),', RI=',num2str(RI)];...
    ['lon=',num2str(plon(1)),'~',num2str(plon(2)),', lat=',num2str(plat(1)),'~',num2str(plat(2))]};
text(pltensize/2,1/pltensize*4.7,tick,'fontsize',15,'HorizontalAlignment','center')

    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),'_m',num2str(pltensize)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
  %}

end %ti

%% for check
%{
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([2 3 5 9 11 13 14],:); cmap(end,:)=[0.72 0.03 0.7];
colL=[1 5 9 13 17 21];
%--- for check
%
% close all
plon=[129 143]; plat=[30 40]; lo_int=110:5:146; la_int=25:5:45;

hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
 m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int);
m_usercoast('gumby','linewidth',1.2,'color',[0.2 0.2 0.2])

m_color_point(lono, lato, windspdo, cmap,colL,'o',10,'none'); hold on

L1=((1:length(colL))*(diff(caxis)/(length(colL)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',colL,'fontsize',14,'LineWidth',1.3);
colormap(cmap); title(hc,'m/s','fontsize',14) 

title('obs')
%%

hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
 m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int);
m_usercoast('gumby','linewidth',1.2,'color',[0.2 0.2 0.2])

m_color_point(lono, lato, ens_ck, cmap,colL,'o',10,'none'); hold on

L1=((1:length(colL))*(diff(caxis)/(length(colL)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',colL,'fontsize',14,'LineWidth',1.3);
colormap(cmap); title(hc,'m/s','fontsize',14) 

title('ens')

%%

cmap2=cmap(1:end-1,:); colL2=[ -10 -5 0 5 10 ];

diffeo=ens_ck'-windspdo;

plon=[129 143]; plat=[30 40]; lo_int=110:5:146; la_int=25:5:45;

hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
 m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int);
m_usercoast('gumby','linewidth',1.2,'color',[0.2 0.2 0.2])

m_color_point(lono, lato, diffeo, cmap2,colL2,'o',10,'none'); hold on

L1=((1:length(colL2))*(diff(caxis)/(length(colL2)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',[ -10 -5 0 5 10  ],'fontsize',14,'LineWidth',1.3);
colormap(cmap2); title(hc,'m/s','fontsize',14) 
%}

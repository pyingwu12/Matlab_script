clear
% close all

saveid=0;

pltensize=1000;  thresh=5;  randmem=0;

expri='Hagibis05kme02'; infilename='201910101800'; %pltime=25:6:49;  %hagibis05
pltrng=[1  55];  pltint=3; 
tint=1;%for x axis
pltime=pltrng(1):pltint:pltrng(end);
%
expsize=1000; 
%
ntime=length(pltime);
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
indir_obs='/data8/wu_py/Data/obs/';
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  10-m wind speed'];   fignam=[expri,'_WindBs_'];
%
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end

% plon=[138 142]; plat=[33 36.5]; % for specify varification area
%%
bs=zeros(ntime,1); pc=zeros(ntime,1); 
for ti=1:length(pltime)
  if ti==1
  infile=[indir,'/',num2str(1,'%.4d'),'/',infilename,'.nc'];  
  lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat')); [nx, ny]=size(lon);  
  data_time = (ncread(infile,'time'));
  end
    
  spd_ens=zeros(nx,ny,pltensize);
  for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];     
  u10= ncread(infile,'u10m',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]);
  v10= ncread(infile,'v10m',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]); 
  spd_ens(:,:,imem)= double(u10.^2+v10.^2).^0.5; 
  end
  if mod(ti,5)==0; disp([num2str(ti),' end reading ensemble']);end
  
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime(ti)));
  infileo=[indir_obs,'amds_',datestr(pltdate,'YYYY'),datestr(pltdate,'mm'),datestr(pltdate,'dd'),...
                            datestr(pltdate,'HH'),datestr(pltdate,'MM'),'.txt']  ;                  
  A=importdata(infileo);  
  lono0=A(:,7); lato0=A(:,8); 
%   fin=find(lono0>=plon(1) & lono0<=plon(2) & lato0>=plat(1) & lato0<=plat(2) )  ;
%   lono=A(fin,7); lato=A(fin,8); windiro=A(fin,10); windspdo=A(fin,9);
  lono=A(:,7); lato=A(:,8); windiro=A(:,10); windspdo=A(:,9);
  nobs=length(lono);
  %%
  pc(ti)=length(find(windspdo>=thresh))/nobs;
  bs(ti)=0;
  for p=1:nobs   
    obs=windspdo(p);
    dis_sta=(lon-lono(p)).^2+(lat-lato(p)).^2;    [xp,yp]=find(dis_sta==min(dis_sta(:)));  
    ens=squeeze(spd_ens(xp,yp,:));    
    prob=length(find(ens>=thresh))/pltensize;
    if obs>=thresh; a=1; else; a=0; end    
    bs(ti)=bs(ti)+(prob-a)^2/nobs;   
  end % for p=1:length(obs)  
end %ti
%%
bsc=pc.*(1-pc);
figure; 
plot(bs);hold on
% plot(pc); 
plot(bsc)

BSS=(bsc-bs)./bs;
plot(BSS)
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
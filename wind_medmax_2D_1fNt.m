clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=50;    
kicksea=0; randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
pltime=42:45;  % will calculate maximum during the <pltime> perid
%
expri='Hagibis05kme02'; infilename='201910101800';%hagibis05
% expri='Hagibis01kme06'; infilename='201910111800';%hagibis01
% expri='H01MultiE0206'; infilename='201910111800';
expsize=1000; 
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,' Wind speed']; fignam0=[expri,'_MaxWind_'];   unit='m/s';
%
% plon=[135 144.5]; plat=[32 39];  lo_int=136:2:144; la_int=33:2:37; % wide Kantou area
% plon=[138 141]; plat=[34 37];  fignam=[expri,'_wind-max_obskanto_'];  lo_int=133:2:145; la_int=26:2:46; 
% plon=[135.5 142.5]; plat=[33.5 37]; fignam=[expri,'_wind-max_zkt_'];  lo_int=135:5:145; la_int=30:5:40; % zoom in Kantou area
% plon=[135.5 142.3]; plat=[33.5 37.3];  fignam=[expri,'_wind-max_zkt2_'];  lo_int=134:2:145; la_int=31:2:40; % zoom in Kantou area

plon=[134.8 143.5]; plat=[32.3 38.5];  fignam=[fignam0,'Kanto_']; lo_int=135:5:144; la_int=30:5:37; % Japan center of Kanto
% plon=[138 141]; plat=[34 37.3]; fignam=[fignam0,'ktp_'];  lo_int=130:2:146; la_int=25:2:45; msize=13;  %Kantou portrait(verticle)
%--
%{
%     cmap =[    
%     0.0784313725490196,0.0431372549019608,0.725490196078431
%     0.1961    0.3137    0.9020
%     0.2745    0.5882    0.9412
%     0.941176470588235,0.901960784313726,0.196078431372549
%     0.98 0.5 0.16
%     1,0.15,0.0431
%     0.3    0.3    0.3];
% % L=5:5:30;
% load('colormap/colormap_wind2.mat') 
% cmap=colormap_wind2([2 3 5 9 11 13 14],:); cmap(end,:)=[0.71 0.1 0.65];
% cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[ 5 10 15 20 25 30];
%}
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([2 3 5 8 9 11 12 14 ],:); cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 5 10 15 20 25 30];
%---
infile_hm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm2.nc',];
land = double(ncread(infile_hm,'landsea_mask'));
%%
%---read ensemble
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time')); [nx, ny]=size(lon); ntime=length(data_time);
    spd0=zeros(nx,ny,pltensize,ntime);      
  end  
  u10 = ncread(infile,'u10m');  v10 = ncread(infile,'v10m');
  spd0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
  if mod(imem,100)==0; disp(['Member ',num2str(imem),' done']); end
end  %imem
disp('finish read files')
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
%%
mtric='median';
spd_m=zeros(nx,ny,length(pltime));
for ti=1:length(pltime)
%   spd_med(:,:,ti)=squeeze(median(squeeze(spd0(:,:,:,pltime(ti))),3));
  eval(['spd_m(:,:,ti)=squeeze(',mtric,'(squeeze(spd0(:,:,:,pltime(ti))),3));'])
end
spdm_maxP=squeeze(max(spd_m,[],3));   
%%
%--plot
plotvar=spdm_maxP; tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
pmin=min(tmp);  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
%--
hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
[~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
%
m_contour(lon,lat,land,[0.5 0.5],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--') %--coast line by mfhm
m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.1 0.1 0.1]); 
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
% m_usercoast('gumby','linewidth',0.8,'color',[0.1 0.1 0.1],'linestyle','-')
% 
tit={titnam;[datestr(pltdate(pltime(1)),'mm/dd HHMM-'),datestr(pltdate(pltime(end)),'HHMM'),' Max. (',...
    num2str(pltensize),'mem ',mtric,')']};  
title(tit,'fontsize',18)
%---colorbar---
fi=find(L>pmin,1);
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
colormap(cmap); xlabel(hc,unit,'fontsize',15) % title(hc,unit,'fontsize',15); 
drawnow;  
hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
for idx = 1 : numel(hFills)
  hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
end
%
outfile=[outdir,'/',fignam,mtric,'_kick',num2str(kicksea),...
    datestr(pltdate(pltime(1)),'_mmdd_HH'),datestr(pltdate(pltime(end)),'HH')...
    ,'_m',num2str(pltensize),'rnd',num2str(randmem)];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%%
%--- for maximum wind during a period
%   spd10_ens_med=zeros(nx,ny,ntime);
% %  spd10_ens_max=zeros(nx,ny,ntime);
%   for ti=1:ntime
%    spd10_ens_med(:,:,ti)=squeeze(median(squeeze(spd10_ens0(:,:,:,ti)),3));
% %   spd10_ens_max(:,:,ti)=squeeze(max(squeeze(spd10_ens0(:,:,:,ti)),[],3));
%    if mode(ti,10)==0; disp([num2str(ti),' time done']); end
%   end
%   
% spdplt=squeeze(max(spd10_ens_med,[],3));
% %  spd10_max2=squeeze(max(spd10_ens_max,[],3));
% 
% if kicksea~=0;   spdplt(land+1==1)=NaN; spd10_max2(land+1==1)=NaN;  end

%% median
%{
%---plot
plotvar=spdmed_maxP; tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
pmin=min(tmp);  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
%%
hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
[~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
%
m_contour(lon,lat,land,[0.1 0.1],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--') %--coast line by mfhm
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
% m_usercoast('gumby','linewidth',0.8,'color',[0.1 0.1 0.1],'linestyle','-')
m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.1 0.1 0.1]); 
% 
tit={titnam;['(',num2str(pltensize),' mem, med.)']};  title(tit,'fontsize',18)
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
outfile=[outdir,'/',fignam,'kick',num2str(kicksea),'_m',num2str(pltensize),'rnd',num2str(randmem),'med'];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
%% max member
    %{
    %---
%     plon=[138 141]; plat=[34 37];  fignam=[fignam,'obskanto_'];  lo_int=133:2:145; la_int=26:2:46; 

        plotvar=spd10_max2;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end   
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    %---coast line by mfhm
    m_contour(lon,lat,land,[0.2 0.2],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--')
    %
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    % m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    tit={titnam;['(',num2str(pltensize),' mem, ens max)']};   
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
    outfile=[outdir,'/',fignam,'kick',num2str(kicksea),'_m',num2str(pltensize),'rnd',num2str(randmem),'max'];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
%}

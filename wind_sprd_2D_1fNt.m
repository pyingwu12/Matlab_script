clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=20;    
kicksea=0; 
randmem=0; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members

%
 pltime=[31];  expri='Hagibis05kme01'; infilename='201910101800';%hagibis
% pltime=[19 20]; expri='Hagibis01kme02'; infilename='201910111800';  expsize=1000;
% pltime=[19 20]; expri='H01MultiE0206'; infilename='201910111800';  expsize=1000;  
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san) 
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  Wind speed spread'];    unit='m/s';
%
% plon=[135 144.5]; plat=[32 39]; fignam=[expri,'_wind-sprd_']; lo_int=136:2:144; la_int=33:2:37; % wide Kantou area
% plon=[135.5 142.5]; plat=[33.5 37]; fignam=[expri,'_wind-sprd_','zkd_'];   lo_int=135:5:145; la_int=30:5:40; % old230306 zoom in Kantou area
% plon=[135.5 142.3]; plat=[33.5 37.3]; fignam=[expri,'_wind-sprd_','zkd2_'];  lo_int=134:2:145; la_int=31:2:40; % zoom in Kantou area
% plon=[139.2 140.9]; plat=[34.85 36.3 ];  fignam=[expri,'_wind-sprd_','tokyobay_']; lo_int=134:2:145; la_int=31:2:40;
plon=[130 144.1]; plat=[28 40]; fignam=[expri,'_WindSprd_','japan_']; lo_int=105:5:155; la_int=10:5:50;% Japan area
%
% load('colormap/colormap_sprd.mat') 
% cmap=colormap_sprd(1:2:end,:); cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% % L=[0.5 1 1.5 2 3 4 5 6 7 8 9 10 11 12];
% L=[1 2 3 4 5 6 7];
load('colormap/colormap_sprd.mat');cmap=colormap_sprd([1 2 3 5, 7:10, 11 13 14],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.5 1 2 3 4 5 6 7 8 9];
%
infile_hm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm.nc'];
land = double(ncread(infile_hm,'landsea_mask'));
%%    
%---read ensemble
if randmem==0; member=1:pltensize;  elseif randmem==50; member=1:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end
%
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   [nx, ny]=size(lon);  ntime=length(data_time);
    spd10_ens0=zeros(nx,ny,pltensize,ntime);    
  end  
  u10 = ncread(infile,'u10m');    v10 = ncread(infile,'v10m');
  spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
  if mod(imem,100)==0; disp([num2str(imem),'mem done']); end
end  %imem
%%
for ti=pltime     
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  spd10_ens= squeeze(spd10_ens0(:,:,:,ti));
  %---
  ensmean=repmat(mean(spd10_ens,3),[1,1,pltensize]);
  enspert=spd10_ens-ensmean;
  sprd=sqrt(sum(enspert.^2,3)./(pltensize-1));   
  
  if kicksea~=0;   sprd(land+1==1)=NaN;  end
%%
    %---plot
    plotvar=sprd;
    tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
    pmin=min(tmp);    if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    %
%---typhoon center
%     m_plot(lon(cen_idx),lat(cen_idx),'.','color',[0.6 0.6 0.6])

    m_contour(lon,lat,land,[0.6 0.6],'linewidth',1.3,'color',[0.95 0.95 0.95],'linestyle','-')
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
%     m_usercoast('gumby','linewidth',1,'color',[0.95 0.95 0.95],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
    % 
    %---ens mean
    plotcnt=[10 15 20 30]; cntcol=[0.1 0.1 0.1];
    [c,hdis]=m_contour(lon,lat,squeeze(mean(spd10_ens,3)),plotcnt,'color',cntcol,'linewidth',1,'linestyle','-');     
    clabel(c,hdis,plotcnt,'fontsize',11,'LabelSpacing',600,'color',cntcol)   
    %
    tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem, rnd',num2str(randmem),')']};   
    title(tit,'fontsize',18)
    %
    %---colorbar---
    fi=find(L>=pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
    colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %
    outfile=[outdir,'/',fignam,'rnd',num2str(randmem),'m',num2str(pltensize),datestr(pltdate,'_mmdd_HHMM')];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---

end % pltime


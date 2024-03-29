clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;    thresholds=[5 10 15 20 25]; 
kicksea=0; randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
%
 pltime=[34 37 40 43 46]; expri1='Hagibis05kme02'; infilename='201910101800';%hagibis05
 expri2='Hagibis05kme01';
 
%  pltime=19; expri1='Hagibis01kme06'; infilename='201910111800';%hagibis05
%  expri2='Hagibis01kme02';
% pltime=[20 21]; expri1='Hagibis01kme02'; infilename='201910111800';%hagibis01
expsize=1000; 
%
indir1=['/obs262_data01/wu_py/Experiments/',expri1,'/',infilename];
indir2=['/obs262_data01/wu_py/Experiments/',expri2,'/',infilename];
infile_hm=['/obs262_data01/wu_py/Experiments/',expri1,'/mfhm.nc',];

outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='Wind prob. diff.';   fignam=[expri1,'_wind-prob-diff',expri2(end-2:end),'_'];   unit='%';
%
 plon=[128 145]; plat=[26 43]; lo_int=105:5:155; la_int=10:5:50;
% plon=[135 144.5]; plat=[32 39];  lo_int=136:2:144; la_int=33:2:37; % wide Kantou area
% plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'zkd_'];  lo_int=135:5:145; la_int=30:5:40; % zoom in Kantou area
%
load('colormap/colormap_br2.mat') 
cmap0=colormap_br2;  cmap=cmap0(3:2:end-1,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-15 -10 -5 -1 1 5 10 15];
%---
land = double(ncread(infile_hm,'landsea_mask'));
%%
%---read ensemble
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for ti=pltime
    infile=[indir1,'/',num2str(1,'%.4d'),'/',infilename,'.nc'];   
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   [nx, ny]=size(lon);
    spd1=zeros(nx,ny,pltensize);  
    spd2=zeros(nx,ny,pltensize); 
for imem=1:pltensize     
  infile1=[indir1,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  infile2=[indir2,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  
  u10 = ncread(infile1,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
  v10 = ncread(infile1,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
  spd1(:,:,imem)=double(u10.^2+v10.^2).^0.5;  
  u10 = ncread(infile2,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
  v10 = ncread(infile2,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
  spd2(:,:,imem)=double(u10.^2+v10.^2).^0.5;
  if mod(imem,500)==0; disp(['Member ',num2str(imem),' done']); end
end  %imem
disp('end read files')
%%  
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
     
  %---probability for different thresholds
  for thi=thresholds      
    wind_pro1=zeros(nx,ny);   
    wind_pro2=zeros(nx,ny);   
    for i=1:nx
      for j=1:ny
        wind_pro1(i,j)=length(find(spd1(i,j,1:pltensize)>=thi));
        wind_pro2(i,j)=length(find(spd2(i,j,1:pltensize)>=thi));
      end
    end
    wind_pro1=wind_pro1/pltensize*100;
    wind_pro2=wind_pro2/pltensize*100;
    probdiff=wind_pro1-wind_pro2;
    if kicksea~=0;   probdiff(land+1==1)=NaN;  end
    %%
    %---plot
    plotvar=probdiff;
    tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
    pmin=min(tmp(:));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 690]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    % ens mean
%     m_contour(lon,lat,mean(spd10_ens,3),[thi thi],'r','linewidth',2); 
    %---coast line by mfhm
    m_contour(lon,lat,land,[0.2 0.2],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--')
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    % m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    tit={[expri1,'-',expri2];titnam;['  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(thi),' m/s, ',num2str(pltensize),' mem)']};   
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
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_thrd',num2str(thi),'kick',num2str(kicksea),'_m',num2str(pltensize),'rnd',num2str(randmem)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
  end %thi
end % pltime
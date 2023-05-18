clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

thresholds=[15]; 
kicksea=1; 

expri={'Hagibis01kme02';'Hagibis01kme06'}; exptext='e02e06';
% expmenum=[500 400]; 
% member=[501:1000, 1:400];

expmenum=[500 500];  % number of member for each exp.
member=[501:1000, 1:500]; % specify member No. for each exp.
%
% pltime=43; expnam='Hagibis05kme02'; infilename='201910101800';%hagibis05
% pltime=[20 21]; expnam='Hagibis01kme06'; infilename='201910111800'; expsize=1000;  %hagibis01
pltime=[19 20]; infilename='201910111800';  %hagibis01e06
%
indir='/obs262_data01/wu_py/Experiments'; outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Wind speed probab.';   fignam=['wind-prob_',exptext,'_'];   unit='%';
%
% plon=[135 144.5]; plat=[32 39];  lo_int=136:2:144; la_int=33:2:37; % wide Kantou area
% plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'zkd_'];  lo_int=135:5:145; la_int=30:5:40; % zoom in Kantou area
plon=[135.5 142.3]; plat=[33.5 37.3]; fignam=[fignam,'zkd2_'];  lo_int=134:2:145; la_int=31:2:40; % zoom in Kantou area
%
load('colormap/colormap_PQPF.mat') 
cmap0=colormap_PQPF; cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[10 30 50 70 90];
%---
nexp=size(expri,1);
pltensize=length(member(:));
if sum(expmenum)~=pltensize; error('Error: please check the setting of expmenum and member'); end
%---
infile_hm=['/obs262_data01/wu_py/Experiments/Hagibis01kme06/mfhm.nc',]; %for tick sea
% terr = double(ncread(infile_hm,'terrain'));
land = double(ncread(infile_hm,'landsea_mask'));
%%
%---read ensemble
nmem=0;
for ei=1:nexp  
  for imem=1:expmenum(ei)     
    nmem=nmem+1;
    infile=[indir,'/',expri{ei},'/',infilename,'/',num2str(member(nmem),'%.4d'),'/',infilename,'.nc'];   
    if nmem==1
      lon = double(ncread(infile,'lon'));
      lat = double(ncread(infile,'lat'));
      data_time = (ncread(infile,'time'));
      [nx, ny]=size(lon);
      spd10_ens0=zeros(nx,ny,pltensize,length(data_time));      
    end  
    u10 = ncread(infile,'u10m');
    v10 = ncread(infile,'v10m');
    spd10_ens0(:,:,nmem,:)=double(u10.^2+v10.^2).^0.5;  
  end  %imem
end
%%
for ti=pltime     
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
 
  spd10_ens=squeeze(spd10_ens0(:,:,:,ti));
    
  %---probability for different thresholds
  for thi=thresholds      
    wind_pro=zeros(nx,ny);   
    for i=1:nx
      for j=1:ny
        wind_pro(i,j)=length(find(spd10_ens(i,j,1:pltensize)>=thi));
      end
    end
    wind_pro=wind_pro/pltensize*100;
    wind_pro(wind_pro+1==1)=NaN;
    if kicksea~=0;   wind_pro(land+1==1)=NaN;  end
    %%
    %---plot
    plotvar=wind_pro;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    % ens mean
%     m_contour(lon,lat,mean(spd10_ens,3),[thi thi],'r','linewidth',2); 
    %---coast line by mfhm
% %     m_contour(lon,lat,land,[0.2 0.2],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--')
% %      m_contour(lon,lat,land,[0.01 0.01],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--')
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    tit={[titnam,'  (',exptext,')'];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(thi),' m/s, ',num2str(pltensize),' mem)']};   
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
        '_thrd',num2str(thi),'kick',num2str(kicksea),'_m',num2str(pltensize)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
  end %thi
end % pltime

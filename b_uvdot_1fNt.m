clear
% close all

saveid=0;
pltensize=1000; 

pltime=37; % staid=2;

randmem=0; %0: plot member 1~pltensize; else:randomly choose members

% xp=538; yp=331; %ti=43
% xp=521; yp=265; %ti=31
%
expri='Hagibis05kme02'; 
infilename='201910101800';%hagibis
expsize=1000;   BCnum=50;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
% titnam='10-m Wind speed';   fignam=[expri,'_WindHist_']; 
titnam='UV dot';   fignam=[expri,'_UVdot_']; 
%---
%%
% %---obs
% staid=3;
% station.name={'Tokyo';'Rinkai';'Haneda';'Narita';'Choshi'};
% station.lon=[139.75 139.863 139.78 140.385 140.857];
% station.lat=[35.692 35.638 35.553 35.763 35.738];
% % amdsdata   UTC TIME
% % start 2019/10/10 01:00  
% % end   2019/10/13 00:00
% sta=station.name{staid};
% indirobs='/data8/wu_py/Data/obs/';
%   infileo=[indirobs,'amds_',sta,'.txt'];
%   obs=importdata(infileo);
%  
% lonp= station.lon(staid); latp=station.lat(staid);
% lonp=142.59; latp=27.15;
% 
load('colormap/colormap_ncl.mat');cmap=colormap_ncl;cmap2=cmap(8:5:end,:);

%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); memtag='rndm';  %!random choose members  
else; member=1:pltensize; memtag='seq'; %!!!!! sequential members
end
for ti=pltime    
%---read ensemble
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon); ntime=length(data_time);
    u10m0=zeros(nx,ny,pltensize);  
    v10m0=zeros(nx,ny,pltensize);  
%--find the grid point nearest to the obs station-----
%     dis_sta=(lon-lonp).^2+(lat-latp).^2;   [xp,yp]=find(dis_sta==min(dis_sta(:))); %!!!!!
  end  

    u10m0(:,:,imem) = ncread(infile,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
    v10m0(:,:,imem) = ncread(infile,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
    
  if mod(imem,300)==0; disp([num2str(imem),' done']); end
end  %imem
disp ('end reading files')
%%
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
%   obs_wind_spd=obs(ti+17,1); 
  %%
%   rng=2; sz=rng*2+1;
%   plotu=reshape( u10m0(xp-rng:xp+rng,yp-rng:yp+rng,:), 1, sz*sz*pltensize );
%   plotv=reshape( v10m0(xp-rng:xp+rng,yp-rng:yp+rng,:), 1, sz*sz*pltensize );

xp=453;yp=382;

% u10=mean(u10m0,[1 2]);  v10=mean(v10m0,[1 2]);

% u10=u10m0(1:50:end,1:50:end,:);  v10=v10m0(1:50:end,1:50:end,:);
u10=u10m0(xp,yp,:);  v10=v10m0(xp,yp,:);

[nx1, ny1, ~ ]=size(u10);

plotu=squeeze(reshape(u10,1,nx1*ny1*pltensize));
plotv=squeeze(reshape(v10,1,nx1*ny1*pltensize));

  
  stdu=std(plotu);  stdv=std(plotv);  
  [ex, ey]=ellipse(stdu,stdv,mean(plotu),mean(plotv));

%---plot
%%
  hf=figure('Position',[2000 100 800 630]);
  
  for ibc=1:BCnum
      plot(plotu(ibc:BCnum:end),plotv(ibc:BCnum:end),'.','color',cmap2(ibc,:),'Markersize',10); hold on
  end
  
%   plot(plotu,plotv,'b.'); hold on
  plot(mean(plotu),mean(plotv),'rx')  
  plot(ex, ey)

  xlabel('U (m/s)'); ylabel('V (m/s)')
  lim=max(stdu,stdv);
  set(gca,'fontsize',18,'linewidth',1.4,'xlim',[mean(plotu)-lim*3 mean(plotu)+lim*3]...
      ,'ylim',[mean(plotv)-lim*3 mean(plotv)+lim*3]) ;    

%   s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
% %   tit={[titnam,' at ',sta,'(',s_lon,', ',s_lat,')'];...
% %        [expri,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
%   tit={[titnam,' at (',s_lon,', ',s_lat,')'];...
%        [expri,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
    tit=[expri,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)'];  
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
      '_x',num2str(xp),'y',num2str(yp),'_m',num2str(pltensize)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  %---  
end % pltime

% function wind_hist_5km(expri)
clear
close all

saveid=1;
pltensize=1000; 

pltime=43; % staid=2;

varinam='u10m';

 randmem=0; %0: plot member 1~pltensize; else:randomly choose members

xp=538; yp=331; %ti=43
% xp=521; yp=265; %ti=31
%
expri='Hagibis05kme02'; 
infilename='201910101800';%hagibis
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
% titnam='10-m Wind speed';   fignam=[expri,'_WindHist_']; 
titnam=varinam;   fignam=[expri,'_',varinam,'Hist_']; 
%---
if strcmp(varinam,'wind'); hist_Edge=0:15; else; hist_Edge=-15:2:15; end
%%
% %---obs
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
%%     
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); memtag='rndm';  %!random choose members  
else; member=1:pltensize; memtag='seq'; %!!!!! sequential members
end
%---read ensemble
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon);
    vari0=zeros(nx,ny,length(data_time),pltensize);       
%--find the grid point nearest to the obs station-----
%     dis_sta=(lon-lonp).^2+(lat-latp).^2;   [xp,yp]=find(dis_sta==min(dis_sta(:))); %!!!!!
  end  
  
  if strcmp(varinam,'wind')
    u10 = ncread(infile,'u10m'); v10 = ncread(infile,'v10m');
    vari0(:,:,:,imem)=double(u10.^2+v10.^2).^0.5; 
  else
    vari0(:,:,:,imem) = ncread(infile,varinam);
  end
  if mod(imem,200)==0; disp([num2str(imem),' done']); end
end  %imem
disp ('end reading files')
%%
% hist_Edge=[15 16 17 18 19 20 21 22 23 ];
for ti=pltime    
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
%   obs_wind_spd=obs(ti+17,1); 
  plotvar=squeeze(vari0(xp,yp,ti,:));
%   plotvar=squeeze(vari0(xp,yp,:,ti));
  %%
%   x=hist_Edge-0.5;
%   sig=std(plotvar); ens_me=mean(plotvar); 
%    normal_dis=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2); 
  %%
%---plot
  hf=figure('Position',[100 100 1000 630]);
  h1=histogram(plotvar,'Normalization','probability','BinEdges',hist_Edge); hold on
%   h1=histogram(plotvar,'Normalization','probability'); hold on
  %---obs
%   xline(obs_wind_spd,'linewidth',2,'color','r');  
  %
  xlabel('Wind speed (m/s)'); ylabel('Frequency (%)')
  set(gca,'xlim',[hist_Edge(1) hist_Edge(end)],'ylim',[0 0.5],'fontsize',18,'linewidth',1.4) ;    
%    set(gca,'ylim',[0 0.5],'fontsize',18,'linewidth',1.4) ;    
  yticklabels(yticks*100)
  %
  x_lim=xlim; y_lim=ylim;
  text(x_lim(2)-5,y_lim(2)-0.03,['xp=',num2str(xp),', yp=',num2str(yp)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
%   tit={[titnam,' at ',sta,'(',s_lon,', ',s_lat,')'];...
%        [expri,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
  tit={[titnam,' at (',s_lon,', ',s_lat,')'];...
       [expri,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
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

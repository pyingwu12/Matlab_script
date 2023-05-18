clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000; 
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
%
expnam='Hagibis05kme01'; infilename='201910101800'; infiletrackname='201910101800track';
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Tracks';   fignam=['01_',expnam,'_track_black_'];  % unit='m s^-^1';
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
%---
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    data_time = (ncread(infile,'time'));
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    lon_track=zeros(length(data_time),pltensize);
    lat_track=zeros(length(data_time),pltensize);
  end  
  infile_track= [indir,'/',num2str(member(imem),'%.4d'),'/',infiletrackname,'.nc'];
  
  len_track=length(ncread(infile_track,'lon'));
  if len_track~=length(data_time)
      lon_track(1:len_track,imem) = ncread(infile_track,'lon');
      lon_track(len_track+1:end,imem) =NaN;
      lat_track(1:len_track,imem) = ncread(infile_track,'lat');
      lat_track(len_track+1:end,imem) =NaN;
  else
   lon_track(:,imem) = ncread(infile_track,'lon');
   lat_track(:,imem) = ncread(infile_track,'lat');
  end
  
end  %imem
%%
%
[nx, ny]=size(lon);
BCmem=50; 
% n=2; pltibc=randperm(BCmem,n)  %randomly plot n groups
pltibc=[42 33 41] ;
pmsl0=zeros(nx,ny,length(data_time),pltensize);
for ibc=pltibc
  for imem=ibc:BCmem:pltensize  
       infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];        
       pmsl0(:,:,:,imem)=ncread(infile,'pmsl'); 
  end
end
%%
%--colored by BC %--- please read data of from 1~pltensize members first
% load('colormap/colormap_ncl.mat')
% cmap=colormap_ncl;
% cmap2=cmap(8:5:end,:);
% cmap2=[0.7 0.7 0.7; 0.1 0.1 0.1; 0.4 0.4 0.4];
cmap2=[0.7 0.7 0.7; 0.4 0.4 0.4; 0.1 0.1 0.1];
%---
% plon=[min(lon(:)) max(lon(:))]; plat=[min(lat(:)) max(lat(:))];
plon=[135 149]; plat=[32 43.3];
%
close all
hf=figure('Position',[100 100 800 650]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%
m_coast('patch',[0.9 0.9 0.9],'linestyle','none');
hold on
n=0;
for ibc=pltibc
          n=n+1;
  for imem=ibc:BCmem:pltensize 
    m_plot(lon_track(:,imem),lat_track(:,imem),'color',cmap2(n,:),'Linewidth',2.2); hold on
    m_contour(lon,lat,pmsl0(:,:,43,imem),[1015 1015],'color',cmap2(n,:),'Linewidth',1.8,'linestyle','--')
    drawnow
  end
end
%---
% m_coast('linewidth',1.1,'color',[0.3 0.3 0.3],'linestyle','-');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
% m_usercoast('gumby','linewidth',1,'color',[0.4 0.4 0.4],'linestyle','--')
m_grid('fontsize',13,'LineStyle','-.','LineWidth',1,'xtick',100:20:170,'ytick',15:10:40,'color',[0.3 0.3 0.3]); 

set(gca,'linewidth',1.5)
%---plot the box of the domain ---
% m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
%---
% tit={expnam,['  ',titnam,'  (',num2str(pltensize/BCmem),' mem per BC)']};   
% title(tit,'fontsize',18)
%
outfile=[outdir,'/',fignam,'m',num2str(pltensize),'_coloredBC1_p'];
% if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
% end
%}

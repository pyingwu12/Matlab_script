clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;    pltspds=[25]; 
randmem=0;
%
% pltime=43;  expnam='Hagibis05kme02';  infilename='201910101800';  expsize=1000; 
% indir_t='/home/wu_py/plot_5kmEns/201910101800/'; 

pltime=19;  expnam='H01MultiE0206';  infilename='201910111800';  expsize=1000; 
load(['H01MultiE0206_center_',infilename,'.mat'])

%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expnam,'  Wind speed'];   fignam=[expnam,'_typhoon-spagh_'];   unit='m s^-^1';
%
% plon=[134 144]; plat=[30 38];
plon=[134.8 143.5]; plat=[32.3 38.5];   lo_int=135:5:144; la_int=30:5:37; % Japan center of Kanto
   
%---
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([2 3 5 8 9 11 12 14 ],:); cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 5 10 15 20 25 30];
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for ti=pltime     
  %---read ensemble
  tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
  for imem=1:pltensize     
    infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
    if imem==1
      lon = double(ncread(infile,'lon'));
      lat = double(ncread(infile,'lat'));
      [nx, ny]=size(lon);
      spd10_ens=zeros(nx,ny,pltensize);
      data_time = (ncread(infile,'time'));
      pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
    end  
    u10 = ncread(infile,'u10m');
    v10 = ncread(infile,'v10m');
    spd10_ens(:,:,imem)=double(u10(:,:,ti).^2+v10(:,:,ti).^2).^0.5;  
  %---
  
%     infile_track= [indir_t,num2str(member(imem),'%.4d'),'/201910101800track.nc'];
%     lon_track(:,imem) = ncread(infile_track,'lon');
%     lat_track(:,imem) = ncread(infile_track,'lat');  

  end  %imem

  
  %%
  plotvar=mean(spd10_ens,3);
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
%
  for plti=pltspds    
      
    %---plot    
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on 
    
%    
    %---
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',0.8,'color',[0.95 0.95 0.95],'linestyle','-')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    hold on
    for imem=1:pltensize     
      m_contour(lon,lat,spd10_ens(:,:,imem),[plti plti],'linewidth',0.6,'color',[0.6 0.4 0.6]); 
      drawnow
    end    
     m_contour(lon,lat,plotvar,[plti plti],'linewidth',1.5,'color',[0.1 0.1 0.1]);  
    for imem=1:pltensize     
%       m_plot(lon_track(pltime,imem),lat_track(pltime,imem),'.','color',[0.3 0.3 0.3],'markersize',10)
      m_plot(lon(typhoon_center(pltime,member(imem))),lat(typhoon_center(pltime,member(imem))),...
          '.','color',[0.4 0.2 0.4],'markersize',12)
      drawnow
    end
    %
    tit={[titnam,' (',num2str(plti),' m/s)'];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
    title(tit,'fontsize',18)    
    %
    %---colorbar---
      fi=find(L>pmin,1);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
      colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
%         hFills(idx).ColorData=uint8(cmap2(idx+fi+1,:)');
        hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
      end
     %
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
              '_spd',num2str(plti),'_m',num2str(pltensize),'rnd',num2str(randmem)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
  end %plti
end % pltime

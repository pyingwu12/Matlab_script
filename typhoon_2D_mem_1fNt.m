clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltime=16;   accuh=3; 
member=76; % member=[41 2];  
pltensize=0; randmem=0; %0: plot specified member ; else:randomly choose <pltensize> members 

expri='Hagibis01kme03'; infilename='201910120000';  filetag='s';
% expri='e02nh01G'; infilename='201910111800';%hagibis

% convert_id=0; %1: duc-san default; 2: convert by wu
%
expsize=1000;   
%
% indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
indir=['/obs262_data01/wu_py/Experiments/',expri];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end

%=============
%---plot wind shaded------
titnam='10-m Wind speed';   fignam0=[expri,'_typhoon-wind_'];  unit='m s^-^1';
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([2 3 5 8 9 11 12 14 ],:); cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 5 10 15 20 25 30];
plotid='wind';
%---plot rainfall shaded------
% titnam='rainfall';   fignam0=[expri,'_typhoon-rain_'];  unit='mm';
% load('colormap/colormap_rain.mat');  cmap=colormap_rain;
% cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 250];
% plotid='rain';
%=============

plon=[133 143]; plat=[31.5 39.5]; fignam=[fignam0,'jap_']; lo_int=135:5:144; la_int=30:5:37; % Japan 
% plon=[134.8 143.5]; plat=[32.3 38.5];  fignam=[fignam0,'japkan_']; lo_int=135:5:144; la_int=30:5:37; % Japan center of Kanto

%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize);end  %!random choose members  
for mem=member
  s_mem=num2str(mem,'%.4d');     
  infile= [indir,'/',s_mem,'/',filetag,infilename,'.nc'];
  %---read---
  data_time = (ncread(infile,'time'));
  lon = double(ncread(infile,'lon'));   lat = double(ncread(infile,'lat'));
  u10 = ncread(infile,'u10m');    v10 = ncread(infile,'v10m');
  pmsl = ncread(infile,'pmsl');
  rain0 = ncread(infile,'rain');
  %---
  spd10=double((u10.^2+v10.^2).^0.5);  
  %%
  for ti=pltime     
    for ai=accuh     
    rain=squeeze(rain0(:,:,ti+ai-1)-rain0(:,:,ti-1));
     pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
%---plot
      switch(plotid)
          case('wind'); plotvar=squeeze(spd10(:,:,ti)); 
          case('rain'); plotvar=rain;  
      end
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
      %
      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
      [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on  
      %
      %---grids and coast lines
      % m_coast('color','k');
      % m_gshhs_h('color','k','LineWidth',0.8);  % m_gshhs_h('save','gumby');
      m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
      %     
      m_contour(lon,lat,squeeze(pmsl(:,:,ti)),10,'color',[0.4 0.4 0.4],'linewidth',1.8); 
      
      switch(plotid)
          case('wind')
      m_contour(lon,lat,rain,[30 100],'color',[0.6 0.1 0.95],'linewidth',2.8);
      tit={[expri,'  ',titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(ai),'-h rain, mem ',num2str(mem,'%.4d'),')']};
          case('rain')
      m_contour(lon,lat,squeeze(spd10(:,:,ti)),[25 25],'color',[0.8 0.4 0.5],'linewidth',2.8);
      tit={[expri,'  ',num2str(ai),'-h ',titnam];[datestr(pltdate,'mm/dd HHMM'),'  (25 m/s, mem ',num2str(mem,'%.4d'),')']};
      end
      title(tit,'fontsize',18)
      
      %---colorbar---
      fi=find(L>pmin,1);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
      colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
      end
      %---
      outfile=[outdir,'/',fignam,'mem',s_mem,'_',datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
          '_',num2str(ai),'h'];
      if saveid==1
        print(hf,'-dpng',[outfile,'.png']) 
        system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
      end    
      
    end  % ai=accuh 
  end % ti=pltime 
end  % mem=member 

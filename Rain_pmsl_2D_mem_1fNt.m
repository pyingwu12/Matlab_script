clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltmem=[3]; pltime=[14];  
%
% expri='Hagibis05kme01'; infilename='201910101800';%hagibis
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san)
% convert_id=2; %1: duc-san default; 2: convert by wu (<-not used,fixed on 230212)
expsize=1000; 
%
% indir=['/data8/leduc/nhm/exp/Fugaku05km/forecast/Fugaku05km06/',infilename];%hagibis
% indir=['/home/leduc/nhm/exp/Kyushu02km/forecast/Kyushu02km06/',infilename];%kumakawa
% indir=['/data8/leduc/nhm/exp/Fugaku05km/forecast/Fugaku05km06/',infilename];nagasaki05km
indir=['/obs262_data01/wu_py/Experiments/Nagasaki02km/',infilename]; %nagasaki02km
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Rainfall';   fignam=[expri,'_rain_'];    unit='mm';
%
%cvrt_name={'';'sfc'};
%cvrt_time={'time';'times'};
%
%   plon=[134.5 143.5]; plat=[32 38.5]; fignam=[fignam,'3_']; 
plon=[120 140]; plat=[25 38]; %nagasaki
%---
load('colormap/colormap_rain.mat');  cmap=colormap_rain;
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%
L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300];

%---
%%
%---read ensemble
 
for imem=pltmem    
  infile=[indir,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];      
  lon = double(ncread(infile,'lon'));
  lat = double(ncread(infile,'lat'));
  [nx, ny]=size(lon);      
  data_time = (ncread(infile,'time'));
  
  rain0 = ncread(infile,'rain');
  pmsl0 = ncread(infile,'pmsl');
    
  for ti=pltime   
    pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
    pmsl_plt=squeeze(pmsl0(:,:,ti));
    plotvar=squeeze(rain0(:,:,ti));
    %
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %---plot    
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on  
    [~,hccc]=m_contour(lon,lat,pmsl_plt,3,'color',[0.3 0.3 0.3],'Linewidth',1.2,'linestyle','-');    
    %---
%   m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1.1,'color',[0.8 0.8 0.8],'linestyle','-')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',100:5:160,'ytick',15:5:50,'color',[0.5 0.5 0.5]); 
    % 
     % box of domain
m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');
m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
%---
    
    tit=[titnam,'  ',datestr(pltdate,'mm/dd HHMM'),'  (mem ',num2str(imem),')'];   
    title(tit,'fontsize',18)    
%     %
      fi=find(L>pmin,1);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
      colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
      end
%      %
%     outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
%               '_m',num2str(pltensize),'thrd',num2str(plti)];
%     if saveid==1
%      print(hf,'-dpng',[outfile,'.png'])    
%      system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%     end
    %---
 
  end % pltime
end

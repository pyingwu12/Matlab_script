clear
close all

saveid=0;

pltensize=100; pltime=[13 25 31];

reftime=pltime-1;

randmem=1; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

expri='Hagibis05kme01'; infilename='201910101800';%hagibis
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% convert_id=2; %1: duc-san default; 2: convert by wu (<-not used,fixed on 230212)
% expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san)
%
expsize=1000;  BCnum=50;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  pmsl spread growth rate'];   fignam=[expri,'_pmsl-SprdRatio_'];
%
%--
%     plon=[134.5 143.5]; plat=[32 38.5]; %hagibis kantou
%     plon=[121.2 138]; plat=[25 36.3]; %kumakawa
 plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center
 % plon=[120 138]; plat=[26 38]; %nagasaki

load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd([1,1:2:end],:); cmap(1,:)=[0.8 0.8 0.8];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=5:5:35;
L=[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7];
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end

for ti=1:length(pltime)
    
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
  if imem==1
      [nx, ny, ~]=size(ncread(infile,'pmsl'));
      pmsl0=zeros(nx,ny,pltensize,2);
      data_time = (ncread(infile,'time'));
  end  
  pmsl0(:,:,imem,:) = ncread(infile,'pmsl',[1 1 reftime(ti)],[Inf Inf 2],[1 1 pltime(ti)-reftime(ti)]);
end
lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
%data_time = (ncread(infile,cvrt_time{convert_id}));
disp('finished reading files')
%
%%
sprd_ref=std(pmsl0(:,:,:,1),0,3,'omitnan');
sprd=std(pmsl0(:,:,:,2),0,3,'omitnan');
%%
% plon=[131 145.5]; plat=[28 40.5];
% close all

    pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime(ti)));
 
%
  growthr=log(sprd./sprd_ref)/(pltime(ti)-reftime(ti));
  pmin=double(min(min(growthr)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,growthr,L2,'linestyle','none'); hold on   
  %
  % m_coast('color','k');
  % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
  m_usercoast('gumby','linewidth',1,'color',[0.9 0.9 0.9],'linestyle','--')
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
  % 
%   % ens mean
%   [c,hdis]=m_contour(lon,lat,squeeze(mean(pmsl0(:,:,ti,:),4)),plotcnt,'color',cntcol,'linewidth',1.8);     
%   clabel(c,hdis,plotcnt,'fontsize',15,'LabelSpacing',500,'color',cntcol) 
  
%  m_contour(lon,lat,sprdall_ini,5,'color',[1 0 0],'linewidth',1.8,'linestyle','--');
%   m_contour(lon,lat,growthr,5,'color',[1 0 0],'linewidth',1.8,'linestyle','--');
%    clabel(c,hdis,'fontsize',15,'LabelSpacing',500) 

  tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltime(ti)-reftime(ti)),' h, ',num2str(pltensize),' mem)']};   
  title(tit,'fontsize',18)
  %
%---colorbar---
  fi=find(L>pmin,1);
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
  colormap(cmap);    title(hc,'\lambda')
  hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
  for idx = 1 : numel(hFills)
    hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
  end
  drawnow; 
%
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_m',num2str(pltensize)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%---   
 %}
 
end %ti
%}

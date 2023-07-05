clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

acch=3; threshold=50;

pltensize=20; pltime=4:3:25;
randmem=0; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members

%  expri='Hagibis05kme01'; infilename='201910101800';%hagibis
% expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san)
%
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Rain spread'];   fignam=[expri,'_RainSprd01_'];
%
%cvrt_name={'';'sfc'};cvrt_time={'time';'times'};
%--
% plon=[134.5 143.5]; plat=[32 38.5]; %hagibis kantou
% plon=[121.2 138]; plat=[25 36.3]; %kumakawa
% plon=[120 142]; plat=[25 38]; %nagasaki
plon=[119.6 137.4]; plat=[27.1 36.9];   lo_int=105:10:155; la_int=15:10:50;  %Oizumi-Nagasaki 02km whole domain center
% plon=[120 139.5]; plat=[23 38];   lo_int=105:10:155; la_int=15:10:50;  %Kyushu02km whole domain center
% plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center
%--
load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd(1:2:end-1,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%---
L=[0.1 0.2 0.3 0.4 0.5 0.6]; 
%---
infile_mfhm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm.nc'];
land = double(ncread(infile_mfhm,'landsea_mask'));
%---
if randmem==0; member=1:pltensize;  elseif randmem==50; member=1:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end
%---
%%
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    vari0=zeros(nx,ny,pltensize,ntime);
    pmsl=zeros(nx,ny,pltensize,ntime);
  end  
  if isfile(infile) 
    vari0(:,:,imem,:) = ncread(infile,'rain');
    pmsl(:,:,imem,:) = ncread(infile,'pmsl');
  else
    vari0(:,:,imem,:) = NaN;
    disp(['member ',num2str(member(imem),'%.4d'),' file does''t exist'])
  end    
end
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
% disp('finished reading files')
%%
for ti=pltime  
  rain_ti=squeeze(vari0(:,:,:,ti)-vari0(:,:,:,ti-acch));
  rain_ti(rain_ti<threshold)=0; 
  rain_ti(rain_ti>=threshold)=1; 
  
%   rain_me=mean(rain_ti,3);
  sprd = std(rain_ti,0,3,'omitnan');   
%   sprd(sprd==0)=NaN;
%   sprd_nrm=sprd./ rain_me;
%%
  %---plot
  plotvar=sprd;
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
  %
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
  m_contour(lon,lat,land,[0.6 0.6],'linewidth',0.8,'color',[0.5 0.5 0.5],'linestyle','-')
%   m_coast('color',[0.4 0.4 0.4],'LineWidth',1.3);
%   m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
%   m_usercoast('gumby','linewidth',1,'color',[0.9 0.9 0.9],'linestyle','--')
  % 
%   %---ens mean
%   cntcol=[0.8 0.1 0.01];
    cntcol=[0.2 0.2 0.2];
%   plotcnt=900:5:1040;    % pmsl Nagasaki05km
%   plotcnt=970:20:1040; % pmsl, Hagibis05km
    plotcnt=[1003 1006 1009];   % pmsl, Nagasaki02km
  [c,hdis]=m_contour(lon,lat,squeeze(mean(pmsl(:,:,:,ti),3)),plotcnt,'color',cntcol,'linewidth',1.4,'linestyle','-');     
  clabel(c,hdis,plotcnt,'fontsize',10,'LabelSpacing',500,'color',cntcol) 
  
  tit={[titnam,'  (',num2str(threshold),' mm)'];[datestr(pltdate(ti-acch),'mm/dd HHMM'),datestr(pltdate(ti),'-HHMM'),...
      '  (',num2str(pltensize),' mem, rnd',num2str(randmem),')']};   
  title(tit,'fontsize',18)
  %
%---colorbar---
  fi=find(L>pmin,1);
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
  colormap(cmap);  drawnow;  
  hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
  for idx = 1 : numel(hFills)
    hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
  end
%
  outfile=[outdir,'/',fignam,'rnd',num2str(randmem),'m',num2str(pltensize),...
      '_th',num2str(threshold),'_',datestr(pltdate(ti-acch),'mmdd_HH'),datestr(pltdate(ti),'HH')];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

end %ti
%}
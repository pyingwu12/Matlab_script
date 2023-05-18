clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;     pltspds=[25]; 
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
%
% pltime=43; expnam='Hagibis05kme02'; infilename='201910101800';%hagibis
 pltime=19; expnam='Hagibis01kme02'; infilename='201910111800';%hagibis
expsize=1000; 
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam=[expnam,'  Wind speed'];    fignam=[expnam,'_wind-spagh_']; 
%
plon=[135 144.5]; plat=[32 39];  lo_int=136:2:144; la_int=33:2:37; % wide Kantou area
%plon=[135.5 142.5]; plat=[33.5 37]; fignam=[expnam,'_wind-spagh2_']; 
%---
%%
%---read ensemble
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);
    data_time = (ncread(infile,'time'));
    spd10_ens0=zeros(nx,ny,pltensize,length(data_time));    
  end  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
end  %imem
disp('End of reading files')
%%
% titnam=[expnam,'  Wind speed'];    fignam=[expnam,'_wind-spagh_']; 
% plon=[135 144.5]; plat=[32 39];  lo_int=136:2:144; la_int=33:2:37; % wide Kantou area

for ti=pltime    
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  spd10_ens= squeeze(spd10_ens0(:,:,:,ti));

  %---probability for different thresholds
  for plti=pltspds  
    %
    wind_pro=zeros(nx,ny);   
    for i=1:nx
      for j=1:ny
        wind_pro(i,j)=length(find(spd10_ens(i,j,:)>=plti));
      end
    end
    wind_pro=wind_pro/pltensize*100;
    wind_pro(wind_pro+1==1)=NaN;
      %}
    %---plot
    %    
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')    
    for imem=1:pltensize     
      m_contour(lon,lat,spd10_ens(:,:,imem),[plti plti],'linewidth',0.9,'color',[0.95 0.85 0.1]); hold on
      drawnow
    end    
    m_contour(lon,lat,wind_pro,[50  90],'linewidth',1.5,'color','r')
    %
    m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    tit={[titnam,' (',num2str(plti),' m/s)'];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
    title(tit,'fontsize',18)    
    %
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
              '_thrd',num2str(plti),'_m',num2str(pltensize),'rnd',num2str(randmem),''];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %}
    %% colored by BC
    %{
load('colormap/colormap_ncl.mat')
cmap=colormap_ncl;
cmap2=cmap(8:5:end,:);

    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')    
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    hold on
BCmem=50; 
n=5; %randomly plot n groups
% for ibc=randperm(BCmem,n)  
for ibc=[6 26 46] 
  for imem=ibc:BCmem:pltensize       
    m_contour(lon,lat,spd10_ens(:,:,imem),[plti plti],'color',cmap2(mod(imem,BCmem)+1,:),'Linewidth',1); hold on
    drawnow
  end
end
    %
    m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    %---
    tit={[titnam,' (',num2str(plti),' m/s)'];[datestr(pltdate,'mm/dd HHMM'),...
          '  (',num2str(pltensize/BCmem),' mem, colored by BC)']};   
    title(tit,'fontsize',18)    
    %
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
              '_thrd',num2str(plti),'_m',num2str(pltensize),'rnd',num2str(randmem),'_colBC'];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %}
    %---
  end %thi
end % pltime

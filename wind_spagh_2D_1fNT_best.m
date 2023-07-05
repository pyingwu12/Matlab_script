% !!! still need to adopt to different radius for different direction

clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltime=43;   pltspd=[15 25];

pltensize=1000;    
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

%plt_bst_time=[12 15];
plt_bst_time=[12]; % for plot typhoon center and radius of best track


expri='Hagibis05kme02'; infilename='201910101800';%hagibis05
expsize=1000; 


indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,' Wind speed']; fignam=[expri,'_WindSpagh_'];  % unit='m/s';
%---
infile_hm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm2.nc',];
land = double(ncread(infile_hm,'landsea_mask'));

%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time')); [nx, ny]=size(lon); ntime=length(data_time);
    spd0=zeros(nx,ny,pltensize,ntime);      
  end  
  
  u10 = ncread(infile,'u10m');  v10 = ncread(infile,'v10m');
  spd0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
  
end
pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));
%
% spd_mean=mean(spd10_ens,3);
%%
for ti=pltime
bst_loc=[139.6 35.6]; % 10/12 2100 JST (1200 UTC)

spd=spd0(:,:,:,ti);

for ispd=pltspd
  %---probability  
  wind_threshold=ispd;
  wind_pro=zeros(nx,ny);
  for i=1:nx
    for j=1:ny
      wind_pro(i,j)=length(find(spd(i,j,:)>=wind_threshold));
    end
  end
  wind_pro=wind_pro/(pltensize)*100;
  %---
  if ispd==25; bst_rad=[260 330];  elseif ispd==15; bst_rad=650; end
%%
bst_time=plt_bst_time;
%   for bst_time=plt_bst_time
%     if bst_time==12
      % 10/12 2100 JST (1200 UTC)
%       bst_loc=[139.6 35.6];
%       if spd_ctr==25; bst_rad=[260 330];  elseif spd_ctr==15; bst_rad=650; end
% %       bst_max=35;
%     elseif bst_time==15
%       % 10/13 0000 JST (1500 UTC)
%       bst_loc=[140.6 36.9];
%       if spd_ctr==25; bst_rad=280;  elseif spd_ctr==15; bst_rad=600; end
% %       bst_max=30;
%     end
    dis2bst=Great_circle_distance(lon,lat,bst_loc(1),bst_loc(2),'d');
    % !!! set to NW only!! need to be modified!
    if length(bst_rad)>1
      mask_rad=zeros(nx,ny);
      mask_rad(dis2bst<=bst_rad(2) & lon>bst_loc(1) & lat>bst_loc(2))=1;
      mask_rad(dis2bst<=bst_rad(2) & lon>bst_loc(1) & lat<bst_loc(2))=1;
      mask_rad(dis2bst<=bst_rad(2) & lon<bst_loc(1) & lat<bst_loc(2))=1;
      mask_rad(dis2bst<=bst_rad(1) & lon<bst_loc(1) & lat>bst_loc(2))=1;
    end
%%
%---plot
    hf=figure('Position',[100 100 800 630]);
    plon=[139.6-8 139.6+8]; plat=[35.6-7 35.6+7]; 
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

    for imem=1:pltensize
      m_contour(lon,lat,squeeze(spd(:,:,imem)),[ispd ispd],'linewidth',0.8,'color',[1 0.8 0]); hold on
      drawnow
      if mod(imem,200)==0; disp([num2str(imem),' done']); end
    end

%     m_contour(lon,lat,wind_pro,[50 90],'linewidth',1.5,'color','r')
    m_contour(lon,lat,wind_pro,[70 70],'linewidth',1.5,'color','r')
    
    %---
    m_plot(bst_loc(1),bst_loc(2),'^','color','b','Markersize',12,'Markerfacecolor','b')
    if length(bst_rad)>1
      m_contour(lon,lat,mask_rad,[1 1],'linewidth',2,'color','b')
    else
      m_contour(lon,lat,dis2bst,[bst_rad bst_rad],'linewidth',2,'color','b')
    end
    %---
    time_str=datestr(pltdate);
    m_text(plon(1)+0.25,plat(1)+0.3,{['Wind speed: ',num2str(ispd),' m/s'],['Valid: ',time_str(1,:)]},'color','k','fontsize',14)
    %---
%    m_coast('color','k');
%    m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color','k')    
    m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',135:5:145,'ytick',25:5:40,'fontsize',13); 
%     m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',[130 130],'ytick',[],'fontsize',13,'xaxislocatio','top');
% 
    title(['10-m wind (',num2str(pltensize),' mem)'],'fontsize',16)
%
    outfile=[outdir,'/',fignam,'t',num2str(pltime),'m',num2str(pltensize),'spd',num2str(ispd),'bst',num2str(bst_time)]; 
    if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
%   end %bst_time
end %spd_ctr
end %pltime

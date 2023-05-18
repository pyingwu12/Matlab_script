clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;
%
pltensize=1000;   hr=0:3;  minu=0:10:50;
%
expnam='H01km';
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='Tracks and pmsl';   fignam=[expnam,'_track-p2_'];  % unit='m s^-^1';
%---
load('H01km_center.mat')

% plon=[130 147]; plat=[26 42];
plon=[131 145.5]; plat=[28 40.5]; 
%
member=1:pltensize; %!!!!!!!!
% member=[1:2:50, 51:38:1000]; %!!!!!!!!
%%
for ti=1:length(hr)
  s_date=num2str(day+fix(hr(ti)/24),'%2.2d');   s_hr=num2str(mod(hr(ti),24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');   
     ntrack=1+(hr(ti)-0)*6+(tmi-0)/10; 
    %  
    for imem=1:pltensize     
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      if imem==1
       lon = double(ncread(infile,'lon'));
       lat = double(ncread(infile,'lat'));
       [nx, ny]=size(lon);
       pmsl_ens=zeros(nx,ny,pltensize);
      end         
      pmsl_ens(:,:,imem)=ncread(infile,'pmsl'); 
    end  %imem
%%
%--
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
 
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',110:5:150,'ytick',15:5:50,'color',[0.3 0.3 0.3]); 
hold on
    
    for imem=1:2:50
      m_plot(lon(typhoon_center(ntrack,imem)),lat(typhoon_center(ntrack,imem)),'.','color',[0.01 0.05 0.8],'Markersize',10); hold on
      m_contour(lon,lat,pmsl_ens(:,:,imem),[970 1005],'color',[0.01 0.05 0.8]);
      drawnow  
    end
    
   
    for imem=51:38:1000
      m_plot(lon(typhoon_center(ntrack,imem)),lat(typhoon_center(ntrack,imem)),'.','color',[0.8 0.05 0.01],'Markersize',10); hold on
      m_contour(lon,lat,pmsl_ens(:,:,imem),[970 1005],'color',[0.8 0.05 0.01]);
      drawnow  
    end
    
 m_contour(lon,lat,mean(pmsl_ens(:,:,1:50),3),[950 970 990 1005],'color',[0.1 0.7 0.05],'linewidth',2.8);

% %---
    m_usercoast('gumby','linewidth',1,'color',[0.3 0.3 0.3],'linestyle','--')
% %---plot the box of the domain ---
boxcol={'color',[0.1 0.1 0.1],'linewidth',1.2};
m_plot(lon(:,1),lat(:,1),'color',[0.1 0.1 0.1],'linewidth',1.2);
m_plot(lon(1,:),lat(1,:),'color',[0.1 0.1 0.1],'linewidth',1.2);
m_plot(lon(:,end),lat(:,end),'color',[0.1 0.1 0.1],'linewidth',1.2);
m_plot(lon(end,:),lat(end,:),'color',[0.1 0.1 0.1],'linewidth',1.2)
% %---
    tit={titnam;[month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem)']};
    title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'_colored50950'];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

  end
end

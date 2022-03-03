%function uv_atVr(pradar,paza,tita)
%
clear all
%
hr=0;  minu='00';  
expri='largens';  infilenam='wrfmean';  type='mean';
pradar=3; pela=0.5;  naza=138:5:313;  ndis=53:10:113;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS011/pwin/201work/data/wrf2obs_uv/largens_wrf2obs_',expri]; 
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_tern.mat';
cmap=colormap_tern(1:8,:)+0.05;  cmap(cmap>1)=1;
%cmap=colormap_br2([4 5 7 8 9 13 14 15 17 18],:);
L=[-90 -60 -30 0 30 60 90];   
%---
filenam=[expri,'_uvatVr_mean'];
g=9.81;
plon=[118.4 121.8]; plat=[20.65 24.35];
%
%
%---
   ti=hr;
   s_hr=num2str(ti,'%2.2d');  
%---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%--- 
      fid=fopen(infile);
      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f');      fclose(fid);
      fin1=find(vo{2}==pela & vo{3}>133 & vo{3}<358 & vo{4}>48 & vo{4}<83 & mod(vo{4}-3,10)==0 & vo{1}==pradar);
      fin2=find(vo{2}==pela & vo{3}>133 & vo{3}<358 & vo{4}>78 & vo{4}<133 & mod(vo{4}-3,10)==0 & vo{1}==pradar);
      fin=[fin1' fin2'];
      vru=sin(vo{3}(fin)./180*pi).*vo{10}(fin).*cos(vo{2}(fin)./180*pi);
      vrv=cos(vo{3}(fin)./180*pi).*vo{11}(fin).*cos(vo{2}(fin)./180*pi);

      u_vr=vru./vo{8}(fin)*100;
      v_vr=vrv./vo{8}(fin)*100;
      fin999= find(vo{8}(fin)==-9999);
      if isempty(fin999)~=1; 
         disp(['member ',nen,' obs have -9999']); 
         disp(num2str(fin999))
      end;       

   lon=vo{5}(fin); lat=vo{6}(fin);

 %----plot
  figure('position',[100 200 600 500])
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
  hp=plot_point(u_vr,lon,lat,cmap,L);
  %
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:1:130,'ytick',17:1:45);
  %m_gshhs_h('color','k','LineWidth',0.8);
  %m_coast('color','k');
  cm=colormap(cmap);    caxis([L(1) L(length(L))]);
  hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13,'LineWidth',1);

%  lonrad=120.8471; latrad=21.9026;
%  m_plot(lonrad,latrad,'^','color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',10)
  lonrad=120.086; latrad=23.1467;
  m_plot(lonrad,latrad,'^','color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',10)

   tit=['u ratio to Vr  ',s_hr,minu,'UTC  (',type,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(pradar)];
%   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);

%


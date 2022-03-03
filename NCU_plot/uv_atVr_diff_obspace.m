%function uv_atVr(pradar,paza,tita)
%
clear all
%
hr=0;  minu='00';   memsize=256;  

expri='largens';  infilenam='wrfout';  type='wrfo';
nrad=4; nela=0.5;  naza=138:5:313;  
ndis=53:10:113;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS011/pwin/201work/data/wrf2obs_uv/largens_wrf2obs_',expri]; 
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_tern.mat';
cmap=colormap_tern([4 3 2 1 8 7 6 5],:)+0.05;
cmap(cmap>1)=1;
%cmap=colormap_br2([4 5 7 8 9 13 14 15 17 18],:);
L=[-90 -60 -30 0 30 60 90];   
%---
filenam=[expri,'_uvatVr_west_'];
%np=length(nrad)*length(naza)*length(ndis)-36;
%fin=zeros(np,1);
pela=nela;
g=9.81;
plon=[118.4 121.8]; plat=[20.65 24.35];
%
%
%---
   ti=hr;
   s_hr=num2str(ti,'%2.2d');  
%---
%{
   for mi=1:memsize;
      nen=num2str(mi,'%.3d');      
      infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen];
%--- 
      fid=fopen(infile);
      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f');      fclose(fid);
      %
      if mi==1
      fin1=find(vo{2}==pela & vo{3}>=138 & vo{3}<=253 & vo{4}>=53 & vo{4}<=70 & mod(vo{4}-3,10)==0 & mod(vo{3}-3,10)==0);
      fin2=find(vo{2}==pela & vo{3}>=143 & vo{3}<=253 & vo{4}>70 & vo{4}<=113 & mod(vo{4}-3,10)==0 );
%      fin1=find(vo{2}==pela & vo{3}>=198 & vo{3}<=303 & vo{4}>=53 & vo{4}<=70 & mod(vo{4}-3,10)==0 & mod(vo{3}-3,10)==0);
%      fin2=find(vo{2}==pela & vo{3}>=203 & vo{3}<=303 & vo{4}>70 & vo{4}<=113 & mod(vo{4}-3,10)==0 );
      fin=[fin1' fin2'];
      u_vrm=zeros(length(fin),1); v_vrm=zeros(length(fin),1);
%        p=0;
%        for pradar=nrad
%          for pdis=ndis               
%            if pdis>70; naza=138:5:313; else naza=138:10:313; end
%            for paza=naza
%              p=p+1;
%              fin(p)=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
%            end
%          end
%        end
      end %m=1
      vru=sin(vo{3}(fin)./180*pi).*vo{10}(fin).*cos(vo{2}(fin)./180*pi);
      vrv=cos(vo{3}(fin)./180*pi).*vo{11}(fin).*cos(vo{2}(fin)./180*pi);

      u_vrm=u_vrm+vru./vo{8}(fin)*100/memsize;
      v_vrm=v_vrm+vrv./vo{8}(fin)*100/memsize;
      fin999= find(vo{8}(fin)==-9999);
      if isempty(fin999)~=1; 
         disp(['member ',nen,' obs have -9999']); 
         disp(num2str(fin999))
      end;       
      if mod(mi,10)==0; disp(num2str(mi)); end
   end   %member

   diff=u_vrm-v_vrm;
   lon=vo{5}(fin); lat=vo{6}(fin);

%}
%uv_diff3= diff;
%save(['uv_atVr_diff_',num2str(nrad),'.mat'],'uv_diff3','lon','lat')
%uv_diff_south=diff; 
%lon_s=lon;
%lat_s=lat;
%save(['uv_atVr_diff_south.mat'],'uv_diff_south','lon_s','lat_s')
load('uv_atVr_diff_west.mat')
diff=uv_diff_west; lon=lon_w; lat=lat_w;
%load(['uv_atVr_diff_',num2str(nrad),'.mat'])
%diff=eval(['uv_diff',num2str(nrad)]);
%
%load(['uv_atVr_diff_3.mat'])
%lon3=lon; lat3=lat;
%load(['uv_atVr_diff_4.mat'])
%lon4=lon; lat4=lat;

%s_hr=num2str(hr,'%2.2d');

 %----plot
  figure('position',[100 200 600 500])
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')

%  hp=plot_point(uv_diff3,lon3,lat3,cmap,L);
%  hp=plot_point(uv_diff4,lon4,lat4,cmap,L);
  hp=plot_point(diff,lon,lat,cmap,L);

  m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:1:130,'ytick',17:1:45);
  m_gshhs_h('color','k','LineWidth',0.8);
  %m_coast('color','k');
  cm=colormap(cmap);    caxis([L(1) L(length(L))]);
  hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13,'LineWidth',1);

  lonrad=120.8471; latrad=21.9026;
  m_plot(lonrad,latrad,'^','color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',10)
  lonrad=120.086; latrad=23.1467;
  m_plot(lonrad,latrad,'^','color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',10)

%   tit=['u-v ratio to Vr  ',s_hr,minu,'UTC  (',type,')'];
   tit='U@Vr/Vr - V@Vr/Vr  (west)';
   title(tit,'fontsize',16)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(nrad)];
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);

%


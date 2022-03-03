clear all
close all

hr=0;   minu='00';   expri='largens';
lev=10;  int=6; memsize=40;

%---DA or forecast time---
dirnam='pert'; infilenam='wrfout'; type=infilenam;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri,'/'];  
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_vr.mat';  cmap=colormap_vr;
L=[-14 -12 -10 -8 -6 -4 -2  0 2 4 6 8 10 12 14];
%------
varinam='Vr Zero-line';    filenam=[expri,'_vr-model-0_']; 
%plon=[118.9 121.8];   plat=[21 24.3];
plon=[118.75 121.9];  plat=[20.65 24.35];
%
rad3=[120.8471 21.9026 42];
rad4=[120.0860 23.1467 38];

for ti=hr;
%---set filename---
   s_hr=num2str(ti,'%2.2d');  % start time string
%----
   infile=[indir,'/wrfmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqDimID(ncid,'west_east');    [~, nx]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'south_north');  [~, ny]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'XLONG');    x =netcdf.getVar(ncid,varid,'double');
   varid  =netcdf.inqVarID(ncid,'XLAT');     y =netcdf.getVar(ncid,varid,'double');
   varid  =netcdf.inqVarID(ncid,'U');        u.stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'V');        v.stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]);
   u.unstag=( u.stag(1:end-1,:)+u.stag(2:end,:) ).*0.5;
   v.unstag=( v.stag(:,1:end-1)+v.stag(:,2:end) ).*0.5;
   uplot=u.unstag(1:int:nx,1:int:ny);   vplot=v.unstag(1:int:nx,1:int:ny);
   x2=x(2:end-1,2:end-1);      y2=y(2:end-1,2:end-1);
   xi=x(1:int:nx,1:int:ny);    yi=y(1:int:nx,1:int:ny);
%-----------------------
   figure('position',[600 500 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
%----
   windmax=15;  scale=1;
   windbarbM_mapVer(xi,yi,uplot,vplot,scale,windmax,[0.02 0.4 0.05],0.8)
   windbarbM_mapVer(plon(1)+0.2,plat(1)+0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1)
   m_text(plon(1)+0.21,plat(1)+0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)
   hold on
   vrm3=cal_model_vr(ncid,x,y,rad3,lev,nx,ny);
   vrm4=cal_model_vr(ncid,x,y,rad4,lev,nx,ny);
   netcdf.close(ncid)
%------------------
   for mi=1:memsize
%---set filename---
      nen=num2str(mi,'%.3d');
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
      ncid = netcdf.open(infile,'NC_NOWRITE');
%      if mi==1
%      varid  =netcdf.inqDimID(ncid,'west_east');    [~, nx]=netcdf.inqDim(ncid,varid);
%      varid  =netcdf.inqDimID(ncid,'south_north');  [~, ny]=netcdf.inqDim(ncid,varid);
%      varid  =netcdf.inqVarID(ncid,'XLONG');    x =netcdf.getVar(ncid,varid,'double'); 
%      varid  =netcdf.inqVarID(ncid,'XLAT');     y =netcdf.getVar(ncid,varid,'double');   
%      x2=x(2:end-1,2:end-1); y2=y(2:end-1,2:end-1);
%      end
      vr=cal_model_vr(ncid,x,y,rad3,lev,nx,ny);
      vr1=(vr(1:end-2,:)+vr(2:end-1,:)+vr(3:end,:))/3;
      vr2=(vr1(:,1:end-2)+vr1(:,2:end-1)+vr1(:,3:end))/3;
      m_contour(x2,y2,vr2,[0 0],'color',[0.78 0.78 0.98],'linewidth',1.1); hold on
%---plot---
      %
      if mod(mi,20)==0; disp([nen,' done']); end
      netcdf.close(ncid)
   end %mi
   for mi=1:memsize
      nen=num2str(mi,'%.3d');
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
      ncid = netcdf.open(infile,'NC_NOWRITE');      
      vr=cal_model_vr(ncid,x,y,rad4,lev,nx,ny);
      vr1=(vr(1:end-2,:)+vr(2:end-1,:)+vr(3:end,:))/3;
      vr2=(vr1(:,1:end-2)+vr1(:,2:end-1)+vr1(:,3:end))/3;
      m_contour(x2,y2,vr2,[0 0],'color',[0.98 0.78 0.78],'linewidth',1.1); hold on     
      if mod(mi,20)==0; disp([nen,' done']); end
      netcdf.close(ncid)
   end
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);
%---plot mean field---------   
   m_contour(x,y,vrm3,[0 0],'color',[0.1 0.1 0.1],'linewidth',2,'linestyle','--');
   m_contour(x,y,vrm4,[0 0],'color',[0.1 0.1 0.1],'linewidth',2,'linesytle','--');
%--------------
   m_plot(rad3(1),rad3(2),'^','color',[0.1 0.1 0.5],'linewidth',1,'MarkerFaceColor',[0.1 0.1 0.5],'MarkerSize',11)
   m_plot(rad4(1),rad4(2),'^','color',[0.5 0.1 0.1],'linewidth',1,'MarkerFaceColor',[0.5 0.1 0.1],'MarkerSize',11)
%---
   tit=[expri,'  ',varinam,'  ',s_hr,'z  (',type,' lev',num2str(lev),')']; 
   outfile=[outdir,filenam,s_hr,'_',type,'_lev',num2str(lev)];
   title(tit,'fontsize',15)
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);    
end



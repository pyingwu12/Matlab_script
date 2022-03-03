%-------------------------------------------------------
% Plot wind vector of difference(exp1-exp2) between expri1 to expri2 (with speed(shaded) when spid~=0)
%-------------------------------------------------------

clear all
close all

hr=3;  expri1='e01';  expri2='e02';   isoid=0;    spid=0;
%
if isoid==0;   lev=10;   else    hgt_w =3500;    end  % level or height for plot
% DA or forecast time---
infilenam='wrfout';  minu='00';  type='sing';
%infilenam='output/fcstmean'; minu='30';  type=infilenam(8:11);  %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';  
%indir='/SAS009/pwin/expri_cctmorakot/';    
%indir='/SAS009/pwin/expri_morakotEC/'; 
indir='/SAS009/pwin/expri_largens/'; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];
L=[-7 -5 -3 -2 -1 -0.5 0.5 1 2 3 5 7 ]; %IOP8
%L=[-9 -7 -5 -3 -2 -1 1 2 3 5 7 9];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br; 
%---
varinam='wind';  filenam=[expri1,'_wind-diff-',expri2,'_'];  
if spid~=0; filenam=['sp_',filenam]; end
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.9 121.8];   plat=[21 24.3];
g=9.81;   int=9; %interval for plot wind vector
  
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');    % start time string
%---set filename---
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
 %  varid  =netcdf.inqVarID(ncid,'PH');       ph1  =netcdf.getVar(ncid,varid);
 %  varid  =netcdf.inqVarID(ncid,'PHB');      phb1 =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   [nx ny]=size(x); nz=size(u.stag,3);
   u.unstag1=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag1=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
   
%====read netcdf data 2----   
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
 %  varid  =netcdf.inqVarID(ncid,'PH');       ph2  =netcdf.getVar(ncid,varid);
 %  varid  =netcdf.inqVarID(ncid,'PHB');      phb2 =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   u.unstag2=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag2=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;      
   
   %---interpolation to constant-height above surface when isoid~=0
   if isoid~=0
      P0=double(phb1+ph1);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg1=double(PH)/g;   
      P0=double(phb2+ph2);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg2=double(PH)/g;   
      hgtiso=double(hgt)+hgt_w; 
      %---interpolation to constant-height above surface
      for i=1:nx
       for j=1:ny
       X=squeeze(zg1(i,j,:));
       Y=squeeze(u.unstag1(i,j,:));     u.iso1(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       Y=squeeze(v.unstag1(i,j,:));     v.iso1(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       
       X=squeeze(zg2(i,j,:));
       Y=squeeze(u.unstag2(i,j,:));     u.iso2(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       Y=squeeze(v.unstag2(i,j,:));     v.iso2(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       end
      end      
      spd1=(u.iso1.^2+v.iso1.^2).^0.5;
      spd2=(u.iso2.^2+v.iso2.^2).^0.5;
      spdiff=spd1-spd2;
      u.diff=u.iso1-u.iso2;  v.diff=v.iso1-v.iso2;  
      u.plot=u.diff(1:int:nx,1:int:ny,:);   v.plot=v.diff(1:int:nx,1:int:ny,:);             
      plotvar=spdiff;
      isotype=[num2str(hgt_w/1000),'km'];
   else
      spd1=(u.unstag1.^2+v.unstag1.^2).^0.5;
      spd2=(u.unstag2.^2+v.unstag2.^2).^0.5;
      spdiff=spd1-spd2;
      u.diff=u.unstag1-u.unstag2;   v.diff=v.unstag1-v.unstag2; 
      u.plot=u.diff(1:int:nx,1:int:ny,lev);   v.plot=v.diff(1:int:nx,1:int:ny,lev); 
      plotvar=spdiff(:,:,lev);
      isotype=['lev',num2str(lev)];
   end   
   xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
   
   %---plot---           
   figure('position',[100 500 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   %---speed shaded--- 
   if spid~=0
    hold on   
    pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
    cm=colormap(cmap);    caxis([L2(1) L(length(L))])  
    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)   
   end
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k','LineWidth',0.8);
  m_gshhs_h('color',[0.2 0.2 0.2],'LineWidth',0.8);
   %---
   hold on
   [c2,hc]=m_contour(x,y,u.diff(:,:,lev),[3 3],'color',[0.05 0.5 0.8],'linewidth',1);
   [c2,hc]=m_contour(x,y,u.diff(:,:,lev),[-3 -3],'color',[0.05 0.8 1],'linewidth',1);
%     clabel(c2,hc,'fontsize',11,'color',[0.05 0.4 0.7],'LabelSpacing',400);
   [c2,hc]=m_contour(x,y,v.diff(:,:,lev),[3 3],'color',[0.8 0.05 0.5],'linewidth',1);
   [c2,hc]=m_contour(x,y,v.diff(:,:,lev),[-3 -3],'color',[0.9 0.05 1],'linewidth',1);
%     clabel(c2,hc,'fontsize',11,'color',[0.7 0.05 0.4],'LabelSpacing',400);
   %---
   windmax=5;
   windbarbM_mapVer(xi,yi,u.plot,v.plot,16,windmax,[0.05 0.02 0.2],1.1)
   windbarbM_mapVer(plon(1)+0.2,plat(2)-0.2,windmax,0,20,windmax,[0.8 0.05 0.1],1)
   m_text(plon(1)+0.21,plat(2)-0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)

   %---
   tit=[expri1,' minus ',expri2,'  ',varinam,'  ',s_hr,minu,'z  (',type,' ',isotype,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype];
   %print('-dpng',outfile,'-r400')      
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]); 
end  %ti


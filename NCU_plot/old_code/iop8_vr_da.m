%function vr_impr(hm,sw,expri,zmind)
% hm: time, string. ex:'15:00'
% sw: elevation angel (/0.5, 1.4, 2.4, 3.4, 4.3, 6.0, 9.9, 14.6, 19.5/)
% expri: experiment name, string. ex:'MR15'
% zmind: if zmind~=0, figure will zoom in to lon=[119.1 121.4]; lat=[22 24.3];
clear
hm='00:00'; sw=2.4; expri='All-10'; zmind=1;  plotid=4;%(1:innovation 2:increment 3:residual 4:improvement)
varid=1;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/'); 
load '/work/pwin/data/colormap_br.mat';   cmap=colormap_br([1:6,8:13],:);
%---setting---
%vari='Vr improvement';   filenam=[expri,'_vr-impr_'];  
num=size(hm,1);
indir=['/work/pwin/data/IOP8_wrf2obs_',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
%---
Lt=[100 500 1000 2000 ];
L=[-2 -1.6 -1.2 -0.8 -0.4 0 0.4 0.8 1.2 1.6 2];
%---
for ti=1:num;
  time=hm(ti,:);
%----read data----=======================
%---obs
  %infile1=['/SAS004/pwin/data/obs_sz6414/obs_d03_2008-06-16_',time,':00'];
  infile1=['/SAS004/pwin/data/obs_OSSE/obs_d03_2008-06-16_',time,':00'];
  A=importdata(infile1);
  radar=A(:,1); finr=find(radar==4 | radar==3);
  lon=A(finr,5); lat=A(finr,6); ela=A(finr,2); 
  vr1 =A(finr,8);  
%---wrf1 on obs fcst/orig---
  infile2=[indir,'/fcstmean_d03_2008-06-16_',time,':00'];
  B=importdata(infile2); 
  vr2 =B(finr,8); 
%---wrf2 on obs anal/expri---    
  infile3=[indir,'/analmean_d03_2008-06-16_',time,':00'];
  C=importdata(infile3); 
  vr3 =C(finr,8); 
%---model x, y, terrain data   ---
  infile2=['/SAS007/pwin/expri_sz6414/',expri,'/output/analmean_d03_2008-06-','16','_',hm,':00'];
  ncid = netcdf.open(infile2,'NC_NOWRITE');
  varid  =netcdf.inqVarID(ncid,'HGT');    hgt =netcdf.getVar(ncid,varid);
  varid  =netcdf.inqVarID(ncid,'XLONG');  lonw =netcdf.getVar(ncid,varid);    x=double(lonw);
  varid  =netcdf.inqVarID(ncid,'XLAT');   latw =netcdf.getVar(ncid,varid);    y=double(latw);
%---tick -9999---=======================
  fin=find(vr3~=-9999 & vr2~=-9999 & vr1~=-9999);
  lon=lon(fin); lat=lat(fin);
  vr1=vr1(fin); vr2=vr2(fin); vr3=vr3(fin);  ela=ela(fin);
%---plot---===============================
  switch (plotid)
  case(1)
    vari='Vr innovation';  filenam=[expri,'_vr-inno_']; 
    if zmind~=0;   filenam=['zm_',filenam];  end
    inno=vr1-vr2;
    for swi=sw
      plotvar=inno(ela==swi);
      lon_sw=lon(ela==swi); lat_sw=lat(ela==swi);
      plot_radar(plotvar,lon_sw,lat_sw,cmap,L,zmind)  %%%----plot function
      %m_plot(obs_lon,obs_lat,'xk','MarkerSize',9,'LineWidth',3)
      ht=m_contour(x,y,double(hgt),Lt,'color',[0.2 0.2 0.2],'LineWidth',1.2);
      %
      tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  (',num2str(swi),')'];
      title(tit,'fontsize',15)
      outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(swi),'.png'];
      print('-dpng',outfile,'-r350')
    end
  case(2)
    vari='Vr increment';  filenam=[expri,'_vr-incr_'];
    if zmind~=0;   filenam=['zm_',filenam];  end
    incr=vr3-vr2;
    for swi=sw
      plotvar=incr(ela==swi);
      lon_sw=lon(ela==swi); lat_sw=lat(ela==swi);
      plot_radar(plotvar,lon_sw,lat_sw,cmap,L,zmind)  %%%----plot function
      %m_plot(obs_lon,obs_lat,'xk','MarkerSize',9,'LineWidth',3)
      ht=m_contour(x,y,double(hgt),Lt,'color',[0.2 0.2 0.2],'LineWidth',1.2);
      %
      tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  (',num2str(swi),')'];
      title(tit,'fontsize',15)
      outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(swi),'.png'];
      print('-dpng',outfile,'-r350')
    end
  case(3)    
    vari='Vr residual';   filenam=[expri,'_vr-resi_']; 
    if zmind~=0;   filenam=['zm_',filenam];  end
    resi=vr1-vr3;
    for swi=sw
      plotvar=resi(ela==swi);  
      lon_sw=lon(ela==swi); lat_sw=lat(ela==swi);
      plot_radar(plotvar,lon_sw,lat_sw,cmap,L,zmind)  %%%----plot function
      %m_plot(obs_lon,obs_lat,'xk','MarkerSize',9,'LineWidth',3)
      ht=m_contour(x,y,double(hgt),Lt,'color',[0.2 0.2 0.2],'LineWidth',1.2);
      %
      tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  (',num2str(swi),')'];
      title(tit,'fontsize',15)
      outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(swi),'.png'];
      print('-dpng',outfile,'-r350')
    end
  case(4)
    vari='Vr improvement';   filenam=[expri,'_vr-impr_']; 
    if zmind~=0;   filenam=['zm_',filenam];  end
    inno=vr1-vr2;  resi=vr1-vr3;
    impr=abs(resi)-abs(inno);
    for swi=sw
      plotvar=impr(ela==swi);
      lon_sw=lon(ela==swi); lat_sw=lat(ela==swi);
      plot_radar(plotvar,lon_sw,lat_sw,cmap,L,zmind)  %%%----plot function
      %m_plot(obs_lon,obs_lat,'xk','MarkerSize',9,'LineWidth',3)
      ht=m_contour(x,y,double(hgt),Lt,'color',[0.2 0.2 0.2],'LineWidth',1.2);
      %
      tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  (',num2str(swi),')'];
      title(tit,'fontsize',15)
      outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(swi),'.png'];
      print('-dpng',outfile,'-r350')
    end
  end
%}
end

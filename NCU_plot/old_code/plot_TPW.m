% hr : time
% expri : experiment name
%hr=18; expri='DA1518vrzh';  %test


s_hr='15'; s_min='45';
expri='MRcycle02';

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr.mat'
%----set---- 
vari='TPW';   filenam=[expri,'_TPW_'];  type='mean';  
indir='/SAS002/pwin/expri_241/morakot_MRcycle02_1518_vr_900/output';

%----
cmap=colormap_qr;
L=[35 38 42 46 50 54 58 62 66 70 74 78 82 85];
%----    
   infile=[indir,'/fcstmean_d03_2009-08-08_',s_hr,':',s_min,':00'];
%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QCLOUD');  qc  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QICE');    qi  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QSNOW');   qs  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QGRAUP');  qg  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb =netcdf.getVar(ncid,varid); 
%---
   qt=qr+qc+qv+qi+qg+qs;
   P=(pb+p);
   nz=size(qt,3); %ny=size(qt,2); nx=size(qt,1);
   g=9.81;
%---  
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qt(:,:,2:nz)+qt(:,:,1:nz-1)).*0.5 ) ;    
   TPW=sum(tpw,3)./g;
   %---plot
   L2=[min(min(TPW)),L];
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,TPW,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
   colorbar;   cm=colormap(cmap);   
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
   tit=[expri,'  ',vari,'  ',s_hr,s_min,'z  (',type,')'];
   title(tit,'fontsize',15)
   outfile=[filenam,s_hr,s_min,'_',type,'.png'];
   saveas(gca,outfile,'png');  
%---    
   netcdf.close(ncid)


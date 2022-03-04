%function TPW_en(hr,expri,member,expid)
clear
% close all
hr=16; expri='MRcycle09'; member=1:5:36; expid=2;

% hr : time
% expri : experiment name

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat'
%----set---- 
vari='total Qr';   filenam=[expri,'_tqr_'];  type='member'; 
if expid==1; indir=['/SAS004/pwin/wrfout_morakot_',expri];
elseif expid==2; indir=['/SAS002/pwin/expri_241/morakot_',expri]; end
outdir=['/work/pwin/plot_cal/Qall/',expri,'/'];
%----
plon=[118.5 122.5]; plat=[21.65 25.65];
cmap=colormap_qr2;
L=[40 44 48 52 56 60 64 68 71 74 77 80 83 86 89 92];
%----
for ti=hr
%---set filename---    
   if ti==24
     s_date='09';   s_hr='00';
   else
     s_date='08';   s_hr=num2str(ti);
   end     
   for mi=member   
     nen=num2str(mi);
     if mi<=9
      if expid==1; infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
      elseif expid==2; infile=[indir,'/cycle0',nen,'/anal_d03_2009-08-',s_date,'_',s_hr,':00:00'];  end
      %elseif expid==2; infile=[indir,'/MRwork/new/wrfinput_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];  end
     else
      if expid==1; infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
      elseif expid==2; infile=[indir,'/cycle',nen,'/anal_d03_2009-08-',s_date,'_',s_hr,':00:00'];  end
      %elseif expid==2; infile=[indir,'/MRwork/new/wrfinput_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];  end
     end     
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
   %
%====
   %---plot
   L2=[min(min(TPW)),L];
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,TPW,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   m_coast('color','k');
   %m_gshhs_h('color','k');
   colorbar;   cm=colormap(cmap);   
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13); 
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z  (',type,nen,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_m',nen,'.png'];
   %print('-dpng',outfile,'-r350');  
%---    
   netcdf.close(ncid)
   end
end 
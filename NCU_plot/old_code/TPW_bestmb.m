%function TPW_en(hr,expri,member)
clear
hr=16; expri='MRcycle09';  mem=[37];

% hr : time
% expri : experiment name
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat'
%----set---- 
vari='TPW';   filenam=[expri,'_TPW-best_'];  type='member';  
indir=['/SAS002/pwin/expri_241/morakot_',expri];
outdir=['/work/pwin/plot_cal/Qall/',expri,'/'];
%----
cmap=colormap_qr2;
L=[40 44 48 52 56 60 64 68 71 74 77 80 83 86 89 92];
%plon=[111 136]; plat=[12 36];
plon=[119 123]; plat=[21.65 25.65];
%----
for ti=hr
%---set filename---    
   if ti==24
     s_date='09';   s_hr='00';
   else
     s_date='08';   s_hr=num2str(ti);
   end     
   
   %[mem]=best_member(ti,1,expri);

   mi=mem;  
     nen=num2str(mi);
        if mi<=9
          infile=[indir,'/cycle0',nen,'/anal_d03_2009-08-',s_date,'_',s_hr,':00:00'];  
        else
          infile=[indir,'/cycle',nen,'/anal_d03_2009-08-',s_date,'_',s_hr,':00:00'];  
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
   varid  =netcdf.inqVarID(ncid,'U');
    u  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');
    v =netcdf.getVar(ncid,varid);
%---
   nn=size(v,1);
   umean=(u(1:nn,:,:)+u(2:nn+1,:,:)).*0.5;
   vmean=(v(:,1:nn,:)+v(:,2:nn+1,:)).*0.5;     
%---plot set
   xi=x(1:5:196,1:5:196);   yi=y(1:5:196,1:5:196);
   uplot=umean(1:5:196,1:5:196,:);   vplot=vmean(1:5:196,1:5:196,:);
   lev=8;
   %
   
   %---plot
   L2=[min(min(TPW)),L];
   figure('position',[1800 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,TPW,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
   colorbar;   cm=colormap(cmap);   
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
   hold on
   %---vector & legend---
   hq=m_quiver(xi,yi,uplot(:,:,lev),vplot(:,:,lev),1.5,'k');
   set(hq,'LineWidth',1.5)
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z  (',type,nen,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'.png'];
   saveas(gca,outfile,'png');  
%---    
   netcdf.close(ncid)
end 
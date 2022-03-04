%function TPW_prob(hr,expri,tresh)
clear
hr=19; expri='MR15'; tresh=80; 

% hr : time
% expri : experiment name

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_PQPF.mat'
%----set---- 
vari='TPW probability';   filenam=[expri,'_TPW-P_'];  
%indir=['/SAS002/pwin/expri_241/morakot_en_',expri];
indir=['/SAS004/pwin/wrfout_morakot_',expri];
outdir=['/work/pwin/plot_cal/Qall/',expri,'/'];
%----
cmap=colormap_PQPF;
L=[35 38 42 46 50 54 58 62 66 70 74 78 82 85];
%----
for ti=hr
%---set filename---    
   if ti==24
     s_date='09';   s_hr='00';
   else
     s_date='08';   s_hr=num2str(ti);
   end     
   for mi=1:40   
     nen=num2str(mi);
     if mi<=9
       %infile=[indir,'/pert0',nen,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];
       infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
     else
       %infile=[indir,'/pert',nen,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];
       infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
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
     nz=size(qt,3); ny=size(qt,2); nx=size(qt,1);
     g=9.81;
%---  
     dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
     tpw= dP.*( (qt(:,:,2:nz)+qt(:,:,1:nz-1)).*0.5 ) ;    
     TPW{mi}=sum(tpw,3)./g;
   %---    
     netcdf.close(ncid)
   end
%---
   for tri=tresh;
     s_tresh=num2str(tri);
     number=zeros(nx,ny);   
     for i=1:nx
     for j=1:ny
      for m=1:40;
      if (TPW{m}(i,j)>=tri );
       number(i,j)=number(i,j)+1;
       end
      end
     end
     end
     number=number*100/40;
     number(number==0)=NaN;
   %---plot  
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,number,20);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
   colorbar;   cm=colormap(cmap);   caxis([0 100])   
   %hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z  (threshold : ',s_tresh,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_',s_tresh,'.png'];
   %saveas(gca,outfile,'png'); 
  end
end 

%--------------------------------------------------------------------------
% plot 2-D (ensemble mean) wind field (u, v, wind vector and W) 
%   improvement of experi1 to experi2 
%--------------------------------------------------------------------------

clear;  
hr=17:21;   expri1='vrzh364L';   expri2='vrzh364';   vari='V';   %plothgt=1000;  
lev=5;  

%
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';   cmap=colormap_br;
%----set---- 

varit=['minus ',expri2,' ',vari];   filenam=[expri1,'-',expri2,'_',vari,'_'];   
%
indir1=['/SAS002/pwin/expri_241/morakot_sing_',expri1];
indir2=['/SAS002/pwin/expri_241/morakot_sing_',expri2];
outdir=['/work/pwin/plot_cal/morakot/',expri1,'/'];

s_date='08';
dom='03';

%---
plon=[118.8 122.8]; plat=[21.5 25.65];
%plon=[118.35 121.65]; plat=[21.3 24.85];
%L=[-1 -0.7 -0.5 -0.3 -0.1 -0.05 -0.01 0.01 0.05 0.1 0.3 0.5 0.7 1];
   %L=[-1.3 -1 -0.7 -0.5 -0.3 -0.1 -0.05 0.05 0.1 0.3 0.5 0.7 1 1.3];
L=[-2.5 -2 -1.5 -1 -0.5 -0.1 0.1 0.5 1 1.5 2 2.5];
%----
for ti=hr;
   s_hr=num2str(ti);
%---set filename---=============================
   infile1=[indir1,'/wrfout_d03_2009-08-08_',s_hr,':00:00'];
   infile2=[indir2,'/wrfout_d03_2009-08-08_',s_hr,':00:00'];
%---read netcdf data and calculate the variable--------

   ncid1 = netcdf.open(infile1,'NC_NOWRITE');
   ncid2 = netcdf.open(infile2,'NC_NOWRITE');   
   
   varid  =netcdf.inqVarID(ncid1,'XLONG');    lon =netcdf.getVar(ncid1,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid1,'XLAT');     lat =netcdf.getVar(ncid1,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid1,'PH');       ph  =netcdf.getVar(ncid1,varid);
   varid  =netcdf.inqVarID(ncid1,'PHB');      phb =netcdf.getVar(ncid1,varid); 
   varid  =netcdf.inqVarID(ncid1,'HGT');      hgt.m =netcdf.getVar(ncid1,varid); 
   [nx ny]=size(lon); nz=size(ph,3)-1;
   %
   
   switch vari             
   case('U')           
     varid =netcdf.inqVarID(ncid1,vari);   u.stag =netcdf.getVar(ncid1,varid);
      u.unstag1=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   u.stag =netcdf.getVar(ncid2,varid);
      u.unstag2=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;       
           
     var.a=u.unstag1-u.unstag2;
 
   case('V')     
     varid =netcdf.inqVarID(ncid1,vari);   v.stag =netcdf.getVar(ncid1,varid);
      v.unstag1=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   v.stag =netcdf.getVar(ncid2,varid);
      v.unstag2=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;  
      
     var.a=v.unstag1-v.unstag2;  
    
   case('W') 
     L=[-0.25 -0.2 -0.15 -0.1 -0.06 -0.03 -0.01 0.01 0.03 0.06 0.1 0.15 0.2 0.25];
     varid =netcdf.inqVarID(ncid1,vari);   w.stag =netcdf.getVar(ncid1,varid);
      w.unstag1=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   w.stag =netcdf.getVar(ncid2,varid);
      w.unstag2=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5; 
      
     var.a=w.unstag1-w.unstag2;  
        
   end
   netcdf.close(ncid1); netcdf.close(ncid2)  
%    %-----------------
%    g=9.81;
%    P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
%    zg=double(PH)/g;   
%    %---interpolation to 1km-height
%    hgt.iso=zeros(size(hgt.m))+plothgt;  
%    %hgt.iso=double(hgt.m)+plothgt;  
%    for i=1:nx
%      for j=1:ny
%      X=squeeze(zg(i,j,:));
%      Y=squeeze(var.a(i,j,:));       var.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
%      end
%    end 

%------plot---=================================
   %plot.var=var.iso;   plot.var(plot.var==0)=NaN;
   plot.var=var.a(:,:,lev);  plot.var(plot.var==0)=NaN;
   pmin=double(min(min(plot.var)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [~, hp]=m_contourf(x,y,plot.var,L2);   set(hp,'linestyle','none');  hold on; 
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
   %
   %tit=[expri1,' ',varit,'  ',s_hr,'z  (',num2str(plothgt/1000),'km)'];
   tit=[expri1,'  ',varit,'  ',s_hr,'z  (lev',num2str(lev),')'];
   title(tit,'fontsize',15,'FontWeight','bold')
   %outfile=[outdir,filenam,s_hr,'_',num2str(plothgt/1000),'km.png'];
   outfile=[outdir,filenam,s_hr,'_lev',num2str(lev),'km.png'];
   print('-dpng',outfile,'-r400')       
end


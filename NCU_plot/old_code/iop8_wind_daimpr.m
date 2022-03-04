function iop8_wind_daimpr(hm,expri1,expri2,vari,plothgt,typeid)
%function iop8_wind_daimpr(hm,expri1,expri2,vari,lev,typeid)

%--------------------------------------------------------------------------
% plot 2-D (ensemble mean) wind field (u, v, wind vector and W) 
%   improvement of experi1 to experi2 
%--------------------------------------------------------------------------

%clear;  
%hm='00:00';   expri1='vr364';   expri2='vr124';   vari='U';   %plothgt=5000;  
%lev=11;  
%typeid='a';

%
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br3.mat';   cmap=colormap_br3;
%----set---- 
if typeid=='a'; type='anal'; elseif typeid=='b'; type='fcst'; end
varit=[vari,' ',type,' improv. to ',expri2];   filenam=[expri1,'_',vari,'-err',typeid,'impr2',expri2,'_'];   
%
indir1=['/SAS007/pwin/expri_sz6414/',expri1];
indir2=['/SAS007/pwin/expri_sz6414/',expri2];
outdir=['/work/pwin/plot_cal/IOP8/',expri1,'/'];
s_date='16';
dom='03';
num=size(hm,1);
dx=3000; dy=3000;
%---
%plon=[118.8 122.8]; plat=[21.5 25.65];
plon=[118.35 121.65]; plat=[21.3 24.85];
%L=[-1 -0.7 -0.5 -0.3 -0.1 -0.05 -0.01 0.01 0.05 0.1 0.3 0.5 0.7 1];
   %L=[-1.3 -1 -0.7 -0.5 -0.3 -0.1 -0.05 0.05 0.1 0.3 0.5 0.7 1 1.3];
L=[-3 -2 -1.5 -1 -0.6 -0.3 -0.1 0.1 0.3 0.6 1 1.5 2 3];
%----
for ti=1:num;
   time=hm(ti,:);
%---set filename---=============================
   infile =['/SAS007/pwin/expri_sz6414/true/wrfout_d',dom,'_2008-06-',s_date,'_',time,':00'];  
   infile1=[indir1,'/output/',type,'mean_d',dom,'_2008-06-',s_date,'_',time,':00'];
   infile2=[indir2,'/output/',type,'mean_d',dom,'_2008-06-',s_date,'_',time,':00'];
%---read netcdf data and calculate the variable--------
   ncid  = netcdf.open(infile ,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt.m =netcdf.getVar(ncid,varid); 
   varid =netcdf.inqVarID(ncid,'U');   ustag =netcdf.getVar(ncid,varid);
   varid =netcdf.inqVarID(ncid,'V');   vstag =netcdf.getVar(ncid,varid);
   varid =netcdf.inqVarID(ncid,'W');   wstag =netcdf.getVar(ncid,varid);
   [nx ny]=size(lon); nz=size(ph,3)-1;
   %
   ncid1 = netcdf.open(infile1,'NC_NOWRITE');
   ncid2 = netcdf.open(infile2,'NC_NOWRITE');   
   
   %wunstag=(wstag(:,:,1:nz)+wstag(:,:,2:nz+1)).*0.5;
   %div= ( ustag(2:nx+1,:,:)-ustag(1:nx,:,:) )./dx +  ( vstag(:,2:ny+1,:)-vstag(:,1:ny,:) )./dy ;
   %div=div*10^3;
   %
   %hgtgrd=zeros(nx,ny);
   %hgtgrd(2:nx-1,2:ny-1)=(  (  ( hgt.m(3:nx,2:ny-1)-hgt.m(1:nx-2,2:ny-1) )./(dx*2)  ).^2 + ...
   %                         (  ( hgt.m(2:nx-1,3:ny)-hgt.m(2:nx-1,1:ny-2) )./(dy*2)  ).^2  ).^0.5;
  
   
   switch vari             
   case('U')           
     %varid =netcdf.inqVarID(ncid,vari);    u.stag =netcdf.getVar(ncid,varid);
      u.tunstag=(ustag(1:nx,:,:)+ustag(2:nx+1,:,:)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   u.stag =netcdf.getVar(ncid1,varid);
      u.unstag1=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   u.stag =netcdf.getVar(ncid2,varid);
      u.unstag2=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;       
           
     var.a=abs(u.tunstag-u.unstag1)-abs(u.tunstag-u.unstag2);   
 
   case('V')     
     %varid =netcdf.inqVarID(ncid,vari);    v.stag =netcdf.getVar(ncid,varid);
      v.tunstag=(vstag(:,1:ny,:)+vstag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   v.stag =netcdf.getVar(ncid1,varid);
      v.unstag1=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   v.stag =netcdf.getVar(ncid2,varid);
      v.unstag2=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;  
      
     var.a=abs(v.tunstag-v.unstag1)-abs(v.tunstag-v.unstag2);   
    
   case('W') 
     L=[-0.25 -0.2 -0.15 -0.1 -0.06 -0.03 -0.01 0.01 0.03 0.06 0.1 0.15 0.2 0.25];
     %varid =netcdf.inqVarID(ncid,vari);    w.stag =netcdf.getVar(ncid,varid);
      w.tunstag=(wstag(:,:,1:nz)+wstag(:,:,2:nz+1)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   w.stag =netcdf.getVar(ncid1,varid);
      w.unstag1=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   w.stag =netcdf.getVar(ncid2,varid);
      w.unstag2=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5; 
      
     var.a=abs(w.tunstag-w.unstag1)-abs(w.tunstag-w.unstag2);  
        
   end
   netcdf.close(ncid); netcdf.close(ncid1); netcdf.close(ncid2)  
   %-----------------
   g=9.81;
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH)/g;   
   %---interpolation to 1km-height
   hgt.iso=zeros(size(hgt.m))+plothgt;  
   %hgt.iso=double(hgt.m)+plothgt;  
   for i=1:nx
     for j=1:ny
     X=squeeze(zg(i,j,:));
     Y=squeeze(var.a(i,j,:));       var.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
     %Yw=squeeze(wunstag(i,j,:));    wiso(i,j)=interp1(X,Yw,hgt.iso(i,j),'linear');
     %Yd=squeeze(div(i,j,:));        diviso(i,j)=interp1(X,Yd,hgt.iso(i,j),'linear');
     end
   end 
%------plot---=================================
   plot.var=var.iso;   plot.var(plot.var==0)=NaN;
   %plot.var=var.a(:,:,lev);  plot.var(plot.var==0)=NaN;
   pmin=double(min(min(plot.var)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [~, hp]=m_contourf(x,y,plot.var,L2);   set(hp,'linestyle','none');  hold on; 
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
   %
   %m_contour(x,y,wiso,[0.5 2.5],'-k','LineWidth',1.2); 
   %m_contour(x,y,wiso,[-0.5 -2.5],'--k','LineWidth',1.2); 
   %m_contour(x,y,wunstag(:,:,lev),[0.5 1],'LineWidth',2,'color',[0.2 0.3 0.2]); 
   %m_contour(x,y,wunstag(:,:,lev),[-0.5 -1],'LineStyle','--','LineWidth',2,'color',[0.2 0.3 0.2]); 
   %
   %m_contour(x,y,diviso,[0.5 2],'-k','LineWidth',1); 
   %m_contour(x,y,diviso,[-0.5 -2],'--k','LineWidth',1); 
   %
   m_contour(x,y,hgt.m,[plothgt plothgt],'k--')
   %m_contour(x,y,hgt.m,[100 500 1000 2000],'color',[0.6 0.6 0.6],'LineWidth',2)
   %m_contour(x,y,hgtgrd,[0.01 0.1 0.2],'color',[0.6 0.6 0.6],'LineWidth',2); 
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
   %
   tit=[expri1,'  ',varit,'  ',time(1:2),time(4:5),'z  (',num2str(plothgt/1000),'km)'];
   %tit=[expri1,'  ',varit,'  ',time(1:2),time(4:5),'z  (lev',num2str(lev),')'];
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(plothgt/1000),'km.png'];
   %outfile=[outdir,filenam,time(1:2),time(4:5),'_lev',num2str(lev),'km.png'];
   print('-dpng',outfile,'-r400')       
end
function morakot_wind_da(hm,expri,vari,plotid,plothgt)

%--------------------------------------------------------------------------
% plot 2-D (ensemble mean) wind field (u, v, wind vector and W) 
%   (1)background error, (2)increment, (3)analysis error and (4)improvement of DA cycle
%--------------------------------------------------------------------------

%clear;  
%hm='15:00';  expri='vr124';   vari='V';   plothgt=3000;  %lev=4;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%----set---- 
  
varit=[vari,' incre.'];          filenam=[expri,'_',vari,'-incr_'];  
%
indir=['/SAS002/pwin/expri_241/morakot_',expri];
outdir=['/work/pwin/plot_cal/morakot/',expri,'/'];
s_date='08';
dom='03';
%type='mean';
%---
plon=[118.8 122.8]; plat=[21.5 25.65];
%plon=[118.35 121.65]; plat=[21.3 24.85];
num=size(hm,1);
%L=[-3 -2.5 -2 -1.5 -1 -0.5 0.5 1 1.5 2 2.5 3];
%L=[-0.9 -0.7 -0.5 -0.3 -0.1 -0.05 0.05 0.1 0.3 0.5 0.7 0.9]*10;
L=[-10 -7 -5 -3 -2 -1  1 2 3 5 7 10];  
%----
for ti=1:num;
   time=hm(ti,:);
%---set filename---============================= 
   infile1=[indir,'/output/fcstmean_d',dom,'_2009-08-',s_date,'_',time,':00'];
   infile2=[indir,'/output/analmean_d',dom,'_2009-08-',s_date,'_',time,':00'];
%---read netcdf data and calculate the variable--------
   ncid  = netcdf.open(infile1 ,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt.m =netcdf.getVar(ncid,varid); 
   [nx ny]=size(lon); nz=size(ph,3)-1;
   %
   ncid1 = netcdf.open(infile1,'NC_NOWRITE');
   ncid2 = netcdf.open(infile2,'NC_NOWRITE');   
       
   switch vari
   case('wind')
     varid  =netcdf.inqVarID(ncid,'U');       u.stag =netcdf.getVar(ncid,varid);
     varid  =netcdf.inqVarID(ncid,'V');       v.stag =netcdf.getVar(ncid,varid);
     u.tunstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     v.tunstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
       
     varid  =netcdf.inqVarID(ncid1,'U');       u.stag =netcdf.getVar(ncid1,varid);
     varid  =netcdf.inqVarID(ncid1,'V');       v.stag =netcdf.getVar(ncid1,varid);
     u.funstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     v.funstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;  

     varid  =netcdf.inqVarID(ncid2,'U');       u.stag =netcdf.getVar(ncid2,varid);
     varid  =netcdf.inqVarID(ncid2,'V');       v.stag =netcdf.getVar(ncid2,varid);
     u.aunstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     v.aunstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;  
        

     u.var=u.aunstag-u.funstag;      v.var=v.aunstag-v.funstag;               
      
        
   case('U')           
     varid =netcdf.inqVarID(ncid,vari);    u.stag =netcdf.getVar(ncid,varid);
      u.tunstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   u.stag =netcdf.getVar(ncid1,varid);
      u.funstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   u.stag =netcdf.getVar(ncid2,varid);
      u.aunstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;       
  
     var.a=u.aunstag-u.funstag;            
  
   case('V')     
     varid =netcdf.inqVarID(ncid,vari);    v.stag =netcdf.getVar(ncid,varid);
      v.tunstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   v.stag =netcdf.getVar(ncid1,varid);
      v.funstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   v.stag =netcdf.getVar(ncid2,varid);
      v.aunstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;       
 
     var.a=v.aunstag-v.funstag;         
                  
   case('W') 
     L=[-1.5 -1 -0.7 -0.4 -0.2 -0.1  0.1 0.2 0.4 0.7 1 1.5];
     varid =netcdf.inqVarID(ncid,vari);    w.stag =netcdf.getVar(ncid,varid);
      w.tunstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   w.stag =netcdf.getVar(ncid1,varid);
      w.funstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   w.stag =netcdf.getVar(ncid2,varid);
      w.aunstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;       
     
      var.a=w.aunstag-w.funstag;  L=L.*0.1;          
        
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
     if strcmp(vari,'wind')==1;
     Y=squeeze(u.var(i,j,:));     u.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');    
     Y=squeeze(v.var(i,j,:));     v.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');   
     else
     Y=squeeze(var.a(i,j,:));     var.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
     end
     end
   end
%------plot---=================================

   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on')
   if strcmp(vari,'wind')==1;     
     int=6;
     xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
     u.plot=u.iso(1:int:nx,1:int:ny,:);   v.plot=v.iso(1:int:nx,1:int:ny,:);        
     if plotid==2; qscale = 0.035; else qscale=0.025; end % scaling factor for all vectors
     h1 = m_quiver(xi,yi,u.plot(:,:),v.plot(:,:),0,'k') ; % the '0' turns off auto-scaling
     hU = get(h1,'UData') ;
     hV = get(h1,'VData') ;
     set(h1,'UData',qscale*hU,'VData',qscale*hV)
     set(h1,'LineWidth',1.5)   
   else   
     plot.var=var.iso;   plot.var(plot.var==0)=NaN;
     %plot.var=var.a(:,:,lev);  plot.var(plot.var==0)=NaN;
     pmin=double(min(min(plot.var)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
     [c hp]=m_contourf(x,y,plot.var,L2);   set(hp,'linestyle','none'); 
     cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
     hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
   end
   hold on
   m_contour(x,y,hgt.m,[plothgt plothgt],'k--')
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
   %
   tit=[expri,'  ',varit,'  ',time(1:2),time(4:5),'z  (',num2str(plothgt/1000),'km)'];
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(plothgt/1000),'km.png'];
   print('-dpng',outfile,'-r400')       
end
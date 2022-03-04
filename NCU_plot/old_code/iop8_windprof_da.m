%function iop8_windprof_da(hm,expri,vari,plotid,plothgt)

%--------------------------------------------------------------------------
% plot *profile* of (ensemble mean) wind field (u, v, w) 
%   (1)background error, (2)increment, (3)analysis error and (4)improvement of DA cycle
%   **for profid=(1):W-E profile, (2):S-N profile.
%--------------------------------------------------------------------------

clear;  
hm='00:00'; expri='vr124';   vari='U';   plotid=4;  profid=1; 

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';   cmap=colormap_br;  
%----set---- 
if plotid==1;      varit=[vari,' background error'];   filenam=[expri,'_',vari,'-errb_'];  
elseif plotid==2;  varit=[vari,' incre.'];             filenam=[expri,'_',vari,'-incr_'];  
elseif plotid==3;  varit=[vari,' analysis error'];     filenam=[expri,'_',vari,'-erra_'];  
elseif plotid==4;  varit=[vari,' improv.'];            filenam=[expri,'_',vari,'-impr_'];  
end
%
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
s_date='16';
dom='03';
type='mean';
%---
proflat=22.5;   
proflon=120.5;
num=size(hm,1);
%L=[-3 -2.5 -2 -1.5 -1 -0.5 0.5 1 1.5 2 2.5 3];
L=[-0.9 -0.7 -0.5 -0.3 -0.1 -0.03 0.03 0.1 0.3 0.5 0.7 0.9]*10;
%----
%for proflat=22:0.1:23.2
for ti=1:num;
   time=hm(ti,:);
%---set filename---=============================
   infile =['/SAS007/pwin/expri_sz6414/true/wrfout_d',dom,'_2008-06-',s_date,'_',time,':00'];  
   infile1=[indir,'/output/fcstmean_d',dom,'_2008-06-',s_date,'_',time,':00'];
   infile2=[indir,'/output/analmean_d',dom,'_2008-06-',s_date,'_',time,':00'];
%---read netcdf data and calculate the variable--------
   ncid  = netcdf.open(infile ,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x.m=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y.m=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt.m =netcdf.getVar(ncid,varid); 
   [nx ny]=size(lon); nz=size(ph,3)-1;
   %
   ncid1 = netcdf.open(infile1,'NC_NOWRITE');
   ncid2 = netcdf.open(infile2,'NC_NOWRITE');   
       
   switch vari  
   case('U')           
     varid =netcdf.inqVarID(ncid,vari);    u.stag =netcdf.getVar(ncid,varid);
      u.tunstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   u.stag =netcdf.getVar(ncid1,varid);
      u.funstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   u.stag =netcdf.getVar(ncid2,varid);
      u.aunstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;       
     if plotid==1;        var.a=u.tunstag-u.funstag;   
     elseif plotid==2;    var.a=u.aunstag-u.funstag;   L=[-5 -4 -3 -2 -1 -0.5 0.5 1 2 3 4 5];            
     elseif plotid==3;    var.a=u.tunstag-u.aunstag;           
     elseif plotid==4;            
     var.a=abs(u.tunstag-u.aunstag)-abs(u.tunstag-u.funstag);   
     load '/work/pwin/data/colormap_br3.mat';   cmap=colormap_br3;
     L=[-5 -4 -3 -2 -1 -0.5 -0.1 0.1 0.5 1 2 3 4 5];
     end    
   case('V')     
     varid =netcdf.inqVarID(ncid,vari);    v.stag =netcdf.getVar(ncid,varid);
      v.tunstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   v.stag =netcdf.getVar(ncid1,varid);
      v.funstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   v.stag =netcdf.getVar(ncid2,varid);
      v.aunstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;       
     if plotid==1;        var.a=v.tunstag-v.funstag;   
     elseif plotid==2;    var.a=v.aunstag-v.funstag;  L=[-5 -4 -3 -2 -1 -0.5 0.5 1 2 3 4 5];          
     elseif plotid==3;    var.a=v.tunstag-v.aunstag;           
     elseif plotid==4;            
     var.a=abs(v.tunstag-v.aunstag)-abs(v.tunstag-v.funstag);  
     load '/work/pwin/data/colormap_br3.mat';   cmap=colormap_br3;
     L=[-5 -4 -3 -2 -1 -0.5 -0.1 0.1 0.5 1 2 3 4 5];     
     end         
   case('W') 
     L=[-1 -0.7 -0.5 -0.3 -0.1 -0.05 0.05 0.1 0.3 0.5 0.7 1];
     varid =netcdf.inqVarID(ncid,vari);    w.stag =netcdf.getVar(ncid,varid);
      w.tunstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   w.stag =netcdf.getVar(ncid1,varid);
      w.funstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   w.stag =netcdf.getVar(ncid2,varid);
      w.aunstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;       
     if plotid==1;        var.a=w.tunstag-w.funstag;   
     elseif plotid==2;    var.a=w.aunstag-w.funstag;  L=[-5 -4 -3 -2 -1 -0.5 0.5 1 2 3 4 5].*0.1;          
     elseif plotid==3;    var.a=w.tunstag-w.aunstag;           
     elseif plotid==4;            
     var.a=abs(w.tunstag-w.aunstag)-abs(w.tunstag-w.funstag);  
     load '/work/pwin/data/colormap_br3.mat';   cmap=colormap_br3;
     L=[-5 -4 -3 -2 -1 -0.5 -0.1 0.1 0.5 1 2 3 4 5].*0.1;
     end  
   end
   netcdf.close(ncid); netcdf.close(ncid1); netcdf.close(ncid2)  
   %---calculate high--------------
   g=9.81;
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg.m=double(PH)/g;      
   %---difine xp, yp for profile---
   dis= ( (y.m-proflat).^2 + (x.m-proflon).^2 );
   [mid mxI]=min(dis);    [dmin yp]=min(mid);    xp=mxI(yp);         
   %---interpolation to profile
   zg.i=[10,50,100:100:10000]';
   if profid==1;
     for i=1:nx
      X=squeeze(zg.m(i,yp,:));   Y=squeeze(var.a(i,yp,:));
      var.prof(:,i)=interp1(X,Y,zg.i,'linear');
     end
     x.axis=x.m(:,yp);  x.limt=[119 122];  hgt.prof=hgt.m(:,yp);
     proflabel=['(',num2str(mean(y.m(:,yp))),'°N)']; x.title='longitude';
     profline=proflat;
   elseif profid==2
     for j=1:ny
      X=squeeze(zg.m(xp,j,:));   Y=squeeze(var.a(xp,j,:));
      var.prof(:,j)=interp1(X,Y,zg.i,'linear');
     end
     x.axis=y.m(xp,:);  x.limt=[21.5 24.5];  hgt.prof=hgt.m(xp,:);
     proflabel=['(',num2str(mean(x.m(xp,:))),'°E)'];   x.title='latitude';
     profline=proflon;
   end
%------plot---=================================
   [xi zi]=meshgrid(x.axis,zg.i);      
   var.plot=var.prof;   var.plot(var.plot==0)=NaN;
   pmin=double(min(min(var.plot)));   if pmin<L(1); L2=[pmin,L]; else  L2=[L(1) L]; end
   %
   figure('position',[200 100 700 500]) 
   [c hp]=contourf(xi,zi,var.plot,L2);   set(hp,'linestyle','none');  
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
   hold on; 
   plot(x.axis,hgt.prof,'k','LineWidth',1.5);
   set(gca,'XLim',x.limt,'fontsize',13,'LineWidth',1);   xlabel(x.title); ylabel('height(m)')
   %
   tit=[expri,'  ',varit,'  ',time(1:2),time(4:5),'z  ',proflabel];
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,filenam,time(1:2),time(4:5),'_prof',num2str(profline),'.png'];
   print('-dpng',outfile,'-r400')     
end
%end

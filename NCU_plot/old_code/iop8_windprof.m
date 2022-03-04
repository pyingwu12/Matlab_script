%function iop8_windprof(hm,expri,vari,plotid,plothgt)

%--------------------------------------------------------------------------
% plot *profile* of (ensemble mean) wind field (u, v, w) 
%   (1)background error, (2)increment, (3)analysis error and (4)improvement of DA cycle
%   **for profid=(1):W-E profile, (2):S-N profile.
%--------------------------------------------------------------------------

clear;  
hm='02:00'; expri='vr368L';   vari='W';   profid=1; 

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_wind2.mat';   cmap=colormap_wind2;
% colormap_wind2=[0.117647058823529,0.0784313725490196,0.862745098039216;
%     0.196078431372549,0.313725490196078,0.901960784313726;
%     60/256,151/256,241/256;
%     95/256,195/256,244/256;
%     92/256,200/256,180/256;
%     90/256,200/256,120/256;
%     146/256,208/256,80/256;
%     0.755882352941177,0.901960784313726,0.353529411764706;
%     0.941176470588235,0.901960784313726,0.196078431372549;
%     0.980392156862745,0.776470588235294,0.160784313725490;
%     1,0.509803921568627,0.0196078431372549;
%     0.996078431372549,0.258823529411765,0.0431372549019608;
%     0.901960784313726,0.156862745098039,0.0588235294117647;
%     0.823529411764706,0.0392156862745098,0.0392156862745098;];



%----set---- 
varit=[vari,' field'];   filenam=[expri,'_',vari,'_'];  
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
s_date='16';
dom='03';
type='mean';
%---
proflat=22.5;   
proflon=120.3;
num=size(hm,1);
%L=[-3 -2.5 -2 -1.5 -1 -0.5 0.5 1 1.5 2 2.5 3];
L=[-1.6 -1.2 -0.8 -0.5 -0.2 -0.1 0 0.1 0.2 0.5 0.8 1.2 1.6]*10;
%----
%for proflat=23.7
for ti=1:num;
   time=hm(ti,:);
%---set filename---=============================
   %infile =[indir,'/wrfout_d',dom,'_2008-06-',s_date,'_',time,':00'];  
   infile =[indir,'/output/analmean_d',dom,'_2008-06-',s_date,'_',time,':00'];  
%---read netcdf data and calculate the variable--------
   ncid  = netcdf.open(infile ,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x.m=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y.m=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt.m =netcdf.getVar(ncid,varid); 
   [nx ny]=size(lon); nz=size(ph,3)-1;
   switch vari  
   case('U')           
     varid =netcdf.inqVarID(ncid,vari);    u.stag =netcdf.getVar(ncid,varid);
     u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;  
     var.a=u.unstag;
   case('V')     
     varid =netcdf.inqVarID(ncid,vari);    v.stag =netcdf.getVar(ncid,varid);
     v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;    
     var.a=v.unstag;  
   case('W') 
     L=L*0.1;
     varid =netcdf.inqVarID(ncid,vari);    w.stag =netcdf.getVar(ncid,varid);
     w.unstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5;              
     var.a=w.unstag;  
   end
   netcdf.close(ncid); 
   %---calculate high--------------
   g=9.81;
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg.m=double(PH)/g;      
   %---difine xp, yp for profile---
   dis= ( (y.m-proflat).^2 + (x.m-proflon).^2 );
   [mid mxI]=min(dis);    [dmin yp]=min(mid);    xp=mxI(yp);         
   %---interpolation to profile
   zg.i=[10,50,100:100:6000]';
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

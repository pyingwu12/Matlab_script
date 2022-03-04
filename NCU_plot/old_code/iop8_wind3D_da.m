%function iop8_qx_da(hm,expri,vari,plotid,plothgt)

%--------------------------------------------------------------------------
% plot *profile* of (ensemble mean) wind field (u, v) 
%   (1)background error, (2)increment, (3)analysis error and (4)improvement of DA cycle
%   **for profid=(1):W-E profile, (2):S-N profile.
%--------------------------------------------------------------------------

clear;  
hm='00:00'; expri='vr368';   vari='U';   plotid=2;  profid=2; 

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';   cmap=colormap_br;  
%----set---- 
varit=[vari,' improv.'];   filenam=[expri,'_',vari,'-impr_'];  

%
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
s_date='16';
dom='03';
type='mean';
%---
proflat=22.5;   
proflon=120.9;
num=size(hm,1);
L=[-5 -4 -3 -2 -1 -0.5 -0.1 0.1 0.5 1 2 3 4 5];

%----
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
          
     var.a=abs(u.tunstag-u.aunstag)-abs(u.tunstag-u.funstag);   
     load '/work/pwin/data/colormap_br3.mat';   cmap=colormap_br3;

   case('V')     
     varid =netcdf.inqVarID(ncid,vari);    v.stag =netcdf.getVar(ncid,varid);
      v.tunstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid1,vari);   v.stag =netcdf.getVar(ncid1,varid);
      v.funstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     varid =netcdf.inqVarID(ncid2,vari);   v.stag =netcdf.getVar(ncid2,varid);
      v.aunstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;       
     
     var.a=abs(v.tunstag-v.aunstag)-abs(v.tunstag-v.funstag);  
     load '/work/pwin/data/colormap_br3.mat';   cmap=colormap_br3;
     
     
   end
   netcdf.close(ncid); netcdf.close(ncid1); netcdf.close(ncid2)  
   %---calculate high--------------
   g=9.81;
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg.m=double(PH)/g;      
   %------
   
   x.thin=x.m(1:10:nx,1:10:ny);
   y.thin=y.m(1:10:nx,1:10:ny);
   zg.thin=zg.m(1:10:nx,1:10:ny,:);
   var.thin=var.a(1:10:nx,1:10:ny,:);
   nxthin=round(nx/10); nythin=round(ny/10);
   
   
   for i=1:nz x3(:,:,i)=x.thin; y3(:,:,i)=y.thin;  end
   
   clen=length(cmap);
   Msize=10; 
   
   x.long=reshape(x3,nxthin*nythin*nz,1);
   y.long=reshape(y3,nxthin*nythin*nz,1);
   
   var.long=reshape(var.thin,nxthin*nythin*nz,1);  var.long(var.long==0 )=NaN;
   var.long(var.long>-0.5 & var.long<0.5)=NaN;
   zg.long=reshape(zg.thin,nxthin*nythin*nz,1);
   
  
   M=length(var.long);
   figure('position',[600 100 600 500])
   
  for i=1:M;      
  if  isnan(var.long(i))~=1
    for k=1:clen-2;
      if (var.long(i) > L(k) && var.long(i)<=L(k+1) )
        c=cmap(k+1,:);
        hp=plot3(x.long(i),y.long(i),zg.long(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
        set(hp,'linestyle','none');    
      end      
    end
    if var.long(i)>L(clen-1)
       c=cmap(clen,:);
       hp=plot3(x.long(i),y.long(i),zg.long(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
       set(hp,'linestyle','none');   
    end
    if var.long(i)<L(1)
       c=cmap(1,:);
       hp=plot3(x.long(i),y.long(i),zg.long(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
       set(hp,'linestyle','none');   
    end   
  end
  end
  hgt.m(hgt.m<=0.1)=NaN;
  plot3(x.m,y.m,hgt.m,'k')
  %m_grid('fontsize',12);
  %m_gshhs_h('color','k');
  %m_coast('color','k');
  colorbar;  cm=colormap(cmap);  
  %caxis([L(1) L(length(L))]);  
  %hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13)

% %------plot---=================================
%    [xi zi]=meshgrid(x.axis,zg.i);      
%    var.plot=var.prof;   var.plot(var.plot==0)=NaN;
%    pmin=double(min(min(var.plot)));   if pmin<L(1); L2=[pmin,L]; else  L2=[L(1) L]; end
%    %
%    figure('position',[200 100 700 500]) 
%    [c hp]=contourf(xi,zi,var.plot,L2);   set(hp,'linestyle','none');  
%    cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
%    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
%    hold on; 
%    plot(x.axis,hgt.prof,'k','LineWidth',1.5);
%    set(gca,'XLim',x.limt,'fontsize',13,'LineWidth',1);   xlabel(x.title); ylabel('height(m)')
%    %
%    tit=[expri,'  ',varit,'  ',time(1:2),time(4:5),'z  ',proflabel];
%    title(tit,'fontsize',15,'FontWeight','bold')
%    outfile=[outdir,filenam,time(1:2),time(4:5),'_prof',num2str(profline),'.png'];
%    print('-dpng',outfile,'-r400')     
end
%end

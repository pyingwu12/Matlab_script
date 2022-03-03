%-------------------------------------------------------
% plot profile of qr+qg+qc+qi+qs and horizontal wind with wind feathers
%     and W with contour
%-------------------------------------------------------
clear

hr=4;   minu='00';   expri='e02';  

%---decide the profile line---
lonA=120; latA=21.9; % start point  
len=1.5; %length of the line (degree)
slopx=0; %integer and >= 0
slopy=1; %integer and >= 0

%---DA or forecast time---
infilenam='wrfout';    type='sing';
%infilenam='output/analmean';  type=infilenam(8:11);  %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];   outdir=['/SAS011/pwin/201work/plot_cal/IOP8_shao/',expri];    % path of the experiments
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
L=[0.1 0.5 1 2 3 4 5 6 7 8];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr3.mat';  cmap=colormap_qr3; 
% cmap=cmap-0.02;
% cmap(cmap<0)=0; cmap(1,:)=[1 1 1];
%---
varinam='Q all';    filenam=[expri,'_qall-prof_'];  
zgi=[10,50,100:100:12000]';    ytick=1000:1000:zgi(end); 
%zgi=[10,50,100:100:16000]';    ytick=1000:2000:zgi(end); 
g=9.81;
  
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'QCLOUD');  qc  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'QICE');    qi  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'QSNOW');   qs  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'QGRAUP');  qg  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');       ph   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid);      
   netcdf.close(ncid)   
   %
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;     zg=double(PH)/g; 
   %
   qall=(qr+qc+qi+qs+qg)*1000;
%---difine xp, yp for profile---
   dis= ( (y-latA).^2 + (x-lonA).^2 );
   [mid mxI]=min(dis);    [dmin py]=min(mid);    px=mxI(py);    
   %---interpoltion---    
   i=0;  lonB=x(px,py); latB=y(px,py);
   while len>abs(x(px,py)-lonB) && len>abs(y(px,py)-latB)
     i=i+1;
     indx=px+slopx*(i-1);    indy=py+slopy*(i-1);
     linex(i)=x(indx,indy);  lonB=linex(i);     
     liney(i)=y(indx,indy);  latB=liney(i);      
     X=squeeze(zg(indx,indy,:));   Y=squeeze(qall(indx,indy,:));   varprof(:,i)=interp1(X,Y,zgi,'linear');
     hgtprof(i)=hgt(indx,indy);
   end  
%---plot setting---   
   if slopx>=slopy;    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;  
   else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;   
   end
   pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
   pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
   if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
   
%--plot----
   plotvar=varprof;   %plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %   
   figure('position',[400 100 750 500]) 
   [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none');  hold on;
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   title(hc,'(g/Kg)')
   %------------
   plot(xaxis,hgtprof,'k','LineWidth',1.5);  %terrain
   text(xaxis(1)+0.1,zgi(end)-zgi(end)/20,[pointA,' ',pointB,' slope=',slope])
   %
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(px),num2str(py),'s',slope];
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);      

end  %ti

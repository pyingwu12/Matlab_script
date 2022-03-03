%--------------------------------------------------
% Potential temperature increment (anal-fcst) profile 
%--------------------------------------------------

clear

hr=0;   minu='00';    expri='e04';  tit='L3612';

%lonA=119.1; latA=22.7;  len=0.7; %length of the line (degree)
%slopx=1; %integer and >= 0
%slopy=0; %integer and >= 0

lonA=119.4; latA=22.25;   len=1.5;   %length of the line (degree)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%fid=fopen('/SAS004/pwin/data/obs_sz6414_point/obs_d03_2008-06-16_00:00:00');
%A=textscan(fid,'%f%f%f%f%f%f%f%f%f');
%obs_h=A{7}; obs_lon=A{5};

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens']; 
%obsdir='/SAS004/pwin/data/obs_sz6414'; indir2=['/work/pwin/data/largens_wrf2obs_',expri];  
L=[-1 -0.8 -0.6 -0.4 -0.2 -0.1 0.1 0.2 0.4 0.6 0.8 1];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam='theta increment';   filenam=[expri,'_Th-incr_prof_'];
zgi=[10,50,100:100:20000];    ytick=1000:2000:zgi(end);
g=9.81;  

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile1=[indir,'/output/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,'/output/analmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   x =double(netcdf.getVar(ncid,varid)); 
   varid  =netcdf.inqVarID(ncid,'XLAT');    y =double(netcdf.getVar(ncid,varid));    
   varid  =netcdf.inqVarID(ncid,'T');       t1  =(netcdf.getVar(ncid,varid))+300;
   varid  =netcdf.inqVarID(ncid,'PH');      ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');     phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;
   zg1=double(PH)/g; 
   netcdf.close(ncid)
  %---integrate TPW---
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'T');      t2  =(netcdf.getVar(ncid,varid))+300;
   varid  =netcdf.inqVarID(ncid,'PH');      ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');     phb =netcdf.getVar(ncid,varid); 
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;
   zg2=double(PH)/g; 
   netcdf.close(ncid)    
%---difine xp, yp for profile---
   dis= ( (y-latA).^2 + (x-lonA).^2 );
   [mid mxI]=min(dis);    [dmin py]=min(mid);    px=mxI(py);    
%---interpoltion---    
   i=0;  lonB=0; latB=0;
   while lonB<=x(px,py)+len && latB<=y(px,py)+len
     i=i+1;
     indx=px+slopx*(i-1);    indy=py+slopy*(i-1);
     linex(i)=x(indx,indy);  lonB=linex(i);     
     liney(i)=y(indx,indy);  latB=liney(i);       
     X=squeeze(zg1(indx,indy,:));   Y=squeeze(t1(indx,indy,:));   varprof1(:,i)=interp1(X,Y,zgi,'linear');
     X=squeeze(zg2(indx,indy,:));   Y=squeeze(t2(indx,indy,:));   varprof2(:,i)=interp1(X,Y,zgi,'linear');
     hgtprof(i)=hgt(indx,indy);
   end  
   
   incr=varprof2-varprof1;  
%   incr(incr<0.001 & incr>-0.001)=NaN; 

%---plot setting---   
   if slopx>=slopy;    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;
   else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;
   end
   if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
%--plot--    
   plotvar=incr;   %plotvar(plotvar+1==1)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[200 100 750 500]) 
   %figure('position',[200 100 350 500]) 
   [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none');  
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   title(hc,'(K)')
   hold on;       
   plot(xaxis,hgtprof,'k','LineWidth',1.5);
%   pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
%   pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
%   text(xaxis(1)+0.1,zgi(end)-zgi(end)/20,[pointA,' ',pointB,' slope=',slope]); 
   %---
%    plot(obs_lon,obs_h,'xk','markersize',12,'LineWidth',2)
   %---
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %
   %tit=[expri,'  ',varinam,'  ',s_hr,minu,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(px),num2str(py),'s',num2str(slope)];
%    print('-dpng',outfile,'-r400')       
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 200 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]); 
end    


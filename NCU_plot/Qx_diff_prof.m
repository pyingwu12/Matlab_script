%-------------------------------------------------------
% Profile of difference(exp1-exp2) of qv between expri1 to expri2  (DA cycle & forecasting time)
%-------------------------------------------------------

clear

hr=2;  minu='00';  
expri1='e04';  expri2='e01';  vari='QVAPOR';   figtit1='L3612'; figtit2='L3604';

lonA=119.4; latA=22.25;  len=1.5;   %length of the line (degree)
%paper: (119.4, 22.25); len=1.5
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%---DA or forecast time---
infilenam='wrfout';        type='sing';
%infilenam='output/analmean';    type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';
indir='/SAS009/pwin/expri_largens/'; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
%L=[-7 -5 -3 -2 -1 -0.5 0.5 1 2 3 5 7 ]*0.1;
L=[-1 -0.8 -0.6 -0.4 -0.2 -0.1 0.1 0.2 0.4 0.6 0.8 1];
%L=[-1.1 -0.9 -0.7 -0.5 -0.3 -0.1  0.1 0.3 0.5 0.7 0.9 1.1];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
%load '/work/pwin/data/colormap_br5.mat';  cmap=colormap_br5; 
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3(2:14,:); 
%------
s_vari=lower(vari(1:2));
varinam=[s_vari,' diff.'];  filenam=[expri1,'-diff-',expri2,'_',s_vari,'_prof_'];
zgi=[10,50,100:100:11000]';    ytick=1000:1000:zgi(end); 
g=9.81;

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');    % start time string
%---set filename---
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,vari);       q1  =(netcdf.getVar(ncid,varid))*1e3;
   varid  =netcdf.inqVarID(ncid,'PH');       ph   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;
   zg1=double(PH)/g; 
   netcdf.close(ncid)
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,vari);       q2  =(netcdf.getVar(ncid,varid))*1e3;
   varid  =netcdf.inqVarID(ncid,'PH');       ph   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb  =netcdf.getVar(ncid,varid); 
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
     X=squeeze(zg1(indx,indy,:));   Y=squeeze(q1(indx,indy,:));   var1(:,i)=interp1(X,Y,zgi,'linear');
     X=squeeze(zg2(indx,indy,:));   Y=squeeze(q2(indx,indy,:));   var2(:,i)=interp1(X,Y,zgi,'linear');
     hgtprof(i)=hgt(indx,indy);
   end  
   diff=var1-var2;    
%---plot setting---   
   if slopx>=slopy;    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;
   else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;
   end
   pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
   pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
   if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
%--plot----
   plotvar=diff;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[400 100 750 500]) 
   [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none');  hold on;
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   title(hc,'(g/Kg)')
   %
   plot(xaxis,hgtprof,'k','LineWidth',1.5);  %terrain
   %text(xaxis(1)+0.1,zgi(end)-zgi(end)/20,[pointA,' ',pointB,' slope=',slope])  %label
   %
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %
   %tit=[expri1,' minus ',expri2,'  ',varinam,'  ',s_hr,minu,'z  (',type,')'];
   tit=['QVAPOR difference  ',figtit1,'-',figtit2];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',num2str(px),num2str(py),'s',slope];  %print('-dpng',outfile,'-r400')       
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
end    

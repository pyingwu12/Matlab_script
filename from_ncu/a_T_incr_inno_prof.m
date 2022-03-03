%--------------------------------------------------
% Potential temperature increment (anal-fcst) profile 
%--------------------------------------------------

clear

hr=[0];   minu='00';    expri='e04';   

lonA=120; latA=21.7;  len=1.5;   %length of the line (degree)
slopx=0; %integer and >= 0
slopy=1; %integer and >= 0

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 
obsdir='/SAS004/pwin/data/obs_sz6414'; indir2=['/work/pwin/data/largens_wrf2obs_',expri];  
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
   
   
   %---obs
   infile1=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   A=importdata(infile1);
   lon=A(:,5); lat=A(:,6); alt=A(:,7);   zh1 =A(:,9);  
   %---model   
   infile2=[indir2,'/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   B=importdata(infile2); 
   zh2 =B(:,9); 
   %---calculate--- 
   fin=find(zh2~=-9999 & zh1~=9999 );
   %fin=find(zh2~=-9999 & zh1~=9999 & aza==93);
   lon=lon(fin); lat=lat(fin); alt=alt(fin);
   zh1=zh1(fin); zh2=zh2(fin);      
   inno=zh1-zh2;
   
   %fin=find(abs(lat-latA)<0.03);
   fin=find(abs(lon-lonA)<0.03);
   pointx=lat(fin);  alt=alt(fin);
   inno=inno(fin);
   
   %---tick white point
   %plotvar(plotvar>L(6) & plotvar<L(7))=NaN;
  
   
   
%---plot setting---   
   if slopx>=slopy;    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;
   else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;
   end
   if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
%--plot--    
   plotvar=incr;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[200 500 750 500]) 
   [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none');  
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   title(hc,'(K)')
   hold on;       
   plot(xaxis,hgtprof,'k','LineWidth',1.5);
   pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
   pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
   text(xaxis(1)+0.1,zgi(end)-zgi(end)/20,[pointA,' ',pointB,' slope=',slope])
   %
   
   load '/work/pwin/data/colormap_br2.mat';  cmapinno=colormap_br2([1 3 5 7   15 17 19 21],:);  
   Linno=[-20 -10 -5 0 5 10 20];
   Var=inno; M=length(Var);  clen=length(Linno); Msize=6;
   for i=1:M;         
     for k=1:clen-2;
      if (Var(i) > Linno(k) && Var(i)<=Linno(k+1))
        c=cmapinno(k+1,:);
        hp=plot(pointx(i),alt(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); 
        set(hp,'linestyle','none');    
      end      
     end
     if Var(i)>Linno(clen-1)
       c=cmapinno(clen,:);
       hp=plot(pointx(i),alt(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize);
       set(hp,'linestyle','none');   
     end
     if Var(i)<Linno(1)
       c=cmapinno(1,:);
       hp=plot(pointx(i),alt(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); 
       set(hp,'linestyle','none');   
     end   
  end
    
   %
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(px),num2str(py),'s',num2str(slope)];
%    print('-dpng',outfile,'-r400')       
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]); 
end    


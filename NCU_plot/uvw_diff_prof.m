%-------------------------------------------------------
% u,v,w difference(exp1-exp2) between expri1 to expri2  (DA cycle & forecasting time)
%          wid=1-U, 2-V, 3-W
%-------------------------------------------------------

clear

hr=4;   expri1='e01';  expri2='e04';   wid=[1 2];     % 0:model level. ~=0:constant-height
%
lonA=118.5; latA=22.3;  len=3;   %length of the line (degree)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%---DA or forecast time---
infilenam='wrfout';  minu='00';   type='sing';
%infilenam='output/analmean'; minu='00'; type=infilenam(8:11); %!!!!infile1

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';   % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';
indir='/SAS009/pwin/expri_largens/';  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
L=[-10 -7 -5 -3 -2 -1 1 2 3 5 7 10];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam={'U';'V';'W'};
zgi=[10,50,100:100:20000];    ytick=1000:2000:zgi(end);
%zgi=[10,50,100:100:10000];    ytick=1000:1000:zgi(end);
g=9.81;  

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;
   zg1=double(PH)/g; 
   netcdf.close(ncid)
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;
   zg2=double(PH)/g; 
   netcdf.close(ncid)
   
   for vi=wid
      if vi==3; L=L*0.1; end
      filenam=[expri1,'-diff-',expri2,'_',varinam{vi},'-prof_'];  
      %
      ncid = netcdf.open(infile1,'NC_NOWRITE');       varid  =netcdf.inqVarID(ncid,varinam{vi});    
        var_stag1 =netcdf.getVar(ncid,varid);  netcdf.close(ncid)
      ncid = netcdf.open(infile2,'NC_NOWRITE');       varid  =netcdf.inqVarID(ncid,varinam{vi});    
        var_stag2 =netcdf.getVar(ncid,varid);  netcdf.close(ncid)
      switch (vi); 
       case 1;   vari1=(var_stag1(1:end-1,:,:)+var_stag1(2:end,:,:)).*0.5;
           vari2=(var_stag2(1:end-1,:,:)+var_stag2(2:end,:,:)).*0.5;
       case 2;   vari1=(var_stag1(:,1:end-1,:)+var_stag1(:,2:end,:)).*0.5; 
           vari2=(var_stag2(:,1:end-1,:)+var_stag2(:,2:end,:)).*0.5; 
       case 3;   vari1=(var_stag1(:,:,1:end-1)+var_stag1(:,:,2:end)).*0.5; 
           vari2=(var_stag2(:,:,1:end-1)+var_stag2(:,:,2:end)).*0.5; 
      end      
      
      %---difine xp, yp for profile---
      dis= ( (y-latA).^2 + (x-lonA).^2 );
      [mid mxI]=min(dis);    [dmin py]=min(mid);    px=mxI(py); 
      %---interpolation to constant-height above surface
      i=0;  lonB=0; latB=0;
      while lonB<=x(px,py)+len && latB<=y(px,py)+len
        i=i+1;
        indx=px+slopx*(i-1);    indy=py+slopy*(i-1);
        linex(i)=x(indx,indy);  lonB=linex(i);     
        liney(i)=y(indx,indy);  latB=liney(i);       
        X=squeeze(zg1(indx,indy,:));  Y=squeeze(vari1(indx,indy,:));   var1(:,i)=interp1(X,Y,zgi,'linear');
        X=squeeze(zg2(indx,indy,:));  Y=squeeze(vari2(indx,indy,:));   var2(:,i)=interp1(X,Y,zgi,'linear');
        hgtprof(i)=hgt(indx,indy);
      end  
      
      diff=var1-var2  ;
      
      %---plot setting---   
      if slopx>slopy;    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;
      else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;
      end
      if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
   %---plot---      
      plotvar=diff;  
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else  L2=[L(1) L]; end
   %
      figure('position',[200 500 750 500]) 
      [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none');  
      cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
      hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
      hold on; 
      plot(xaxis,hgtprof,'k','LineWidth',1.5);
      %
      pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
      pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
      text(xaxis(1)+0.1,zgi(end)-zgi(end)/20,[pointA,' ',pointB,' slope=',slope])
      %
      ytick=get(gca,'YTick');
      set(gca,'Yticklabel',ytick./1000,'fontsize',13)
      xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %
      tit=[expri1,' minus ',expri2,'  ',varinam{vi},'  ',s_hr,minu,'z  (',type,')'];
      title(tit,'fontsize',15)
      outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',num2str(px),num2str(py),'s',slope];  %print('-dpng',outfile,'-r400')       
      set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
      system(['rm ',[outfile,'.pdf']]);         
   end  % wid
end     % time


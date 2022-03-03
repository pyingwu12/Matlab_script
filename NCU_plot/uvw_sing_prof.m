%-------------------------------------------------------
% Caculate u,v,w of a single run (DA cycle & forecasting time), 
%          wid=1-U, 2-V, 3-W
%-------------------------------------------------------

clear

hr=4;   expri='e02';   wid=[1 2];   
lonA=118.3; latA=22.5;   
len=3;   %length of the line (degree)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%---DA or forecast time---
infilenam='wrfout';  minu='00';   type='sing';
%infilenam='output/fcstmean'; minu='00'; type=infilenam(8:11); %!!!!


%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';     % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];       % path of the experiments
indir=['/SAS009/pwin/expri_largens/',expri];
%indir=['/SAS009/pwin/expri_whatsmore/',expri];
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];   % path of the figure output
L=[-15 -10 -7 -5 -3 -1  1 3 5 7 10 15];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br; 
%---
varinam={'U';'V';'W'};
zgi=[10,50,100:100:20000]';   g=9.81;   

%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');    % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid);   
   %---
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;   
   zg=double(PH)/g; 
   %---difine xp, yp for profile---
   dis= ( (y-latA).^2 + (x-lonA).^2 );
   [mid mxI]=min(dis);    [dmin py]=min(mid);    px=mxI(py);    
   %---
   for vi=wid
      if vi==3; L=L*0.1; end
      filenam=[expri,'_',varinam{vi},'_']; 
      varid  =netcdf.inqVarID(ncid,varinam{vi});    var_stag =netcdf.getVar(ncid,varid); 
      switch (vi); 
       case 1;   wind=(var_stag(1:end-1,:,:)+var_stag(2:end,:,:)).*0.5;
       case 2;   wind=(var_stag(:,1:end-1,:)+var_stag(:,2:end,:)).*0.5; 
       case 3;   wind=(var_stag(:,:,1:end-1)+var_stag(:,:,2:end)).*0.5; 
       end  
      %---interpolation to constant-height above surface
      i=0;  lonB=0; latB=0;
      while lonB<=x(px,py)+len && latB<=y(px,py)+len
        i=i+1;
        indx=px+slopx*(i-1);    indy=py+slopy*(i-1);
        linex(i)=x(indx,indy);  lonB=linex(i);     
        liney(i)=y(indx,indy);  latB=liney(i);       
        X=squeeze(zg(indx,indy,:));  Y=squeeze(wind(indx,indy,:));   varprof(:,i)=interp1(X,Y,zgi,'linear');
        hgtprof(i)=hgt(indx,indy);
      end  
      
      %---plot setting---   
      if slopx>slopy;    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;
      else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;
      end
      if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
   %---plot---      
      plotvar=varprof;  
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
      tit=[expri,'  ',varinam{vi},'  ',s_hr,minu,'z'];
      title(tit,'fontsize',15,'FontWeight','bold')
      outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',num2str(px),num2str(py),'s',num2str(slope)];
%       set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%       system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%       system(['rm ',[outfile,'.pdf']]);      
   end  %vari
   netcdf.close(ncid)
end  %ti


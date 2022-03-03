%-------------------------------------------------------
% plot profile of QVAPOR convergence and equivalent potential temperature or wind 
%-------------------------------------------------------
clear

hr=2;   minu='00';   expri='e01';  figtit='L3604';

%---decide the profile line---
lonA=119.4; latA=22.25; % start point  
len=1.5; %length of the line (degree)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%---DA or forecast time---
infilenam='wrfout';    type='sing';
%infilenam='output/analmean';  type=infilenam(8:11);  %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%L=[-5 -4 -3 -2 -1 -0.5 0.5 1 2 3 4 5]*0.2;
L=[-0.7 -0.4 -0.1  0.1 0.4 0.7];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
%load '/work/pwin/data/colormap_br4.mat';  cmap=colormap_br4;
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br([3 4 6 7 8 9 10],:); 
%---
varinam='Qv conv.';    filenam=[expri,'_qv-conv-prof_'];  
zgi=[10,50,100:100:11000]';    ytick=1000:1000:zgi(end); 
%zgi=[10,50,100:100:16000]';    ytick=1000:2000:zgi(end); 
g=9.81;

%---coeffitions--
 cp=1005;  % J/(K*kg)
 Lat=2430; % J/g
 Lc=2.5e6; % J/Kg
 R=287.43;
 eps=0.622; % esp=Rd/Rv=Mv/Md
 A=1.26e-3;  % K^-1
 B=5.14e-4;  % K^-1
%==============================  
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   dx =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DX')); 
   dy =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DY'));
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'T');        t   =netcdf.getVar(ncid,varid);  T=t+300; %potential temprature
   varid  =netcdf.inqVarID(ncid,'P');        p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');       pb  =netcdf.getVar(ncid,varid); 

   varid  =netcdf.inqVarID(ncid,'PH');       ph   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'W');     w.stag =netcdf.getVar(ncid,varid);
    netcdf.close(ncid)
%===============================
%---Qv convegence---       
     u.unstag=(u.stag(2:end,:,:)-u.stag(1:end-1,:,:))./dx;
     v.unstag=(v.stag(:,2:end,:)-v.stag(:,1:end-1,:))./dy; 
     qconv=qv*-1000.*(u.unstag+v.unstag)*100;      
%---3-dimention wind speed---
     u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
     v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
     w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;      
%---  
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;
   zg=double(PH)/g; 
%---caculate equivalent potential temperature---
   P=p+pb;    
   ev=qv./eps.*P;   %partial pressure of water vapor
   Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor
   Tlcl=(1-A.*Td)./(1./Td+B.*log(T./Td)-A);    
   the=T.*exp(Lc.*qv./(cp.*Tlcl));
   the=the-273;   
%===============================
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
     X=squeeze(zg(indx,indy,:));   Y=squeeze(qconv(indx,indy,:));   varprof(:,i)=interp1(X,Y,zgi,'linear'); 
        Y=squeeze(u.unstag(indx,indy+1,:));   u.prof(:,i)=interp1(X,Y,zgi,'linear');
        Y=squeeze(v.unstag(indx,indy+1,:));   v.prof(:,i)=interp1(X,Y,zgi,'linear');
        Y=squeeze(w.unstag(indx,indy+1,:));   w.prof(:,i)=interp1(X,Y,zgi,'linear');
        Y=squeeze(the(indx,indy,:));   theprof(:,i)=interp1(X,Y,zgi,'linear');
     hgtprof(i)=hgt(indx,indy);
   end  
%===============================
%---plot setting---   
   if abs(slopx)>=abs(slopy);    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;
   else                          xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;   end
   pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
   pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
   if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
   %%
%--plot----
   plotvar=varprof;   %plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %   
   figure('position',[100 100 750 500]) 
   [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none');  hold on;
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   title(hc,'(10^-^2gKg^-^1s^-^1)','fontsize',11)
   %
   %--wind barb----------
%   intz=5;  intx=4; windmax=20;  scale=0.25; wcol=[0.6 0.1 0.6];
%   xi2=xi(1:intz:end,1:intx:end);   zi2=zi(1:intz:end,1:intx:end);   
%   u.plot=u.prof(1:intz:end,1:intx:end);    v.plot=v.prof(1:intz:end,1:intx:end); 
%   windbarbM(xi2,zi2,u.plot,v.plot,scale,windmax,wcol,1)
%   windbarbM(max(xaxis)-0.1,zgi(end)-zgi(end)/22,windmax,0,scale,windmax,[0.85 0.05 0.1],1)
%   text(max(xaxis)-0.08,zgi(end)-zgi(end)/22,num2str(windmax),'color',[0.85 0.05 0.1],'fontsize',14)
%
   %---vwetical wind contour--------   
%   [c2 hc]=contour(xi,zi,w.prof,[0.5 1 ],'color',[0 0 0.1],'LineWidth',1);   
%   clabel(c2,hc,'fontsize',13,'color',[0 0 0],'LabelSpacing',250);
%   [c2 hc]=contour(xi,zi,w.prof,[-0.5 -1 ],'color',[0 0 0.1],'LineStyle',':','LineWidth',1.3);
   %---the contour--------
   [c2 hc]=contour(xi,zi,theprof,54:3:78,'color',[0.2 0.2 0.2],'LineWidth',1.6);
   clabel(c2,hc,'fontsize',14,'color',[0.2 0.2 0.2],'LabelSpacing',300); 
   %-----------   
   plot(xaxis,hgtprof,'k','LineWidth',1.5);  %terrain
   %text(min(xaxis)+0.1,zgi(end)-zgi(end)/20,[pointA,' ',pointB,' slope=',slope]) %label
   %
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z'];
   %tit=figtit;
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(px),num2str(py),'s',slope];
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]);      

end  %ti

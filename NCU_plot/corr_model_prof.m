%-------------------------------------------------
% calculate and plot Corr(<v1nam>,<v2nam>) 
%        between a point <px,py,plev> and vertical profile of <px>(profid=2) or <py>(profid=1)
%-------------------------------------------------
clear

hr=2;  minu='00';   v1nam='QRAIN';  v2nam='QCLOUD';  
expri='e01';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
%expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';

len=4;  slopx=1;   slopy=0; %integer and >= 0
plev=10;  px=137;  py=118;   memsize=256;   
%hclr=36/111;  vclr=4000;  %for plot the localization range

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir='/SAS011/pwin/201work/plot_cal/largens'; 
%indir=['/work/pwin/data/sz_wrf2obs_',expri];  outdir='/SAS011/pwin/201work/plot_cal/IOP8'; 
%memsize=256;  
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');  load '/work/pwin/data/colormap_br2.mat'; 
cmap=colormap_br2([3 4 5 7 8 9 11 13 14 15 17 18 19],:);
L=[-0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6];   
%---
if strcmp(v1nam(1),'Q')==1;  s_v1=v1nam(1:2);  else  s_v1=v1nam; end
if strcmp(v2nam(1),'Q')==1;  s_v2=v2nam(1:2);  else  s_v2=v2nam; end
corrvari=[s_v1,'-',lower(s_v2)];  
%
varinam=[corrvari,' Corr.'];    filenam=[expri,'_corr_']; 
zgi=100:100:20000;  ytick=1000:2000:20000;  
nzi=length(zgi);   g=9.81;
%
v1en=zeros(memsize,1); 

%---
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');  
%---member
   for mi=1:memsize;
% ---filename----
      nen=num2str(mi,'%.3d'); 
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
      ncid = netcdf.open(infile,'NC_NOWRITE'); 
      if mi==1
        varid  =netcdf.inqVarID(ncid,'XLONG');   x =netcdf.getVar(ncid,varid,'double');
        varid  =netcdf.inqVarID(ncid,'XLAT');    y =netcdf.getVar(ncid,varid,'double');  
        varid  =netcdf.inqVarID(ncid,'HGT');     hgt =netcdf.getVar(ncid,varid); 
        varid  =netcdf.inqVarID(ncid,'PH');      ph =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'PHB');     phb =netcdf.getVar(ncid,varid); 
        P0=(phb+ph);   PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;   zg=double(PH)./g;
      end      
      %---read variable 1 at the point---
      varid=netcdf.inqVarID(ncid,v1nam);     v1 =netcdf.getVar(ncid,varid,[px-1 py-1 plev-1 0],[2 2 1 1],'double'); 
      if     strcmp(v1nam(1),'Q')==1;  v1en(mi)= v1(1,1)*1000;        
      elseif strcmp(v1nam,'U')==1;     v1en(mi)=(v1(1,1)+v1(2,1)).*0.5;
      elseif strcmp(v1nam,'V')==1;     v1en(mi)=(v1(1,1)+v1(1,2)).*0.5;
      else   error('Error: Wrong model varible setting of <v1nam>');  
      end
      %---read variable 2 of model---
      varid  =netcdf.inqVarID(ncid,v2nam);   v2 =netcdf.getVar(ncid,varid,'double'); 
      if     strcmp(v2nam(1),'Q')==1;  v2= v2.*1000; 
      elseif strcmp(v2nam,'U')==1;     v2=(v2(1:end-1,:,:)+v2(2:end,:,:)).*0.5;
      elseif strcmp(v2nam,'V')==1;     v2=(v2(:,1:end-1,:)+v2(:,2:end,:)).*0.5;
      else   error('Error: Wrong model varible setting of <v2nam>');  
      end 
      netcdf.close(ncid);  
%---interpoltion--- 
      if mi==1
        n=0;  lonB=0; latB=0;
        while lonB<=x(px,py)+len/2 && latB<=y(px,py)+len/2
         n=n+1; lonB=x(px+slopx*(n-1),py+slopy*(n-1));  latB=y(px+slopx*(n-1),py+slopy*(n-1));  
        end
        np=n*2;
        linex=zeros(1,np); liney=zeros(1,np); hgtprof=zeros(1,np); 
        for i=1:np
         indx=px+slopx*(i-n);    indy=py+slopy*(i-n);
         linex(i)=x(indx,indy);  liney(i)=y(indx,indy);   hgtprof(i)=hgt(indx,indy);
        end
        v2en=zeros(nzi,np,memsize);
        varprof=zeros(nzi,np);
      end
      %
      for i=1:np
       indx=px+slopx*(i-n);     indy=py+slopy*(i-n);
       X=squeeze(zg(indx,indy,:));   Y=squeeze(v2(indx,indy,:));   varprof(:,i)=interp1(X,Y,zgi,'linear'); 
      end   
      %
      v2en(:,:,mi)=varprof;
   end   %member
   
   %---estimate background error---
   % A:2-D, 3-dimention array, b:point, vector
   A=reshape(v2en,nzi*np,memsize);    b=v1en;    
   at=mean(A,2);                      bt=mean(b);  %estimate true   
   At=repmat(at,1,memsize);
   Ae=A-At;                           be=b-bt;
   %---variance---    
   % !!notice: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean
   varae=sum(Ae.^2,2)./(memsize-1);     varbe=be'*be/(memsize-1);  
   cov=(Ae*be)./(memsize-1); %covariance   
   %---correlation--- 
   corr0=cov./(varae.^0.5)./(varbe^0.5);
   corr=reshape(corr0,nzi,np);
   
%---plot setting---   
   if slopx>=slopy;   xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex; xpoint=x(px,py);
   else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney; xpoint=y(px,py);
   end
   if slopx==0; slope=1; else slope=fixpy(slopy/slopx,0.01); end
%---plot---
   %xmi=x(px,py)-hclr; xma=x(px,py)+hclr; ymi=zg(px,py,plev)-vclr; yma=zg(px,py,plev)+vclr;    
   %
   pmin=double(min(min(corr)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[400 500 750 500]) 
   %---
   [c hp]=contourf(xi,zi,corr,L2);   set(hp,'linestyle','none');  hold on;  
   cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
   %
   %---lines, points or text---
   plot(xpoint,zg(px,py,plev),'x','color','k','MarkerSize',12,'lineWidth',2.5)  % plot the point
   %line([xmi xma xma xmi xmi],[ymi ymi yma yma ymi],'color','k','LineStyle','--','LineWidth',1.1)    
   plot(xaxis,hgtprof,'k','LineWidth',1.5); % plot terrain
   pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
   pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
   text(xaxis(1)+0.1,-zgi(end)/20,[pointA,' ',pointB,' slope=',num2str(slope)])
   %---
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %---title and print the figure
   plev=num2str(plev); mem=num2str(memsize); 
    %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,', lev',plev,', mem',mem,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(px),num2str(py),'s',num2str(slope),'_',type,'_',corrvari,'_lev',plev,'_m',mem];
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]); 
end


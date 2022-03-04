%-------------------------------------------------
% calculate and plot Corr(<v1nam>,<v2nam>) 
%        between a point <px,py,plev> and vertical profile of <px>(profid=2) or <py>(profid=1)
%-------------------------------------------------
clear

hr=2;  minu='00';   v1nam='V';  v2nam='V';   profid=1; % 1:east-west 2:south-north

%expri='e02';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
plev=20;  px=137;  py=118;   memsize=40;   
hclr=36/111;  vclr=4000;  %for plot the localization range

%---DA or forecast time---
%infilenam='wrfout';  dirnam='pert';  type='wrfo';
%infilenam='fcst';    dirnam='cycle'; type=infilenam;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir='/work/pwin/plot_cal/largens'; 
%indir=['/work/pwin/data/sz_wrf2obs_',expri];  outdir='/work/pwin/plot_cal/IOP8'; 
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
varinam=['Corr.',corrvari];     filenam=[expri,'_corr_']; 
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
        [nx ny]=size(x); 
        if profid==1; nh=nx; elseif profid==2; nh=ny; end;  v2en=zeros(nzi,nh,memsize);         
      end      
      %---point
      varid=netcdf.inqVarID(ncid,v1nam);     v1 =netcdf.getVar(ncid,varid,[px-1 py-1 plev-1 0],[2 2 1 1],'double'); 
      if     strcmp(v1nam(1),'Q')==1;  v1en(mi)= v1(1,1);        
      elseif strcmp(v1nam,'U')==1;     v1en(mi)=(v1(1,1)+v1(2,1)).*0.5;
      elseif strcmp(v1nam,'V')==1;     v1en(mi)=(v1(1,1)+v1(1,2)).*0.5;
      else   error('Error: Wrong model varible setting of <pvari>');  
      end
      %---
      varid  =netcdf.inqVarID(ncid,v2nam);   v2 =netcdf.getVar(ncid,varid,'double'); 
      if     strcmp(v2nam,'U')==1;     v2=(v2(1:nx,:,:)+v2(2:nx+1,:,:)).*0.5;
      elseif strcmp(v2nam,'V')==1;     v2=(v2(:,1:ny,:)+v2(:,2:ny+1,:)).*0.5;
      else   error('Error: Wrong model varible setting of <mvari>');  
      end 
      netcdf.close(ncid);
      %
      if profid==1
        varprof=zeros(length(zgi),nx);
        for i=1:nx
         X=squeeze(zg(i,py,:));   Y=squeeze(v2(i,py,:));   varprof(:,i)=interp1(X,Y,zgi,'linear');
        end      
      elseif profid==2    
        varprof=zeros(length(zgi),ny);
        for j=1:ny
         X=squeeze(zg(px,j,:));   Y=squeeze(v2(px,j,:));   varprof(:,j)=interp1(X,Y,zgi,'linear');
        end    
      end   
      v2en(:,:,mi)=varprof;
   end   %member
   
   %---estimate background error---
   % A:2-D, 3-dimention array, b:point, vector
   A=reshape(v2en,nzi*nh,memsize);    b=v1en;    
   at=mean(A,2);                      bt=mean(b);  %estimate true   
   At=repmat(at,1,memsize);
   Ae=A-At;                           be=b-bt;
   %---variance---    
   % !!notice: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean
   varae=sum(Ae.^2,2)./(memsize-1);     varbe=be'*be/(memsize-1);  
   cov=(Ae*be)./(memsize-1); %covariance   
   %---correlation--- 
   corr0=cov./(varae.^0.5)./(varbe^0.5);
   corr=reshape(corr0,nzi,nh);
%---plot---
   if profid==1
     hgtprof=hgt(:,py);
     xaxis=x(:,py);  xlimt=[117.5 122.5];  xtitle='longitude';   prof=num2str(py);   
     profline=[num2str( round(y(px,py)*10)/10 ) , '°N'];
   elseif profid==2          
     hgtprof=hgt(px,:);
     xaxis=y(px,:);  xlimt=[20.5  25.5];   xtitle='latitude';    prof=num2str(px);
     profline=[num2str( round(x(px,py)*10)/10 ) , '°E'];
   end   
   %--- 
   xmi=x(px,py)-hclr; xma=x(px,py)+hclr; ymi=zg(px,py,plev)-vclr; yma=zg(px,py,plev)+vclr;    
   [xi zi]=meshgrid(xaxis,zgi);   
   %
   pmin=double(min(min(corr)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[400 500 750 500]) 
   %
   [c hp]=contourf(xi,zi,corr,L2);   set(hp,'linestyle','none');  hold on;  
   cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
   %---lines, points or text   
   plot(xaxis,hgtprof,'k','LineWidth',1.5);   %terrain profile
   plot(x(px,py),zg(px,py,plev),'x','color','k','MarkerSize',12,'lineWidth',2.5)  %the point
   text(xlimt(1)+0.2,zgi(nzi)-zgi(nzi)/20,profline,'fontsize',13)
   line([xmi xma xma xmi xmi],[ymi ymi yma yma ymi],'color','k','LineStyle','--','LineWidth',1.1)
   %---axis
   set(gca,'XLim',xlimt,'YLim',[0 zgi(end)],'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13,'LineWidth',1.1);   
   xlabel(xtitle); ylabel('height (km)')
   %---title and print the figure
   plev=num2str(plev); mem=num2str(memsize); 
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,', lev',plev,', mem',mem,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_prof',prof,'_',type,'_',corrvari,'_lev',plev,'_m',mem];
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]); 
end


%function corr_obsmodel_prof(vonam,vmnam,memsize)
%-------------------------------------------
%  Corr.(obs_point,model_profile) 
%-------------------------------------------
%clear

hr=0;  minu='00';   vonam='Zh';  vmnam='QRAIN';  memsize=40;

%expri='e01';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
pradar=4;  pela=0.5;  paza=178;  pdis=98;  
%pradar=3;  pela=6;  paza=298;  pdis=88;  

len=1.5;     slopx=1;   slopy=0; %integer 

hclr=36/111;  vclr=12000; vclr2=4000; % for plot dashed line to show the localization range

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri]; indir2=['/SAS009/pwin/expri_largens/',expri]; 
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br2.mat';  cmap=colormap_br2([3 4 5 7 8 9 11 13 14 15 17 18 19],:);
L=[-0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6];    
%---
if strcmp(vmnam(1),'Q')==1;  s_vm=[vmnam(1),lower(vmnam(2))];  else  s_vm=vmnam; end
corrvari=[vonam,'-',lower(s_vm)];  %
varinam=['Corr.',corrvari];    filenam=[expri,'_']; 
%
voen=zeros(memsize,1); 
zgi=100:100:15000;  ytick=1000:2000:zgi(end);  
nzi=length(zgi);   g=9.81;

%tic
%---
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');  
%---member
   for mi=1:memsize;
% ---filename----
      nen=num2str(mi,'%.3d');
      infile1=[indir1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen]; 
      infile2=[indir2,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------obs space------
      %vari1=load(infile1);
      fid=fopen(infile1);
      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');
      fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
      %fin=30424;
      if isempty(fin)==1;  error('Error: No this obs point, pleast check the setting of <pradar> etc.'); end
      if     strcmp(vonam,'Vr')==1;  voen(mi)=vo{8}(fin); 
      elseif strcmp(vonam,'Zh')==1;  voen(mi)=vo{9}(fin); 
      else   error('Error: Wrong obs varible setting of <vonam>');  
      end      
      if voen(mi)==-9999; disp(['member ',nen,' obs is -9999']); voen(mi)=0;  end;       
%------model space----      
      ncid = netcdf.open(infile2,'NC_NOWRITE'); 
      if mi==1
         p_lon=vo{5}(fin); p_lat=vo{6}(fin); obs_hgt=vo{7}(fin);          
         varid  =netcdf.inqDimID(ncid,'bottom_top');  [~, nz]=netcdf.inqDim(ncid,varid);
         varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
         varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);       
         varid  =netcdf.inqVarID(ncid,'PH');       ph   =netcdf.getVar(ncid,varid);
         varid  =netcdf.inqVarID(ncid,'PHB');      phb  =netcdf.getVar(ncid,varid); 
         varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
         P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;      zg=double(PH)/g;          
         %---difine xp, yp for profile---
         dis= ( (y-p_lat).^2 + (x-p_lon).^2 );
         [mid mxI]=min(dis);    [~, py]=min(mid);    px=mxI(py);        
%---find to profile coordinate---     
         n=0;  lonB=0; latB=0;
         while lonB<=x(px,py)+len/2 && latB<=y(px,py)+len/2
         n=n+1; lonB=x(px+slopx*(n-1),py+slopy*(n-1));  latB=y(px+slopx*(n-1),py+slopy*(n-1));
         end
         %
         np=n*2;  linex=zeros(1,np); liney=zeros(1,np); hgtprof=zeros(1,np);
         vmen=zeros(nzi,np,memsize);
         varprof=zeros(nzi,np);
      end
%---read model variable---
      varid  =netcdf.inqVarID(ncid,vmnam);   %vm =netcdf.getVar(ncid,varid,'double');
      npx2=1; npy2=1;  if strcmp(vmnam,'V')==1; npy2=2; elseif strcmp(vmnam,'U')==1; npx2=2; end
      for i=1:np
         indx=px+slopx*(i-n);     indy=py+slopy*(i-n);
         vm =netcdf.getVar(ncid,varid,[indx-1 indy-1 0 0],[npx2 npy2 nz 1]); 
         if     strcmp(vmnam(1),'Q')==1;   vm=vm*1000;   %vm(vm<10e-4)=0;
         elseif strcmp(vmnam,'T')==1;      vm=vm+300;
         elseif strcmp(vmnam,'U')==1;      vm=(vm(1,1,:)+vm(2,1,:)).*0.5;
         elseif strcmp(vmnam,'V')==1;      vm=(vm(1,1,:)+vm(1,2,:)).*0.5;
         else   error('Error: Wrong model varible setting of <vmnam>');
         end               
%---interpoltion to profile--- 
         X=squeeze(zg(indx,indy,:));   Y=squeeze(vm);   varprof(:,i)=interp1(X,Y,zgi,'linear');
         %set x-axis
         if mi==1; linex(i)=x(indx,indy);  liney(i)=y(indx,indy);  hgtprof(i)=hgt(indx,indy); end
      end
      vmen(:,:,mi)=varprof;            
%---      
      netcdf.close(ncid);
      fclose(fid);      
   end   %member
   %
%---background error correlation calculation---
   %---background error---
   % A:2-D, 3-dimention array, b:point, vector
   A=reshape(vmen,nzi*np,memsize);      b=voen;    
   at=mean(A,2);                        bt=mean(b);  %estimate true   
   At=repmat(at,1,memsize);
   Ae=A-At;                             be=b-bt;
   %---variance---    
   % !!notice: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean
   varae=sum(Ae.^2,2)./(memsize-1);     varbe=be'*be/(memsize-1);  
   cov0=(Ae*be)./(memsize-1); %covariance   
   %---correlation--- 
   corr0=cov0./(varae.^0.5)./(varbe^0.5);
   corr0(single(varae)<10e-6)=NaN;
   corr=reshape(corr0,nzi,np);
   
   %%
%---plot setting---   
   if slopx>=slopy;   xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex; xpoint=p_lon;
                       xmi=x(px,py)-hclr;  xma=x(px,py)+hclr;   ymi=obs_hgt-vclr;   yma=obs_hgt+vclr; 
                       ymi2=obs_hgt-vclr2; yma2=obs_hgt+vclr2; 
   else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;  xpoint=p_lat;
                      xmi=y(px,py)-hclr; xma=y(px,py)+hclr;   ymi=obs_hgt-vclr; yma=obs_hgt+vclr; 
   end
   if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
%---plot---

   %xmi=y(px,py)-hclr; xma=y(px,py)+hclr; ymi=obs_hgt-vclr; yma=obs_hgt+vclr;    
   
   pmin=double(min(min(corr)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[400 100 750 500]) 
   %---
   [c hp]=contourf(xi,zi,corr,L2);   set(hp,'linestyle','none');  hold on;  
   cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
   %
   %---lines, points or text---
   plot(xpoint,obs_hgt,'x','color','k','MarkerSize',12,'lineWidth',2.5)  % plot the point
    line([xmi xma xma xmi xmi],[ymi ymi yma yma ymi],'color','k','LineStyle','--','LineWidth',1)    
    %line([xmi xma xma xmi xmi],[ymi2 ymi2 yma2 yma2 ymi2],'color','k','LineStyle','--','LineWidth',1)    
    line([xmi xma],[ymi2 ymi2],'color','k','LineStyle','--','LineWidth',1)    
    line([xmi xma],[yma2 yma2],'color','k','LineStyle','--','LineWidth',1)    
   plot(xaxis,hgtprof,'k','LineWidth',1.5);  % plot terrain   
   %
   %pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
   %pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
   %text(xaxis(1)+(xaxis(end)-xaxis(1))/24,zgi(end)-(zgi(end)-zgi(1))/20,[pointA,' ',pointB,' slope=',slope])
   %text(xaxis(end)-(xaxis(end)-xaxis(1))/6,zgi(end)-(zgi(end)-zgi(1))/20,[num2str(pradar),'-',num2str(pela),'-',num2str(paza),'-',num2str(pdis)],'color',[0.4 0.4 0.4])
   %---
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14);   ylabel('Height (km)','fontsize',14)
   %---title and print the figure
   mem=num2str(memsize);  %
   %tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,', mem',mem,')'];
   tit=['CORR(',vonam,', ',s_vm,')','  ',mem,' members'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(fin),'_',type,'_',corrvari,'_prof',slope,'_m',mem];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
   
end
%}

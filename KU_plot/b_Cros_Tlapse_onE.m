% close all
clear;   ccc=':';
saveid=0; % save figure (1) or not (0)

%---setting
expri='TWIN003B';  day=22;  hr=23;  minu=00;    h_int=100;
%----
cloudid=0;
datec='22';  hrc='23';  minc='40';
%---
xp=1; yp=110;  %start grid
len=150;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%----
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];

titnam='Temperature lapse rate';   fignam=[expri,'_Tlapseprof_'];

%---
load('colormap/colormap_parula20.mat'); cmap=colormap_parula20;
cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-2 -1 0 1 2 4 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 10.5 11];
%---
Rcp=287.43/1005; Rsd=287.43; cpd=1005;
g=9.81;
zgi=50:h_int:4000;    ytick=500:1000:zgi(end); 
epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
Lv=(2.4418+2.43)/2 * 10^6 ;


for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    t = ncread(infile,'T');   t=t+300;   
    qv = ncread(infile,'QVAPOR');  qv=double(qv);   
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    p = ncread(infile,'P');   pb = ncread(infile,'PB');
    hgt = ncread(infile,'HGT');    
    
    %----   
    P=p+pb;
    T=t.*(1e5./P).^(-Rcp); %temperature
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;      
    [nx, ny, nz]=size(t);
    [y, x]=meshgrid(1:ny,1:nx);
    
    %---LCL---
    hP=P/100; %pressure in hap
    ev=qv./epsilon.*hP;   %partial pressure of water vapor
    Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor 
    Zlcl=( zg(:,:,1)*1e-3+(T(:,:,1)-Td(:,:,1))/8 )*1e3;    
    
    %---
    if cloudid~=0
    infilecloud=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',datec,'_',hrc,ccc,minc,ccc,'00'];    
    qr = ncread(infilecloud,'QRAIN');  qr=double(qr);   
    qs = ncread(infilecloud,'QSNOW');  qs=double(qs);    
    qg = ncread(infilecloud,'QGRAUP'); qg=double(qg);
    qi = ncread(infilecloud,'QICE');   qi=double(qi);
    qc = ncread(infilecloud,'QCLOUD'); qc=double(qc);
%     hyd=qs+qg+qi+qc; hyd=hyd*1e3;
    hyd=qr+qs+qg+qi+qc; hyd=hyd*1e3;
    end
    %--- 
 
%---interpoltion---    
    i=0;  lonB=0; latB=0;
    while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);     
      liney(i)=y(indx,indy);  latB=liney(i);       
      X=squeeze(zg(indx,indy,:));   Y=squeeze(T(indx,indy,:));   
      tprof(:,i)=interp1(X,Y,zgi,'linear');
      hgtprof(i)=hgt(indx,indy);      
      if cloudid~=0
           Yh=squeeze(hyd(indx,indy,:));  cloudprof(:,i)=interp1(X,Yh,zgi,'linear');  
%            Yqr=squeeze(qr(indx,indy,:));  qrprof(:,i)=interp1(X,Yqr,zgi,'linear'); 
      end
%       zlclprof(i)=Zlcl(indx,indy);
    end       
    plotvar=(tprof(1:end-1,:)-tprof(2:end,:))/h_int*1000;   
    zgi2 = (zgi(1:end-1)+zgi(2:end))/2;

    %
%---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';   xaxis=linex;   
    else;               xtitle='Y (km)';   xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end
    %---plot---       
    [xi, zi]=meshgrid(xaxis,zgi2);
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 200 900 600]);
    [c, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none');   
    %---
    % hold on;      plot(zlclprof,'color',[1 0 0],'LineWidth',1.8)
    %
    if (max(max(hgtprof))~=0)
     hold on;      plot(hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end
    if cloudid~=0
     [xi2, zi2]=meshgrid(xaxis,zgi); 
     hold on;   contour(xi2,zi2,cloudprof,[0.005 0.005],'color',[0.5 0.02 0.1],'LineWidth',1.5)
%      contour(xi2,zi2,qrprof,[0.001 0.001],'color',[0.02 0.5 0.1],'LineWidth',1.5)
    end
    
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Ytick',ytick,'Yticklabel',ytick./1000)
    xlabel(xtitle); ylabel('Height (km)')
    tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
    title(tit,'fontsize',18)  
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1(1:2:end),'YTickLabel',L(1:2:end),'fontsize',13,'LineWidth',1.2);
    colormap(cmap); title(hc,['K/km'],'fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---
    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,...
        '_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_h',num2str(h_int)];
    if cloudid~=0
     outfile=[outdir,'/',fignam,'cld',mon,datec,hrc,minc,'_d',dom,'_',mon,s_date,'_',s_hr,s_min,...
         '_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_h',num2str(h_int)];
    end
if saveid~=0
%     print(hf,'-dpng',[outfile,'.png'])    
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
    %}
  end
end

% close all
clear;   ccc=':';
%---setting
expri='TWIN003B';  s_date='23'; hr=6; minu=00;  h_int=50;
%----
cloudid=0;
datec='22';  hrc='23';  minc='40';
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];

titnam='Temperature lapse rate';   fignam=[expri,'_Tlapse-rank-prof_'];

%---
load('colormap/colormap_parula20.mat'); cmap=colormap_parula20;
cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-2 -1 0 1 2 3 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10];
%---
Rcp=287.43/1005; Rsd=287.43; cpd=1005;
g=9.81;
zgi=10:h_int:3000;    ytick=500:1000:zgi(end); 
epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
Lv=(2.4418+2.43)/2 * 10^6 ;


for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
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
    
%     %---LCL---
%     hP=P/100; %pressure in hap
%     ev=qv./epsilon.*hP;   %partial pressure of water vapor
%     Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor 
%     Zlcl=( zg(:,:,1)*1e-3+(T(:,:,1)-Td(:,:,1))/8 )*1e3;    
    
    %---
    if cloudid~=0
    infilecloud=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',datec,'_',hrc,ccc,minc,ccc,'00'];    
    qr = ncread(infilecloud,'QRAIN');  qr=double(qr);   
    qs = ncread(infilecloud,'QSNOW');  qs=double(qs);    
    qg = ncread(infilecloud,'QGRAUP'); qg=double(qg);
    qi = ncread(infilecloud,'QICE');   qi=double(qi);
    qc = ncread(infilecloud,'QCLOUD'); qc=double(qc);
    hyd=qr+qs+qg+qi+qc; hyd=hyd*1e3;
    end
    %--- 
 
%---interpoltion---

    t_vector=reshape(T,nx*ny,nz);
    zg_vector=reshape(zg,nx*ny,nz);    
    t_iso=zeros(nx*ny,length(zgi));
    for i=1:nx*ny
        X=squeeze(zg_vector(i,:));    
        Y=squeeze(t_vector(i,:));
        t_iso(i,:)=interp1(X,Y,zgi,'linear');            
    end
    hgt_vector=reshape(hgt,nx*ny,1);
    [hgt_sort, hgt_rank]=sort(hgt_vector,'descend');

    t_sort=t_iso(hgt_rank,:);
    
    t_lapse=(t_sort(:,1:end-1)-t_sort(:,2:end))/h_int*1000;  
    
    for i=1:3000
    plotvar(i,:)= mean( t_lapse(i:i+30,:),1 );
    end
    zgi2 = (zgi(1:end-1)+zgi(2:end))/2;

    %
    %---plot---       
    [zi, xi]=meshgrid(zgi2,1:3000);
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 200 900 600]);
    [c, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none');   
    %---
    % hold on;      plot(zlclprof,'color',[1 0 0],'LineWidth',1.8)
    %
    if (max(max(hgt_sort))~=0)
     hold on;      plot(hgt_sort(1:3000),'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end
    if cloudid~=0
     [xi2, zi2]=meshgrid(xaxis,zgi); 
     hold on;   contour(xi2,zi2,cloudprof,[0.005 0.005],'color',[0.5 0.02 0.1],'LineWidth',1.5)
%      contour(xi2,zi2,qrprof,[0.001 0.001],'color',[0.02 0.5 0.1],'LineWidth',1.5)
    end
    
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Ytick',ytick,'Yticklabel',ytick./1000)
    xlabel('Rank of terrain height'); ylabel('Height (km)')
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
    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_h',num2str(h_int)];
    if cloudid~=0
     outfile=[outdir,'/',fignam,'cld',mon,datec,hrc,minc,'_d',dom,'_',mon,s_date,'_',s_hr,s_min,...
         '_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_h',num2str(h_int)];
    end
%     print(hf,'-dpng',[outfile,'.png'])    
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %}
  end
end

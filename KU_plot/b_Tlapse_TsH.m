% close all
clear;   ccc=':';

%---setting
expri='TWIN020B';  
stday=22;   sth=15;     lenh=16;  minu=[00 30];   h_int=100; tint=2;
xp=50;  yp=100;  % plot point
%
cloudid=1;  
%---
year='2018'; mon='06'; infilenam='wrfout';  dom='01'; 
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='Temperature lapse rate';   fignam=[expri,'_Tlapse_Ts_'];

%---
load('colormap/colormap_parula20.mat'); cmap=colormap_parula20;
cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-2 -1 0 1 2 4 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 10.5 11];
%---
Rcp=287.43/1005; %Rsd=287.43; cpd=1005;
% epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
g=9.81; zgi=10:h_int:4000;    ytick=500:1000:zgi(end); 
nminu=length(minu);  ntime=lenh*nminu;
%
nti=0; ntii=0; ss_hr=cell(length(tint:tint:lenh),1);
for ti=1:lenh 
  hr=sth+ti-1;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  if mod(ti,tint)==0 
    ntii=ntii+1;  ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
  end   
  for mi=minu 
    nti=nti+1;
    s_min=num2str(mi,'%2.2d');       
    %--- filename---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    t = ncread(infile,'T');   t=t+300;   
%     qv = ncread(infile,'QVAPOR');  qv=double(qv);   
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB'); 
    p = ncread(infile,'P');   pb = ncread(infile,'PB');     P=p+pb;
    hgt = ncread(infile,'HGT');       
    %----   
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;      
    T=t.*(1e5./P).^(-Rcp); %temperature
    [nx, ny, nz]=size(t);    
    %---LCL---
%     hP=P/100; %pressure in hap
%     ev=qv./epsilon.*hP;   %partial pressure of water vapor
%     Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor 
%     Zlcl=( zg(:,:,1)*1e-3+(T(:,:,1)-Td(:,:,1))/8 )*1e3;    
 
%---interpoltion---
    X=squeeze(zg(xp,yp,:));   Y=squeeze(T(xp,yp,:));  
    tp=interp1(X,Y,zgi,'linear');      
    plotvar(:,nti)=(tp(1:end-1)-tp(2:end))/h_int*1000;
    
 %---
    if cloudid~=0
    qr = ncread(infile,'QRAIN');  qr=double(qr);   
    qs = ncread(infile,'QSNOW');  qs=double(qs);    
    qg = ncread(infile,'QGRAUP'); qg=double(qg);
    qi = ncread(infile,'QICE');   qi=double(qi);
    qc = ncread(infile,'QCLOUD'); qc=double(qc);
    hyd=qr+qs+qg+qi+qc; 
    
    Y=squeeze(hyd(xp,yp,:));  
    hyd2=interp1(X,Y,zgi,'linear');         
    hyd_all(:,nti)=hyd2*1e3;
    end
%--- 
    w = ncread(infile,'W');  wmax(nti)=max(w(xp,yp,:));     
    
  end
end
 %%  
%---plot---       
zgi2 = (zgi(1:end-1)+zgi(2:end))/2;
[xi, zi]=meshgrid(1:nti,zgi2); 
pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
%
hf=figure('position',[100 200 900 600]);
[c, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none');   
%---
%     if (max(max(hgtprof))~=0)
%      hold on;      plot(hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
%     end
if cloudid~=0
  [xi2, zi2]=meshgrid(1:nti,zgi); 
  hold on;   contour(xi2,zi2,hyd_all,[0.01 0.1 0.5],'color',[0.5 0.02 0.1],'LineWidth',1.5)
end
    
set(gca,'fontsize',16,'LineWidth',1.2)
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
% set(gca,'XLim',[1 lenh*length(minu)],'XTick',length(minu)*(tint-1)+1 : tint*length(minu) : lenh*length(minu),'XTickLabel',ss_hr)
set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'Ylim',[10 4000])
xlabel('Local time'); ylabel('Height (km)')
tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)  

%---colorbar---
fi=find(L>pmin,1);
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
hc=colorbar('YTick',L1(1:2:end),'YTickLabel',L(1:2:end),'fontsize',13,'LineWidth',1.2);
colormap(cmap); title(hc,'K/km','fontsize',13);  drawnow;
hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
for idx = 1 : numel(hFills)
  hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
end
%---

% yyaxis right
% plot(wmax,'color','k','linewidth',1.8)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min',...
    '_x',num2str(xp),'y',num2str(yp),'_h',num2str(h_int)];
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);

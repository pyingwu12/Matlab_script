%----------------------------------------------------
% Time-height cross section of averaged error over a specific sub-domain (decided by <xsub> and <ysub>)
%                                                             ^^^^^^^^^^^
% One experiments; x-axis: time; y-axis: Height
% PY WU @2021/06/22
%----------------------------------------------------
close all;
clear; ccc=':';
saveid=1;

%---setting 
% expri='TWIN201';  xsub=151:300;  ysub=51:200;   stday=23;  sth=0;  stmin=50;
% expri='TWIN013';     xsub=1:150;  ysub=51:200;  stday=22;  sth=23;  stmin=30;
% expri='TWIN021';     xsub=1:150;  ysub=51:200;  stday=22;  sth=23;  stmin=00;
%%% expri='TWIN020';     xsub=1:150;  ysub=51:200;  stday=22;  sth=22;  stmin=50;
% expri='TWIN003';     xsub=1:150;  ysub=51:200;  stday=22;  sth=22;  stmin=50;
% expri='TWIN017';     xsub=1:150;  ysub=51:200;  stday=22;  sth=23;  stmin=10;

     % for plain area
     % expri='TWIN003';     xsub=151:300;  ysub=51:200;   stday=23;  sth=0;  stmin=50; 

% expri='TWIN042';     xsub=151:300;  ysub=151:300;  stday=23;  sth=0;  stmin=00;
% expri='TWIN043';     xsub=1:150;  ysub=76:225;  stday=22;  sth=22;  stmin=30;

% expri='TWIN040';     xsub=1:150;  ysub=76:225;  stday=22;  sth=22;  stmin=30;

% expri='TWIN030';     xsub=1:150;  ysub=1:150;  stday=23;  sth=0;  stmin=20;
expri='TWIN031';     xsub=1:150;  ysub=76:225;  stday=22;  sth=22;  stmin=30;

expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];
% expri1=[expri,'Pr0025THM062221'];  expri2=[expri,'B'];


% stday=22;  sth=22;  stmin=50;
mint=10; lenm=160;  tint=2; 
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/JAS_R2'];
% outdir=['/mnt/e/figures/expri_twin/',expri];
fignam=[expri1,'_DTE_TsH_'];  titnam=[expri,'  time-height']; 
%
ntime=fix(lenm/mint)+1;
g=9.81;    nx=length(xsub); ny=length(ysub);

zlimt=15000;
%%
%{
%---
nti=0;  ntii=0;
for mi=stmin:mint:stmin+lenm
  nti=nti+1;   
  hr=sth+fix(mi/60);
  s_min=num2str(mod(mi,60),'%2.2d');  s_hr=num2str(mod(hr,24),'%2.2d');  s_date=num2str(stday+fix(hr/24),'%2.2d');     
  if mod(nti,tint)==0
   ntii=ntii+1;   s_hrj=num2str(mod(hr+9,24),'%2.2d');   ss_hr{ntii}=[s_hrj,s_min];
  end  
  %---infile 1---
  infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
   qr1 = double(ncread(infile1,'QRAIN'));   
   qc1 = double(ncread(infile1,'QCLOUD'));
   qg1 = double(ncread(infile1,'QGRAUP'));  
   qs1 = double(ncread(infile1,'QSNOW'));
   qi1 = double(ncread(infile1,'QICE'));      
   hyd1=qr1+qc1+qg1+qs1+qi1;
   w1 = double(ncread(infile1,'W'));    
  %---infile 2---
  infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
   qr2 = double(ncread(infile2,'QRAIN'));   
   qc2 = double(ncread(infile2,'QCLOUD'));
   qg2 = double(ncread(infile2,'QGRAUP'));  
   qs2 = double(ncread(infile2,'QSNOW'));
   qi2 = double(ncread(infile2,'QICE'));     
   hyd2=qr2+qc2+qg2+qs2+qi2;
   w2 = double(ncread(infile2,'W')); 
   theta2 = ncread(infile2,'T');  theta2=theta2+300;
  %---
  [DTE, ~]=cal_DTEterms(infile1,infile2);      
  
  %---heights to interpolate
  ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');  PH0=(phb+ph);  zg0=PH0/g; 
  PH=( PH0(:,:,1:end-1)+PH0(:,:,2:end) ).*0.5;   zg=PH/g; 
  zg_1D=squeeze(zg0(150,150,:));     
  if nti==1
     nz=length(zg_1D); 
     zgi0(1:2:nz*2-1,1)= zg_1D;   
     zgi0(2:2:nz*2-1,1)= (zg_1D(1:end-1) + zg_1D(2:end) )/2;   
     zgi=zgi0(zgi0<zlimt);  
     nzgi=length(zgi); 
  end     
  %----interpolation
  hyd_sub1=zeros(nx,ny,nzgi);  hyd_sub2=zeros(nx,ny,nzgi);    w_sub2=zeros(nx,ny,nzgi);  theta_iso=zeros(nx,ny,nzgi);
  KE3D_sub=zeros(nx,ny,nzgi);    SH_sub=zeros(nx,ny,nzgi);     LH_sub=zeros(nx,ny,nzgi);  
  %
  ni=0;
  for i=xsub
    ni=ni+1;
    nj=0;
    for j=ysub      
      nj=nj+1;
      hyd_sub1(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(hyd1(i,j,:)),zgi,'linear');
%       w_sub1(ni,nj,:)=interp1(squeeze(zg0(i,j,:)),squeeze(w1(i,j,:)),zgi,'linear');         
      hyd_sub2(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(hyd2(i,j,:)),zgi,'linear');         
      w_sub2(ni,nj,:)=interp1(squeeze(zg0(i,j,:)),squeeze(w2(i,j,:)),zgi,'linear');
      %
      KE3D_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(DTE.KE3D(i,j,:)),zgi,'linear');
      SH_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(DTE.SH(i,j,:)),zgi,'linear');
      LH_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(DTE.LH(i,j,:)),zgi,'linear');
      %  
      theta_iso(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(theta2(i,j,:)),zgi,'linear');
    end
  end         

  %--variables of the control simulation
  hyd2_m(:,nti)= max(hyd_sub2,[],[1 2]); 
  w_m(:,nti)= max(w_sub2,[],[1 2],'omitnan');
  theta_hm=mean(theta_iso,[1, 2],'omitnan');
  theta_ano=theta_iso-repmat(theta_hm,size(theta_iso,1),size(theta_iso,2),1);    
  theta_ano_max(:,nti)=max(theta_ano,[],[1 2]);
    
  %---mean of errors---
  KE3D_m(:,nti)=mean(KE3D_sub,[1 2],'omitnan');
  SH_m(:,nti)=mean(SH_sub,[1 2],'omitnan');
  LH_m(:,nti)=mean(LH_sub,[1 2],'omitnan');   
%  rmsd_hyd(:,nti)=(mean(  (hyd_sub1-hyd_sub2).^2,[1 2] ,'omitnan' )).^0.5;
     
  disp([s_hr,s_min,' done'])
end %mi    
[xi, zi]=meshgrid(1:ntime,zgi);
CMDTE_m=LH_m+KE3D_m+SH_m;

%}

s_sth=num2str(sth,'%2.2d');
load(['matfile/',expri,'_',mon,num2str(stday),s_sth,num2str(stmin,'%2.2d'),'_',num2str(lenm),'m_'...
    ,'x',num2str(xsub(1)),num2str(xsub(end)),'y',num2str(ysub(1)),num2str(ysub(end)),'.mat'])
%%
%---plot settings
load('colormap/colormap_ncl.mat')
cmap=colormap_ncl(15:11:95,:); %cmap(1,:)=[1 1 1];
% cmap2=cmap*255;  cmap2(:,4)= (zeros(1,size(cmap2,1))+255)*0.5;

% ----------------------------
L=10.^[-3 -2.5 -2 -1.5 -1 -0.5 0];
%contours---

%
% ytick=1000:2000:zgi(end);
ytick=1000:2000:zi(end,1);
%
plotvar=CMDTE_m;
pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
%
% close all
%-------plot--------------------------
 hf=figure('position',[80 350 1100 600]);
[~, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none');   hold on
% contour(xi,zgi,qc_m*1e3,[0.1 0.1],'color',[0.1 0.1 0.1],'linewidth',2,'linestyle','--');

LSpac=600; Lfs=25; linw=2.4;

%---hydrometeors
[c,hdis]=contour(xi,zi,hyd2_m*1e3,[0.1 0.1],'linewidth',linw+1.5,'color',[0.2 0.2 0.2],'linestyle','-');
   clabel(c,hdis,[0.1 5 6 7 8 10],'fontsize',Lfs,'color',[0.2 0.2 0.2],'LabelSpacing',300)   
[c,hdis]=contour(xi,zi,hyd2_m*1e3,[7 7],'linewidth',linw+1.2,'color',[0 0 0],'linestyle','-');
   clabel(c,hdis,[0.1 5 6 7 8 10],'fontsize',Lfs,'color',[0 0 0],'LabelSpacing',250)   

%---horizontal max of theta'---
 thecol=[1 0.8 0.1]; 
[c,hdis]=contour(xi,zi,theta_ano_max,[1 1],'color',thecol,'linewidth',linw+0.8,'linestyle','-'); 
clabel(c,hdis,[0.5 1 2 2.5 3 3.5 4 ],'fontsize',Lfs,'color',thecol,'LabelSpacing',250)   
% thecol2=thecol-[0.1 0.1 0.1]; thecol2(thecol2<0)=0;
 thecol2=[0.97 0.9 0]; 
[c,hdis]=contour(xi,zi,theta_ano_max,[4 4],'color',thecol2,'linewidth',linw+0.1,'linestyle','-'); 
clabel(c,hdis,[0.5 1 2 2.5 3 3.5 4 ],'fontsize',Lfs,'color',thecol2,'LabelSpacing',200) 


%---horizontal max updraft of cntl simulation
wcol=[0.9 0.1 0.4];
% wcol=[0.95 0.1 0];
[c,hdis]=contour(xi,zi,w_m,[1.5 1.5],'color',wcol,'linewidth',linw+0.5,'linestyle','-'); 
clabel(c,hdis,[1 1.5 2 5 6 7 10 11 12 13 14 15],'fontsize',Lfs,'color',wcol,'LabelSpacing',300)   
wcol2=[1 0 0.25];
[c,hdis]=contour(xi,zi,w_m,[15 15],'color',wcol2,'linewidth',linw+0.2,'linestyle','-'); 
clabel(c,hdis,[1 1.5 2 5 6 7 10 11 12 13 14 15],'fontsize',Lfs,'color',wcol2,'LabelSpacing',300)   

  

% LSpac=500; Lfs=15;
% %---root mean square difference of hydrometeor---
% [c,hdis]=contour(xi,zi,rmsd_hyd*1e3,[0.01 0.1],'color',dhydcol,'linewidth',3); 
% clabel(c,hdis,[0.01 0.1],'fontsize',Lfs,'color',dhydcol,'LabelSpacing',LSpac)   

set(gca,'fontsize',18,'LineWidth',1.2)
set(gca,'Ylim',[0 zlimt-1000],'Ytick',ytick,'Yticklabel',ytick./1000)
set(gca,'Xlim',[1 ntime],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)
xlabel('Local time'); ylabel('Height (km)')
title(titnam,'Interpreter','none')


colormap(cmap); 
brighten(0.2)
bri_cmap=colormap;
cmap2=bri_cmap*255;  cmap2(:,4)= (zeros(1,size(cmap2,1))+255)*0.5;

%---colorbar---
Ltick={'10^-^3'; '10^-^2^.^5'; '10^-^2';'10^-^1^.^5';'10^-^1';'10^-^0^.^5';'10^0';};
fi=find(L>0);
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
% hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',16,'LineWidth',1.2);
hc=colorbar('YTick',L1,'YTickLabel',Ltick,'fontsize',16,'LineWidth',1.2);
title(hc,'J kg^-^1','fontsize',16);  drawnow;
hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
for idx = 1 : numel(hFills)
  hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
end  
%
%---
s_sth=num2str(sth,'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(stday),s_sth,num2str(stmin,'%2.2d'),'_',num2str(lenm)...
    ,'m_x',num2str(xsub(1)),num2str(xsub(end)),'y',num2str(ysub(1)),num2str(ysub(end))];
if saveid~=0
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
%%
% save(['matfile/',expri,'_',mon,num2str(stday),s_sth,num2str(stmin,'%2.2d'),'_',num2str(lenm),'m_'...
%     ,'x',num2str(xsub(1)),num2str(xsub(end)),'y',num2str(ysub(1)),num2str(ysub(end)),'.mat'],...
%     'CMDTE_m','xi','zi','hyd2_m','w_m','theta_ano_max','ss_hr')

%---check vertical velocity---
%{
ytick=1000:2000:zgi(end);
xi=repmat(1:ntime,size(zgi,1),1);
figure('position',[80 350 1200 400]);
[~, hp]=contourf(xi,zgi,w_m,30,'linestyle','none');   hold on
colorbar
caxis([0 7])
hold on
[c,hdis]=contour(xi,zgi,w_m,[0.3 1 10],'color',[0.9 0.1 0.1],'linewidth',2,'linestyle','--'); 
set(gca,'fontsize',16,'LineWidth',1.2)
set(gca,'Ylim',[0 5000],'Ytick',ytick,'Yticklabel',ytick./1000)
set(gca,'Xlim',[1 ntime],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)
%}
%%
% plot DTEterms seperately
%{
KE3D_m(1:2,:)=NaN;
SH_m(1:2,:)=NaN;
LH_m(1:2,:)=NaN;
% theta_ano_max(1:20,:)=NaN;
%---colormap of cloud---
cmap=[1 1 1; 0.95 0.95 0.95; .9 .9 .9; 0.85 0.85 0.85; 0.8 0.8 0.8; 0.75 0.75 0.75; 0.65 0.65 0.65];
cmap2=cmap*255;  cmap2(:,4)= (zeros(1,size(cmap2,1))+255)*0.5;
L=[0.1 1 5 10 15 20];
%---settings of contours---
LHcol=[0.7 0.2 0.8]; KEcol=[0.3 0.75 0.94]; SHcol=[0.9 0.65 0.1];  %KEcol=[0.1 0.2 0.9];
dhydcol=[0.3 0.3 0.3]; wcol=[0.9 0.1 0.1]; thecol=[0.1 0.5 0.1];
DTElw=4;
%
ytick=1000:2000:zgi(end);
%
% xi=repmat(1:ntime,size(zgi,1),1);
[xi, zi]=meshgrid(1:ntime,zgi);
%
plotvar=hyd2_m*1e3;
pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end

%-------plot--------------------------
 hf=figure('position',[80 350 1100 600]);
[~, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none');   hold on
% contour(xi,zgi,qc_m*1e3,[0.1 0.1],'color',[0.1 0.1 0.1],'linewidth',2,'linestyle','--');


LSpac=500; Lfs=15;
%---root mean square difference of hydrometeor---
[c,hdis]=contour(xi,zi,rmsd_hyd*1e3,[0.01 0.1],'color',dhydcol,'linewidth',3,'linestyle','-'); 
clabel(c,hdis,[0.01 0.1],'fontsize',Lfs,'color',dhydcol,'LabelSpacing',LSpac)   

%---horizontal mean errors---
CMDTE_m=LH_m+KE3D_m+SH_m;
ctr_int=[0.005  0.5];
[c,hdis]=contour(xi,zi,CMDTE_m,ctr_int,'color',LHcol,'linewidth',DTElw,'linestyle','-'); 
clabel(c,hdis,ctr_int,'fontsize',Lfs,'color',LHcol,'LabelSpacing',LSpac) 

% [c,hdis]=contour(xi,zi,LH_m,ctr_int,'color',LHcol,'linewidth',DTElw,'linestyle','-'); 
% clabel(c,hdis,ctr_int,'fontsize',Lfs,'color',LHcol,'LabelSpacing',LSpac)   
% [c,hdis]=contour(xi,zi,KE3D_m,ctr_int,'color',KEcol,'linewidth',DTElw,'linestyle','-'); 
% clabel(c,hdis,ctr_int,'fontsize',Lfs,'color',KEcol,'LabelSpacing',LSpac)  
% [c,hdis]=contour(xi,zi,SH_m,ctr_int,'color',SHcol,'linewidth',DTElw,'linestyle','-'); 
% clabel(c,hdis,ctr_int,'fontsize',Lfs,'color',SHcol,'LabelSpacing',LSpac)   

%---horizontal max updraft of cntl simulation
[c,hdis]=contour(xi,zi,w_m,[2 10],'color',wcol,'linewidth',2.5,'linestyle','--'); 
clabel(c,hdis,[2 10],'fontsize',Lfs,'color',wcol,'LabelSpacing',LSpac)   

%---horizontal max of theta'---
[c,hdis]=contour(xi,zi,theta_ano_max,[1.5 1.5],'color',thecol,'linewidth',2.5,'linestyle','--'); 
clabel(c,hdis,[1 5],'fontsize',Lfs,'color',thecol,'LabelSpacing',LSpac)   

set(gca,'fontsize',16,'LineWidth',1.2)
set(gca,'Ylim',[0 zlimt],'Ytick',ytick,'Yticklabel',ytick./1000)
set(gca,'Xlim',[1 ntime],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)
% set(gca,'Xlim',[3 ntime-3],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)

xlabel('Local time'); ylabel('Height (km)')
title(titnam,'Interpreter','none')

%---colorbar---
fi=find(L>0);
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
colormap(cmap); title(hc,'g/kg','fontsize',14);  drawnow;
hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
for idx = 1 : numel(hFills)
  hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
end  
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
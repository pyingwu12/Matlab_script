%------------------------------------------
% plot vertical weighted average MDTE or CMDTE between two simulations
%------------------------------------------
% close all
clear;   ccc=':';
%---
plotid='CMDTE';  %optioni: MDTE or CMDTE
expri='TWIN001'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='23';  hr=3;  minu=[50];  
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin/';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam=plotid;   fignam=[expri1(8:end),'_',plotid,'_',];
%---
col=load('colormap/colormap_dte.mat');
cmap=col.colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
  L=[0.5 2 4 6 10 15 20 30 40 60];
%  L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
%---pamaters---
cp=1004.9;
R=287.04;
Lv=(2.4418+2.43)/2 * 10^6 ;
Tr=270;
Pr=1000;
g=9.81;
%---
xsub=1:300; ysub=1:300;

% xsub=100:200; ysub=100:200;


%---
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile2,'HGT');
 
%---infile 1---
 u.stag = ncread(infile1,'U');   v.stag = ncread(infile1,'V');   w.stag = ncread(infile1,'W');
 u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
 v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
 w.f1=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5; 
 p=ncread(infile1,'P');  pb = ncread(infile1,'PB');  P.f1 = (pb+p)/100;
 th.f1=ncread(infile1,'T')+300; 
 t.f1=th.f1.*(1e3./P.f1).^(-R/cp);
 qv.f1=double(ncread(infile1,'QVAPOR'));
 ps.f1 = ncread(infile1,'PSFC')/100;  
 PH0 = ncread(infile1,'PH')+ncread(infile1,'PHB');
 PH=( PH0(:,:,1:end-1)+PH0(:,:,2:end) ).*0.5;   zg.f1=PH/g; 
 
%---infile 2---
 u.stag = ncread(infile2,'U');   v.stag = ncread(infile2,'V');   w.stag = ncread(infile2,'W');
 u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
 v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
 w.f2=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5; 
 p=ncread(infile2,'P');  pb = ncread(infile2,'PB');  P.f2 = (pb+p)/100; 
 th.f2=ncread(infile2,'T')+300;  
 t.f2=th.f2.*(1e3./P.f2).^(-R/cp);
 qv.f2=double(ncread(infile2,'QVAPOR')); 
 ps.f2 = ncread(infile2,'PSFC')/100; 
  PH0 = ncread(infile2,'PH')+ncread(infile2,'PHB');
 PH=( PH0(:,:,1:end-1)+PH0(:,:,2:end) ).*0.5;   zg.f2=PH/g; 
 
 zg0=PH0/g;  
 zgi=squeeze(zg0(150,150,2:end-1));     
 
    ni=0;
    for i=xsub
      ni=ni+1;
      nj=0;
      for j=ysub      
         nj=nj+1;
         u.iso1(ni,nj,:)=interp1(squeeze(zg.f1(i,j,:)),squeeze(u.f1(i,j,:)),zgi,'linear');
         u.iso2(ni,nj,:)=interp1(squeeze(zg.f2(i,j,:)),squeeze(u.f2(i,j,:)),zgi,'linear');         
         v.iso1(ni,nj,:)=interp1(squeeze(zg.f1(i,j,:)),squeeze(v.f1(i,j,:)),zgi,'linear');
         v.iso2(ni,nj,:)=interp1(squeeze(zg.f2(i,j,:)),squeeze(v.f2(i,j,:)),zgi,'linear');         
         w.iso1(ni,nj,:)=interp1(squeeze(zg.f1(i,j,:)),squeeze(w.f1(i,j,:)),zgi,'linear');
         w.iso2(ni,nj,:)=interp1(squeeze(zg.f2(i,j,:)),squeeze(w.f2(i,j,:)),zgi,'linear');         
         t.iso1(ni,nj,:)=interp1(squeeze(zg.f1(i,j,:)),squeeze(t.f1(i,j,:)),zgi,'linear');
         t.iso2(ni,nj,:)=interp1(squeeze(zg.f2(i,j,:)),squeeze(t.f2(i,j,:)),zgi,'linear');
         qv.iso1(ni,nj,:)=interp1(squeeze(zg.f1(i,j,:)),squeeze(qv.f1(i,j,:)),zgi,'linear');
         qv.iso2(ni,nj,:)=interp1(squeeze(zg.f2(i,j,:)),squeeze(qv.f2(i,j,:)),zgi,'linear');         
         P.iso2(ni,nj,:)=interp1(squeeze(zg.f1(i,j,:)),squeeze(P.f2(i,j,:)),zgi,'linear');         
      end
    end        
 
%---calculate different
 u.diff=u.iso1-u.iso2; 
 v.diff=v.iso1-v.iso2;
 w.diff=w.iso1-w.iso2;
 t.diff=t.iso1-t.iso2;
 qv.diff=qv.iso1-qv.iso2;
 ps.diff=ps.f1-ps.f2; 
 
%---moist Different Total Energy----
DTE.KE3D = 1/2 * ( u.diff.^2 + v.diff.^2 + w.diff.^2);
DTE.SH = 1/2 *  cp/Tr*t.diff.^2 ;
DTE.LH = 1/2 * Lv^2/cp/Tr*qv.diff.^2 ;
DTE.Ps = 1/2 * R*Tr*(ps.diff/Pr).^2 ;

%---vertical mass weighted average (Selz and Craig 2015)--- 
 dP = P.iso2(:,:,2:end)-P.iso2(:,:,1:end-1);
 dPall = P.iso2(:,:,end)-P.iso2(:,:,1);
 dPm = dP./repmat(dPall,1,1,size(dP,3));
 %
 CMDTE = DTE.KE3D + DTE.SH + DTE.LH;
 CMDTE_2D = sum(dPm.*CMDTE(:,:,1:end-1),3,'omitnan') + DTE.Ps(xsub,ysub);
%===================
    [~, CMDTE_grid] = cal_DTE_2D(infile1,infile2) ;
%===================
%%
    %---plot---
%     eval([' plotvar=',plotid,'_2D''; '])    
    plotvar=CMDTE_grid';
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 75 800 700]); 
    [~, hp]=contourf(plotvar,L2,'linestyle','none');    
    %---
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.45 0.45 0.45],'linestyle','--','linewidth',2.5); 
    end
    %---
    set(gca,'fontsize',18,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    %---
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % JST time string
      if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); title(hc,'J kg^-^1','fontsize',14);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---    
%     outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
%       print(hf,'-dpng',[outfile,'.png']) 
%       system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
  end %tmi
end

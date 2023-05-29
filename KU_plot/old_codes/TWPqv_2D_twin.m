% close all
clear; ccc=':';
%---setting
expri='TWIN003';
expri1=[expri,'B'];  expri2=[expri,'Pr001qv062221'];  

s_date='23'; hr=2; minu=[00]; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir='/mnt/HDD008/pwin/Experiments/expri_twin'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%---
titnam='PW';   fignam=[expri2(8:end),'_TPWqvcontr_'];
%
load('colormap/colormap_qr3.mat')
cmap=colormap_qr3; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[65.5 66 66.5 67 67.5 68 69 70 71 72];
% L=[50 55 60 65 67  68 69 70 71 72];
%---

for ti=hr
  for mi=minu    
    %---set filename---
    s_hr=num2str(ti,'%2.2d');   s_min=num2str(mi,'%2.2d');
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    qv = ncread(infile1,'QVAPOR');qv=double(qv);
    p = ncread(infile1,'P');p=double(p);
    pb = ncread(infile1,'PB');pb=double(pb);  
    hgt = ncread(infile1,'HGT');
    %---
    [nz]=size(qv,3);
    P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
    tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
    TPW1=squeeze(sum(tpw,3)./9.81);
    %---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    qv = ncread(infile2,'QVAPOR');qv=double(qv);
    p = ncread(infile2,'P');p=double(p);
    pb = ncread(infile2,'PB');pb=double(pb);  
    %---
    P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
    tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
    TPW2=squeeze(sum(tpw,3)./9.81);
%%
    %---plot---
    plotvar=TPW1';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 45 800 680]);  
%     [c, hp]=contourf(plotvar,L2,'linestyle','none');
    contour(TPW1',[68 68],'color','k','linestyle','-','linewidth',1.8)
%     [c, hp]=contourf(plotvar,20,'linestyle','none');    colorbar
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    %
    hold on
    contour(TPW2',[68 69],'color','r','linestyle','-','linewidth',1.8)
    %tick=100:200:900;
    set(gca,'fontsize',16,'LineWidth',1.2) 
%     set(gca,'Xtick',tick,'Xticklabel',tick*grids,'Ytick',tick,'Yticklabel',tick*grids)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={expri2,[titnam,'  ',s_hr,s_min,' UTC']}; 
    title(tit,'fontsize',18)

    %---colorbar---
%     fi=find(L>pmin);
%     L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
%     hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
%     colormap(cmap); title(hc,'Kg/m^2','fontsize',13);  drawnow;
%     hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
%     for idx = 1 : numel(hFills)
%       hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
%     end
    %---
   
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   
  end
end

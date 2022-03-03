%------------------------------------------
% calculate different total engergy of two experiments
%------------------------------------------
% close all
clear;  ccc=':';
%---
expri='TWIN001';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='23';  hr=15;  minu=[00];  
year='2018'; mon='06';  
dirmem='pert'; infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin/';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='relative DTE (vertical average)';   fignam=[expri1(8:end),'_reDTE_',];
%
load('colormap/colormap_dte.mat')
cmap=colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.005 0.01 0.05 0.1 0.5 1 2 3 4 5];
%  L=[0.5 2 4 6 8 10 15 20 25 30];
%
cp=1004.9;
Tr=270;
%
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V');
    u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
    t.f1=ncread(infile1,'T')+300; 
    p =ncread(infile1,'P');  pb = ncread(infile1,'PB');
    P = (pb+p);    dP = P(:,:,2:end)-P(:,:,1:end-1);
    dPall = P(:,:,end)-P(:,:,1);
    dPm = dP./repmat(dPall,1,1,size(dP,3));
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V');
    u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
    t.f2=ncread(infile2,'T')+300; 
    hgt = ncread(infile2,'HGT');
    %
    %---calculate different
    u.diff=u.f1-u.f2; 
    v.diff=v.f1-v.f2;
    t.diff=t.f1-t.f2;    
    %---
    TE = 1/2*(u.f2.^2 + v.f2.^2 + cp/Tr*t.f2.^2);
    vmTE = sum(dPm.*TE(:,:,1:end-1),3) ;
    
    DTE = 1/2*(u.diff.^2 + v.diff.^2 + cp/Tr*t.diff.^2);
    vmDTE = sum(dPm.*DTE(:,:,1:end-1),3) ; 
    
    reMDTE=vmDTE./vmTE * 100 * 10^2;
    %MDTE = sum(dPm.*reDTE(:,:,1:end-1),3) ;  % vertical weighted average (dPm=dP/dPall)
  
    %---plot---
    plotvar=reMDTE';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 45 800 680]);  
    [c, hp]=contourf(plotvar,L2,'linestyle','none');    
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    %
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    %s_hrj=num2str(mod(ti+9,24),'%2.2d'); 
    tit={[expri1,'  ',s_hr,s_min,' UTC'],titnam};     
    title(tit,'fontsize',18)
      
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2); 
    title(hc,'10^-^2 %')
    colormap(cmap);     drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
  end %tmi
end

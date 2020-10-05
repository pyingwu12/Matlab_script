close all
clear; ccc=':';
%---setting
expri='TWIN003';
expri1=[expri,'Pr001qv062221'];   expri2=[expri,'B'];  
s_date='23';   hr=6;   minu=[00]; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/']; outdir=['/mnt/e/figures/expri191009/',expri1];
indir='/mnt/HDD008/pwin/Experiments/expri_twin/'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%---
titnam='PW difference';   fignam=[expri1(8:end),'_TPWqv-diff_',];
%
load('colormap/colormap_br3.mat')
cmap=colormap_br3(2:14,:);  cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-11 -9 -7 -5 -3 -1 1 3 5 7 9 11];
% L=[-7 -5 -3 -1 -0.5 -0.1 0.1 0.5 1 3 5 7]*0.1;
%---
%
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %------infile 1--------
    infile=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
    qv = ncread(infile,'QVAPOR');qv=double(qv); 
    p = ncread(infile,'P');p=double(p);   pb = ncread(infile,'PB');pb=double(pb);  
    hgt = ncread(infile,'HGT');
    %---
    [nz]=size(qv,3);
    P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
    tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
    TPW1=squeeze(sum(tpw,3)./9.81);
    %
    %------infile 2--------
    infile=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
    qv = ncread(infile,'QVAPOR');qv=double(qv); 
    p = ncread(infile,'P');p=double(p);   pb = ncread(infile,'PB');pb=double(pb);  
    %---
    P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
    tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
    TPW2=squeeze(sum(tpw,3)./9.81);
    %---
    diff_qv=TPW1-TPW2;
    %%
    %---plot---
    plotvar=diff_qv';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %---    
    hf=figure('position',[100 45 800 680]);
    [c, hp]=contourf(plotvar,L2,'linestyle','none');
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    %
    set(gca,'fontsize',16,'LineWidth',1.2) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={[expri1];[titnam,'  ',s_hr,s_min,' UTC']}; 
    title(tit,'fontsize',18)
    
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap); title(hc,'Kg/m^2','fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %--- 

   outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
   print(hf,'-dpng',[outfile,'.png']) 
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
end


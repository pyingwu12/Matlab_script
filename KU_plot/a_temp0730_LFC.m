%------------------------------------------
% plot horizontal distribution of variables
%------------------------------------------
% close all
clear;   ccc=':';
saveid=1; % save figure (1) or not (0)
%---
expri='TWIN003B'; 
s_date='22';  hr=22;  minu=30;  
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];
outdir='/mnt/e/figures/expri_twin/temp0730';
LFC_indir=['/mnt/HDDA/Python_script/LFC_data/',expri];
%
titnam='LFC & 10-m wind';   fignam=[expri,'_LFC_',];   tit_unit='m';
%---
cmap0=bone(10);cmap=cmap0(3:end,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[500 600 700 800 900 1000 1100];
%---
int=15;  qscale=3;

%---
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile,'HGT');
    u10 = ncread(infile,'U10');
    v10 = ncread(infile,'V10');
    %
    LFC_infile=[LFC_indir,'_',mon,s_date,'_',s_hr,s_min,'_LFC.npy'];
    LFC=readNPY(LFC_infile)+hgt';
 
    [nx, ny, ~]=size(u10);
    uplot=u10(1:int:end,1:int:end);   vplot=v10(1:int:end,1:int:end);
    [xi, yi]=meshgrid(1:int:nx, 1:int:ny);

    qv = ncread(infile,'QVAPOR');
    qv2d=sum(qv,3);

    %---plot---  
    plotvar=LFC;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 75 800 700]); 
    [~, hp]=contourf(plotvar,L2,'linestyle','none');  
    hold on    
    
    h1 = quiver(xi,yi,uplot',vplot',0,'color',[0.1 0.1 0.6]) ; % the '0' turns off auto-scaling
    hU = get(h1,'UData');   hV = get(h1,'VData') ;
    set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',2);   
    
    h1 = quiver(25,275,5,0,0,'color',[0.9 0.1 0]) ;
    hU = get(h1,'UData');   hV = get(h1,'VData') ;
    set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',2); 
    text(45,275,'5 m/s','fontsize',15,'color',[0.9 0.1 0])
    
    %---
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[ 0.466,0.874,0.188],'linestyle','--','linewidth',3.5); 
    end

    contour(plotvar,[max(hgt(:)) max(hgt(:))],'color',[0.01 0.1 0.1],'linewidth',2.8)
    
%     contour(qv2d',10,'color',[1 0 0],'linewidth',2)

    
    %---
    set(gca,'fontsize',18,'LineWidth',1.2)
    set(gca,'Xlim',[1 nx],'Ylim',[1 ny])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    %---
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % JST time string
      if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); title(hc,tit_unit,'fontsize',15);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    if saveid==1
      print(hf,'-dpng',[outfile,'.png']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
    end
  end %tmi
end

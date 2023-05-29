%------------------------------------------
% plot horizontal distribution of variables
%------------------------------------------
% close all
clear;   ccc=':';
saveid=0; % save figure (1) or not (0)
%---
expri='TWIN031B'; 
day=22;  hr=21;  minu=30;   lev=3;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='non-dimensional mountain height';   fignam=[expri,'_M_',];
tit_unit=' ';
%---
load('colormap/colormap_qr3.mat');
cmap=colormap_qr3; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.1 0.5 1 3 5 10 15 20 25 30];

g=9.81;

%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile,'HGT');
    %
    theta = ncread(infile,'T');  theta=theta+300;
    phb = ncread(infile,'PHB');  ph = ncread(infile,'PH');  
    PH0=double(phb+ph);  PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;       
    u.stag = ncread(infile,'U');
    v.stag = ncread(infile,'V');
    %----   
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
    wind_spd= (u.unstag.^2 + v.unstag.^2).^0.5;
    %----   

    theta_bar=mean(theta(:,:,1:lev),3);
    N= ( g./theta_bar .* (theta(:,:,lev)-theta(:,:,1))./(zg(:,:,lev)-zg(:,:,1)) .^0.5);
    
    U_bar=mean(wind_spd(:,:,1:lev),3);
    
    M=N.*max(hgt(:))./U_bar;
    
    %
    %---plot---  
    plotvar=M'; plotvar(plotvar>1)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 75 800 700]); 
    [~, hp]=contourf(plotvar,10,'linestyle','none');   
    colorbar
    %---
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.45 0.45 0.45],'linestyle','--','linewidth',2.5); 
    end
    %---
    caxis([min(plotvar(:)) 1])
    set(gca,'fontsize',18,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    %---
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % JST time string
      if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---colorbar---
%     fi=find(L>pmin,1);
%     L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
%     hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
%     colormap(cmap);  title(hc,tit_unit,'fontsize',14);  drawnow;
%     hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
%     for idx = 1 : numel(hFills)
%       hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
%     end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    if saveid==1
      print(hf,'-dpng',[outfile,'.png']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
    end
    %}
  end %tmi
end

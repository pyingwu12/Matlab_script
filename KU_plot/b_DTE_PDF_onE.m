%------------------------------------------
% plot 
%------------------------------------------
% close all
clear;   ccc=':';
saveid=1; % save figure (1) or not (0)
%---
plotid='CMDTE';  %optioni: MDTE or CMDTE
expri='TWIN013'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='23';  hr=0;  minu=40;  
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam=[plotid,' frequency distribution'];   fignam=[expri1(8:end),'_',plotid,'_',];
%---
col=load('colormap/colormap_dte.mat');
cmap=col.colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%  L=[0.5 2 4 6 8 10 15 20 25 35];
  L=[0.5 2 4 6 10 15 20 30 40 60];

LErr= 10.^(-4:0.1:1);

LThe=-5:0.2:5;

g=9.81;

zlim=10000; ytick=1000:2000:zlim; 

  
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
    %
    
    theta = ncread(infile2,'T');  theta=theta+300;
    ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g; 
    zg0=PH0/g;

        
    zg_1D=squeeze(zg0(150,150,:));     
    nz=length(zg_1D); nzgi=nz*2-1; 
    zgi0(1:2:nzgi,1)= zg_1D;   
    zgi0(2:2:nzgi,1)= ( zg_1D(1:end-1) + zg_1D(2:end) )/2;   
    zgi=zgi0(zgi0<zlim);    
    
    
        
        [DTE, P]=cal_DTEterms(infile1,infile2);
      CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   

    
    
    ni=0; nj=0;
    for i=1:300
      ni=ni+1;
      nj=0;
      for j=1:300
         nj=nj+1;
         theta_iso(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(theta(i,j,:)),zgi,'linear');
         CMDTE_iso(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(CMDTE(i,j,:)),zgi,'linear');
      end
    end         


    theta_hm=mean(theta_iso,[1, 2],'omitnan');
    theta_ano=theta_iso-repmat(theta_hm,size(theta_iso,1),size(theta_iso,2),1);    


    for k=1:length(zgi)       
       for m=1:length(LErr)-1           
         err_pdf(k,m) =  length(find(CMDTE_iso(:,:,k)>=LErr(m) & CMDTE_iso(:,:,k)<LErr(m+1))) / (300*300) *100 ;            
       end   
       for m=1:length(LThe)-1           
         theta_pdf(k,m) =  length(find(theta_ano(:,:,k)>=LThe(m) & theta_ano(:,:,k)<LThe(m+1))) / (300*300) *100 ;            
       end 
    end
    
    
theta_ano_max=max(theta_ano,[],[1 2]);
for k=1:length(zgi) 
    theta_ano_k=theta_ano(:,:,k);
theta_ano_mean(k)=mean(theta_ano_k(theta_ano_k>0));
end

CMDTE_mean=mean(CMDTE_iso,[1 2],'omitnan');

%%

    [xi, zi]=meshgrid(1:length(LErr)-1,zgi);

%     %---plot---
%     eval([' plotvar=',plotid,'''; '])    
%     pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
%     %
    hf=figure('position',[100 75 800 700]); 
    
    ax1 = axes(hf);
    
    h=pcolor(ax1,xi,zi,err_pdf);
    set(h,'linestyle','none')
    
    set(gca,'fontsize',18,'LineWidth',1.2)
    set(gca,'Xtick',1:5:length(LErr),'Xticklabel',log10(LErr(1:5:end)))
    xlabel('CMDTE'); ylabel('model level');
%     %---
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % JST time string
      if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
%         title(tit,'fontsize',18,'Interpreter','none')
% colorbar


    ax2 = axes(hf);
    plot(squeeze(theta_ano_max),zgi,'color','r','linewidth',2);
ax2.XAxisLocation = 'top';
ax2.YAxisLocation = 'right';
ax2.Color = 'none';
ax1.Box = 'off';
ax2.Box = 'off';

set(ax2,'Xlim',[0 6])



%     
%     %---colorbar---
%     fi=find(L>pmin,1);
%     L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
%     hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
%     colormap(cmap); title(hc,'J kg^-^1','fontsize',14); 
drawnow;
%     hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
%     for idx = 1 : numel(hFills)
%       hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
%     end
%     %---    
%     outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
%     if saveid==1
%       print(hf,'-dpng',[outfile,'.png']) 
%       system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
%     end


  end %tmi
end

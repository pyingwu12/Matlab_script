% calculate cloud grid ratio and only plot 2D MDTE when cloud ratio larger than <hydlim>

% close all
clear;    ccc=':';

expri='TWIN101'; 
expri1=[expri,'Prl001qv062221'];  expri2=[expri,'B']; 

%-----
rang=30;  cloudhyd=0.005; 
%---
stday=22;   sth=21;   lenh=10;  minu=[0 20 40];   tint=1;

year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='MDTE and cloud grid ratio';    fignam=[expri1(8:end),'_MDTE-cldr_Ts_'];
%
nminu=length(minu);  ntime=lenh*nminu;
%
%---decide sub-domain to find max cloud area---
if contains(expri1,'TWIN001')
   subx1=151; subx2=300; suby1=51; suby2=200;
else    
   subx1=1; subx2=150; suby1=51; suby2=200;
end   

%---plot
nti=0;  ntii=0;
cld_gn_s=zeros(ntime,1); cld_gr_s=zeros(ntime,1); cld_gn_c=zeros(ntime,1); cld_gr_c=zeros(ntime,1);
MDTE_s=zeros(ntime,1);  MDTE_c=zeros(ntime,1);

for ti=1:lenh 
  hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  if mod(ti,tint)==0 
    ntii=ntii+1;    ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
  end   
  for tmi=minu 
    nti=nti+1;      s_min=num2str(tmi,'%.2d');
    %---infile 1---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---
    hgt = ncread(infile2,'HGT');
    qr = double(ncread(infile2,'QRAIN'));   
    qc = double(ncread(infile2,'QCLOUD'));
    qg = double(ncread(infile2,'QGRAUP'));  
    qs = double(ncread(infile2,'QSNOW'));
    qi = double(ncread(infile2,'QICE')); 
    hyd2D = sum(qr+qc+qg+qs+qi,3); 
    [MDTE,CMDTE] = cal_DTE_2D(infile1,infile2) ; 
    
    
    CMDTE_dm(nti)=mean(CMDTE(:));
    
%     %---cloud grid ratio and error over sub-domain
%     hyd2D_s =hyd2D(subx1:subx2,suby1:suby2);
%     cld_gn_s(nti) = length(hyd2D_s(hyd2D_s>cloudhyd));
%     cld_gr_s(nti) = cld_gn_s(nti) / (size(hyd2D_s,1)*size(hyd2D_s,2)) *100 ;
%     %
%     MDTE_s(nti) = mean(mean(MDTE(subx1:subx2,suby1:suby2)));
%   
%     %---find max cloud area in the sub-domain and its center---
%     [nx, ny]=size(hyd2D); 
%     rephyd=repmat(hyd2D,3,3);      
%     BW = rephyd > cloudhyd;  
%     stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');     
%     if isempty(stats)~=1
%       centers = stats.Centroid;      
%       fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1);     
%       if isempty(stats.Area(fin))~=1    
%         [maxcldsize, maxcldid]=max(stats.Area(fin));      
%         centers_fin=centers(fin,:);      
%         cenx=centers_fin(maxcldid,2)-nx;        ceny=centers_fin(maxcldid,1)-ny;    
%           
%         %---calculate distance from the center of the selected cloud area----------
%         [yi, xi]=meshgrid(1:ny,1:nx);
%         yi(yi-ceny > ny/2)= yi(yi-ceny > ny/2)-ny-1; % for doubly period lateral boundary
%         yi(yi-ceny < -ny/2)= yi(yi-ceny < -ny/2)+ny;
%         xi(xi-cenx > nx/2)= xi(xi-cenx > nx/2)-nx-1;
%         xi(xi-cenx < -nx/2)= xi(xi-cenx < -nx/2)+nx;
%         dis2topo=((xi-cenx).^2 + (yi-ceny).^2 ).^0.5;        
% 
%         cld_gn_c(nti) = length(find(hyd2D+1>cloudhyd+1 & dis2topo<=rang));   
%         cld_gr_c(nti) = cld_gn_c(nti) /length(dis2topo(dis2topo<=rang))*100;  % Ratio of cloud grids in the specific range    
%         MDTE_c(nti) = mean(MDTE(dis2topo<=rang));
%       end
%     end 
    
    if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
  end % tmi 
end %ti    
%%
  %---plot---       
hf=figure('position',[200 45 1000 600]);

% plot(MDTE_s,'LineWidth',2.5,'color',[0.85 0.325 0.098],'linestyle','-'); hold on
% plot(MDTE_c,'LineWidth',2.5,'color',[0.85 0.325 0.098],'linestyle','--');

plot(CMDTE_dm,'LineWidth',3);

set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr,'Linewidth',1.2,'fontsize',16)
set(gca,'Yscale','log')
ylabel('J kg^-^1')  

% yyaxis right
% plot(cld_gr_s,'LineWidth',2.5,'color',[0.929 0.694 0.125],'linestyle','-'); hold on
% plot(cld_gr_c,'LineWidth',2.5,'color',[0.929 0.694 0.125],'linestyle','--'); 
% set(gca,'Ylim',[0 90])
%---second axis---
% ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
% box off
%  ax1=gca; ax1_pos = ax1.Position;  %ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
%  ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
%  set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
%  set(ax2,'Ylim',ylim,'Yticklabel',[])
%  xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;

%

xlabel('Local time'); 
%---
tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);

  

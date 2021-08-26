%------------------------------------------
% plot vertical weighted average MDTE or CMDTE between two simulations with
% cloud boxes
%------------------------------------------
% close all
clear;   ccc=':';
saveid=0; % save figure (1) or not (0)
%---
plotid='CMDTE';  %optioni: MDTE or CMDTE
expri='TWIN003'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
% expri1=[expri,'Pr0025THM062221'];  expri2=[expri,'B'];  
s_date='23';  hr=1;  minu=[0 30];  
%
cloudhyd=0.003;
cloudtpw=0.75;
areasize=10;
%
hydid=3;  % for hydid~=0, plot contour of hydemeteros = <hydid> (g/kg)
zhid=0;   % for zhid~=0, plot contour of zh composite = <zhid> (dBZ)
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam=plotid;   fignam=[expri1(8:end),'_',plotid,'-cloud_',];
if hydid~=0; fignam=[fignam,'hyd',num2str(hydid),'_'];  end
if zhid~=0; fignam=[fignam,'zh',num2str(zhid),'_'];  end
%
load('colormap/colormap_dte.mat')
cmap=colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=0.001*[0.1 0.5 1 1.5 2 2.5 3 3.5 4 4.5];
% L=[0.001 0.003 0.005 0.007 0.009 0.01 0.02 0.03 0.04 0.05];
% L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
%   L=[0.5 2 4 6 8 10 15 20 25 30];
%     L=[0.5 2 4 6 8 10 15 20 25 35];
% L=10.^[-1.5 -1 -0.5 -0.25 0 0.25 0.5 1 1.5 2];
% L=[0.03 0.1 0.32 0.56 1 1.78 3.16 5.62 10 31.6];
  L=[0.5 2 4 6 10 15 20 30 40 60];
%  L=[0.005 0.01 0.05 0.1 0.3 0.5 1 2 3 4 ];



for ti=hr
    if ti>=24; s_date2=num2str(str2double(s_date)+1,'%2.2d'); else; s_date2=s_date; end
  s_hr=num2str(mod(ti,24),'%2.2d');  
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date2,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date2,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile2,'HGT');
    %
    [MDTE, CMDTE] = cal_DTE_2D(infile1,infile2) ;        % vertical weighted average (dPm=dP/dPall)      
    
    [nx ,ny]=size(hgt);
    if zhid~=0
%     zh_max=cal_zh_cmpo(infile2,'WSM6');  % zh of perturbed state   
%     repzh1=repmat(zh_max,3,3);
    end
    qr = double(ncread(infile2,'QRAIN'));   
    qc = double(ncread(infile2,'QCLOUD'));
    qg = double(ncread(infile2,'QGRAUP'));  
    qs = double(ncread(infile2,'QSNOW'));
    qi = double(ncread(infile2,'QICE')); 
    hyd2D = sum(qr+qc+qg+qs+qi,3); 
    
    
    P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
    hyd  = qr+qc+qg+qs+qi;   
    dP=P(:,:,1:end-1,:)-P(:,:,2:end,:);
    tpw= dP.*( (hyd(:,:,2:end,:)+hyd(:,:,1:end-1,:)).*0.5 ) ;
    TPW=squeeze(sum(tpw,3)./9.81);

    repTPW =repmat(TPW,3,3);  
    
    rephyd=repmat(hyd2D,3,3);  
    
    BW = rephyd > cloudhyd;  
%     BW = repTPW > cloudtpw;  
    CC = bwconncomp(BW,8);    
    LL = labelmatrix(CC);    
    stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');
  
%     centers = stats.Centroid;
    bounds=stats.BoundingBox;
%     fin=find(stats.Area>areasize & centers(:,1)>ny & centers(:,1)<2*ny+1 & centers(:,2)>nx & centers(:,2)<2*nx+1);  
    fin=find(stats.Area>areasize );  
    %%
    %---plot---
    eval(['plotvar=repmat(',plotid,''',3,3);'])    
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 45 800 700]); 
    [c, hp]=contourf(plotvar,L2,'linestyle','none');    
    if (max(max(hgt))~=0)
     hold on; contour(repmat(hgt',3,3),[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    if hydid~=0;  hold on; contour(rephyd'*1e3,[hydid hydid],'color',[0.1 0.1 0.1],'linewidth',3);     end
    if zhid~=0;   hold on; contour(zh_max',[zhid zhid],'color',[0.1 0.1 0.1],'linewidth',3);    end    

    hold on
    for i=1:length(fin)
%     hrec=rectangle('Position',[bounds(fin(i),2)-nx bounds(fin(i),1)-ny bounds(fin(i),4) bounds(fin(i),3)]);
        hrec=rectangle('Position',[bounds(fin(i),2) bounds(fin(i),1) bounds(fin(i),4) bounds(fin(i),3)]);
    set(hrec,'linewidth',2.5,'EdgeColor',[0.95 0.05 0.2])    
    end    
    %
    set(gca,'fontsize',18,'LineWidth',1.2)
    set(gca,'xlim',[nx+1 nx+nx],'ylim',[ny+1 ny+ny]) 
    set(gca,'Xtick',nx+50:50:nx+nx,'Xticklabel',50:50:nx,'Ytick',ny+50:50:ny+ny,'Yticklabel',50:50:ny)

    xlabel('(km)'); ylabel('(km)');
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date2)+fix((ti+9)/24)); else; s_datej=s_date2; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')

    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap);     drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date2,'_',s_hr,s_min];
    if saveid==1
      print(hf,'-dpng',[outfile,'.png']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
    end
  end %tmi
end

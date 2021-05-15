% function DTE_2D_twin(expri)
%------------------------------------------
% plot vertical weighted average MDTE or CMDTE between two simulations
%------------------------------------------
close all
clear;  
ccc=':';
saveid=1; % save figure (1) or not (0)
%---
plotid='MDTE'; %optioni: MDTE or CMDTE
expri='TWIN003'; 
% expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
expri1=[expri,'Pr0025THM062221'];  expri2=[expri,'B'];  
s_date='23';  hr=0;  minu=[20];  
%
hydid=5;  % for hydid~=0, plot contour of hydemeteros = <hydid> (g/kg)
zhid=0;   % for zhid~=0, plot contour of zh composite = <zhid> (dBZ)
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin/';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam=plotid;   fignam=[expri1(8:end),'_',plotid,'_',];
if hydid~=0; fignam=[fignam,'hyd',num2str(hydid),'_'];  end
if zhid~=0; fignam=[fignam,'zh',num2str(zhid),'_'];  end
%---
col=load('colormap/colormap_dte.mat');
cmap=col.colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%  L=[0.5 2 4 6 8 10 15 20 25 35];
%   L=[0.5 2 4 6 10 15 20 30 40 60];
%  L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
 L=[0.005 0.01 0.05 0.1 0.3 0.5 1 2 3 4 ];

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
    if zhid~=0;  zh_max=cal_zh_cmpo(infile2,'WSM6');  end % zh of based state
    if hydid~=0
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
     hyd = sum(qr+qc+qg+qs+qi,3)*1e3;        
    end  

    [MDTE, CMDTE] = cal_DTE_2D(infile1,infile2) ;       

    %---plot---
    eval([' plotvar=',plotid,'''; '])    
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 75 800 700]); 
    [~, hp]=contourf(plotvar,L2,'linestyle','none');    
    %---
    if hydid~=0;  hold on; contour(hyd',[hydid hydid],'color',[0.1 0.1 0.1],'linewidth',3);     end
    if zhid~=0;   hold on; contour(zh_max',[zhid zhid],'color',[0.1 0.1 0.1],'linewidth',3);    end   
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
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); title(hc,'J kg^-^1','fontsize',14);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    if saveid==1
      print(hf,'-dpng',[outfile,'.png']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
    end
  end %tmi
end
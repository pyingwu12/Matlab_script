% function a_temp0602_DTE_2D(expri)
%------------------------------------------
% plot vertical weighted average MDTE or CMDTE between two simulations
%------------------------------------------
close all
% clear;   
ccc=':';
saveid=1; % save figure (1) or not (0)
%---
plotid='CMDTE';  %optioni: MDTE or CMDTE
% expri='TWIN030'; %TWIN003Pr0001qv062221 TWIN013B062221noMP
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
% expri1=[expri,'Pr0025THM062221'];  expri2=[expri,'B'];  
day=22;    hr=[23 24 25 26 27];  minu=[00 30];  
%
tpwid=0.7;  % for tpwid~=0, plot contour of TPW = <tpwid> (kg/m^2)
zhid=0;   % for zhid~=0, plot contour of zh composite = <zhid> (dBZ)
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin/JAS_R1';
%  outdir=['/mnt/e/figures/expri_twin/',expri];
% indir='D:expri_twin';   %outdir=['D:/figures/expri_twin/',expri];
% outdir=['G:/我的雲端硬碟/3.博班/研究/figures/expri_twin/',expri];

titnam=plotid;   fignam=[expri1,'_',plotid,'_',];
if tpwid~=0; fignam=[fignam,'tpw',num2str(tpwid),'_'];  end
if zhid~=0; fignam=[fignam,'zh',num2str(zhid),'_'];  end
%---
col=load('colormap/colormap_dte.mat');
cmap=col.colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
 L=[0.5 2 4 6 8 10 15 20 25 35];
%   L=[0.5 2 4 6 10 15 20 30 40 60];
%  L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
%  L=[0.005 0.01 0.05 0.1 0.3 0.5 1 2 3 4 ];

%---
for ti=hr    
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile2,'HGT');
    [nx ,ny]=size(hgt);
    %
    if zhid~=0;  zh_max=cal_zh_cmpo(infile2,'WSM6');  end % zh of based state
    if tpwid~=0
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
%      hyd = sum(qr+qc+qg+qs+qi,3)*1e3;   
     P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 

      hyd  = qr+qc+qg+qs+qi;   
      dP=P(:,:,1:end-1)-P(:,:,2:end);
      tpw= dP.*( (hyd(:,:,2:end)+hyd(:,:,1:end-1)).*0.5 ) ;
      TPW=squeeze(sum(tpw,3)./9.81);   
      repTPW =repmat(TPW,3,3);      
    end  

    [MDTE, CMDTE] = cal_DTE_2D(infile1,infile2) ;       
%%
    %---plot---
    eval(['plotvar=repmat(',plotid,''',3,3);'])  
%     eval([' plotvar=',plotid,'''; '])    
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 75 800 700]); 
    [~, hp]=contourf(plotvar,L2,'linestyle','none');    
    %---
    if tpwid~=0;  hold on; contour(repTPW',[tpwid tpwid],'color',[0.1 0.1 0.1],'linewidth',3);     end
    if zhid~=0;   hold on; contour(zh_max',[zhid zhid],'color',[0.1 0.1 0.1],'linewidth',3);    end   
    %---
    if (max(max(hgt))~=0)
     hold on; contour(repmat(hgt',3,3),[100 500 900],'color',[0.45 0.45 0.45],'linestyle','--','linewidth',2.5); 
    end
    %---
    
    set(gca,'fontsize',24,'LineWidth',2)  % temp0602
    set(gca,'xlim',[nx+1 nx+nx],'ylim',[ny+1 ny+ny]) 
    set(gca,'Xtick',nx+50:50:nx+250,'Xticklabel',50:50:250,'Ytick',ny+50:50:ny+250,'Yticklabel',50:50:250)
    
%     set(gca,'Xtick',50:50:250,'Ytick',50:50:250)
    xlabel('(km)'); ylabel('(km)');
    %---
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % JST time string
    s_datej=num2str(day+fix((ti+9)/24),'%2.2d'); 
%       if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',20,'LineWidth',1.5);
    colormap(cmap); title(hc,'J kg^-^1','fontsize',20);  drawnow
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

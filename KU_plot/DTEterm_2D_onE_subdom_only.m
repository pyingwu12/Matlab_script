% function DTE_2D_twin(expri)
%------------------------------------------
% plot vertical weighted average errors 
%------------------------------------------
% close all
clear;   ccc=':';
saveid=1; % save figure (1) or not (0)
%---
plotid='LH'; 
expri='TWIN201';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='23';  hr=2;  minu=20;  
%
% cloudhyd=0.003;
cloudtpw=0.7;

  subx1=151; subx2=300; suby1=51; suby2=200;
%   subx1=1; subx2=150; suby1=51; suby2=200;

%  subx1=1; subx2=150; suby1=76; suby2=175;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin/';   outdir='/mnt/e/figures/expri_twin/JAS_R1';
% outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam=plotid;   fignam=['sub_',expri1,'_',plotid,'_cld',num2str(cloudtpw*1000),'_x',num2str(subx1),num2str(subx2),'y',num2str(suby1),num2str(suby2),'_'];
%---
col=load('colormap/colormap_dte.mat');
cmap=col.colormap_dte;  cmap(10,:)=[0.9847 0.75 0.18];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%  L=[0.5 2 4 6 8 10 15 20 25 35];
  
% L=[0.5 2 4 6 10 15 20 25 35 45];
  
%   L=[0.5 2 4 6 10 15 20 30 40 60];

%  L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
   L=[0.05 0.1 0.5 1   3 5 7 9 11 13];


%  L=[0.001 0.005 0.01 0.05 0.1 0.3 0.5 1 2 3 ];
 
%  L=[0.0005 0.001 0.005 0.007 0.01 0.03 0.05 0.1 0.3 0.5];

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
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
     
    P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
    hyd  = qr+qc+qg+qs+qi;   
    dP=P(:,:,1:end-1,:)-P(:,:,2:end,:);
    tpw= dP.*( (hyd(:,:,2:end,:)+hyd(:,:,1:end-1,:)).*0.5 ) ;
    TPW=squeeze(sum(tpw,3)./9.81);

     
     
    [DTE, P]=cal_DTEterms(infile1,infile2);               
     dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
     dPall = P.f2(:,:,end)-P.f2(:,:,1);
     dPm = dP./repmat(dPall,1,1,size(dP,3));       
     MDTE = DTE.KE + DTE.SH + DTE.LH;            
     CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   

     if contains(plotid,'MDTE')           
       eval(['error2D = sum(dPm.*',plotid,'(:,:,1:end-1),3) + DTE.Ps;'])      
     elseif contains(plotid,'Ps')
       eval(['error2D = DTE.',plotid,';'])   
     elseif contains(plotid,'w')
       w_err = DTE.KE3D - DTE.KE; 
       error2D = sum(dPm.*w_err(:,:,1:end-1),3) ;
     else
       eval(['error2D = sum(dPm.*DTE.',plotid,'(:,:,1:end-1),3);'])   
     end

    %---plot---
    plotvar=error2D';    
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 75 800 700]); 
    [~, hp]=contourf(plotvar,L2,'linestyle','none');   
    hold on
    %---
    if (max(max(hgt))~=0)
     contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',3); 
    end
    %---
%     contour(hyd',[cloudhyd cloudhyd],'color',[0.1 0.1 0.1],'linewidth',3.5);  
    contour(TPW',[cloudtpw cloudtpw],'color',[0.1 0.1 0.1],'linewidth',3); 

    
    set(gca,'fontsize',25,'LineWidth',2) 
%     set(gca,'Xtick',0:100:300,'Xticklabel',0:100:300,'Ytick',0:50:300,'Yticklabel',0:50:300)
      set(gca,'Xtick',[0 100 200 250],'Xticklabel',[0 100 200 250],'Ytick',0:50:300,'Yticklabel',0:50:300)
    set(gca,'xlim',[subx1-1 subx2],'ylim',[suby1-1 suby2])
    xlabel('(km)'); ylabel('(km)');

    %---
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % JST time string
      if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
    colormap(cmap); title(hc,'J kg^-^1','fontsize',15);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min];
    if saveid==1
      print(hf,'-dpng',[outfile,'.png']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
    end
  end %tmi
end

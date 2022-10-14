%-----------------
% find the time when cloud grid raito in the "whole-domain" larger than <cgrthresh>
%    and plot CMDTE and contour of hyd at different time
% 2021/10/15: change the criteria of cloud grid to TPW
%---------------

close all
clear;    ccc=':';
saveid=1; % save figure (1) or not (0)

% expri='TWIN020';   subx1=1; subx2=150; suby1=51; suby2=200;   
% expri='TWIN201';   subx1=151; subx2=300; suby1=51; suby2=200;    

% expri='TWIN043';   subx1=1; subx2=150; suby1=76; suby2=225;    
% expri='TWIN042';   subx1=151; subx2=300; suby1=151; suby2=300;    

% expri='TWIN031';    subx1=1; subx2=150; suby1=76; suby2=225;   
% expri='TWIN030';    subx1=1; subx2=150; suby1=1; suby2=150;     

% expri='TWIN040';    subx1=1; subx2=150; suby1=76; suby2=225;  
% expri='TWIN039';    subx1=101; subx2=250; suby1=26; suby2=175;      


subx1=1; subx2=300; suby1=1; suby2=300;     
expri='TWIN030';   

expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];   
%-----
cloudtpw=0.7;
cgrthresh=[0.1 1 5];

%---
day=22;   hrs=[23 24 25 26 27 28 29 30];  minu=0:10:50; 

year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin/JAS_R2';
titnam='CMDTE';  fignam=[expri,'_CMDTE-SpecT_'];  
%
fload=load('colormap/colormap_dte.mat');
cmap=fload.colormap_dte; cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%  L=[0.5 2 4 6 8 10 15 20 25 35];
 L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
%
nexp=size(expri1,1); 

%---plot

  nti=0;   ntii=1;
  for ti=hrs       
    hr=ti;  s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');  
    for tmi=minu
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      
      P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 

       
      hyd  = qr+qc+qg+qs+qi;   
      dP=P(:,:,1:end-1)-P(:,:,2:end);
      tpw= dP.*( (hyd(:,:,2:end)+hyd(:,:,1:end-1)).*0.5 ) ;
      TPW=squeeze(sum(tpw,3)./9.81); 

      if strcmp(expri,'TWIN040')==1
        TPWsub=TPW(1:300,75:225);
        cgr = length(TPWsub(TPWsub>cloudtpw)) / (size(TPW,1)*size(TPW,2))*100 ;   
      else
        cgr = length(TPW(TPW>cloudtpw)) / (size(TPW,1)*size(TPW,2))*100 ; 
      end

      thresh=cgrthresh(ntii);
      
      if cgr>thresh
          
          disp([num2str(ntii),': ',s_hr,s_min]);
          
          if ntii==1
            [~,CMDTE] = cal_DTE_2D(infile1,infile2) ; 
            s_datej=num2str(  day+fix((ti+9)/24),'%2.2d' );
          end
          
          TPW_plt{ntii} = TPW; 
          time_tick{ntii}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT'];

      ntii=ntii+1;
      
      end
    
      vinfo = ncinfo(infile1,'U10');   nx = vinfo.Size(1); ny = vinfo.Size(2); 
    
      if ntii==length(cgrthresh)+1; break; end
    end %mi    
    if ntii==length(cgrthresh)+1; break; end   
  end %ti    
  
  hgt = ncread(infile2,'HGT');  
  %
  
%%
% close all
  plotvar=CMDTE';   
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
  %---
  hf=figure('position',[100 80 800 700]); 
  [~, hp]=contourf(plotvar,L2,'linestyle','none');    
  if (max(max(hgt))~=0)
%     hold on; contour(hgt',[100 500 900],'color',[0.4 0.6 0.15],'linestyle','--','linewidth',3.5);  %JAS_ORI
    hold on; contour(hgt',[100 500 900],'color',[0.4 0.6 0.15],'linestyle','-.','linewidth',2.8);  %JAS_R2
  end
          
  hold on;         
   contour(TPW_plt{3}',[cloudtpw cloudtpw],'color',[0.7 0.7 0.7],'linewidth',3);    
   contour(TPW_plt{2}',[cloudtpw cloudtpw],'color',[0.4 0.4 0.4],'linewidth',2.8);  
   contour(TPW_plt{1}',[cloudtpw cloudtpw],'color',[0.1 0.1 0.1],'linewidth',2.5);    

%---upper left  
%    text(subx1+5,suby2-8,time_tick{1},'color',[0.1 0.1 0.1],'fontsize',18)
%    text(subx1+5,suby2-16,time_tick{2},'color',[0.4 0.4 0.4],'fontsize',18)
%    text(subx1+5,suby2-24,time_tick{3},'color',[0.7 0.7 0.7],'fontsize',18)
%JASR2
% rectangle('Position',[subx1+3 suby2-67 63.5 63],'Facecolor',[1, 1, 1, 0.7],'Curvature',0.2,'Edgecolor',[0.5 0.5 0.5],'linewidth',1.5)
%    text(subx1+6,suby2-16,time_tick{1},'color',[0.1 0.1 0.1],'fontsize',19.5)
%    text(subx1+6,suby2-36,time_tick{2},'color',[0.4 0.4 0.4],'fontsize',19.5)
%    text(subx1+6,suby2-56,time_tick{3},'color',[0.7 0.7 0.7],'fontsize',19.5)
%---upper right
% rectangle('Position',[subx2-31.5 suby2-30 29.5 28],'Facecolor',[1 1 1],'Curvature',0.2)
%    text(subx2-30,suby2-8,time_tick{1},'color',[0.1 0.1 0.1],'fontsize',18)
%    text(subx2-30,suby2-16,time_tick{2},'color',[0.4 0.4 0.4],'fontsize',18)
%    text(subx2-30,suby2-24,time_tick{3},'color',[0.7 0.7 0.7],'fontsize',18)
%JASR2
rectangle('Position',[subx2-69.5 suby2-68 63.5 63],'Facecolor',[1, 1, 1, 0.7],'Curvature',0.2,'Edgecolor',[0.5 0.5 0.5],'linewidth',1.5)
   text(subx2-66.5,suby2-17,time_tick{1},'color',[0.1 0.1 0.1],'fontsize',19.5)
   text(subx2-66,suby2-37,time_tick{2},'color',[0.4 0.4 0.4],'fontsize',19.5)
   text(subx2-66,suby2-57,time_tick{3},'color',[0.7 0.7 0.7],'fontsize',19.5)
%---outside bottom right
%    text(subx2-30,suby1-6,time_tick{1},'color',[0.1 0.1 0.1],'fontsize',18)
%    text(subx2-30,suby1-14,time_tick{2},'color',[0.4 0.4 0.4],'fontsize',18)
%    text(subx2-30,suby1-22,time_tick{3},'color',[0.7 0.7 0.7],'fontsize',18)
%---bottom right
%    text(subx2-30,suby1+22,time_tick{1},'color',[0.1 0.1 0.1],'fontsize',18)
%    text(subx2-30,suby1+14,time_tick{2},'color',[0.4 0.4 0.4],'fontsize',18)
%    text(subx2-30,suby1+6,time_tick{3},'color',[0.7 0.7 0.7],'fontsize',18)
%
   set(gca,'fontsize',25,'LineWidth',2)           
   set(gca,'Xtick',[50  150  250],'Xticklabel',[50  150  250],'Ytick',[50  150  250],'Yticklabel',[50  150  250])
   set(gca,'xlim',[subx1-1 subx2],'ylim',[suby1-1 suby2])
   xlabel('(km)'); ylabel('(km)');

%---line for cross section's locations --------- 
%---for x direction
% xp=1;  yp=144;  
% line([xp xp+99],[yp yp],'color',[202 75 81]/255,'Linestyle',':','Linewidth',2.8)
%---for y direction
% xp=56; yp=50;
% line([xp xp],[yp yp+99],'color',[202 75 81]/255,'Linestyle',':','Linewidth',2.8)


   tit={expri1,[titnam,'  ',mon,s_datej,'  ',time_tick{1}]}; 
   title(tit,'fontsize',20,'Interpreter','none')
%     
   %---colorbar---
   fi=find(L>pmin,1);
   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
   hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
   colormap(cmap); title(hc,'J kg^-^1','fontsize',14);  drawnow;
   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
   for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
   end
   drawnow
%---        
   outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_tpw',num2str(cloudtpw*10,'%.2d')];
   if saveid==1
   print(hf,'-dpng',[outfile,'.png']) 
   system(['convert -trim ',outfile,'.png ',outfile,'.png']); 
   end 
  

clear;  ccc=':';
close all

saveid=1; % save figure (1) or not (0)

%---experiments

% expri1={'TWIN201Pr001qv062221';'TWIN042Pr001qv062221';...
%         'TWIN003Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN042B';'TWIN003B'; 'TWIN043B'}; 
% exptext='U00';
% % expnam={'FLAT'; 'U00_FLAT'; 'TOPO';'U00_TOPO'};
% expnam={'ORI_H00V00';'U00_H00V00';  'ORI_H00V00';'U00_H10V10'};
% cexp=[87 198 229;  95 85 147;   242 155 0;  168 63 63]/255; 

expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN013B'}; 
exptext='H500';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
expnam={'ORI_H00V00';'ORI_H10V10';'ORI_H05V10'};
cexp=[87 198 229; 242 155 0; 146 200 101]/255;

    subx1=1; subx2=300; suby1=1; suby2=300;
      xsub=1:300;  ysub=1:300;

cloudtpw=0.7; 
%---setting---
plotid='CMDTE'; % "MDTE" or "CMDTE"
stday=22;  sth=21;  lenh=10; minu=[0 20 40];  tint=1;
% stday=22;  sth=21;  lenh=6; minu=0:10:50;  tint=1;

plotarea=0; %if ~=0, plot sub-domain average set below
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin/JAS_R1';
% indir='D:expri_twin';  %outdir='D:/figures/expri_twin';
% outdir='G:/§Úªº¶³ºÝµwºÐ/3.³Õ¯Z/¬ã¨s/figures/expri_twin/';
titnam=plotid;   fignam=[plotid,'_Ts_',exptext,'_'];

%-----
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
%---------------------------------------------------
DTE_dm=zeros(nexp,ntime);  if plotarea~=0; DTE_am=zeros(nexp,ntime,narea); end
ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
%% 
for ei=1:nexp
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntii=ntii+1;     ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
    end
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---
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
          
      %---cloud grid ratio and error over sub-domain
      TPW_sub =TPW(xsub,ysub); 
      cgr(nti,ei) = length(TPW_sub(TPW_sub>cloudtpw)) / (size(TPW_sub,1)*size(TPW_sub,2)) *100 ;  

      %---
      if cgr(nti,ei)>0          
        %---find max cloud area in the sub-domain---
        [nx, ny]=size(TPW); 
        rephyd=repmat(TPW,3,3);      
        BW = rephyd > cloudtpw;  
        stats = regionprops('table',BW,'Area','Centroid');     
        centers = stats.Centroid;      
        fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1); 
%         fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1);     
        [cgn, ~]=max(stats.Area(fin));   
        max_cldarea(nti,ei) = ((cgn/pi)^0.5)*2;
        max_cldareag(nti,ei) = cgn;
      end
      
      %---
      [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
      CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   
      %----             
      error2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
       CMDTE_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
%        
%       error2D = sum(dPm.*DTE.KE3D(:,:,1:end-1),3);     
%        DiKE3D_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
%        
%       error2D = sum(dPm.*DTE.SH(:,:,1:end-1),3);     
%        DiSH_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
%        
%       error2D = sum(dPm.*DTE.LH(:,:,1:end-1),3);     
%        DiLH_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 



    
      if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
    end %minu    
  end %ti
  disp([expri1{ei},' done'])
end % expri

%%
%---plot

ploterms={'CMDTE';'DiKE3D';'DiSH';'DiLH'};

lin_wid=4; 
plotexp=1:nexp; 
% for ploti=1:size(ploterms,1)-1
for ploti=1

  ploterm=ploterms{ploti}; titnam=ploterm;    eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 1100 600]);
  for ei=plotexp
%     if ei==1; lin_wid=5; else; lin_wid=4;  end
%     plot(max_cldarea(13:end-3,ei),DiffE_m(13:end-3,ei),'+-','linewidth',lin_wid,'color',cexp(ei,:),'Markersize',15); hold on
    h(ei)=plot(max_cldareag(:,ei),DiffE_m(:,ei),'linewidth',lin_wid,'color',cexp(ei,:)); hold on
  end  
  
  legend(h(plotexp),expnam{plotexp},'location','bestout','fontsize',22,'Interpreter','none','FontName','Monospaced')
  
  set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
    set(gca,'Ylim',[1e-3 2e1],'xlim',[1.5 3e4])

  xlabel('Grid numbers'); 

  ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
  %
  outfile=[outdir,'/',ploterm,'_x-area'];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']); 
end
%%

% plotexp=1:nexp; 
% for ploti=1:size(ploterms,1)-1

for ploti=1

  ploterm=ploterms{ploti}; titnam=ploterm;    eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 1100 600]);
  for ei=plotexp
%     if ei==1; lin_wid=5; else; lin_wid=4;  end
    h(ei)=plot(cgr(:,ei),DiffE_m(:,ei),'linewidth',lin_wid,'color',cexp(ei,:)); hold on
  end  
  legend(h(plotexp),expnam{plotexp},'location','bestout','fontsize',22,'Interpreter','none','FontName','Monospaced')
  
  set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
  xlabel('Ratio (%)'); 

  ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
%   set(gca,'Ylim',[1e-4 1e1])
  set(gca,'Xlim',[1e-3 8e1],'Ylim',[1e-3 2e1])

  outfile=[outdir,'/',ploterm,'_x-ratio'];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']); 
end

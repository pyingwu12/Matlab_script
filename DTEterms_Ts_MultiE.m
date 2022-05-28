clear;  ccc=':';
% close all
saveid=0; % save figure (1) or not (0)

%---experiments
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='exp0103';
% expri2={'TWIN001B';'TWIN003B'};
% expnam={'FLAT';'TOPO'};

% expri1={'TWIN001Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN001B';'TWIN021B';'TWIN003B';'TWIN020B'}; exptext='h1000';
% expnam={'FLAT';'v05h10';'v10h10';'v20h10'};
% linestyl={':';'-';'--';'-.'};

expri1={'TWIN001Pr001qv062221';'TWIN013Pr001qv062221';'TWIN003Pr001qv062221'};   
expri2={'TWIN001B';'TWIN013B';'TWIN003B'}; exptext='e0313';
expnam={'FLAT';'V10H05';'V10H10'};
linestyl={'-';'-';'-';};
expmark={'s';'o';'^'};

lev=10;

%---setting---
stday=22;  sth=21;  lenh=3;  minu=0:10:50;  tint=1;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam='Terms of MDTE';   fignam=['DTEterms_',exptext,'_'];
%
nexp=size(expri1,1);  nminu=length(minu);  ntime=lenh*nminu;
%---
ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
KE2D_m=zeros(nexp,ntime); ThE2D_m=zeros(nexp,ntime); LH2D_m=zeros(nexp,ntime);

for ei=1:nexp  
  if contains(expri1{ei},'TWIN001')
      subx1=151; subx2=300; suby1=51; suby2=200;
      xsub=151:300;  ysub=51:200;
  else    
      subx1=1; subx2=150; suby1=51; suby2=200;
      xsub=1:150;  ysub=51:200;
  end       
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntii=ntii+1; ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d'); %xticks
    end
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---            
      [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
%       MDTE = DTE.KE + DTE.SH + DTE.LH;            
%       CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   
      %----      
%       error2D = sum(dPm.*MDTE(:,:,1:end-1),3) + DTE.Ps;  
%        MDTE_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
%        
%       error2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
%         CMDTE_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
%       error2D = sum(dPm.*DTE.KE(:,:,1:end-1),3);     
%        DiKE_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
       
      error2D = sum(dPm(:,:,1:lev).*DTE.KE3D(:,:,1:lev),3);     
       DiKE3D_m(nti,ei)=mean(mean(error2D(xsub,ysub)));
       
      error2D = sum(dPm(:,:,1:lev).*DTE.SH(:,:,1:lev),3);     
       DiSH_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
      error2D = sum(dPm(:,:,1:lev).*DTE.LH(:,:,1:lev),3);     
        DiLH_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
       
%       error2D = DTE.Ps;     
%         DiPs_m(nti,ei)=mean(mean(error2D(xsub,ysub)));       

      if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
    end %minu   
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
%---plot
% hf=figure('position',[100 55 1200 600]);
hf=figure('position',[100 55 1000 600]);

for ei=1:nexp  
  plot(DiKE3D_m(:,ei),expmark{ei},'LineWidth',1.5,'color',[0.929,0.694,0.125],'linestyle',linestyl{ei},'Markersize',10); hold on
  plot(DiSH_m(:,ei),expmark{ei},'LineWidth',1.5,'color',[0.466,0.674,0.188],'linestyle',linestyl{ei},'Markersize',10);
  plot(DiLH_m(:,ei),expmark{ei},'LineWidth',1.5,'color',[0.494,0.184,0.556],'linestyle',linestyl{ei},'Markersize',10);
%   line([35 38],[10^(-3-0.5*ei) 10^(-3-0.5*ei)],'color','k','LineWidth',2.5,'linestyle',linestyl{ei})
%   text(6,10^(-3-0.5*ei),expnam{ei},'fontsize',18)
end
legh=legend({'KE','ThE','LH'},'Box','off','Interpreter','none','fontsize',20,'Location','se','FontName','Consolas');
%---
set(gca,'YScale','log','Linewidth',1.2,'fontsize',16)
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Local time'); ylabel('JKg^-^1')  
% title([titnam,'  (area:',areatext,')'],'fontsize',18)

%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
% outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_',areatext];
if saveid~=0
% print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

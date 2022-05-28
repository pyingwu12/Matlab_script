clear;  ccc=':';
% close all

saveid=1; % save figure (1) or not (0)

%---experiments
% expri1={'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN021B'; 'TWIN020B'}; 
% exptext='V05V20';
% expnam={'V05';'V20'};
% cexp=[230 84 80; 239 144 185]/255; 

expri1={'TWIN201Pr001qv062221noMP';'TWIN003Pr001qv062221noMP';'TWIN013Pr001qv062221noMP'};  
expri2={'TWIN201B062221noMP';'TWIN003B062221noMP';'TWIN013B062221noMP'};
exptext='noMP13';
expnam={'FLATnoMP';'TOPOnoMP';'H500noMP'};
cexp=[0.3,0.745,0.933; 0.929,0.694,0.125; 0.572 0.784 0.396]; 
 
%---setting---
plotid='LH'; % KE3D, LH, SH

stday=22;  sth=21;  lenh=13;  minu=[0 20 40];  tint=1;
plotarea=1; %if ~=0, plot sub-domain average set below
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam=['Di',plotid];   fignam=['Di',plotid,'_Ts_',exptext,'_'];

%---set sub-domain average range---
x1=1:150; y1=76:175;    x2=151:300; y2=201:300;   % SOLA paper
% x1=1:150; y1=51:200;    x2=151:300; y2=51:200;   % 2nd paper
% x1=1:150; y1=26:175;    x2=151:300; y2=26:175;   
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'whole';'mount';'plain'};
linestyl={'--',':.'};   
%-----
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
if plotarea~=0; narea=size(xarea,1); else; narea=0; end
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
      if exist([indir,'/',expri1{ei}],'dir') && ~exist(infile1,'file') 
        DTE_dm(ei,nti)=NaN;
        continue
      end
      
      
     [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
 
     eval(['DiffE = sum(dPm.*DTE.',plotid,'(:,:,1:end-1),3);'])
      
      
%       eval(['DiffE=',plotid,';'])
      DTE_dm(ei,nti) = mean(mean(DiffE));  % domain mean of 2D DTE      
      if plotarea~=0  % area mean of 2D DTE
        for ai=1:narea
        DTE_am(ei,nti,ai) = mean(mean( DiffE(xarea(ai,:),yarea(ai,:)) ));
        end
      end    
      if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
    end %minu    
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
%---set legend---
ni=0;  lgnd=cell(nexp*(narea+1),1);
for ei=1:nexp    
  for ai=0:narea
    ni=ni+1;
    lgnd{ni}=[expnam{ei},'_',arenam{ai+1}];
  end
end
%%
%---plot
% close all
% saveid=1;
% cexp=[87 198 229; 242 135 0; 146 200 101; 230 84 80; 239 144 185]/255; 

% linexp={'-.';'-';':';'-';'-';'-';'-';'-';'-'};
linexp={'-';'-';'-';':';':';'-';'-';'-';'-'};

% hf=figure('position',[100 55 1200 600]);
hf=figure('position',[100 55 1000 600]);
% for ei=[1 3 2 4 5] 
for ei=1:nexp   
 h(ei)= plot(DTE_dm(ei,:),linexp{ei},'LineWidth',4.5,'color',cexp(ei,:),'Markersize',10); hold on
%   h(ei)=plot(DTE_dm(ei,:),'LineWidth',4.5,'color',cexp(ei,:),'Markersize',10); hold on
  if plotarea~=0
    for ai=1:narea
      plot(DTE_am(ei,:,ai),linestyl{ai},'LineWidth',2.5,'color',cexp(ei,:));hold on
    end
  end
end
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'Location','se','FontName','Consolas');
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',25,'Location','se','FontName','Consolas');
%
%---
set(gca,'Linewidth',1.2,'fontsize',20)
set(gca,'YScale','log');  %
set(gca,'Ylim',[2e-5 2e1])
% set(gca,'Ylim',[1e-6 3e1])
% set(gca,'Ylim',[1e-6 2e-2])
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)

xlabel('Local time'); ylabel('J kg^-^1')  
title([titnam,' time evolution'],'fontsize',23)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
if saveid==1
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

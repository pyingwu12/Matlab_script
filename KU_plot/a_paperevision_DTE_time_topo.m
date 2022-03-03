clear;  ccc=':';
close all

%---experiments
expri1='TWIN003Pr001qv062221';   exptext='paper_revision';
expri2='TWIN003B';
expnam='TOPO';

%---set sub-domain average range---
xarea=[1:150; 51:200; 1:150; 51:200;     101:250; 151:300; 101:250; 151:300];  

yarea=[51:150; 51:150; 76:175; 76:175;    176:275;  176:275;  201:300; 201:300];
% yarea=[51:150; 51:150; 76:175; 76:175;   201:300; 201:300; [1:25,226:300]; [1:25,226:300]];

arenam={'M1';'M2';'M3';'M4';'P1';'P2';'P3';'P4'};
col=[0.6,0.2,0.098;    0.8,0.13,0.098;   0.9,0.425,0.098;   0.95,0.815,0.098; 
     0.5490 0.1176  0.5294; 0.78 0.19 0.66; 0,0.447,0.741;  0.3,0.745,0.933;  ]; 
linestyl={'--';'--';'--';'--';':';':';':';':'}; 

%---setting---
stday=22;  sth=21;  lenh=17;  minu=[00 20 40];  tint=2;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri2(1:7)];
titnam='moist DTE';   fignam=['2DMoDTE_',exptext,'_'];

%-----
nminu=length(minu);  ntime=lenh*nminu;
narea=size(xarea,1); 
%
%---------------------------------------------------
 DTEmo_am=zeros(ntime,narea); 
ss_hr=cell(length(tint:tint:lenh),1); ntint=0;

  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if mod(ti,tint)==0
      ntint=ntint+1;
      ss_hr{ntint}=num2str(mod(hr+9,24),'%2.2d');
    end
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---
      MDTEmo=cal_DTE_2D(infile1,infile2);      
        for ai=1:narea
        DTEmo_am(nti,ai) = mean(mean( MDTEmo(xarea(ai,:),yarea(ai,:)) ));
        end
    end %minu
    if mod(ti,5)==0; disp([s_hr,' done']); end
  end %ti

%%
%---plot
% hf=figure('position',[100 55 1200 600]);
hf=figure('position',[100 55 1000 600]);

    for ai=1:narea
      plot(DTEmo_am(:,ai),'LineWidth',3,'color',col(ai,:),'linestyle','-');hold on
    end

legh=legend(arenam,'Box','off','Interpreter','none','fontsize',23,'Location','southeast','FontName','Monospaced');
%---
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'YScale','log');
  set(gca,'Ylim',[2e-4 3e1])
set(gca,'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
set(gca,'Xlim',[1 50])
xlabel('Local time'); ylabel('J kg^-^1')  
% title(titnam,'fontsize',18)

%---
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',num2str(sth),'_',num2str(lenh),'hr_',num2str(nminu),'min'];
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

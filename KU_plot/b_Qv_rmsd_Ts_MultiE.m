clear;  ccc=':';
% close all

%---set experiments---
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';'TWIN013Pr001qv062221'};   exptext='exp0103';
expri2={'TWIN001B';'TWIN003B';'TWIN013B'};
expnam={'FLAT';'TOPO';'V10H05'};
col=[0.1 0.1 0.1;  0.85,0.325,0.098;  0  0.45 0.74;]; 


%---setting---
tit_unit='g kg^-^1';

stday=22;  sth=21;  lenh=5;  minu=0:10:50;  tint=1;  

zlimt1=500; 
zlimt2=1500; 

%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam='qv  RMSD';   fignam=['RMSD-qv_',exptext,'_'];
%
% xsub=1:300;  ysub=1:300;

%
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
g=9.81;
%---------------------------------------------------
rmsd_qv=zeros(nexp,ntime);
ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
for ei=1:nexp
  nti=0;
  
  if contains(expri1{ei},'TWIN001')      
      xsub=151:300;  ysub=51:200;
  else          
      xsub=1:150;  ysub=51:200;
  end 
  
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntii=ntii+1;  ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
    end
    for tmi=minu
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      qv1 =  double(ncread(infile1,'QVAPOR'))*1e3; 

      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      qv2 =  double(ncread(infile2,'QVAPOR'))*1e3; 
      
      PH0=double(ncread(infile2,'PHB')+ ncread(infile2,'PH'));  PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;
      zg=double(PH)/g;     

      
      %---difference square---
      diff_qv = (qv1(xsub,ysub,:)-qv2(xsub,ysub,:)).^2;
      diff_qv2 = diff_qv(zg(xsub,ysub,:)<zlimt2 & zg(xsub,ysub,:)>zlimt1);
      %---root mean---
      rmsd_qv(ei,nti) =  sqrt( mean(diff_qv2(:)) );   % domain mean
      
       if mod(nti,10)==0; disp([s_hr,s_min,' done']); end
    end %tmi   
  end
  disp([expri2{ei},' done'])
end

%%
%---plot
hf=figure('position',[100 55 1000 600]);
% hf=figure('position',[100 45 1200 600]);
for ei=1:nexp
  plot(rmsd_qv(ei,:),'LineWidth',2.5,'color',col(ei,:)); hold on
end
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Consolas');
%---
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'YScale','log')
% set(gca,'Ylim',[3e-3 1.1e0])
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Local time'); ylabel(['RMSD  (',tit_unit,')'])  

title([titnam,'  (',num2str(zlimt1),')'],'fontsize',18)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_z',num2str(zlimt1)];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);

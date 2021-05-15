close all
clear;  ccc=':';
%---
expri='ens07';  
stday=21; sth=22;  lenh=24;  minu=[00 30];
year='2018'; mon='06'; 
dom='01';  dirmem='pert'; infilenam='wrfout'; 
ensize=10; 
%
indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
titnam='Total-qv Spread';   fignam=[expri,'_TPWqv-sprd_'];
%
g=9.81;

nti=0;
for ti=1:lenh 
   hr=sth+ti-1;
   hrday=fix(hr/24);  hr=hr-24*hrday;
   s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
   for tmi=minu
     nti=nti+1;
     s_min=num2str(tmi,'%.2d');
     for mi=1:ensize
       nen=num2str(mi,'%.2d');
       infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
       %------read netcdf data--------
       qv =ncread(infile,'QVAPOR');
       p = ncread(infile,'P');  pb = ncread(infile,'PB');
       if nti==1; [nx,ny,~]=size(qv);  end
       if mi==1;  TPWmem=zeros(nx,ny,ensize);  end
       %---
       P=(pb+p);        dP=P(:,:,1:end-1)-P(:,:,2:end);    
       tpw= dP.*( (qv(:,:,2:end)+qv(:,:,1:end-1)).*0.5 ) ;   
       TPWmem(:,:,mi)=sum(tpw,3)./g;   
     end
     %---
     A=reshape(TPWmem,nx*ny,ensize);     
     am=mean(A,2);     Am=repmat(am,1,ensize);
     Ap=A-Am; 
     varae=sum(Ap.^2,2)./(ensize-1);    
     sprd{nti}=reshape(sqrt(varae),nx,ny);            
   end %tmi
   disp([s_hr,' done'])
end
%%
%---area mean-------------------------------------------------
x1=51:125;    x2=151:225;   %x3=1:150; 
y1=76:150;    y2=26:100;    %y3=51:150;

xi=[x1; x2];
yi=[y1; y2];

  for ti=1:lenh*length(minu)
    for ai=1:size(xi,1)
       sprd_m(ti,ai)=mean(mean(sprd{ti}(xi(ai,:),yi(ai,:))));
    end
    sprd_m(ti,ai+1)=mean(mean(sprd{ti}));
  end    
 
%---set xais for plot
tint=2; nti=0;
for ti=1:tint:lenh 
   nti=nti+1;
   hr=mod(sth+ti-1+9,24);   
   ss_hr{nti}=num2str(hr,'%2.2d');
end
%---plot---
hf=figure('position',[10 25 900 590]);           
plot(sprd_m(:,1),'color',[0.3 0.64 0.05],'LineWidth',2.2); hold on
plot(sprd_m(:,2),'color',[0.01 0.38 0.64],'LineWidth',2.2);
%
legend('mountain','plain','Location','northeast','fontsize',18,'box','off')
set(gca,'Linewidth',1.2,'fontsize',17)
set(gca,'Xlim',[1 lenh*length(minu)],'XTick',1:tint*length(minu):length(minu)*lenh,...
    'XTickLabel',ss_hr)
xlabel('Time(JST)','fontsize',20); ylabel('Spread (Kg/m^2)','fontsize',20)
%      
tit=[expri,'  ',titnam,ss_hr{1},'00-',ss_hr{end},'00JST'];     
title(tit,'fontsize',17)
  
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',num2str(sth),'00_',num2str(lenh),'h'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);  

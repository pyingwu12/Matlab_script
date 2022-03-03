
clear
hr=2;   minu='00';   expri='largens';   infilenam='wrfout';  dirnam='pert';  
px=115;  py=90;  n=40;

outdir='/work/pwin/plot_cal/largens'; 

%---
s_hr=num2str(hr,'%2.2d'); 
%---
Rbig  =a_cal_corr_model_ver(hr,minu,expri,infilenam,dirnam,px,py,256);
Rsmall=a_cal_corr_model_ver(hr,minu,expri,infilenam,dirnam,px,py,n);
%---
N=20:260;  ln=length(N);
norm2=zeros(ln,1);  normf=zeros(ln,1); 
for i=1:ln
  cn=sqrt(n-3)/sqrt(N(i)-3);
  Rp=((1+Rsmall).^cn - (1-Rsmall).^cn) ./  ((1+Rsmall).^cn + (1-Rsmall).^cn); 
  norm2(i)=norm(Rp-Rbig);
  normf(i)=norm(Rp-Rbig,'fro');
end    

%------
figure('position',[500 500 600 500]) 
plot(N,norm2,'LineWidth',2);  hold on; 
plot(N,normf./2,'LineWidth',2,'color','r')
legend('norm2','normf')
set(gca,'XLim',[10 300],'YLim',[fix(min(norm2)/10)*10 ceil(max(norm2)/10)*10],'fontsize',16,'LineWidth',0.8)

line([n n],[10 ceil(max(norm2)/10)*10],'color','k','LineStyle','--')
text(280,20-0.5,'40','color','r','fontsize',16);  text(280,30-0.5,'60','color','r','fontsize',16); 
px=num2str(px); py=num2str(py);
text(220,12,['px=',px,', py=',py],'color','k','fontsize',14); 

xlabel('N','fontsize',14);   ylabel('||R-R''(N)||','fontsize',14)

mem=num2str(n);
tit=['N-R'' ',s_hr,minu,'z  (',infilenam,', n=',mem,')']; 
title(tit,'fontsize',15)
outfile=[outdir,'/N_Rp_',s_hr,minu,'_',px,py,'_',infilenam(1:4),'_m',mem,'.png'];
print('-dpng',outfile,'-r400')  


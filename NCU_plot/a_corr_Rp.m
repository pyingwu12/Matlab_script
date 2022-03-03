
clear
hr=2;   minu='00';   expri='largens';   infilenam='wrfout';  dirnam='pert';  
%expri='e02';   infilenam='fcst';    dirnam='cycle';
px=137;  py=118;   n=40;  N=65;
%---
global nz
outdir='/work/pwin/plot_cal/largens'; 
ticklabel={'u';'v';'w';'ws';'t';'qv';'qr'};

%---
for ti=hr
%------    
   s_hr=num2str(ti,'%2.2d');  
%------
   Rsmall=a_corr_cal_model_ver(ti,minu,expri,infilenam,dirnam,px,py,n);   
   cn=sqrt(n-3)/sqrt(N-3);
   Rp=( (1+Rsmall).^cn -(1-Rsmall).^cn ) ./  ( (1+Rsmall).^cn  + (1-Rsmall).^cn );
%------
   np=size(Rp,1);
   figure('position',[500 500 600 500]) 
%
   imagesc(Rp); hold on
   colorbar;   caxis([-1 1])  
   set(gca,'XTick',nz/2:nz:np,'XTickLabel',ticklabel,'YTick',nz/2:nz:np,'YTickLabel',ticklabel, ...
           'TickLength',[0 0],'fontsize',13,'LineWidth',0.8)
   %---plot the grid line---
   for i=1:np/nz-1
    line([nz*i+0.5 nz*i+0.5],[0 np],'color','k','LineWidth',0.8);   
    line([0 np],[nz*i+0.5 nz*i+0.5],'color','k','LineWidth',0.8)
   end
%
   px=num2str(px); py=num2str(py);  mem=num2str(n); N=num2str(N);
   tit=['R'' localization  ',s_hr,minu,'z  (',infilenam,', mem',mem,', N=',N,')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/Rp_',s_hr,minu,'_',px,py,'_',infilenam(1:4),'_m',mem,'_N',N,'.png'];
   print('-dpng',outfile,'-r400')     
end
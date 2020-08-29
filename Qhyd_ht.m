%close all
clear;   ccc=':';
%---setting
expri='test94';  
sth=15;  lenh=24; minu=[0 30]; tint=2;
%minu=[0]; tint=3;
year='2018'; mon='06'; stdate=21;
%infilenam='mean/wrfmean';  dom='01'; 
infilenam='wrfout';  dom='01'; 


%---
 indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];
 outdir=['/mnt/e/figures/expri_test/',expri,'/'];
%indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
%outdir=['/mnt/e/figures/ens200323/',expri,'/'];


titnam='Hydrometeor mean';   fignam=[expri,'_qhyd-ht_'];

load('colormap/colormap_qr3.mat')
cmap=colormap_qr3; %cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[2 4 6 8 10 12 14 16 18 20]*0.01;
%---
g=9.81;
zgi=[10,50,100:100:15000];    ytick=1000:2000:zgi(end); 

nti=0;
uitp=zeros(size(zgi,2),lenh); vitp=zeros(size(zgi,2),lenh); qitp=zeros(size(zgi,2),lenh);
for ti=1:lenh   
  for tmi=minu
    nti=nti+1;
    s_min=num2str(tmi,'%.2d'); 
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stdate+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
   %---read filename---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u = ncread(infile,'U');         v = ncread(infile,'V');
    qr = double(ncread(infile,'QRAIN'))*1000;   
    qc = double(ncread(infile,'QCLOUD'))*1000;
    qg = double(ncread(infile,'QGRAUP'))*1000;  
    qs = double(ncread(infile,'QSNOW'))*1000;
    qi = double(ncread(infile,'QICE'))*1000;
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');  PH0=(phb+ph); 
    %----  
    qhyd=qr+qc+qs+qi+qg;  
    um=squeeze(mean(mean(u,1),2));   vm=squeeze(mean(mean(v,1),2));              
    qm=squeeze(mean(mean(qhyd,1),2));  qm(qm+0.01==0.01)=0;
    PHm=squeeze(mean(mean(PH0,1),2));
    PH=(PHm(1:end-1)+PHm(2:end)).*0.5;   zg=PH/g; 
%---interpolation---    
    uitp(:,nti)=interp1(zg,um,zgi,'linear');  
    vitp(:,nti)=interp1(zg,vm,zgi,'linear'); 
    qitp(:,nti)=interp1(zg,qm,zgi,'linear');  
  end
  if mod(ti,5)==0; disp([s_hr,'UTC done']); end
end

%---

nti=0;
for ti=1:tint:lenh 
   nti=nti+1;
   hr=sth+ti-1+9;   hrday=fix(hr/24);  hr=hr-24*hrday;
   ss_hr{nti}=num2str(hr,'%2.2d');
end
[xi, zi]=meshgrid(1:lenh*length(minu),zgi);
%%
%---plot---
plotvar=qitp;   %plotvar(plotvar<=0)=NaN;
pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
fi=find(L>pmin); 
%---    
hf=figure('position',[100 45 985 590]);
%
[c, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none');
%
set(gca,'fontsize',16,'LineWidth',1.2)
set(gca,'Xlim',[1 lenh*length(minu)],'XTick',1:tint*length(minu):length(minu)*lenh,...
    'XTickLabel',ss_hr)
set(gca,'Ylim',[1 12000])
set(gca,'Ytick',ytick,'Yticklabel',ytick./1000)
xlabel('Time (JST)','fontsize',15); ylabel('Height (km)','fontsize',15)

tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)
%
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
title(hc,'g/Kg')
colormap(cmap)

drawnow;
hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
for idx = 1 : numel(hFills)
   hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
end
%
intz=10; intt=3;
windbarbM(xi(5:intz:end,2:intt:end),zi(5:intz:end,2:intt:end),...
    uitp(5:intz:end,2:intt:end),vitp(5:intz:end,2:intt:end),0.3,10,[0.5 0.02 0.3],0.5)

%---    
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stdate),'_'...
      ,num2str(sth),'00_',num2str(lenh),'h'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);


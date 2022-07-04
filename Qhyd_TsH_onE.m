% plot domain mean hydrometeors and wind
% x-aixs: time; y-axis: height; color: hydrometeors; vecter: horizontal wind
%
%close all
clear;   ccc=':';
saveid=1; % save figure (1) or not (0)
%---setting
areax=25:125; areay=51:150;
expri='TWIN003B';  
stday=22; sth=21;  lenh=12;  minu=[00 30];  tint=1;
%
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 

%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir='/mnt/e/figures/expri_twin';

% titnam='Hydrometeor mean';   fignam=[expri,'_hyd_Ts-h_'];
titnam='qv mean';   fignam=[expri,'_hyd_Ts-h_'];


load('colormap/colormap_qr3.mat')
cmap=colormap_qr3; %cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[2 4 6 8 10 12 14 16 18 20];
%---
nminu=length(minu);  ntime=lenh*nminu;
g=9.81;  zgi=[10,50,100:100:5000];    ytick=1000:1000:zgi(end); 

%
nti=0; ntii=0; ss_hr=cell(length(tint:tint:lenh),1);
uitp=zeros(size(zgi,2),lenh); vitp=zeros(size(zgi,2),lenh); qitp=zeros(size(zgi,2),lenh);
for ti=1:lenh   
  hr=sth+ti-1;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  if mod(ti,tint)==0 
    ntii=ntii+1;    ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
  end 
  for tmi=minu
    nti=nti+1;     s_min=num2str(tmi,'%.2d'); 
   %---read filename---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u = ncread(infile,'U');         v = ncread(infile,'V');
    qr = double(ncread(infile,'QRAIN'))*1000;   
    qc = double(ncread(infile,'QCLOUD'))*1000;
    qg = double(ncread(infile,'QGRAUP'))*1000;  
    qs = double(ncread(infile,'QSNOW'))*1000;
    qi = double(ncread(infile,'QICE'))*1000;
    qv = double(ncread(infile,'QVAPOR'))*1000;
    pt = double(ncread(infile,'T'))+300;
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');  PH0=(phb+ph); 
    %----  
    qhyd=qr+qc+qs+qi+qg;  
    um=squeeze(mean(u(areax,areay,:),[1 2]));   vm=squeeze(mean(v(areax,areay,:),[1 2]));              
    qm=squeeze(mean(qhyd(areax,areay,:),[1 2]));  qm(qm+0.01==0.01)=0;
    qvm=squeeze(mean(qv(areax,areay,:),[1 2]));  qvm(qvm+0.01==0.01)=0;
    PHm=squeeze(mean(PH0(areax,areay,:),[1 2]));
    PH=(PHm(1:end-1)+PHm(2:end)).*0.5;   zg=PH/g; 
    ptm=squeeze(mean(pt(areax,areay,:),[1 2]));

    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g; 
    zg0=PH0/g;
    zg_1D=squeeze(zg0(150,150,:)); 
    
    nz=length(zg_1D); nzgi=nz*2-1; 
    zgi0(1:2:nzgi,1)= zg_1D;   
    zgi0(2:2:nzgi,1)= ( zg_1D(1:end-1) + zg_1D(2:end) )/2;   
    zgi=zgi0(zgi0<zlim);

%---interpolation---    
    uitp(:,nti)=interp1(zg,um,zgi,'linear');  
    vitp(:,nti)=interp1(zg,vm,zgi,'linear'); 
    qitp(:,nti)=interp1(zg,qm,zgi,'linear');
    qvitp(:,nti)=interp1(zg,qvm,zgi,'linear');
    ptitp(:,nti)=interp1(zg,ptm,zgi,'linear');
  end
  if mod(ti,5)==0; disp([s_hr,'UTC done']); end
end

[xi, zi]=meshgrid(1:ntime,zgi);
%%
%---plot---
plotvar=qvitp;   %plotvar(plotvar<=0)=NaN;
pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
%---    
hf=figure('position',[100 45 985 590]);
%
[~, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none');

hold on
[c,hdis]=contour(xi,zi,ptitp,[304:309],'color',[0.6 0.6 0.6],'linewidth',2.2); 
 contour(xi,zi,ptitp,[304.5:308.5],'color',[0.6 0.6 0.6],'linewidth',2.2); 
    clabel(c,hdis,hdis.TextList,'fontsize',14,'color',[0.6 0.6 0.6],'LabelSpacing',500)  

%
set(gca,'fontsize',16,'LineWidth',1.2)
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
set(gca,'Ylim',[1 zgi(end)])
set(gca,'Ytick',ytick,'Yticklabel',ytick./1000)
xlabel('Local time','fontsize',15); ylabel('Height (km)','fontsize',15)

tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)

%---colorbar---
fi=find(L>pmin,1);
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
colormap(cmap); title(hc,'g kg^-^1','fontsize',14);  drawnow;
hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
for idx = 1 : numel(hFills)
   hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
end
%

intz=7; intt=2;
windbarbM(xi(5:intz:end,2:intt:end),zi(5:intz:end,2:intt:end),...
    uitp(5:intz:end,2:intt:end),vitp(5:intz:end,2:intt:end),0.3,10,[0.5 0.02 0.3],0.5)

%---  
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if saveid~=0
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

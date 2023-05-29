% plot domain mean hydrometeors and wind
% x-aixs: time; y-axis: height; color: hydrometeors; vecter: horizontal wind
%
close all
clear;   ccc=':';
saveid=1; % save figure (1) or not (0)
%---setting
areax=25:125; areay=51:150;

  xsub=25:125;  ysub=51:150;  
expri='TWIN003B';  
stday=22; sth=21;  lenh=12;  minu=[00 30];  tint=1;
%
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 

%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir='/mnt/e/figures/expri_twin/JAS_R1';

% titnam='Hydrometeor mean';   fignam=[expri,'_hyd_Ts-h_'];
titnam='qv mean';   fignam=[expri,'_hyd_Ts-h_'];


load('colormap/colormap_qr3.mat')
cmap=colormap_qr3; %cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[2 4 6 8 10 12 14 16 18 20];
%---
nminu=length(minu);  ntime=lenh*nminu;
g=9.81; % zgi=[10,50,100:100:5000];    

zlimt=5000;
ytick=1000:1000:zlimt; 

%
nti=0; ntii=0; ss_hr=cell(length(tint:tint:lenh),1);

nx=length(xsub); ny=length(ysub);

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
%     qr = double(ncread(infile,'QRAIN'))*1000;   
%     qc = double(ncread(infile,'QCLOUD'))*1000;
%     qg = double(ncread(infile,'QGRAUP'))*1000;  
%     qs = double(ncread(infile,'QSNOW'))*1000;
%     qi = double(ncread(infile,'QICE'))*1000;
    qv = double(ncread(infile,'QVAPOR'))*1000;
    pt = double(ncread(infile,'T'))+300;
%     ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');  PH0=(phb+ph); 
    %----  
%     qhyd=qr+qc+qs+qi+qg;  

  %---heights to interpolate
  ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');  PH0=(phb+ph);  zg0=PH0/g; 
  PH=( PH0(:,:,1:end-1)+PH0(:,:,2:end) ).*0.5;   zg=PH/g; 
  zg_1D=squeeze(zg0(150,150,:));     
  if nti==1
     nz=length(zg_1D); 
     zgi0(1:2:nz*2-1,1)= zg_1D;   
     zgi0(2:2:nz*2-1,1)= (zg_1D(1:end-1) + zg_1D(2:end) )/2;   
     zgi=zgi0(zgi0<zlimt);  
     nzgi=length(zgi); 

uitp=zeros(nzgi,lenh); vitp=zeros(nzgi,lenh); 
qvitp=zeros(nzgi,lenh); ptitp=zeros(nzgi,lenh);


  end     
  %%
  %----interpolation
  qv_sub=zeros(nx,ny,nzgi);  u_sub=zeros(nx,ny,nzgi);  v_sub=zeros(nx,ny,nzgi);     pt_sub=zeros(nx,ny,nzgi);
  
 
  %
  ni=0;
  for i=xsub
    ni=ni+1;
    nj=0;
    for j=ysub      
      nj=nj+1;
      qv_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qv(i,j,:)),zgi,'linear');
      u_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(u(i,j,:)),zgi,'linear');
      pt_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(pt(i,j,:)),zgi,'linear');
      v_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(v(i,j,:)),zgi,'linear');

    end
  end         

%%

    um=squeeze(mean(u_sub,[1 2],'omitnan'));   vm=squeeze(mean(v_sub,[1 2],'omitnan'));              
    
    qvm=squeeze(mean(qv_sub,[1 2],'omitnan'));  qvm(qvm+0.01==0.01)=0;
    
    ptm=squeeze(mean(pt_sub,[1 2],'omitnan'));

%---interpolation---    
    uitp(:,nti)=um;  
    vitp(:,nti)=vm; 

    qvitp(:,nti)=qvm;
    ptitp(:,nti)=ptm;
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
[c,hdis]=contour(xi,zi,ptitp,[304:311],'color',[0.6 0.6 0.6],'linewidth',2.2); 
 contour(xi,zi,ptitp,[304.5:310.5],'color',[0.6 0.6 0.6],'linewidth',2.2); 
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
    uitp(5:intz:end,2:intt:end),vitp(5:intz:end,2:intt:end),0.3,10,[0.5 0.02 0.3],1.2)

%---  
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if saveid~=0
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

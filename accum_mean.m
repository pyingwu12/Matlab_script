close all
clear
%---setting
expri='ens09';  ensize=10;  plotid=[1];  % 1:mean, 2:PM, 3:PMmod
date=21;  sth=21;  acch=21;  
year='2018'; mon='06';  minu='00';  
dirmem='pert'; infilenam='wrfout';  dom='01';  
grids=1; %grid_spacing(km)
%
indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri,'/'];
%
titnam='Accumulated Rainfall';   fignam=[expri,'_accum_'];
typst={'mean';'PM';'PMmod'};
%
addpath('colorbar')
load('colormap/colormap_rain.mat')
cmap=colormap_rain;
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[  1   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];
%L=[ 0.5  1   2   4   6  10  15  20  25  30 35 40 45 50 55 60];


%
%---
for ti=sth
  s_sth=num2str(ti,'%2.2d');  
  s_sthj=num2str(mod(ti+9,24),'%2.2d');
  for ai=acch
    s_edh=num2str(mod(ti+ai,24),'%2.2d');  % end time string
    s_edhj=num2str(mod(ti+ai+9,24),'%2.2d');
%---read ensemble data---
   for mi=1:ensize
      nen=num2str(mi,'%.2d');  
      for j=1:2
        hr=(j-1)*ai+ti;
        hrday=fix(hr/24);  hr=hr-24*hrday;
        s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
        %------read netcdf data--------
        infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00'];
        rc{j} = ncread(infile,'RAINC');
        rsh{j} = ncread(infile,'RAINSH');
        rnc{j} = ncread(infile,'RAINNC');
      end %j=1:2
      acci{mi}=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
   end %mi
   hgt = ncread(infile,'HGT'); 
%---caculate mean---
   [meacci, PM, PMmod]=cal_PM(acci);   
%---plot    
%
   for pi=plotid   % 1:mean, 2:PM, 3:PMmod
     switch (pi); case 1; plotvar=meacci';  case 2; plotvar=PM'; case 3; plotvar=PMmod';  end          
     pmin=(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
     fi=find(L>pmin);
     % 
     hf=figure('position',[100 10 800 630]);
     [c, hp]=contourf(plotvar,L2,'linestyle','none');
     set(gca,'fontsize',15,'LineWidth',1.2)
     set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
     xlabel('(km)'); ylabel('(km)');
   %
     %
     if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
     end
     %
     tit=[expri,'  ',titnam,'  ',s_sthj,minu,'JST ',num2str(ai),'h (',typst{pi},')'];
     title(tit,'fontsize',16,'Interpreter','none')
     %--- 
     L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
     hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);
     colormap(cmap)
     drawnow;
     hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
     for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
     end
     %---
     outfile=[outdir,fignam,mon,num2str(date),'_',s_sth,s_edh,'_',typst{pi}];
     print(hf,'-dpng',[outfile,'.png'])
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);        
   end %plot
  end  %ai
end  %ti

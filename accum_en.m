close all
clear
%---setting
expri='ens03';  sth=21;  acch=24;  member=2:10;  
%---
year='2018'; mon='06';  date=21;  minu='00'; 
dirmem='pert'; infilenam='wrfout';  dom='01';  

indir=['/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/HDD001/Figures/ens200323/',expri];
titnam='Accumulated Rainfall';   fignam=[expri,'_accum_'];

addpath('colorbar')
load('colormap/colormap_rain.mat')
cmap=colormap_rain;
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300]; %CWB
L=[  1   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];
%
%---
for ti=sth    
  s_sth=num2str(ti,'%2.2d');
  for ai=acch
    edh=mod(ti+ai,24);   s_edh=num2str(edh,'%2.2d'); 
    for mi=member
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
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
      rain(rain+1==1)=NaN;
      %
      hgt = ncread(infile,'HGT');
      
      %---plot--- 
      plotvar=rain';
      pmin=(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
      %
      hf=figure('position',[-1100 200 900 650]);
      [c, hp]=contourf(plotvar,L2,'linestyle','none');
      set(gca,'fontsize',16,'LineWidth',1.2)
      
      if (max(max(hgt))~=0)
      hold on; contour(hgt',[100 500 900],'color',[0.2 0.3 0.3],'linestyle','--'); 
      end
      
      tit=[expri,' mem',nen,'  ',titnam,'  ',s_sth,minu,'-',s_edh,minu,' UTC'];
      title(tit,'fontsize',15)
      %-----
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);
      colormap(cmap)
      drawnow;
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx,:)');
      end
      %-----      
      outfile=[outdir,'/',fignam,s_sth,s_edh,'_m',nen];
      print(hf,'-dpng',[outfile,'.png'])
      
      %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);
      %system(['rm ',[outfile,'.pdf']]); 

    end %member
  end %acch  
end %ti

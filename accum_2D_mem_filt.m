close all
clear
%---setting
expri='ens09'; stday=21;  sth=23;  acch=12;  member=9;  
filt_len=50;  dx=1; dy=1;
%---
year='2018'; mon='06';   s_min='00'; 
dirmem='pert';  infilenam='wrfout';  dom='01'; 
%
indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
%
titnam='Filtered accumulated Rainfall';    fignam=[expri,'_accum_'];
%
load('colormap/colormap_rain.mat')
cmap=colormap_rain; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300]; %CWB
L=[  0.1   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];
%
%---
for ti=sth    
  s_sth=num2str(ti,'%2.2d');
  for ai=acch
    s_edh=num2str(mod(ti+ai,24),'%2.2d'); 
    for mi=member
      nen=num2str(mi,'%.2d');
      for j=1:2
        hr=(j-1)*ai+ti;
        hrday=fix(hr/24);  hr=hr-24*hrday;
        s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
        %------read netcdf data--------
        infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];
        rc{j} = ncread(infile,'RAINC');
        rsh{j} = ncread(infile,'RAINSH');
        rnc{j} = ncread(infile,'RAINNC');
      end %j=1:2      
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
      rain(rain+1==1)=0;
      hgt = ncread(infile,'HGT');
      %---low pass filter
      rainfilt=low_pass_filter(rain,filt_len,dx,dy); 
      %rainfilt(rainfilt<0.2)=0;
      %     
      %---plot--- 
      plotvar=rainfilt';
      pmin=(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
      %
      hf=figure('position',[100 200 800 680]);
      [c, hp]=contourf(plotvar,L2,'linestyle','none');
      if (max(max(hgt))~=0)
      hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
      end
      %
      set(gca,'fontsize',16,'LineWidth',1.2)
      set(gca,'Xticklabel',get(gca,'Xtick')*dx,'Yticklabel',get(gca,'Ytick')*dy)
      xlabel('(km)'); ylabel('(km)');     
      tit={[expri,'  mem',nen,'  ',s_sth,s_min,'-',s_edh,s_min,' UTC'];[titnam,'  WL=',num2str(filt_len)]};
      title(tit,'fontsize',18)
      
      %---colorbar---
      fi=find(L>pmin);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
      colormap(cmap); title(hc,'mm','fontsize',13);   drawnow;
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
      end
      %---    
      
      outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',num2str(ai),'h_m',nen,'_L',num2str(filt_len)];
      print(hf,'-dpng',[outfile,'.png'])
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);

    end %member
  end %acch  
end %ti

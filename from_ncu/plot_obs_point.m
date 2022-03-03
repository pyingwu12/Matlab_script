
outfile=[outfile,'obspAB']; %!!!!!!

hold on
%
%hr=0;  
minu='00';  
%expri='largens';  infilenam='wrfout';  s_hr=num2str(hr,'%2.2d');
s_date=num2str(date);
indir=['/SAS011/pwin/201work/data/largens_wrf2obs_',expri];
infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00_001']; 

%
fid=fopen(infile);
vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');

pradar=4;  pela=0.5;  paza=248;  pdis=83;
fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
%fin=30881;
p_lon=vo{5}(fin);  p_lat=vo{6}(fin); %p_hgt=vo{7}(fin)
m_plot(p_lon,p_lat,'xk','MarkerSize',15,'LineWidth',3)
m_text(p_lon+0.1,p_lat-0.1,'A','color',[0 0 0],'fontsize',16,'FontWeight','bold')

pradar=4;  pela=0.5;  paza=188;  pdis=83;
fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
p_lon=vo{5}(fin);  p_lat=vo{6}(fin); %p_hgt=vo{7}(fin)
m_plot(p_lon,p_lat,'xk','MarkerSize',15,'LineWidth',3)
m_text(p_lon+0.1,p_lat-0.1,'B','color',[0 0 0],'fontsize',16,'FontWeight','bold')

%
%lonrad=120.8471; latrad=21.9026;
% m_plot(lonrad,latrad,'^','color',[0.1 0.1 0.5],'MarkerFaceColor',[0.1 0.1 0.75],'MarkerSize',11)
% m_text(lonrad+0.1,latrad+0.1,'RCKT','color',[0.1 0.1 0.75],'fontsize',16,'FontWeight','bold')
lonrad=120.086; latrad=23.1467;
 m_plot(lonrad,latrad,'^','color',[0.1 0.1 0.5],'MarkerFaceColor',[0.1 0.1 0.75],'MarkerSize',14)
 m_text(lonrad+0.1,latrad+0.1,'RCCG','color',[0.1 0.1 0.75],'fontsize',16,'FontWeight','bold')
%}

    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    system(['convert -trim -density 600 ',outfile,'.pdf ',outfile,'.png']);
 %   system(['rm ',[outfile,'.pdf']]);


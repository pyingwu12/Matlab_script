
%outfile=[outfile,'fig8']; %!!!!!!

hold on
%
hr=0;  minu='00';  
expri='largens';  infilenam='wrfout';    

s_hr=num2str(hr,'%2.2d');
indir1=['/work/pwin/data/largens_wrf2obs_',expri];
infile1=[indir1,'/',infilenam,'_d02_2008-06-16_',s_hr,':',minu,':00_001']; 

%
fid=fopen(infile1);
vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');

pradar=3;  pela=0.5;  paza=248;  pdis=83;   
fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
p_lon=vo{5}(fin); p_lat=vo{6}(fin); %p_hgt=vo{7}(fin)
%m_plot(p_lon,p_lat,'xr','MarkerSize',12,'LineWidth',2.6)

pradar=4;  pela=0.5;  paza=248;  pdis=83;
fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
p_lon=vo{5}(fin); p_lat=vo{6}(fin); %p_hgt=vo{7}(fin)
%m_plot(p_lon,p_lat,'xr','MarkerSize',12,'LineWidth',2.6)

pradar=3;  pela=0.5;  paza=208;  pdis=83;
fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
p_lon=vo{5}(fin); p_lat=vo{6}(fin); %p_hgt=vo{7}(fin)
m_plot(p_lon,p_lat,'xr','MarkerSize',12,'LineWidth',2.6)

pradar=4;  pela=0.5;  paza=208;  pdis=83;
fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
p_lon=vo{5}(fin); p_lat=vo{6}(fin); %p_hgt=vo{7}(fin)
m_plot(p_lon,p_lat,'xr','MarkerSize',12,'LineWidth',2.6)


    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'_.png']);
    system(['rm ',[outfile,'.pdf']]);


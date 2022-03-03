
close all
clear;  ccc=':';

%---setting
expri='TWIN003B';  
year='2018'; mon='06'; s_date='22';  s_hr='23'; minu='30';
infilenam='wrfout';  dom='01'; 
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];
outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];


infile = [indir,'/',infilenam,'_d01_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
hgt= ncread(infile,'HGT');

%%
% Side lengths
Lx = 300;
Ly = 300;
Lz = 10000;

% Vertices
vertices = [
    0,   0,  0;  % #1
    Lx,  0,  0;  % #2
    0,  Ly,  0;  % #3
    0,   0, Lz;  % #4
    Lx, Ly,  0;  % #5
    0,  Ly, Lz;  % #6
    Lx,  0, Lz;  % #7
    Lx, Ly, Lz]; % #8

% Faces
faces = [
    1, 2, 5, 3;  % #1
    1, 3, 6, 4;  % #2
    1, 4, 7, 2;  % #3
    4, 7, 8, 6;  % #4
    2, 5, 8, 7;  % #5
    3, 6, 8, 5]; % #6
%%
% hgt(hgt+1<=1)=NaN;
hf=figure('position',[50 200 1100 570]);


surf(hgt','linestyle','none');
hold on
hface = patch('Faces', faces, 'Vertices', vertices, 'FaceColor', 'none','linewidth',2);
% hold on
% hp=surf(hgt,'linestyle','none');

axis([0 Lx 0 Ly 0 Lz])
set(gca,'fontsize',20,'linewidth',2)
set(gca,'ZTick',[0 10000],'ZTicklabel',[0 25])
set(gca,'position',[0.1 0.11 0.7 0.8])
% grid off
grid minor

cmp = getPyPlot_cMap('BuGn');
colormap(cmp); hc=colorbar; title(hc,'m'); caxis([0 1000])
  set(hc,'position',[0.9 0.12 0.018 0.7150],'Linewidth',1.5);

view([-20.5 33])

xlabel('X (km)'); ylabel('Y (km)'); zlabel('Height (km)')

outfile=[outdir,'/terrain_3D'];
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);


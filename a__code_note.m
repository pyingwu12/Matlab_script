
%dark blue: 0,0.447,0.741;   %light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125;  %orange: 0.85,0.325,0.098;   
%purple: 0.494,0.184,0.556;  %dark red: [0.6350 0.0780 0.1840]
%green: 0.466,0.674,0.188

x='test'; eval([x,'=0:4;'])

plon=[135 144.5]; plat=[32 39]; % wide Kantou area

idifx=53; %Fugaku05km
idifx=58; %Kyushu02km
idifx=44; %Oizumi-Nagasaki

ax = gca;  c = ax.Color;  ax.Color = 'blue';

indir=['E:/wrfout/expri191009/',expri]; outdir='E:/figures/expri191009/'; % for matlab under windows

legh=legend(expnam,'Box','off','Interpreter','none','location','nw','fontsize',16);
set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
set(gca,'TickDir','out','box','on')

set(gcf,'PaperPositionMode','auto'); print('-dpdf',[outfile,'.pdf']) 

L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300]; %CWB

clabel(c,hdis,ctr_int,'fontsize',15)   
%-----------------------------------
ax1=subplot('position',[0.1300 0.43  0.7750 0.47]);
ax2=subplot('position',[0.13 0.1657 0.7750 0.125]);
%----------------------------------
% wrf variable
phb = ncread(infile,'PHB');  ph = ncread(infile,'PH');  
PH0=double(phb+ph);  PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;       zg=double(PH)/g;    
p = ncread(infile,'P');     pb = ncread(infile,'PB');  P=(p+pb)/100;
theta = ncread(infile,'T');  theta=theta+300;
temp  = theta.*(1e3./P).^(-Rcp); %temperature (K)   
qv = ncread(infile,'QVAPOR');  
ev = qv./(0.622+qv) .* p;  %partial pressure of water vapor
%----get dimesion from netcdf file-------
vinfo = ncinfo(infile,'U10'); nx = vinfo.Size(1); ny = vinfo.Size(2);   %nx, ny
dx=ncreadatt(infile,'/','DX') ; 
dy=ncreadatt(infile,'/','DY') ; 
scale_factor = ncreadatt('example.nc','temperature','scale_factor');
attvalue = ncreadatt(source,location,attname);

%---fitting---
% if fitid~=0
%  fo = fit(log10(scale_all)',log10(double(dte_all))','poly1');
%  x12=[log10(7) log10(40)];
%  y12=fo.p1.*x12+fo.p2;
%  plot(10.^x12,10.^y12,'color','k','linewidth',1.5)
% end

%-----
expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
       'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'};
expri2={'TWIN001B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'};     
   
    expnam={'FLAT';
        'V05H05';'V10H05';'V20H05';
        'V05H075';'V10H075';'V20H075';
        'V05H10';'TOPO';'V20H10';
        'V05H20';'V10H20';'V20H20'
        };    
    
cexp=[0.1 0.1 0.1; 
      0.32 0.8  0.95; 0    0.45 0.74; 0.01 0.11 0.63; 
      0.96 0.6  0.79; 0.78 0.19 0.67; 0.47 0.05 0.45;  
      0.95 0.8  0.13; 0.85 0.43 0.10; 0.70 0.08 0.18;
      0.65 0.85 0.35; 0.38 0.6  0.13; 0.01 0.48 0.15
      ];     
  
%       cexp=[ 20 20 20;
%         75 190 237 ; 0  114  189;  5 55 160 ; 
%        245 153 202; 200 50 170; 140 30 135 
%        235 175 32 ;  220 85 25;  160 20 45;  
%        143 204 128;  97 153  48; 35 120 35 
%        ]/255; 



expri='TWIN017';  %minu=10;
% expri='TWIN013';  %minu=40;
% expri='TWIN022';  %minu=30;
% expri='TWIN025';  %minu=10;
% expri='TWIN019';  %minu=00;
% expri='TWIN024';  %minu=10;
% expri='TWIN021';  %minu=20;
% expri='TWIN003';  %minu=10;
% expri='TWIN020';  %minu=10;
% expri='TWIN023';  %minu=30;
% expri='TWIN016';  %minu=00;
% expri='TWIN018';  %minu=00;

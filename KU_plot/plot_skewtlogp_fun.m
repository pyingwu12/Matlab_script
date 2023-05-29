function hf=plot_skewtlogp_fun(P1,TT,P2,Td,P3,WS,WD)

% P1: Pressure for TT
% TT: Temp. profile (degree C)
% P2: Pressure for Td
% Td: dew point Temp profile (degree C)
% P3: Pressure for WS and WD
% WS and WD: Wind speed and wind direction

%--------------------------
xlim=40;
wbarx0 = 48;
%---coordination----
p_coor = 0:1050;
t_coor = linspace( -40, 60, 1001);
[x_coor, y_coor] = meshgrid(t_coor,-log(p_coor));
p = exp(-y_coor); 
ptick = -log([1000 850 700 600 500 400 300 250 200 150 100 50]);
t   = zeros(length(p_coor),length(t_coor));
t(length(p_coor),:) = t_coor;
for j = length(p_coor):-1:2
    dy= -y_coor(j,1)+y_coor(j-1,1);
    t(j-1,1:length(t_coor)) = t(j,1:length(t_coor))-35*dy;
end
th  = (t+273.15).*(1000./p).^(287/1005)-273.15;
esw = 6.11.*exp(53.49-6808./(t+273.15)-5.09.*log(t+273.15));
qsw = 0.622.*esw./(p-esw);
thep= (t+273.15).*(1000./p).^(0.285.*(1-0.28.*qsw)).*exp(qsw.*(1+0.81.*qsw).*(3376./(t+273.15)-2.54))-273.15;
qsw = 0.622.*esw./(p-esw).*1000;
qsw (p<200) = NaN;
thep(p<100) = NaN;

for i = 1:length(TT)
    dumX_u = t(ceil(P1(i)+1),:);
    dumX_l = t( fix(P1(i)+1),:);
    if (ceil(P1(i))-fix(P1(i)) == 0)
        dumX   = dumX_l;
    else 
        dumX   = (P1(i)-fix(P1(i)))./(ceil(P1(i))-fix(P1(i))).*(dumX_u-dumX_l)+dumX_l;
    end
    dum1 = dumX-TT(i);
    dum2 = dum1(1,2:length(t_coor)).*dum1(1,1:length(t_coor)-1);
    %
    nTT(i) = t_coor(dum2 == min(dum2));
end
nTT(nTT>xlim)=NaN;

for i = 1:length(Td)
    dumX_u = t(ceil(P2(i)+1),:);
    dumX_l = t( fix(P2(i)+1),:);
    if (ceil(P2(i))-fix(P2(i)) == 0)
        dumX   = dumX_l;
    else 
        dumX   = (P2(i)-fix(P2(i)))./(ceil(P2(i))-fix(P2(i))).*(dumX_u-dumX_l)+dumX_l;
    end
    dum1 = dumX-Td(i);
    dum2 = dum1(1,2:length(t_coor)).*dum1(1,1:length(t_coor)-1);
    %   
    nTd(i) = t_coor(dum2 == min(dum2));
end
nTd(nTd>xlim)=NaN;

t   (x_coor > xlim) = NaN;
p   (x_coor > xlim) = NaN;
th  (x_coor > xlim) = NaN;
qsw (x_coor > xlim) = NaN;
thep(x_coor > xlim) = NaN;

TT0   = max(TT.*(P1 == max(P1)))+273.15;
Td0   = max(Td.*(P1 == max(P2)))+273.15;
rh0   = exp(-(TT0-Td0)/(TT0*Td0)*2.501*10^6/461.51);
qs0   = 0.622*6.11.*exp(53.49-6808/TT0-5.09*log(TT0))/(max(P1)-6.11.*exp(53.49-6808/TT0-5.09*log(TT0)))*rh0;
T_LCL = 55+1/((1/(TT0-55))-(log(rh0)/2840));
P_LCL = max(P1)*(T_LCL/TT0)^(1/0.286*(1-0.26*qs0));

dumX_u = t(ceil(P_LCL)+1,:);
dumX_l = t( fix(P_LCL)+1,:);
if (ceil(P_LCL)-fix(P_LCL) == 0)
    dumX   = dumX_l;
else 
    dumX   = (P_LCL-fix(P_LCL))./(ceil(P_LCL)-fix(P_LCL)).*(dumX_u-dumX_l)+dumX_l;
end
dum1 = dumX-T_LCL+273.15;
dum2 = dum1(1,2:length(t_coor)).*dum1(1,1:length(t_coor)-1);
pth  = th  (round(P_LCL)+1,401+(t_coor(dum2 == min(dum2)))*10);
pthe = thep(round(P_LCL)+1,401+(t_coor(dum2 == min(dum2)))*10);
pthb = th; pteb = thep;
pthb(p < P_LCL | p > max(P1)) = NaN;
pteb(p > P_LCL) = NaN;

%----
hf=figure('position',[100 200 800 700]);
contour(x_coor,y_coor,t,[-120 -110 -100 -90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40],'LineWidth',0.3,'Color',[189/255 094/255 000/255]);   %temparature
hold on
contour(x_coor,y_coor,p,[50 100 150 200 250 300 400 500 600 700 850 1000] ,'LineWidth',0.3,'Color',[189/255 094/255 000/255]);   %pressure
contour(x_coor,y_coor,th,[-40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200],'LineWidth',0.3,'Color',[189/255 094/255 000/255]); %theta
contour(x_coor,y_coor,qsw ,[0.5 1 2 4 8 12 16 24 32],'LineStyle','--','LineWidth',0.3,'Color',[000/255 143/255 000/255]);  % mixing ratio
contour(x_coor,y_coor,thep,[-5 2.3 10.5 20.3 31.75 45.6 63 85.1 114],'LineWidth',0.3,'Color',[000/255 143/255 000/255]);   % theta e
contour(x_coor,y_coor,t,[0 0] ,'LineWidth',1.5,'Color',[189/255 094/255 000/255]); % t= 0 contour
contour(x_coor,y_coor,p,[200 1000] ,'LineWidth',1.5,'Color',[189/255 094/255 000/255]); % p=1000 and p=200 contour
line([xlim xlim],[0 -log(p_coor(end))],'color','k','LineWidth',1.1)
line([wbarx0 wbarx0],[0 -log(p_coor(end))],'linestyle',':','color','k','LineWidth',1.5)

%---plot sounding profile---
plot(nTT,-log(P1),'-b','LineWidth',1.8)
plot(nTd,-log(P2),'-r','LineWidth',1.8)
contour (x_coor,y_coor,pthb,[ pth  pth] ,'LineWidth',1.1,'Color','k','LineStyle','--');
contour (x_coor,y_coor,pteb,[pthe pthe] ,'LineWidth',1.1,'Color','k','LineStyle','--');
%---wind barb---
wcut   = 15;
for i = 1:length(WS)
  plot_windbarb(WS(i),WD(i),P3(i),wbarx0,wcut)
end
plot(ones(length(P3),1)*wbarx0,-log(P3),'LineStyle','none','Marker','o','MarkerSize',3,'MarkerFaceColor','w','MarkerEdgeColor','k')
%---
%
axis([-10 55 -log(1050) -log(min(P3)-1)])
set(gca,'XTick',[-40 -35 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35 40],'fontsize',12)
set(gca,'YTick',ptick,'YTickLabel',{'1000','850','700','600','500','400','300','250','200','150','100','50'},'fontsize',12)
set(gca,'LineWidth',0.5,'FontSize',13,'TickDir','out')
xlabel('Temperature');  ylabel('Pressure')
%
text( 34.4,-4.7875, '-40','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text( 24.4,-4.7875, '-50','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text( 14.4,-4.7875, '-60','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text( 04.4,-4.7875, '-70','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text(-05.4,-4.7875, '-80','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
%
text( 12.5,-5.3845, '0.5','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 19.5,-5.3845, '1.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 26.5,-5.3845, '2.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 34.5,-5.3845, '4.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-5.5535, '8.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-5.8019,'12.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-6.0039,'16.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-6.2944,'24.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-6.5396,'32.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)


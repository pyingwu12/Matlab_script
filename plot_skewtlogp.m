%function output = skewtlogp(P1,TT,P2,Td,P3,WS,WD,figure_name)
clear
close all
%==========================================================================
figure_name='E:/figures/shionomisaki_1908190000_modified';
title_name='shionomisaki 20190819 0000UTC Modified';
%--------
%upair=importdata('Taipei_20190722_0000.txt');
%P3=upair(:,4);  WS=upair(:,9); WD=upair(:,8); 
%P1=upair(:,4); TT=upair(:,6);
%P2=upair(:,4); Td=upair(:,7);

Wind=importdata('E:/data/sounding/shionomisaki_20190819_0000_wind_modified.txt');
Temp=importdata('E:/data/sounding/shionomisaki_20190819_0000_temp_modified.txt');
TT=Temp(:,3);
Td=TT-(100-Temp(:,4))/5;
P1=Temp(:,1);  P2=Temp(:,1); P3=Wind(:,1);
WS=Wind(:,3); WD=Wind(:,4);



%--------------
xlim=40;

p_coor = linspace(0,1050,1051);
t_coor = linspace( -40, 60, 1001);
[x_coor, y_coor] = meshgrid(t_coor,-log(p_coor));
p = exp(-y_coor); 
ptick = -log([1000 850 700 600 500 400 300 250 200 150 100 50]);
t   = zeros(length(p_coor),length(t_coor));
tshd= zeros(length(p_coor),length(t_coor));
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

wbarx0 = 48;
wcut   = 17;

t   (x_coor > xlim) = NaN;
p   (x_coor > xlim) = NaN;
th  (x_coor > xlim) = NaN;
qsw (x_coor > xlim) = NaN;
thep(x_coor > xlim) = NaN;
tshd(x_coor > xlim) = NaN;

tshd((t >   30) & (t <   35)) = 1;
tshd((t >   20) & (t <   25)) = 1;
tshd((t >   10) & (t <   15)) = 1;
tshd((t >    0) & (t <    5)) = 1;
tshd((t > - 10) & (t < -  5)) = 1;
tshd((t > - 20) & (t < - 15)) = 1;
tshd((t > - 30) & (t < - 25)) = 1;
tshd((t > - 40) & (t < - 35)) = 1;
tshd((t > - 50) & (t < - 45)) = 1;
tshd((t > - 60) & (t < - 55)) = 1;
tshd((t > - 70) & (t < - 65)) = 1;
tshd((t > - 80) & (t < - 75)) = 1;
tshd((t > - 90) & (t < - 85)) = 1;
tshd((t > -100) & (t < - 95)) = 1;
tshd((t > -110) & (t < -105)) = 1;
tshd((t > -120) & (t < -115)) = 1;

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
% TT0 = max(TT.*(P1 == max(P1)));
% TT0 = th(nTT(1),round(P1(i))-99);
% Td0 = max(Td.*(P1 == max(P2)));
% pq0 = 0.622.*(6.11.*exp(53.49-6808./(Td0+273.15)-5.09.*log(Td0+273.15)))./(max(P2)-(6.11.*exp(53.49-6808./(Td0+273.15)-5.09.*log(Td0+273.15)))).*1000;
% pth = th;
% pth((p > 1000) | (qsw < pq0)) = NaN;
% p0 = 6.11.*0.622./pq0.*exp(19.83-5417./(TT0+273.15));
%%
%figure('position',[-1000 200 800 700]);
figure('position',[100 200 800 700]);
hold on
% contourf(x_coor,y_coor,tshd,[0.5 0.5],'LineStyle','none')
caxis([0 1]);
cshading = [000/255 000/255 000/255; 255/255 237/255 219/255];
% cshading = [000/255 000/255 000/255; 225/255 228/255 200/255];
colormap(cshading);
contour(x_coor,y_coor,t,[-120 -110 -100 -90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40],'LineWidth',0.3,'Color',[189/255 094/255 000/255]);   %temparature
contour(x_coor,y_coor,p,[50 100 150 200 250 300 400 500 600 700 850 1000] ,'LineWidth',0.3,'Color',[189/255 094/255 000/255]);   %pressure
contour(x_coor,y_coor,th,[-40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200],'LineWidth',0.3,'Color',[189/255 094/255 000/255]); %theta
contour(x_coor,y_coor,qsw ,[0.5 1 2 4 8 12 16 24 32],'LineStyle','--','LineWidth',0.3,'Color',[000/255 143/255 000/255]);  % mixing ratio
contour(x_coor,y_coor,thep,[-5 2.3 10.5 20.3 31.75 45.6 63 85.1 114],'LineWidth',0.3,'Color',[000/255 143/255 000/255]);   % theta e
contour(x_coor,y_coor,t,[0 0] ,'LineWidth',1.5,'Color',[189/255 094/255 000/255]); % t= 0 contour
contour(x_coor,y_coor,p,[200 1000] ,'LineWidth',1.5,'Color',[189/255 094/255 000/255]); % p=1000 and p=200 contour
plot(linspace(xlim,xlim,length(p_coor)),-log(p_coor),'-','LineWidth',1.1,'Color',[000/255 000/255 000/255]);
plot(linspace(wbarx0,wbarx0,length(p_coor)),-log(p_coor),':','LineWidth',1.5,'Color',[050/255 050/255 050/255]);
contour (x_coor,y_coor,pthb,[ pth  pth] ,'LineWidth',1.1,'Color',[000/255 000/255 000/255],'LineStyle','--');
contour (x_coor,y_coor,pteb,[pthe pthe] ,'LineWidth',1.1,'Color',[000/255 000/255 000/255],'LineStyle','--');
plot(nTT,-log(P1),'-b','LineWidth',1.2)
plot(nTd,-log(P2),'-r','LineWidth',1.2)
%----
for i = 1:length(WS)
    theta = 450-WD(i);
    wbar  = linspace(0,5,wcut);
    wfeah = linspace(0,1.0,3);
    wfeaf = linspace(0,2.0,3);
    wbarx = wbarx0     +wbar.*cosd(theta);
    wbary = -log(P3(i))+wbar.*sind(theta)./35;
    kt    = round(round(WS(i)./0.514444)./5);
    if (kt == 1)
        wfeax = wbarx(wcut-2)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 2)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 3)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 4)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 5)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 6)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 7)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 8)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 9)
        wfeax = wbarx(wcut  )   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut  )   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 10)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
    end
    if (kt == 11)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 12)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 13)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 14)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 15)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 16)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 17)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-10)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-10)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 18)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-10)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-10)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 19)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-6)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-6)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-8)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-8)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-10)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-10)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-12)   +wfeah.*cosd(theta-60);
        wfeay = wbary(wcut-12)   +wfeah.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
    end
    if (kt == 20)
        wfeax = wbarx(wcut-2)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-2)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut  ) wfeax(end)],[wbary(wcut  ) wfeay(end)],'-k','LineWidth',1.0)
        wfeax = wbarx(wcut-4)   +wfeaf.*cosd(theta-60);
        wfeay = wbary(wcut-4)   +wfeaf.*sind(theta-60)./35;
        plot(wfeax,wfeay,'-k','LineWidth',1.0)
        plot([wbarx(wcut-2) wfeax(end)],[wbary(wcut-2) wfeay(end)],'-k','LineWidth',1.0)
    end
    
        plot(wbarx,wbary,'-k','LineWidth',1.0)
end
plot(linspace(wbarx0,wbarx0,length(P3)),-log(P3),'LineStyle','none','Marker','o','MarkerSize',3,'MarkerFaceColor',[255/255 255/255 255/255],'MarkerEdgeColor',[000/255 000/255 000/255])
% plot([-40, 60],[min(min(y_coor)),min(min(y_coor))],'-k')
% plot([-40, 60],[max(max(y_coor)),max(max(y_coor))],'-k')
% plot([-40,-40],[min(min(y_coor)),max(max(y_coor))],'-k')
% plot([ 60, 60],[min(min(y_coor)),max(max(y_coor))],'-k')

axis([-10 55 -log(1050) -log(40)])
set(gca,'XTick',[-40 -35 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35 40],'fontsize',12)
set(gca,'YTick',ptick,'YTickLabel',{'1000','850','700','600','500','400','300','250','200','150','100','50'},'fontsize',12)
set(gca,'TickDir','out')
set(gca,'box','on','LineWidth',0.5)
gca_pos = get(gca,'Position');
% gca_pos(1) = 0.10;
% gca_pos(2) = 0.06;
% gca_pos(3) = 0.80;
% gca_pos(4) = 0.85;
% set(gca,'Position',gca_pos)
set(gca,'FontSize',10)
text( 34.4,-4.7875, '-40','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text( 24.4,-4.7875, '-50','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text( 14.4,-4.7875, '-60','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text( 04.4,-4.7875, '-70','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text(-05.4,-4.7875, '-80','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
%text(-15.4,-4.7875, '-90','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
% text(-25.4,-4.7875,'-100','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
%text(-35.4,-4.7875,'-110','FontSize',8,'Color',[189/255 094/255 000/255],'Rotation',40)
text( 12.5,-5.3845, '0.5','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 19.5,-5.3845, '1.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 26.5,-5.3845, '2.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 34.5,-5.3845, '4.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-5.5535, '8.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-5.8019,'12.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-6.0039,'16.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
% text( 40.5,-6.1583,'20.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-6.2944,'24.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
% text( 40.5,-6.4236,'28.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)
text( 40.5,-6.5396,'32.0','FontSize',8,'Color',[000/255 143/255 000/255],'Rotation',50)

title(title_name,'position',[22.5 -3.64],'fontsize',16)
xlabel('Temperature')
ylabel('Pressure')

print('-dpng',[figure_name,'.png'])
%saveas(h,figure_name)
%output = h;
%end
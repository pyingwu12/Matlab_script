% function windbarbM(x,y,U,V,scale,fullbar)
% wind barb's width & color be seted in the code
% fullbar is a number represented by a triangle flag
% Draw wind barb given U component wind and V component wind on current plot.
% The size of the barb is scaled by the diagonal length of the plot.

function windbarbM_mapVer(x,y,U,V,scale,fullbar,color,width)

%width=1.5;
%color='b';
%color
xm = get(gca,'XLim');
ym = get(gca,'YLim');
ylim(ym)
xlim(xm)
ut=fullbar/50;
ut10=10*ut;
as = pbaspect;
ass=sqrt(as(1:2)*as(1:2)');
ll = sqrt((xm(2)-xm(1))^2+(ym(2)-ym(1))^2);
l1 = ll * 0.1 * scale;
l2 = 0.45 * l1;
xunit=(xm(2)-xm(1))*ass/(ll*as(1));
yunit=(ym(2)-ym(1))*ass/(ll*as(2));
%--- calculate wind spd and dir ---
spd=sqrt(U.^2+V.^2);
dir=zeros(size(spd));
D=atan2(V,U).*(180/pi); 
% define dir=0 wind come from the North;dir=90 wind come from the East
dir=270-D;
dir(find(dir>360))=dir(find(dir>360))-360;
%dir(find(D<0))=90-D(find(D<0)); % define dir=0 wind come from the North;dir=90 wind come from the East
%dir(find(0<=D & D<=90))=90-D(find(0<=D & D<=90));
%dir(find(90<=D & D<=180))=450-D(find(90<=D & D<=180));
spd1=round(spd./ut).*ut;
%--- plot all wind dir (x,y)->(x1,y1) ---
Xo=reshape(x,1,size(x,1)*size(x,2)); %1xN
Yo=reshape(y,1,size(y,1)*size(y,2)); %1xN
XI=x+(sin(dir.*(pi/180))).*(l1*xunit); 
YI=y+(cos(dir.*(pi/180))).*(l1*yunit);
XI=reshape(XI,1,size(x,1)*size(x,2)); %1xN
YI=reshape(YI,1,size(x,1)*size(x,2)); %1xN
spd1=reshape(spd1,1,size(x,1)*size(x,2)); %1xN
dir=reshape(dir,1,size(x,1)*size(x,2));
h=m_line([Xo;XI],[Yo;YI],'linewidth',width,'color',color);
colmap=get(h(1),'color'); %1x3
clear h
%return
%--- PartI : find spd1 < fullbar ---
ind=find(spd1<(fullbar-2*ut));
if isempty(ind)==0
spd_tmp=spd1(ind); %1xN
dir_tmp=dir(ind);  %1xN
Xv=Xo(ind); %1xN
Yv=Yo(ind); %1xN
% (x,y) 0/1/3/5/7/9
Xtmp(1,:)=XI(ind); %1xN
Ytmp(1,:)=YI(ind); %1xN
d=0.15;
for k=1:4
    r=1-d*k;
    Xtmp(1+2*k,:)=Xv+r*(Xtmp(1,:)-Xv);
    Ytmp(1+2*k,:)=Yv+r*(Ytmp(1,:)-Yv);
end
% (x,y) 2/4/6/8/10
l3 = sqrt(l1^2+l2^2-2*l1*l2*cos(pi*(90+30)/180));
d1 = 180/pi*acos((l1^2+l3^2-l2^2)/2/l1/l3);
d0 = dir_tmp + d1; %1xN
d0(find(d0>360))=d0(find(d0>360))-360;
X2=Xv+(l3*xunit)*sin((pi/180)*d0); %1xN
Y2=Yv+(l3*yunit)*cos((pi/180)*d0); %1xN
Xtmp(2,:)=X2;
Ytmp(2,:)=Y2;
check=ones(size(spd_tmp)); %1xN
idd=find(spd_tmp<3*ut);
check(idd)=0;
Xtmp(2,idd)=(1/4)*(Xtmp(2,idd)+3*Xtmp(1,idd));
Ytmp(2,idd)=(1/4)*(Ytmp(2,idd)+3*Ytmp(1,idd));
idd1=find(check>0);
idd2=find(spd_tmp(idd1)<=7*ut);
idd=idd1(idd2);
Xtmp(2,idd)=(0.5)*(Xtmp(2,idd)+Xtmp(1,idd));
Ytmp(2,idd)=(0.5)*(Ytmp(2,idd)+Ytmp(1,idd));
m_line([Xtmp(1,:);Xtmp(2,:)],[Ytmp(1,:);Ytmp(2,:)],'linewidth',width,'color',color);
clear idd idd1 idd2
for k=1:4
    Xtmp(2+2*k,:)=Xtmp(1+2*k,:) + (X2-Xtmp(1,:));
    Ytmp(2+2*k,:)=Ytmp(1+2*k,:) + (Y2-Ytmp(1,:));
    check=ones(size(spd_tmp)); %Nx1
    idd=find(spd_tmp<(10*k+3)*ut);
    check(idd)=0;
    Xtmp(2+2*k,idd)=Xtmp(1+2*k,idd);
    Ytmp(2+2*k,idd)=Ytmp(1+2*k,idd);
    idd1=find(check>0);
    idd2=find(spd_tmp(idd1)<=(10*k+7)*ut);
    idd=idd1(idd2);
    Xtmp(2+2*k,idd)=(0.5)*(Xtmp(1+2*k,idd)+Xtmp(2+2*k,idd));
    Ytmp(2+2*k,idd)=(0.5)*(Ytmp(1+2*k,idd)+Ytmp(2+2*k,idd));
    m_line([Xtmp(1+2*k,:);Xtmp(2+2*k,:)],[Ytmp(1+2*k,:);Ytmp(2+2*k,:)],'linewidth',width,'color',color);
    clear idd idd1 idd2
end
clear ind spd_tmp dir_tmp Xv Yv X2 Y2 Xtmp Ytmp
end
%--- PartII : find spd1 >= fullbar ---
ind=find(spd1>=(fullbar-2*ut));
if isempty(ind)==0
spd_tmp=spd1(ind); %1xN
dir_tmp=dir(ind);  %1xN
Xv=Xo(ind); %1xN
Yv=Yo(ind); %1xN
% (x,y) 1/3/5/7/9
Xtmp(1,:)=XI(ind); %1xN
Ytmp(1,:)=YI(ind); %1xN
d=0.15;
for k=1:4
    r=1-d*k;
    Xtmp(1+2*k,:)=Xv+r*(Xtmp(1,:)-Xv);
    Ytmp(1+2*k,:)=Yv+r*(Ytmp(1,:)-Yv);
end
% (x,y) 2/4/6/8/10
l3 = sqrt(l1^2+l2^2-2*l1*l2*cos(pi*(90+30)/180));
d1 = 180/pi*acos((l1^2+l3^2-l2^2)/2/l1/l3);
d0 = dir_tmp + d1; %1xN
d0(find(d0>360))=d0(find(d0>360))-360;
X2=Xv+(l3*xunit)*sin((pi/180)*d0);%1xN
Y2=Yv+(l3*yunit)*cos((pi/180)*d0);%1xN
Xtmp(4,:)=Xtmp(3,:) + (X2-Xtmp(1,:));
Ytmp(4,:)=Ytmp(3,:) + (Y2-Ytmp(1,:));
tcolor(1,1,1:3)=colmap;
m_patch([Xtmp(3,:);Xtmp(4,:);Xtmp(1,:)],[Ytmp(3,:);Ytmp(4,:);Ytmp(1,:)],tcolor,'Edgecolor',colmap);
for k=2:4
    Xtmp(2+2*k,:)=Xtmp(1+2*k,:) + 0.9*(Xtmp(4,:)-Xtmp(3,:));
    Ytmp(2+2*k,:)=Ytmp(1+2*k,:) + 0.9*(Ytmp(4,:)-Ytmp(3,:));
    check=ones(size(spd_tmp)); %1xN
    idd=find(spd_tmp<(30+10*k+3)*ut);
    check(idd)=0;
    Xtmp(2+2*k,idd)=Xtmp(1+2*k,idd);
    Ytmp(2+2*k,idd)=Ytmp(1+2*k,idd);
    idd1=find(check>0);
    idd2=find(spd_tmp(idd1)<=(30+10*k+7)*ut);
    idd=idd1(idd2);
    Xtmp(2+2*k,idd)=(0.5)*(Xtmp(1+2*k,idd)+Xtmp(2+2*k,idd));
    Ytmp(2+2*k,idd)=(0.5)*(Ytmp(1+2*k,idd)+Ytmp(2+2*k,idd));
    m_line([Xtmp(1+2*k,:);Xtmp(2+2*k,:)],[Ytmp(1+2*k,:);Ytmp(2+2*k,:)],'linewidth',width,'color',color);
    clear idd idd1 idd2
end
clear ind spd_tmp dir_tmp Xv Yv Xtmp Ytmp X2 Y2
end
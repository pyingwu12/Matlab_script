ph1(1:27)=ph(:,50,50);
clear ph2;
for k=2:27
    dzs=log(znw(k))-log(znw(k-1));
    dz=log(znu(k-1))-log(znw(k-1));
    if(k==27); dzs=log(1.e-8)-log(znw(k-1));;end
    ph2(k-1)=ph1(k-1)+(ph1(k)-ph1(k-1))*(dz/dzs);
end
ph2(26)=0.5*(ph1(27)+ph1(26));
for k=2:26
dz=log(znu(k))-log(znu(k-1));
dzs=log(znw(k))-log(znu(k-1));
ph4(k)=ph2(k-1)+(ph2(k)-ph2(k-1))*(dzs/dz);
end
ph4(27)=2*ph2(26)-ph4(26);
ph4(1)=2*ph2(1)-ph4(2);
for k=2:26
ph5(k)=0.5*(ph2(k-1)+ph2(k));
end

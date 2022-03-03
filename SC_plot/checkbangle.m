mradius=[    6340453.        6340513.        6340600.        6340714. ...
    6340856.        6341035.        6341263.        6341533. ...
    6342018.        6342526.        6343060.        6343623. ...
    6344669.        6345716.        6346766.        6347821. ...
    6348880.        6349941.        6351002.        6352063. ...
    6353122.        6354178.        6355232.        6356294. ...
    6357387.        6358554.        6359833.]
mref=[389.1450        385.7559        382.2845        377.8799 ...
    367.7746        346.9902        319.2734        298.0137 ...
    282.7357        266.1045        244.7503        213.7013 ...
    183.8246        162.5396        141.1878        122.1623 ...
    107.5019        94.54857        83.03226        73.27312 ...
    64.90662        57.21376        49.87675        42.35580 ...
    34.51316        27.27035        21.43329]
%z2= 6340453.:(6359833.-6340453.)/20:6359833.;
z2= 6340453.:100:6359833.;
nobs=length(z2);
ref2=interp1(mradius,mref,z2,'linear');

n=1+mref*1.e-6;
n2=1+ref2*1.e-6;

x=n.*mradius;
x2=n2.*z2;
for i=1:26
   %dlnndx(i)=1.e6*(log(n(i+1))-log(n(i)))/(x(i+1)-x(i));
   dlnndx(i)=(log(n(i+1))-log(n(i)))/(x(i+1)-x(i));
   %if (abs(dlnndx(i))>1.e-7) dlnndx(i)=-1.e-7;end
   dum(i)=n(i);
   if(i>1)
     if(dlnndx(i)/dlnndx(i-1) > 1)
        dum(i)=nan;
     else
        dum(i)=n(i);
        dum(i+1)=n(i+1);
     end
   end
   %z(i)=0.5*(mradius(i)+mradius(i+1));
   z(i)=0.5*(x(i)+x(i+1));
end
zz=0.5*(x2(1:nobs-1)+x2(2:nobs));
for i=1:nobs-1
   dlnndx2(i)=(log(n2(i+1))-log(n2(i)))/(x2(i+1)-x2(i));
   %dlnndx2(i)=(x2(i+1)-x2(i));
   %dlnndx2(i)=(n2(i+1)-n2(i));
   %zz(i)=0.5*(x2(i)+x2(i+1));
   f(i)=dlnndx2(i)/sqrt(zz(i)*zz(i)-x2(1)*x2(1));
   %dum(i)=1./sqrt(zz(i)*zz(i)-x2(1)*x2(1));
end
clf
subplot(2,2,1)
%plot(log(mref),mradius,'-bx');hold on
%plot(log(n2),x2,'ro');hold on
%plot(log(n),x,'bo');hold on
plot((n-1),x,'bo');hold on
%plot((n2-1),x2,'ro');hold on
set(gca,'ylim',[x2(1) x2(1)+1500])
subplot(2,2,2)
%plot(dlnndx*1.e7,z,'b');hold on
plot(dlnndx2*1.e7,zz,'r');hold on
%plot(dum*1.e7,z,'ko');hold on
set(gca,'ylim',[x2(1) x2(1)+1500])
return
subplot(2,2,3)
%plot(dlnndx,z);hold on
plot(dum,zz,'r');hold on
set(gca,'ylim',[x2(1) x2(1)+1000])
subplot(2,2,4)
plot(f,zz,'r');hold on
set(gca,'ylim',[x2(1) x2(1)+1000])

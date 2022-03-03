clear all
infile='/SAS002/ailin/Tainan/obs_2008_IOP8.txt';
fid=fopen(infile,'r');
levs=[1000.,975.,950.,925.,900.,875.0,850.,825.0,800.,775.0,750.,725.0,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.];

for i=1:12
time=fscanf(fid,'%s',1);
nz=fscanf(fid,'%f',1);
for k=1:nz
    x=fscanf(fid,'%f %f %f %f %f',5);
    p(k)=x(1);
    u(k)=x(2);
    v(k)=x(3);
    temp(k)=x(4);
    qv(k)=x(5);
    Tv(k)=temp(k)*((1000.0/p(k))^(287/1004))*(1+0.608*qv(k));
    if(temp(k)== -888888.000 | qv(k)== -888888.000)
       Tv(k)=-888888.000;
    end
end
for ivar=1:5
    switch(ivar)
    case(1)
      var=u;
    case(2)
      var=v;
    case(3)
      var=temp;
    case(4)
      var=qv;
    case(5)
      var=Tv;
    end

    index=find(abs(var+888888.000)>1.e-3);
    vv=var(index);
    pp=p(index);
    varp(1:25,i,ivar)=interp1(pp,vv,levs);
    if (i==5 & ivar==5);return;end
    clear vv var pp;
    clear index;
end
    clear p u v temp qv Tv;

end

fclose(fid)

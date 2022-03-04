function [ vg ] = vpotcalc( vpot,Ck,Cd,vcap )
%
% This script calculates actual potential intensity (vg) from raw potential
% intensity (vpot), the exchange coefficients, and any capping wind speed
%
vg=0.5*(vcap+vpot);
r=1;
n=0;
while r > 0.0001   % Need to find the solution iteratively
    n=n+1;
    ckn=Ck*min(vcap/vg,1);
    ckcd=ckn/Cd;
    if ckcd == 2
        ckcd=1.99;
    end
    vgnew=sqrt(2)*vpot*(0.5*ckcd)^(0.5*ckcd/(2-ckcd));
    r=abs(vgnew-vg);
    vg=vgnew;
end
%
end


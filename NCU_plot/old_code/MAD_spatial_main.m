%-------------------------------------------------
%   Corr.(obs_point,model_2D-level) 
%-------------------------------------------------
%
function sMAD_spatial_main(dis)
%clear

hr=0;  minu='00';   

%---set---
sub=12;
sub2=sub*2+1; 
%-----------------

vn=12;   %!!! variable numbers 6(u,v,qv,qr,t,qc)*2(vr,zh)
%^^^---check the function <Corr256n40allvari_fun.m>----^^^
n=0;

%
%rad=4;  ela=0.5; aza=128:5:348;  %dis=53; 
rad=4;  ela=0.5; aza=138:5:348;  %dis=113; 
%rad=3;  ela=0.5; aza=128:5:313;  %dis=83; 
for i=1:length(aza)
  n=n+1
  [corr256 corr40 lon(n) lat(n)]=Corr256n40allvari_fun(hr,minu,rad,ela,aza(i),dis,sub);
  for j=1:vn
    err(n,j)=sum(abs(corr40{j}-corr256{j}))/length(corr256{j});
  end
end

s_rad=num2str(rad); s_ela=num2str(ela); s_dis=num2str(dis); s_sub=num2str(sub);
save(['MAD_',s_rad,'-',s_ela,'-',s_dis,'_',s_sub,'.mat'],'err','lon','lat')





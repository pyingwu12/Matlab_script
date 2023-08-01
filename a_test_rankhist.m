

clear

obsz=100;   obsmp=1;
exsz=1000;  ensmp=1;
rksz=25;    rksmp=1;

obs=normrnd(0,1,obsz,1);
mo=mean(obs); so=std(obs);
% figure; histogram(obs)

ens0=normrnd(0,1,exsz,ensmp);
% ens0=(rand(exsz,ensmp)-0.5)*5;  %flat
% tmp=normrnd(1,0.5,exsz/2,ensmp);tmp2=normrnd(-1,0.5,exsz/2,ensmp); ens0=[tmp; tmp2]; %bimodel

ens=mean(sort(ens0,1),2);
me=mean(ens); se=std(ens);
% figure; histogram(ens)
%
ens2=0;
for i=1:rksmp
tmp=randperm(exsz); member=tmp(1:rksz);
ens2=ens2+sort(ens(member))/rksmp;
end
% figure; histogram(ens2)
%%
rank=zeros(rksz+1,1);

for i=1:obsmp
    if obsmp~=1; tmp=randperm(exsz); member=tmp(1:rksz); ens2=sort(ens(member)); end
for p=1:obsz
  tmp=find(ens2>obs(p),1);
  if isempty(tmp); rank(rksz+1)=rank(rksz+1)+1; else; rank(tmp)=rank(tmp)+1; end
end
end

rank=rank/(obsz*obsmp);
%%
figure; bar(rank,'hist')
hold on; line([0 exsz+2],[1/rksz 1/rksz],'color','r')
set(gca,'ylim',[0 1/rksz*5],'xlim',[0.5 rksz+1.5])
% set(gca,'ylim',[0 1],'xlim',[0.5 rksz+1.5])
tit=['obs',num2str(obsz),'; ens',num2str(exsz),'; rnk',num2str(rksz),...
    '; ensmp',num2str(ensmp),'; rksmp',num2str(rksmp),'; obsmp',num2str(obsmp)];
title(tit)
%%
% rank=zeros(rnksz+1,1);
% for m=1:rnksz+1
%   if m==1
%    rank(m)=length(find(obs<ens2(1)));
%   elseif m==rnksz+1
%    rank(m)=length(find(obs>=ens2(end)));
%   else
%    rank(m)=length(find(obs>=ens2(m-1) & obs<ens2(m)));
%   end
% end
% figure; bar(rank,'hist')

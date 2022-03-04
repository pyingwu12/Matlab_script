%function SMAD_rand_allv_main
%------------------
%  use function <Corr256n40allvari_rand_fun> and <Corr256n40allvari_fun>
%  calculate corr. of 256 member and randam 40 member, for <randtimes> times
%  than calculate SMAD <err> 
%--------------------

clear
hr=0;  minu='00';   sub=12;  randtimes=50; 

%---set---
sub2=sub*2+1;   
%------------
%
pradar=4;  pela=0.5;  paza=188;  pdis=83;  point='B';
%
for i=1:randtimes
  i
  randmem(i,:)=randi(256,1,40);
  [corr256, corr40 , ~, ~]=Corr256n40allvari_rand_fun(hr,minu,pradar,pela,paza,pdis,sub,randmem(i,:));
  for j=1:size(corr256,2)
    maxcorr=max(max(abs(corr40{j}),abs(corr256{j})));
    err(i,j)=sum(abs(corr40{j}-corr256{j}))/length(corr256{j})/maxcorr;
  end
end  
%
  [corr256, corr40 , ~, ~]=Corr256n40allvari_fun(hr,minu,pradar,pela,paza,pdis,sub);
  for j=1:size(corr256,2)
    maxcorr=max(max(abs(corr40{j}),abs(corr256{j})));
    err(randtimes+1,j)=sum(abs(corr40{j}-corr256{j}))/length(corr256{j})/maxcorr;
  end
save(['smad',num2str(sub),'_',point,'.mat'],'err')
%
%-----------------------------------------------
pradar=4;  pela=0.5;  paza=248;  pdis=83;  point='A';
%
for i=1:randtimes
  i
  [corr256, corr40 , ~, ~]=Corr256n40allvari_rand_fun(hr,minu,pradar,pela,paza,pdis,sub,randmem(i,:));
  for j=1:size(corr256,2)
    maxcorr=max(max(abs(corr40{j}),abs(corr256{j})));
    err(i,j)=sum(abs(corr40{j}-corr256{j}))/length(corr256{j})/maxcorr;
  end
end
%
  [corr256, corr40 , ~, ~]=Corr256n40allvari_fun(hr,minu,pradar,pela,paza,pdis,sub);
  for j=1:size(corr256,2)
    maxcorr=max(max(abs(corr40{j}),abs(corr256{j})));
    err(randtimes+1,j)=sum(abs(corr40{j}-corr256{j}))/length(corr256{j})/maxcorr;
  end
save(['smad',num2str(sub),'_',point,'.mat'],'err')
save('randmem2.mat','randmem')



 
  clear

  vonam='Zh'; vmnam='QVAPOR';


  sub=[4 8 12 24 36];   memsize=[20 40 60 80 100 120 160 200 256];
  corraccum=zeros(length(sub),length(memsize));

for si=1:length(sub);
%  si=3;
  sub2=sub(si)*2+1;

rad=[4];  aza=168:10:228;  dis=[83 93 103]; 

 for i=1:length(rad)
   for j=1:length(aza)
     for k=1:length(dis)
      load(['varis_',num2str(rad(i)),'-0.5-',num2str(aza(j)),'-',num2str(dis(k)),'_sub36.mat'])

      for mj=1:length(memsize)
       eval(['A0=',vmnam,'(37-sub(si):37+sub(si),37-sub(si):37+sub(si),1:memsize(mj));'])
     %---estimate background error---
       A=reshape(A0,sub2*sub2,memsize(mj));   eval(['b=',vonam,'(1:memsize(mj));']);
       at=mean(A,2);                        bt=mean(b);  %estimate true
       At=repmat(at,1,memsize(mj));
       Ae=A-At;                             be=b-bt;
       varae=sum(Ae.^2,2)./(memsize(mj)-1);     varbe=be'*be/(memsize(mj)-1);  %---variance---
       cov=(Ae*be)./(memsize(mj)-1);              %---covariance---  
       corr=cov./(varae.^0.5)./(varbe^0.5);   %---correlation---
       corraccum(si,mj)=corraccum(si,mj)+sum(corr);
      end    

     end %k
   end %j
 end %i

  rad=3;  aza=248:10:308;  dis=[83 93 103];

 for i=1:length(rad)
   for j=1:length(aza)
     for k=1:length(dis)
      load(['varis_',num2str(rad(i)),'-0.5-',num2str(aza(j)),'-',num2str(dis(k)),'_sub36.mat'])

      for mj=1:length(memsize)
       eval(['A0=',vmnam,'(37-sub(si):37+sub(si),37-sub(si):37+sub(si),1:memsize(mj));'])
     %---estimate background error---
       A=reshape(A0,sub2*sub2,memsize(mj));   eval(['b=',vonam,'(1:memsize(mj));']);
       at=mean(A,2);                        bt=mean(b);  %estimate true
       At=repmat(at,1,memsize(mj));
       Ae=A-At;                             be=b-bt;
       varae=sum(Ae.^2,2)./(memsize(mj)-1);     varbe=be'*be/(memsize(mj)-1);  %---variance---
       cov=(Ae*be)./(memsize(mj)-1);              %---covariance---
       corr=cov./(varae.^0.5)./(varbe^0.5);   %---correlation---
       corraccum(si,mj)=corraccum(si,mj)+sum(corr);
      end

     end %k
   end %j
 end %i


end %si




%function [scc rmse ETS bias]=accum_score(sth,acch,expri,target,tresh)
% sth: start time
% acch: accumulation time
% expri: experiment name
% target: 'mean' or 'member'
clear; sth=2; acch=12; expri='truerun'; target='member'; tresh=6; seaid=0;
%---set
expdir=['/work/pwin/plot_cal/IOP8/',expri];
%expdir=['/work/pwin/plot_cal/Rain/',expri];
memsize=36;
%---
nt=0;
for ti=sth;
  if ti<=10;  s_sth=['0',num2str(ti)];  else   s_sth=num2str(ti);  end
  for ai=acch;
    edh=ti+ai;   edh=edh-24*fix(edh/24);              % end time       
    if edh<=10;  s_edh=['0',num2str(edh)];  else   s_edh=num2str(edh);  end
%---read data---    
    infile=[expdir,'/obs_acci_',s_sth,s_edh,'.mat'];
    load (infile);       
    switch(target)
    case('mean')
      nt=nt+1;
      [wrfaccim{1} wrfaccim{2} wrfaccim{3}]=calPM(wrfacci);
      for mi=1:3
        fin=find(isnan(obsacci) ==0 & isnan(wrfaccim{mi})==0 & wrfaccim{mi}>=0 & obsacci>=0);
        [scc(nt,mi) rmse(nt,mi) ETS(nt,mi) bias(nt,mi)]=score(obsacci(fin),wrfaccim{mi}(fin),tresh);
      end
      scc(nt,4)=ti; scc(nt,5)=ai; 
      rmse(nt,4)=ti; rmse(nt,5)=ai; 
      ETS(nt,4)=ti; ETS(nt,5)=ai; 
      bias(nt,4)=ti; bias(nt,5)=ai; 
    case('member')
      for mi=1:memsize
        fin=find(isnan(obsacci) ==0 & isnan(wrfacci{mi})==0 & wrfacci{mi}>=0 & obsacci>=0);
        [scc(mi,1) rmse(mi,1) ETS(mi,1) bias(mi,1)]=score(obsacci(fin),wrfacci{mi}(fin),tresh); 
      end %member 
    end %switch
    %save([expdir,'/score/score_',s_sth,s_edh,'.mat'],'scc','rmse')
  end
end
if size(scc,1)==memsize
  [scc(:,2) scc(:,3)]=sort(scc(:,1));
  [ETS(:,2) ETS(:,3)]=sort(ETS(:,1));
  [rmse(:,2) rmse(:,3)]=sort(rmse(:,1));
end

%{
[a b]=sort(scc);
[c d]=sort(rmse);
for i=1:40
s_r(d(i))=i;
s_s(d(i))=41-i;
end
for i=1:40
s_r(d(i))=i;
s_s(b(i))=41-i;
end
ss=(s_r+s_s)/2;
[e f]=sort(ss);
[e f]=sort(ss');
%}


%function [scc rmse ETS bias]=accum_score(sth,acch,expri,target,tresh)
% sth: start time
% acch: accumulation time
% expri: experiment name
% target: 'mean' or 'member'
clear; sth=10; acch=2; expri='0614e01'; tresh=6;
%---set
expdir=['/work/pwin/plot_cal/IOP8/Rain/',expri];
%expdir=['/work/pwin/plot_cal/Rain/',expri];
xmi=118; xma=120; ymi=21; yma=23.3;
%---
nt=0;
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
    edh=ti+ai;
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    infile=[expdir,'/qpe_acci_',s_sth,s_edh,'.mat'];
    load (infile);       

      for mi=1:40
        obsacci2=    obsacci(xi>xmi & xi<xma & yj>ymi & yj<yma);
        wrfacci2=wrfacci{mi}(xi>xmi & xi<xma & yj>ymi & yj<yma);
        %fin=find(isnan(obsacci2) ==0 & isnan(wrfacci2)==0 & wrfacci2>=0 & obsacci2>=0);
        [scc(mi,1) rmse(mi,1) ETS(mi,1) bias(mi,1)]=score(obsacci2,wrfacci2,tresh); 
      end %member 
    %save([expdir,'/score/score_',s_sth,s_edh,'.mat'],'scc','rmse')
  end
end
if size(scc,1)==40
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

